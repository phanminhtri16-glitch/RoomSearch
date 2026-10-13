class AuditLogEntity {
  final String maLog;
  final String adminId;
  final String adminEmail;
  final String userId;
  final String userEmail;
  final String hanhDong; // 'KHOA_TAI_KHOAN', 'MO_KHOA_TAI_KHOAN', 'CAP_NHAT_THAM_SO'
  final String lyDo;
  final String trangThaiTruoc;
  final String trangThaiSau;
  final DateTime thoiGian;

  AuditLogEntity({
    required this.maLog,
    required this.adminId,
    required this.adminEmail,
    required this.userId,
    required this.userEmail,
    required this.hanhDong,
    required this.lyDo,
    required this.trangThaiTruoc,
    required this.trangThaiSau,
    required this.thoiGian,
  });
}
