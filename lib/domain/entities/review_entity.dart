class ReviewEntity {
  final String maDanhGia;
  final String maPhong;
  final String maSV;
  final String tenSV;
  final double diem;
  final String noiDung; // Tối thiểu 20 ký tự
  final DateTime ngayDanhGia;
  final bool isHiddenByAdmin;

  ReviewEntity({
    required this.maDanhGia,
    required this.maPhong,
    required this.maSV,
    required this.tenSV,
    required this.diem,
    required this.noiDung,
    required this.ngayDanhGia,
    this.isHiddenByAdmin = false,
  });
}
