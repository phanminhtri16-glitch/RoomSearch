class ContractEntity {
  final String maHopDong;
  final String maYeuCau;
  final String maPhong;
  final String maSV;
  final String maChuTro;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final double giaThueHangThang;
  final double tienCoc;
  final String trangThai; // 'HIEU_LUC', 'THANH_LY', 'DA_HOAN_THANH'

  ContractEntity({
    required this.maHopDong,
    required this.maYeuCau,
    required this.maPhong,
    required this.maSV,
    required this.maChuTro,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.giaThueHangThang,
    required this.tienCoc,
    required this.trangThai,
  });
}
