import '../datasources/admin_remote_datasource.dart';
import '../models/audit_log_model.dart';
import '../models/review_model.dart';
import '../models/room_model.dart';
import '../models/system_param_model.dart';
import '../models/system_report_model.dart';
import '../models/user_model.dart';

class AdminRepositoryImpl {
  final AdminRemoteDatasource _datasource;

  AdminRepositoryImpl({AdminRemoteDatasource? datasource})
      : _datasource = datasource ?? AdminRemoteDatasource();

  Future<SystemParamModel> getSystemParameters() => _datasource.getSystemParameters();

  Future<bool> updateSystemParameters(SystemParamModel params) =>
      _datasource.updateSystemParameters(params);

  Future<List<UserModel>> getAllUsers() => _datasource.getAllUsers();

  Future<bool> deleteUserAccount(String userId) => _datasource.deleteUserAccount(userId);

  Future<bool> updateUserAccountStatus({
    required String userId,
    required String status,
    required String reason,
    required String adminId,
    required String adminEmail,
    required String userEmail,
    required String currentStatus,
  }) =>
      _datasource.updateUserAccountStatus(
        userId: userId,
        status: status,
        reason: reason,
        adminId: adminId,
        adminEmail: adminEmail,
        userEmail: userEmail,
        currentStatus: currentStatus,
      );

  Future<List<AuditLogModel>> getAuditLogs() => _datasource.getAuditLogs();

  Future<List<ReviewModel>> getAllReviews() => _datasource.getAllReviews();

  Future<bool> toggleReviewVisibility({
    required String reviewId,
    required String roomId,
    required bool isHidden,
  }) =>
      _datasource.toggleReviewVisibility(
        reviewId: reviewId,
        roomId: roomId,
        isHidden: isHidden,
      );

  Future<List<RoomModel>> getDeletedRooms() => _datasource.getDeletedRooms();

  Future<bool> restoreDeletedRoom(String roomId) => _datasource.restoreDeletedRoom(roomId);

  Future<bool> deleteRoomPermanently(String roomId) => _datasource.deleteRoomPermanently(roomId);

  Future<bool> softDeleteRoomByAdmin(String roomId) => _datasource.softDeleteRoomByAdmin(roomId);

  Future<bool> approveOrRejectRoom({
    required String roomId,
    required String status,
    required String landlordId,
    String? rejectionReason,
  }) =>
      _datasource.approveOrRejectRoom(
        roomId: roomId,
        status: status,
        landlordId: landlordId,
        rejectionReason: rejectionReason,
      );

  Future<Map<String, dynamic>> getDashboardStats() => _datasource.getDashboardStats();

  Future<SystemReportModel> generateReport({
    required String loaiBaoCao,
    required DateTime tuNgay,
    required DateTime denNgay,
  }) =>
      _datasource.generateReport(
        loaiBaoCao: loaiBaoCao,
        tuNgay: tuNgay,
        denNgay: denNgay,
      );

  Future<List<SystemReportModel>> getSystemReports() => _datasource.getSystemReports();
}
