import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/rental_request_entity.dart';

class RentalRequestModel extends RentalRequestEntity {
  RentalRequestModel({
    required super.maYeuCau,
    required super.maSV,
    super.tenSV,
    required super.maPhong,
    required super.ngayMuonVaoO,
    required super.thoiHanThue,
    required super.soNguoiO,
    required super.ghiChu,
    required super.trangThai,
    required super.ngayTao,
    super.lyDoTuChoi,
    super.maChuTro,
  });

  factory RentalRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RentalRequestModel(
      maYeuCau: id,
      maSV: map['MaSV'] ?? '',
      tenSV: map['TenSV'],
      maPhong: map['MaPhong'] ?? '',
      ngayMuonVaoO: map['NgayMuonVaoO'] is Timestamp
          ? (map['NgayMuonVaoO'] as Timestamp).toDate()
          : (map['NgayMuonVaoO'] != null
              ? DateTime.parse(map['NgayMuonVaoO'])
              : DateTime.now()),
      thoiHanThue: map['ThoiHanThue'] ?? 1,
      soNguoiO: map['SoNguoiO'] ?? 1,
      ghiChu: map['GhiChu'] ?? '',
      trangThai: map['TrangThai'] ?? 'CHO_XU_LY',
      ngayTao: map['NgayTao'] is Timestamp
          ? (map['NgayTao'] as Timestamp).toDate()
          : (map['NgayTao'] != null
              ? DateTime.parse(map['NgayTao'])
              : DateTime.now()),
      lyDoTuChoi: map['LyDoTuChoi'],
      maChuTro: map['MaChuTro'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaYeuCau': maYeuCau,
      'MaSV': maSV,
      'TenSV': tenSV,
      'MaPhong': maPhong,
      'NgayMuonVaoO': Timestamp.fromDate(ngayMuonVaoO),
      'ThoiHanThue': thoiHanThue,
      'SoNguoiO': soNguoiO,
      'GhiChu': ghiChu,
      'TrangThai': trangThai,
      'NgayTao': Timestamp.fromDate(ngayTao),
      'LyDoTuChoi': lyDoTuChoi,
      'MaChuTro': maChuTro,
    };
  }
}
