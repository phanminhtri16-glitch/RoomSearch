import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/audit_log_model.dart';
import '../models/review_model.dart';
import '../models/room_model.dart';
import '../models/system_param_model.dart';
import '../models/system_report_model.dart';
import '../models/user_model.dart';

class AdminRemoteDatasource {
  final FirebaseFirestore? _customFirestore;

  AdminRemoteDatasource({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Collections
  CollectionReference? get _usersCol =>
      _firestore?.collection(AppConstants.colTaiKhoan);
  CollectionReference? get _roomsCol =>
      _firestore?.collection(AppConstants.colPhongTro);
  CollectionReference? get _reviewsCol =>
      _firestore?.collection(AppConstants.colDanhGia);
  CollectionReference? get _auditCol =>
      _firestore?.collection('NHAT_KY_HE_THONG');
  CollectionReference? get _paramCol =>
      _firestore?.collection(AppConstants.colThamSo);
  CollectionReference? get _reportCol =>
      _firestore?.collection('BAO_CAO_HE_THONG');
  CollectionReference? get _requestsCol =>
      _firestore?.collection(AppConstants.colYeuCauThue);
  CollectionReference? get _depositsCol =>
      _firestore?.collection(AppConstants.colGiaoDichDatCoc);
  CollectionReference? get _notifCol =>
      _firestore?.collection('THONG_BAO');

  /// 1. Lấy & Cập nhật Tham số hệ thống (THAM_SO)
  Future<SystemParamModel> getSystemParameters() async {
    if (_paramCol == null) return SystemParamModel();
    try {
      final doc = await _paramCol!.doc('CONFIG_MAIN').get();
      if (doc.exists && doc.data() != null) {
        return SystemParamModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Khởi tạo mặc định nếu chưa tồn tại
        final defaultParams = SystemParamModel();
        await _paramCol!.doc('CONFIG_MAIN').set(defaultParams.toMap());
        return defaultParams;
      }
    } catch (e) {
      debugPrint('Error fetching system params: $e');
      return SystemParamModel();
    }
  }

  Future<bool> updateSystemParameters(SystemParamModel params) async {
    if (_paramCol == null) return false;
    try {
      await _paramCol!.doc('CONFIG_MAIN').set(params.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error updating system params: $e');
      return false;
    }
  }

  static final List<UserModel> _mockUsersList = [];

  /// 2. Tra cứu & Quản lý tài khoản Người dùng + Audit Log
  Future<List<UserModel>> getAllUsers() async {
    if (_usersCol == null) return List.from(_mockUsersList);
    try {
      final snapshot = await _usersCol!.get();
      if (snapshot.docs.isEmpty) return List.from(_mockUsersList);
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return List.from(_mockUsersList);
    }
  }

  Future<bool> deleteUserAccount(String userId) async {
    _mockUsersList.removeWhere((u) => u.maTK == userId);
    if (_usersCol != null) {
      try {
        await _usersCol!.doc(userId).delete();
      } catch (e) {
        debugPrint('Error deleting user account from Firestore: $e');
      }
    }
    return true;
  }

  Future<bool> updateUserAccountStatus({
    required String userId,
    required String status, // 'HOAT_DONG' hoặc 'KHOA'
    required String reason,
    required String adminId,
    required String adminEmail,
    required String userEmail,
    required String currentStatus,
  }) async {
    if (_usersCol == null || _auditCol == null) return false;
    try {
      // Cập nhật trạng thái tài khoản
      await _usersCol!.doc(userId).update({
        'TrangThai': status,
      });

      // Ghi nhật ký hệ thống (Audit Log)
      final logDoc = _auditCol!.doc();
      final auditLog = AuditLogModel(
        maLog: logDoc.id,
        adminId: adminId,
        adminEmail: adminEmail,
        userId: userId,
        userEmail: userEmail,
        hanhDong: status == 'KHOA' ? 'KHOA_TAI_KHOAN' : 'MO_KHOA_TAI_KHOAN',
        lyDo: reason,
        trangThaiTruoc: currentStatus,
        trangThaiSau: status,
        thoiGian: DateTime.now(),
      );
      await logDoc.set(auditLog.toMap());

      return true;
    } catch (e) {
      debugPrint('Error updating user status and audit log: $e');
      return false;
    }
  }

  Future<List<AuditLogModel>> getAuditLogs() async {
    if (_auditCol == null) return [];
    try {
      final snapshot = await _auditCol!.orderBy('ThoiGian', descending: true).get();
      return snapshot.docs
          .map((doc) => AuditLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
      return [];
    }
  }

  /// 3. Quản lý Đánh giá & Xử lý Vi phạm
  Future<List<ReviewModel>> getAllReviews() async {
    if (_reviewsCol == null) return [];
    try {
      final snapshot = await _reviewsCol!.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Future<bool> toggleReviewVisibility({
    required String reviewId,
    required String roomId,
    required bool isHidden,
  }) async {
    if (_reviewsCol == null || _roomsCol == null) return false;
    try {
      // 1. Cập nhật trạng thái bài đánh giá
      await _reviewsCol!.doc(reviewId).update({
        'IsHiddenByAdmin': isHidden,
      });

      // 2. Lấy lại tất cả đánh giá không bị ẩn của phòng trọ này để tính toán lại điểm trung bình
      final reviewsSnapshot = await _reviewsCol!
          .where('MaPhong', isEqualTo: roomId)
          .get();

      final validReviews = reviewsSnapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) => !r.isHiddenByAdmin)
          .toList();

      double avgRating = 0.0;
      int count = validReviews.length;
      if (count > 0) {
        final totalPoints = validReviews.fold<double>(0.0, (acc, item) => acc + item.diem);
        avgRating = totalPoints / count;
      }

      // 3. Cập nhật lại thông số trên document phòng trọ
      await _roomsCol!.doc(roomId).update({
        'DiemDanhGiaTB': double.parse(avgRating.toStringAsFixed(1)),
        'CountLuotDanhGia': count,
      });

      return true;
    } catch (e) {
      debugPrint('Error toggling review visibility: $e');
      return false;
    }
  }

  /// 4. Quản lý & Phục hồi Tin đăng bị xóa (isDeleted = true)
  Future<List<RoomModel>> getDeletedRooms() async {
    if (_roomsCol == null) return [];
    try {
      final snapshot = await _roomsCol!.where('IsDeleted', isEqualTo: true).get();
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching deleted rooms: $e');
      return [];
    }
  }

  Future<bool> restoreDeletedRoom(String roomId) async {
    if (_roomsCol == null) return false;
    try {
      await _roomsCol!.doc(roomId).update({
        'IsDeleted': false,
        'DeletedAt': null,
      });
      return true;
    } catch (e) {
      debugPrint('Error restoring room: $e');
      return false;
    }
  }

  Future<bool> deleteRoomPermanently(String roomId) async {
    if (_roomsCol == null) return false;
    try {
      await _roomsCol!.doc(roomId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting room permanently: $e');
      return false;
    }
  }

  Future<bool> softDeleteRoomByAdmin(String roomId) async {
    if (_roomsCol == null) return false;
    try {
      await _roomsCol!.doc(roomId).update({
        'IsDeleted': true,
        'DeletedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      debugPrint('Error soft deleting room: $e');
      return false;
    }
  }

  /// 5. Phê duyệt/Từ chối tin đăng & gửi thông báo cho Chủ trọ
  Future<bool> approveOrRejectRoom({
    required String roomId,
    required String status, // 'DA_DUYET' hoặc 'TU_CHOI'
    required String landlordId,
    String? rejectionReason,
  }) async {
    if (_roomsCol == null) return false;
    try {
      final updates = <String, dynamic>{
        'TrangThaiDuyet': status,
      };

      if (status == 'TU_CHOI') {
        updates['SoLanTuChoi'] = FieldValue.increment(1);
        if (rejectionReason != null) {
          updates['LyDoTuChoi'] = rejectionReason;
        }
      }

      await _roomsCol!.doc(roomId).update(updates);

      // Gửi thông báo đến Chủ trọ
      if (_notifCol != null) {
        final notifDoc = _notifCol!.doc();
        final isApprove = status == 'DA_DUYET';
        await notifDoc.set({
          'MaThongBao': notifDoc.id,
          'MaNguoiNhan': landlordId,
          'TieuDe': isApprove ? 'Tin đăng đã được phê duyệt' : 'Tin đăng bị từ chối kiểm duyệt',
          'NoiDung': isApprove
              ? 'Phòng trọ của bạn đã được Admin duyệt và hiển thị công khai.'
              : 'Tin đăng bị từ chối với lý do: "${rejectionReason ?? 'Thông tin chưa hợp lệ'}". Vui lòng chỉnh sửa và gửi lại.',
          'LoaiThongBao': isApprove ? 'DUYET_TIN' : 'TU_CHOI_TIN',
          'ThoiGian': Timestamp.fromDate(DateTime.now()),
          'IsDaDoc': false,
          'MaLienQuan': roomId,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error approving/rejecting room: $e');
      return false;
    }
  }

  /// 6. Thống kê Dashboard real-time & Báo cáo
  Future<Map<String, dynamic>> getDashboardStats() async {
    int totalUsers = 0;
    int pendingRoomsCount = 0;
    int approvedRoomsCount = 0;
    int totalRequestsCount = 0;
    double totalDepositRevenue = 0.0;

    try {
      if (_usersCol != null) {
        final usersSnap = await _usersCol!.get();
        totalUsers = usersSnap.docs.length;
      }

      if (_roomsCol != null) {
        final pendingSnap = await _roomsCol!.where('TrangThaiDuyet', isEqualTo: 'CHO_DUYET').get();
        pendingRoomsCount = pendingSnap.docs.length;

        final approvedSnap = await _roomsCol!.where('TrangThaiDuyet', isEqualTo: 'DA_DUYET').get();
        approvedRoomsCount = approvedSnap.docs.length;
      }

      if (_requestsCol != null) {
        final reqSnap = await _requestsCol!.get();
        totalRequestsCount = reqSnap.docs.length;
      }

      if (_depositsCol != null) {
        final depSnap = await _depositsCol!.get();
        for (var doc in depSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['SoTienCoc'] ?? 0).toDouble();
          totalDepositRevenue += amount;
        }
      }
    } catch (e) {
      debugPrint('Error computing dashboard stats: $e');
    }

    return {
      'totalUsers': totalUsers,
      'pendingRoomsCount': pendingRoomsCount,
      'approvedRoomsCount': approvedRoomsCount,
      'totalRequestsCount': totalRequestsCount,
      'totalDepositRevenue': totalDepositRevenue,
    };
  }

  /// Báo cáo thủ công hoặc định kỳ
  Future<SystemReportModel> generateReport({
    required String loaiBaoCao, // 'TU_DONG_HANG_THANG', 'THU_CONG'
    required DateTime tuNgay,
    required DateTime denNgay,
  }) async {
    int newUsers = 0;
    int newListings = 0;
    int totalRequests = 0;
    int totalDeposits = 0;
    double totalRevenue = 0.0;

    try {
      if (_usersCol != null) {
        final snap = await _usersCol!
            .where('NgayDangKy', isGreaterThanOrEqualTo: Timestamp.fromDate(tuNgay))
            .where('NgayDangKy', isLessThanOrEqualTo: Timestamp.fromDate(denNgay))
            .get();
        newUsers = snap.docs.length;
      }

      if (_roomsCol != null) {
        final snap = await _roomsCol!
            .where('NgayTao', isGreaterThanOrEqualTo: Timestamp.fromDate(tuNgay))
            .where('NgayTao', isLessThanOrEqualTo: Timestamp.fromDate(denNgay))
            .get();
        newListings = snap.docs.length;
      }

      if (_requestsCol != null) {
        final snap = await _requestsCol!.get();
        totalRequests = snap.docs.length;
      }

      if (_depositsCol != null) {
        final snap = await _depositsCol!.get();
        totalDeposits = snap.docs.length;
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRevenue += (data['SoTienCoc'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error generating report: $e');
    }

    final reportDoc = _reportCol?.doc();
    final reportId = reportDoc?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final report = SystemReportModel(
      maBaoCao: reportId,
      loaiBaoCao: loaiBaoCao,
      tuNgay: tuNgay,
      denNgay: denNgay,
      soTaiKhoanMoi: newUsers,
      soTinDangMoi: newListings,
      tongYeuCauThue: totalRequests,
      tongGiaoDichDatCoc: totalDeposits,
      tongDoanhThuDatCoc: totalRevenue,
      ngayTao: DateTime.now(),
    );

    await reportDoc?.set(report.toMap());

    return report;
  }

  Future<List<SystemReportModel>> getSystemReports() async {
    if (_reportCol == null) return [];
    try {
      final snapshot = await _reportCol!.orderBy('NgayTao', descending: true).get();
      return snapshot.docs
          .map((doc) => SystemReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      return [];
    }
  }
}
