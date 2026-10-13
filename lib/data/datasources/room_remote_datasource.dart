import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/code_generator_util.dart';
import '../models/room_model.dart';

class RoomRemoteDatasource {
  final FirebaseFirestore? _customFirestore;

  RoomRemoteDatasource({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestoreInstance {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  CollectionReference? get _roomsCol =>
      _firestoreInstance?.collection(AppConstants.colPhongTro);

  /// Lấy danh sách phòng trọ đã duyệt (hỗ trợ Cache offline để load < 3s)
  Future<List<RoomModel>> getApprovedRooms({
    String? quanHuyen,
    String? searchKeyword,
  }) async {
    if (_roomsCol == null) return [];

    try {
      Query query = _roomsCol!.where('TrangThaiDuyet', isEqualTo: 'DA_DUYET');

      if (quanHuyen != null && quanHuyen.isNotEmpty) {
        query = query.where('QuanHuyen', isEqualTo: quanHuyen);
      }

      // Thử lấy từ Cache trước để đạt tốc độ < 3 giây
      QuerySnapshot snapshot;
      try {
        snapshot = await query.get(const GetOptions(source: Source.cache));
        if (snapshot.docs.isEmpty) {
          snapshot = await query.get(const GetOptions(source: Source.server));
        }
      } catch (_) {
        snapshot = await query.get();
      }

      final rooms = snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) => !r.isDeleted && r.isHienThi)
          .toList();

      if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
        final keyword = searchKeyword.toLowerCase();
        return rooms
            .where((r) =>
                r.tieuDe.toLowerCase().contains(keyword) ||
                r.diaChi.toLowerCase().contains(keyword) ||
                r.quanHuyen.toLowerCase().contains(keyword))
            .toList();
      }

      return rooms;
    } catch (e) {
      debugPrint('Error getting approved rooms: $e');
      return [];
    }
  }

