class DepositTransactionEntity {
  final String maGiaoDich;
  final String maYeuCau;
  final double soTienCoc;
  final String phuongThuc; // 'VNPAY', 'MOMO'
  final String trangThai; // 'DANG_XU_LY', 'THANH_CONG', 'THAT_BAI'
  final DateTime ngayGiaoDich;

  DepositTransactionEntity({
    required this.maGiaoDich,
    required this.maYeuCau,
    required this.soTienCoc,
    required this.phuongThuc,
    required this.trangThai,
    required this.ngayGiaoDich,
  });
}
