class RentalRequestEntity {
  final String maYeuCau;
  final String maSV;
  final String? tenSV;
  final String maPhong;
  final DateTime ngayMuonVaoO;
  final int thoiHanThue; // Số tháng
  final int soNguoiO;
  final String ghiChu;
  final String trangThai; // 'CHO_XU_LY', 'CHO_THANH_TOAN', 'HOAN_THANH', 'TU_CHOI', 'HET_HAN'
  final DateTime ngayTao;

  final String? lyDoTuChoi;
  final String? maChuTro;

  RentalRequestEntity({
    required this.maYeuCau,
    required this.maSV,
    this.tenSV,
    required this.maPhong,
    required this.ngayMuonVaoO,
    required this.thoiHanThue,
    required this.soNguoiO,
    required this.ghiChu,
    required this.trangThai,
    required this.ngayTao,
    this.lyDoTuChoi,
    this.maChuTro,
  });

  String get tenSinhVien {
    if (tenSV != null && tenSV!.trim().isNotEmpty && !tenSV!.startsWith('SV')) return tenSV!;
    int? number;
    final match = RegExp(r'(\d+)$').firstMatch(maSV);
    if (match != null) {
      number = int.tryParse(match.group(1)!);
    }
    final numStr = number != null ? '$number' : '1';
    return 'Sinh viên $numStr';
  }
}

