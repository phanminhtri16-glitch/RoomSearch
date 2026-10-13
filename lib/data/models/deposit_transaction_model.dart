import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/deposit_transaction_entity.dart';

class DepositTransactionModel extends DepositTransactionEntity {
  DepositTransactionModel({
    required super.maGiaoDich,
    required super.maYeuCau,
    required super.soTienCoc,
    required super.phuongThuc,
    required super.trangThai,
    required super.ngayGiaoDich,
  });

  factory DepositTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return DepositTransactionModel(
      maGiaoDich: id,
      maYeuCau: map['MaYeuCau'] ?? '',
      soTienCoc: (map['SoTienCoc'] ?? 0).toDouble(),
      phuongThuc: map['PhuongThuc'] ?? 'VNPAY',
      trangThai: map['TrangThai'] ?? 'DANG_XU_LY',
      ngayGiaoDich: map['NgayGiaoDich'] is Timestamp
          ? (map['NgayGiaoDich'] as Timestamp).toDate()
          : (map['NgayGiaoDich'] != null
              ? DateTime.parse(map['NgayGiaoDich'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaGiaoDich': maGiaoDich,
      'MaYeuCau': maYeuCau,
      'SoTienCoc': soTienCoc,
      'PhuongThuc': phuongThuc,
      'TrangThai': trangThai,
      'NgayGiaoDich': Timestamp.fromDate(ngayGiaoDich),
    };
  }
}
