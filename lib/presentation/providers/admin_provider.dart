import 'package:flutter/foundation.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/system_param_model.dart';
import '../../data/models/system_report_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepositoryImpl _adminRepository;
  final RoomRepositoryImpl _roomRepository;

  AdminProvider({
    AdminRepositoryImpl? adminRepository,
    RoomRepositoryImpl? roomRepository,
  })  : _adminRepository = adminRepository ?? AdminRepositoryImpl(),
        _roomRepository = roomRepository ?? RoomRepositoryImpl();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SystemParamModel _systemParams = SystemParamModel();
  SystemParamModel get systemParams => _systemParams;

  List<UserModel> _allUsers = [];
  List<UserModel> get allUsers => _allUsers;

  List<AuditLogModel> _auditLogs = [];
  List<AuditLogModel> get auditLogs => _auditLogs;

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  List<RoomModel> _deletedRooms = [];
  List<RoomModel> get deletedRooms => _deletedRooms;

  List<RoomModel> _pendingRooms = [];
  List<RoomModel> get pendingRooms => _pendingRooms;

  List<SystemReportModel> _systemReports = [];
  List<SystemReportModel> get systemReports => _systemReports;

  Map<String, dynamic> _dashboardStats = {
    'totalUsers': 0,
    'pendingRoomsCount': 0,
    'approvedRoomsCount': 0,
    'totalRequestsCount': 0,
    'totalDepositRevenue': 0.0,
  };
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  /// Load toàn bộ dữ liệu quản trị khi khởi chạy
  Future<void> fetchAllAdminData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchSystemParameters(),
        fetchUsers(),
        fetchAuditLogs(),
        fetchReviews(),
        fetchPendingRooms(),
        fetchDeletedRooms(),
        fetchDashboardStats(),
        fetchSystemReports(),
      ]);
    } catch (e) {
      debugPrint('Error fetching all admin data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 1. Cấu hình Tham số hệ thống
  Future<void> fetchSystemParameters() async {
    _systemParams = await _adminRepository.getSystemParameters();
    notifyListeners();
  }

  Future<bool> updateSystemParameters(SystemParamModel newParams) async {
    final success = await _adminRepository.updateSystemParameters(newParams);
    if (success) {
      _systemParams = newParams;
      notifyListeners();
    }
    return success;
  }

  /// 2. Quản lý Tài khoản & Audit Log
  Future<void> fetchUsers() async {
    _allUsers = await _adminRepository.getAllUsers();
    notifyListeners();
  }

  String getLandlordName(String landlordId) {
    try {
      final user = _allUsers.firstWhere((u) => u.maTK == landlordId);
      if (user.hoTen.trim().isNotEmpty && user.hoTen != landlordId && !user.hoTen.contains('LANDLORD') && !user.hoTen.contains('CT-')) {
        return user.hoTen;
      }
    } catch (_) {}
    int? number;
    final match = RegExp(r'(\d+)$').firstMatch(landlordId);
    if (match != null) {
      number = int.tryParse(match.group(1)!);
    }
    final numStr = number != null ? '$number' : '1';
    return 'Chủ trọ $numStr';
  }

  Future<bool> updateUserStatus({
    required String userId,
    required String status,
    required String reason,
    required String adminId,
    required String adminEmail,
    required String userEmail,
    required String currentStatus,
  }) async {
    final success = await _adminRepository.updateUserAccountStatus(
      userId: userId,
      status: status,
      reason: reason,
      adminId: adminId,
      adminEmail: adminEmail,
      userEmail: userEmail,
      currentStatus: currentStatus,
    );

    if (success) {
      await fetchUsers();
      await fetchAuditLogs();
    }
    return success;
  }

  Future<bool> deleteUserAccount(String userId, dynamic roomProvider) async {
    try {
      await _adminRepository.deleteUserAccount(userId);
      _allUsers.removeWhere((u) => u.maTK == userId);
      if (roomProvider != null) {
        await roomProvider.deleteRoomsByLandlord(userId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      return false;
    }
  }

  Future<void> fetchAuditLogs() async {
    _auditLogs = await _adminRepository.getAuditLogs();
    notifyListeners();
  }

  /// 3. Duyệt & Quản lý tin đăng
  Future<void> fetchPendingRooms() async {
    final list = await _roomRepository.getPendingApprovalRooms();
    _pendingRooms = list.map((e) => RoomModel.fromEntity(e)).toList();
    notifyListeners();
  }

  Future<bool> approveOrRejectRoom({
    required String roomId,
    required String status,
    required String landlordId,
    String? rejectionReason,
  }) async {
    final success = await _adminRepository.approveOrRejectRoom(
      roomId: roomId,
      status: status,
      landlordId: landlordId,
      rejectionReason: rejectionReason,
    );

    if (success) {
      await fetchPendingRooms();
      await fetchDashboardStats();
    }
    return success;
  }

  Future<void> fetchDeletedRooms() async {
    _deletedRooms = await _adminRepository.getDeletedRooms();
    notifyListeners();
  }

  Future<bool> restoreDeletedRoom(String roomId) async {
    _deletedRooms.removeWhere((r) => r.maPhong == roomId);
    final success = await _adminRepository.restoreDeletedRoom(roomId);
    notifyListeners();
    return success;
  }

  Future<bool> softDeleteRoom(dynamic roomOrId) async {
    RoomModel? roomModel;
    if (roomOrId is RoomModel) {
      roomModel = roomOrId;
    } else if (roomOrId is String) {
      try {
        roomModel = _pendingRooms.firstWhere((r) => r.maPhong == roomOrId);
      } catch (_) {}
    }

    final roomId = roomModel?.maPhong ?? roomOrId.toString();
    if (roomModel != null) {
      _deletedRooms.removeWhere((r) => r.maPhong == roomId);
      _deletedRooms.insert(0, roomModel);
    } else {
      await fetchDeletedRooms();
    }
    _pendingRooms.removeWhere((r) => r.maPhong == roomId);
    await _adminRepository.softDeleteRoomByAdmin(roomId);
    notifyListeners();
    return true;
  }

  Future<bool> deleteRoomPermanently(String roomId) async {
    _deletedRooms.removeWhere((r) => r.maPhong == roomId);
    final success = await _adminRepository.deleteRoomPermanently(roomId);
    notifyListeners();
    return success;
  }

  /// 4. Quản lý Đánh giá
  Future<void> fetchReviews() async {
    _reviews = await _adminRepository.getAllReviews();
    notifyListeners();
  }

  Future<bool> toggleReviewVisibility({
    required String reviewId,
    required String roomId,
    required bool isHidden,
  }) async {
    final success = await _adminRepository.toggleReviewVisibility(
      reviewId: reviewId,
      roomId: roomId,
      isHidden: isHidden,
    );

    if (success) {
      await fetchReviews();
    }
    return success;
  }

  /// 5. Dashboard Chỉ số & Báo cáo
  Future<void> fetchDashboardStats() async {
    _dashboardStats = await _adminRepository.getDashboardStats();
    notifyListeners();
  }

  Future<void> fetchSystemReports() async {
    _systemReports = await _adminRepository.getSystemReports();
    notifyListeners();
  }

  Future<SystemReportModel?> generateCustomReport({
    required String loaiBaoCao,
    required DateTime tuNgay,
    required DateTime denNgay,
  }) async {
    try {
      final report = await _adminRepository.generateReport(
        loaiBaoCao: loaiBaoCao,
        tuNgay: tuNgay,
        denNgay: denNgay,
      );
      await fetchSystemReports();
      return report;
    } catch (e) {
      debugPrint('Error generating report in provider: $e');
      return null;
    }
  }

  /// Kiểm tra hàng chờ duyệt tồn đọng > 24h
  List<RoomModel> get overduePendingRooms {
    final now = DateTime.now();
    return _pendingRooms.where((room) {
      if (room.ngayTao == null) return false;
      final diff = now.difference(room.ngayTao!);
      return diff.inHours >= _systemParams.adminApprovalDeadlineHours;
    }).toList();
  }
}
