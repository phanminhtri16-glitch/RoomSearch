import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contract_entity.dart';

class ContractModel extends ContractEntity {
  ContractModel({
    required super.maHopDong,
    required super.maYeuCau,
    required super.maPhong,
    required super.maSV,
    required super.maChuTro,
    required super.ngayBatDau,
    required super.ngayKetThuc,
    required super.giaThueHangThang,
    required super.tienCoc,
    required super.trangThai,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map, String id) {
    return ContractModel(
      maHopDong: id,
      maYeuCau: map['MaYeuCau'] ?? '',
      maPhong: map['MaPhong'] ?? '',
      maSV: map['MaSV'] ?? '',
      maChuTro: map['MaChuTro'] ?? '',
      ngayBatDau: map['NgayBatDau'] is Timestamp
          ? (map['NgayBatDau'] as Timestamp).toDate()
          : DateTime.now(),
      ngayKetThuc: map['NgayKetThuc'] is Timestamp
          ? (map['NgayKetThuc'] as Timestamp).toDate()
          : DateTime.now(),
      giaThueHangThang: (map['GiaThueHangThang'] ?? 0).toDouble(),
      tienCoc: (map['TienCoc'] ?? 0).toDouble(),
      trangThai: map['TrangThai'] ?? 'HIEU_LUC',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaHopDong': maHopDong,
      'MaYeuCau': maYeuCau,
      'MaPhong': maPhong,
      'MaSV': maSV,
      'MaChuTro': maChuTro,
      'NgayBatDau': Timestamp.fromDate(ngayBatDau),
      'NgayKetThuc': Timestamp.fromDate(ngayKetThuc),
      'GiaThueHangThang': giaThueHangThang,
      'TienCoc': tienCoc,
      'TrangThai': trangThai,
    };
  }
}
