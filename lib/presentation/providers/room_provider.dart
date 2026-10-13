import 'package:flutter/foundation.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';

class RoomProvider with ChangeNotifier {
  final RoomRepository _repository;

  RoomProvider(this._repository);

  List<RoomEntity> _approvedRooms = [];
  List<RoomEntity> get approvedRooms => _approvedRooms;

  List<RoomEntity> _landlordRooms = [];
  List<RoomEntity> get landlordRooms => _landlordRooms;

  List<RoomEntity> _pendingRooms = [];
  List<RoomEntity> get pendingRooms => _pendingRooms;

  final List<RoomEntity> _favoriteRooms = [];
  List<RoomEntity> get favoriteRooms => _favoriteRooms;

  bool isFavorite(String roomId) {
    return _favoriteRooms.any((r) => r.maPhong == roomId);
  }

  void toggleFavorite(RoomEntity room) {
    final index = _favoriteRooms.indexWhere((r) => r.maPhong == room.maPhong);
    if (index >= 0) {
      _favoriteRooms.removeAt(index);
    } else {
      _favoriteRooms.add(room);
    }
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load danh sách phòng trọ đã duyệt (cho sinh viên)
  Future<void> fetchApprovedRooms({String? quanHuyen, String? searchKeyword}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _approvedRooms = await _repository.getApprovedRooms(
        quanHuyen: quanHuyen,
        searchKeyword: searchKeyword,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Load danh sách phòng trọ của Chủ trọ
  Future<void> fetchLandlordRooms(String landlordId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _landlordRooms = await _repository.getRoomsByLandlord(landlordId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Load danh sách phòng trọ chờ duyệt (cho Admin)
  Future<void> fetchPendingRooms() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _pendingRooms = await _repository.getPendingApprovalRooms();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng tin phòng trọ mới
  Future<bool> createRoom(RoomEntity room) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newRoom = await _repository.createRoomListing(room);
      _landlordRooms.insert(0, newRoom);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật / Gửi lại tin đăng
  Future<bool> updateRoom(RoomEntity room) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updated = await _repository.updateRoomListing(room);
      final index = _landlordRooms.indexWhere((r) => r.maPhong == room.maPhong);
      if (index != -1) {
        _landlordRooms[index] = updated;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Ẩn / Hiện tin đăng
  Future<bool> toggleVisibility(String roomId, bool currentVisibility, String landlordId) async {
    try {
      await _repository.toggleRoomVisibility(roomId, !currentVisibility);
      await fetchLandlordRooms(landlordId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// Xác nhận trả phòng / Đăng lại phòng
  Future<bool> relistRoom(String roomId, String landlordId) async {
    try {
      await _repository.relistRoom(roomId);
      await fetchLandlordRooms(landlordId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// Admin duyệt tin / từ chối tin
  Future<bool> updateApproval(String roomId, String status, {String? reason}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.updateRoomApprovalStatus(roomId, status, reason: reason);
      _pendingRooms.removeWhere((r) => r.maPhong == roomId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa tin đăng phòng trọ
  Future<bool> deleteRoom(String roomId, String landlordId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _repository.deleteRoomListing(roomId);
      _landlordRooms.removeWhere((r) => r.maPhong == roomId);
      _approvedRooms.removeWhere((r) => r.maPhong == roomId);
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa toàn bộ tin đăng của một Chủ trọ (khi xóa tài khoản)
  Future<void> deleteRoomsByLandlord(String landlordId) async {
    _landlordRooms.removeWhere((r) => r.maChuTro == landlordId);
    _approvedRooms.removeWhere((r) => r.maChuTro == landlordId);
    _pendingRooms.removeWhere((r) => r.maChuTro == landlordId);
    notifyListeners();
  }

  /// Tăng số lượt xem khi mở chi tiết
  Future<void> viewRoomDetail(String roomId) async {
    await _repository.incrementRoomViewCount(roomId);
  }

  /// Đánh dấu tin đăng phòng trọ thành trạng thái "Đã cho thuê" (khi cọc thành công)
  void markRoomAsRented(String roomId) {
    // 1. Update in approvedRooms
    final appIndex = _approvedRooms.indexWhere((r) => r.maPhong == roomId);
    if (appIndex != -1) {
      final old = _approvedRooms[appIndex];
      _approvedRooms[appIndex] = RoomEntity(
        maPhong: old.maPhong,
        maChuTro: old.maChuTro,
        tieuDe: old.tieuDe,
        diaChi: old.diaChi,
        quanHuyen: old.quanHuyen,
        giaThue: old.giaThue,
        dienTich: old.dienTich,
        loaiPhong: old.loaiPhong,
        moTa: old.moTa,
        trangThaiDuyet: old.trangThaiDuyet,
        trangThaiThue: 'DA_CHO_THUE',
        danhSachAnh: old.danhSachAnh,
        tienIch: old.tienIch,
        chiPhiDien: old.chiPhiDien,
        chiPhiNuoc: old.chiPhiNuoc,
        chiPhiKhac: old.chiPhiKhac,
        soNguoiOToiDa: old.soNguoiOToiDa,
        isHienThi: old.isHienThi,
        lyDoTuChoi: old.lyDoTuChoi,
        luotXem: old.luotXem,
        diemDanhGiaTB: old.diemDanhGiaTB,
        countLuotDanhGia: old.countLuotDanhGia,
        soLanTuChoi: old.soLanTuChoi,
        ngayTao: old.ngayTao,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
      );
    }

    // 2. Update in landlordRooms
    final landIndex = _landlordRooms.indexWhere((r) => r.maPhong == roomId);
    if (landIndex != -1) {
      final old = _landlordRooms[landIndex];
      final updated = RoomEntity(
        maPhong: old.maPhong,
        maChuTro: old.maChuTro,
        tieuDe: old.tieuDe,
        diaChi: old.diaChi,
        quanHuyen: old.quanHuyen,
        giaThue: old.giaThue,
        dienTich: old.dienTich,
        loaiPhong: old.loaiPhong,
        moTa: old.moTa,
        trangThaiDuyet: old.trangThaiDuyet,
        trangThaiThue: 'DA_CHO_THUE',
        danhSachAnh: old.danhSachAnh,
        tienIch: old.tienIch,
        chiPhiDien: old.chiPhiDien,
        chiPhiNuoc: old.chiPhiNuoc,
        chiPhiKhac: old.chiPhiKhac,
        soNguoiOToiDa: old.soNguoiOToiDa,
        isHienThi: old.isHienThi,
        lyDoTuChoi: old.lyDoTuChoi,
        luotXem: old.luotXem,
        diemDanhGiaTB: old.diemDanhGiaTB,
        countLuotDanhGia: old.countLuotDanhGia,
        soLanTuChoi: old.soLanTuChoi,
        ngayTao: old.ngayTao,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
      );
      _landlordRooms[landIndex] = updated;
      try {
        _repository.updateRoomListing(updated);
      } catch (e) {
        debugPrint('Error updating room status in repository: $e');
      }
    }

    notifyListeners();
  }

  /// Cập nhật điểm đánh giá trung bình & lượt đánh giá của phòng trọ
  void updateRoomRating(String roomId, double avgRating, int reviewCount) {
    final appIndex = _approvedRooms.indexWhere((r) => r.maPhong == roomId);
    if (appIndex != -1) {
      final old = _approvedRooms[appIndex];
      _approvedRooms[appIndex] = RoomEntity(
        maPhong: old.maPhong,
        maChuTro: old.maChuTro,
        tieuDe: old.tieuDe,
        diaChi: old.diaChi,
        quanHuyen: old.quanHuyen,
        giaThue: old.giaThue,
        dienTich: old.dienTich,
        loaiPhong: old.loaiPhong,
        moTa: old.moTa,
        trangThaiDuyet: old.trangThaiDuyet,
        trangThaiThue: old.trangThaiThue,
        danhSachAnh: old.danhSachAnh,
        tienIch: old.tienIch,
        chiPhiDien: old.chiPhiDien,
        chiPhiNuoc: old.chiPhiNuoc,
        chiPhiKhac: old.chiPhiKhac,
        soNguoiOToiDa: old.soNguoiOToiDa,
        isHienThi: old.isHienThi,
        lyDoTuChoi: old.lyDoTuChoi,
        luotXem: old.luotXem,
        diemDanhGiaTB: avgRating,
        countLuotDanhGia: reviewCount,
        soLanTuChoi: old.soLanTuChoi,
        ngayTao: old.ngayTao,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
      );
    }

    final landIndex = _landlordRooms.indexWhere((r) => r.maPhong == roomId);
    if (landIndex != -1) {
      final old = _landlordRooms[landIndex];
      _landlordRooms[landIndex] = RoomEntity(
        maPhong: old.maPhong,
        maChuTro: old.maChuTro,
        tieuDe: old.tieuDe,
        diaChi: old.diaChi,
        quanHuyen: old.quanHuyen,
        giaThue: old.giaThue,
        dienTich: old.dienTich,
        loaiPhong: old.loaiPhong,
        moTa: old.moTa,
        trangThaiDuyet: old.trangThaiDuyet,
        trangThaiThue: old.trangThaiThue,
        danhSachAnh: old.danhSachAnh,
        tienIch: old.tienIch,
        chiPhiDien: old.chiPhiDien,
        chiPhiNuoc: old.chiPhiNuoc,
        chiPhiKhac: old.chiPhiKhac,
        soNguoiOToiDa: old.soNguoiOToiDa,
        isHienThi: old.isHienThi,
        lyDoTuChoi: old.lyDoTuChoi,
        luotXem: old.luotXem,
        diemDanhGiaTB: avgRating,
        countLuotDanhGia: reviewCount,
        soLanTuChoi: old.soLanTuChoi,
        ngayTao: old.ngayTao,
        isDeleted: old.isDeleted,
        deletedAt: old.deletedAt,
      );
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