  /// Lấy danh sách phòng theo Chủ trọ
  Future<List<RoomModel>> getRoomsByLandlord(String landlordId) async {
    if (_roomsCol == null) return [];
    try {
      final snapshot = await _roomsCol!
          .where('MaChuTro', isEqualTo: landlordId)
          .get();

      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) => !r.isDeleted)
          .toList();
    } catch (e) {
      debugPrint('Error getting landlord rooms: $e');
      return [];
    }
  }

  /// Lấy danh sách phòng đang chờ Admin duyệt
  Future<List<RoomModel>> getPendingApprovalRooms() async {
    if (_roomsCol == null) return [];
    try {
      final snapshot = await _roomsCol!
          .where('TrangThaiDuyet', isEqualTo: 'CHO_DUYET')
          .get();

      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending rooms: $e');
      return [];
    }
  }

  /// Lấy chi tiết phòng trọ
  Future<RoomModel?> getRoomById(String roomId) async {
    if (_roomsCol == null) return null;
    try {
      final doc = await _roomsCol!.doc(roomId).get();
      if (!doc.exists) return null;
      return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error getting room by ID: $e');
      return null;
    }
  }

  /// Đăng tin phòng mới (Quy định: Tối thiểu 3 ảnh, tối đa 10 ảnh, Giá >= 500k)
  Future<RoomModel> createRoomListing(RoomModel room) async {
    if (room.danhSachAnh.length < AppConstants.minListingImages) {
      throw Exception('Chủ trọ phải cung cấp tối thiểu 3 ảnh thực tế của phòng trọ');
    }

    if (room.danhSachAnh.length > 10) {
      throw Exception('Chủ trọ chỉ được tải lên tối đa 10 ảnh thực tế');
    }

    if (room.giaThue < AppConstants.minListingPrice) {
      throw Exception('Giá thuê phòng trọ phải từ 500.000 VNĐ/tháng trở lên');
    }

    if (_roomsCol == null) throw Exception('Dịch vụ CSDL Firebase không khả dụng');

    final roomId = (room.maPhong.isNotEmpty && room.maPhong.startsWith('P-'))
        ? room.maPhong
        : CodeGeneratorUtil.generateRoomCode(district: room.quanHuyen);
    final docRef = _roomsCol!.doc(roomId);

    final newRoom = RoomModel(
      maPhong: roomId,
      maChuTro: room.maChuTro,
      tieuDe: room.tieuDe,
      diaChi: room.diaChi,
      quanHuyen: room.quanHuyen,
      giaThue: room.giaThue,
      dienTich: room.dienTich,
      loaiPhong: room.loaiPhong,
      moTa: room.moTa,
      trangThaiDuyet: room.trangThaiDuyet, // 'NHAP' hoặc 'CHO_DUYET'
      trangThaiThue: 'CON_TRONG',
      danhSachAnh: room.danhSachAnh,
      tienIch: room.tienIch,
      chiPhiDien: room.chiPhiDien,
      chiPhiNuoc: room.chiPhiNuoc,
      chiPhiKhac: room.chiPhiKhac,
      soNguoiOToiDa: room.soNguoiOToiDa,
      isHienThi: room.isHienThi,
      luotXem: 0,
      diemDanhGiaTB: 0.0,
      countLuotDanhGia: 0,
      soLanTuChoi: 0,
    );

    await docRef.set(newRoom.toMap());
    return newRoom;
  }

  /// Cập nhật tin đăng (Nếu bị từ chối, được sửa & resubmit tối đa 3 lần - QD04)
  Future<RoomModel> updateRoomListing(RoomModel room) async {
    if (room.danhSachAnh.length < AppConstants.minListingImages) {
      throw Exception('Chủ trọ phải cung cấp tối thiểu 3 ảnh thực tế của phòng trọ');
    }

    if (room.danhSachAnh.length > 10) {
      throw Exception('Chủ trọ chỉ được tải lên tối đa 10 ảnh thực tế');
    }

    if (_roomsCol == null) throw Exception('Dịch vụ CSDL Firebase không khả dụng');

    final existing = await getRoomById(room.maPhong);
    if (existing != null && existing.trangThaiDuyet == 'TU_CHOI') {
      if (existing.soLanTuChoi >= AppConstants.maxRejectionResubmissions) {
        throw Exception('Tin đăng đã bị từ chối 3 lần. Không thể chỉnh sửa và gửi lại nữa');
      }
    }

    final updatedRoom = RoomModel(
      maPhong: room.maPhong,
      maChuTro: room.maChuTro,
      tieuDe: room.tieuDe,
      diaChi: room.diaChi,
      quanHuyen: room.quanHuyen,
      giaThue: room.giaThue,
      dienTich: room.dienTich,
      loaiPhong: room.loaiPhong,
      moTa: room.moTa,
      trangThaiDuyet: room.trangThaiDuyet == 'NHAP' ? 'NHAP' : 'CHO_DUYET', // Gửi lại duyệt hoặc lưu nháp
      trangThaiThue: room.trangThaiThue,
      danhSachAnh: room.danhSachAnh,
      tienIch: room.tienIch,
      chiPhiDien: room.chiPhiDien,
      chiPhiNuoc: room.chiPhiNuoc,
      chiPhiKhac: room.chiPhiKhac,
      soNguoiOToiDa: room.soNguoiOToiDa,
      isHienThi: room.isHienThi,
      lyDoTuChoi: null, // Reset lý do khi sửa & resubmit
      luotXem: room.luotXem,
      diemDanhGiaTB: room.diemDanhGiaTB,
      countLuotDanhGia: room.countLuotDanhGia,
      soLanTuChoi: room.soLanTuChoi,
    );

    await _roomsCol!.doc(room.maPhong).update(updatedRoom.toMap());
    return updatedRoom;
  }

  /// Ẩn / Hiện tin đăng khỏi kết quả tìm kiếm của Sinh viên
  Future<void> toggleRoomVisibility(String roomId, bool isHienThi) async {
    if (_roomsCol == null) return;
    await _roomsCol!.doc(roomId).update({
      'IsHienThi': isHienThi,
    });
  }

  /// Xác nhận trả phòng / Đăng lại phòng (Chuyển trạng thái phòng từ DA_CHO_THUE thành CON_TRONG)
  Future<void> relistRoom(String roomId) async {
    if (_roomsCol == null) return;
    await _roomsCol!.doc(roomId).update({
      'TrangThaiThue': 'CON_TRONG',
    });
  }

  /// Admin cập nhật trạng thái duyệt tin
  Future<void> updateRoomApprovalStatus(String roomId, String status, {String? reason}) async {
    if (_roomsCol == null) return;
    final data = <String, dynamic>{
      'TrangThaiDuyet': status,
    };
    if (status == 'TU_CHOI') {
      data['SoLanTuChoi'] = FieldValue.increment(1);
      if (reason != null) {
        data['LyDoTuChoi'] = reason;
      }
    }
    await _roomsCol!.doc(roomId).update(data);
  }

  /// Tự động đếm LuotXem mỗi khi sinh viên mở chi tiết phòng
  Future<void> incrementRoomViewCount(String roomId) async {
    if (_roomsCol == null) return;
    try {
      await _roomsCol!.doc(roomId).update({
        'LuotXem': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  /// Xóa tin đăng phòng trọ (Đánh dấu IsDeleted: true)
  Future<void> deleteRoomListing(String roomId) async {
    if (_roomsCol == null) return;
    try {
      await _roomsCol!.doc(roomId).update({
        'IsDeleted': true,
        'DeletedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error deleting room listing from firestore: $e');
    }
  }
}
