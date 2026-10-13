class SystemReportEntity {
  final String maBaoCao;
  final String loaiBaoCao; // 'TU_DONG_HANG_THANG', 'THU_CONG'
  final DateTime tuNgay;
  final DateTime denNgay;
  final int soTaiKhoanMoi;
  final int soTinDangMoi;
  final int tongYeuCauThue;
  final int tongGiaoDichDatCoc;
  final double tongDoanhThuDatCoc;
  final DateTime ngayTao;

  SystemReportEntity({
    required this.maBaoCao,
    required this.loaiBaoCao,
    required this.tuNgay,
    required this.denNgay,
    required this.soTaiKhoanMoi,
    required this.soTinDangMoi,
    required this.tongYeuCauThue,
    required this.tongGiaoDichDatCoc,
    required this.tongDoanhThuDatCoc,
    required this.ngayTao,
  });
}
