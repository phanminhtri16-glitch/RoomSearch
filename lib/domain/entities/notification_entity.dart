class NotificationEntity {
  final String maThongBao;
  final String maNguoiNhan;
  final String tieuDe;
  final String noiDung;
  final String loaiThongBao; // 'YEU_CAU_MOI', 'DUYET_TIN', 'TU_CHOI_TIN', 'COC_THANH_CONG', 'TIN_NHAN_MOI'
  final DateTime thoiGian;
  final bool isDaDoc;
  final String? maLienQuan; // maPhong / maYeuCau / maHopDong / maTinNhan

  NotificationEntity({
    required this.maThongBao,
    required this.maNguoiNhan,
    required this.tieuDe,
    required this.noiDung,
    required this.loaiThongBao,
    required this.thoiGian,
    this.isDaDoc = false,
    this.maLienQuan,
  });
}
