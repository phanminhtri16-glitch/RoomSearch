import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.maDanhGia,
    required super.maPhong,
    required super.maSV,
    required super.tenSV,
    required super.diem,
    required super.noiDung,
    required super.ngayDanhGia,
    super.isHiddenByAdmin,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      maDanhGia: id,
      maPhong: map['MaPhong'] ?? '',
      maSV: map['MaSV'] ?? '',
      tenSV: map['TenSV'] ?? '',
      diem: (map['Diem'] ?? 5.0).toDouble(),
      noiDung: map['NoiDung'] ?? '',
      ngayDanhGia: map['NgayDanhGia'] is Timestamp
          ? (map['NgayDanhGia'] as Timestamp).toDate()
          : (map['NgayDanhGia'] != null
              ? DateTime.parse(map['NgayDanhGia'])
              : DateTime.now()),
      isHiddenByAdmin: map['IsHiddenByAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaDanhGia': maDanhGia,
      'MaPhong': maPhong,
      'MaSV': maSV,
      'TenSV': tenSV,
      'Diem': diem,
      'NoiDung': noiDung,
      'NgayDanhGia': Timestamp.fromDate(ngayDanhGia),
      'IsHiddenByAdmin': isHiddenByAdmin,
    };
  }
}
