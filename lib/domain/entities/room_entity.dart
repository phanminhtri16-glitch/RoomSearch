class RoomEntity {
  final String maPhong;
  final String maChuTro;
  final String tieuDe;
  final String diaChi;
  final String quanHuyen;
  final double giaThue;
  final double dienTich;
  final String loaiPhong; // Trọ / Căn hộ / Chung cư mini
  final String moTa;
  final String trangThaiDuyet; // 'NHAP', 'CHO_DUYET', 'DA_DUYET', 'TU_CHOI'
  final String trangThaiThue; // 'CON_TRONG', 'TAM_KHOA_CHO_COC', 'DA_CHO_THUE'
  final List<String> danhSachAnh;
  final List<String> tienIch;
  final int luotXem;
  final double diemDanhGiaTB;
  final int countLuotDanhGia;
  final int soLanTuChoi; // Tối đa 3 lần sửa & resubmit nếu bị Admin từ chối

  final double? chiPhiDien;
  final double? chiPhiNuoc;
  final double? chiPhiKhac;
  final int soNguoiOToiDa;
  final bool isHienThi;
  final String? lyDoTuChoi;
  final DateTime? ngayTao;
  final bool isDeleted;
  final DateTime? deletedAt;
  final double? viDo;
  final double? kinhDo;

  RoomEntity({
    required this.maPhong,
    required this.maChuTro,
    required this.tieuDe,
    required this.diaChi,
    required this.quanHuyen,
    required this.giaThue,
    required this.dienTich,
    required this.loaiPhong,
    required this.moTa,
    required this.trangThaiDuyet,
    required this.trangThaiThue,
    required this.danhSachAnh,
    required this.tienIch,
    this.chiPhiDien,
    this.chiPhiNuoc,
    this.chiPhiKhac,
    this.soNguoiOToiDa = 2,
    this.isHienThi = true,
    this.lyDoTuChoi,
    this.luotXem = 0,
    this.diemDanhGiaTB = 0.0,
    this.countLuotDanhGia = 0,
    this.soLanTuChoi = 0,
    this.ngayTao,
    this.isDeleted = false,
    this.deletedAt,
    this.viDo,
    this.kinhDo,
  });
}
