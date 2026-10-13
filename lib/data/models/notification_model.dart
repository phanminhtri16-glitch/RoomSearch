import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.maThongBao,
    required super.maNguoiNhan,
    required super.tieuDe,
    required super.noiDung,
    required super.loaiThongBao,
    required super.thoiGian,
    super.isDaDoc,
    super.maLienQuan,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      maThongBao: id,
      maNguoiNhan: map['MaNguoiNhan'] ?? '',
      tieuDe: map['TieuDe'] ?? '',
      noiDung: map['NoiDung'] ?? '',
      loaiThongBao: map['LoaiThongBao'] ?? 'KHAC',
      thoiGian: map['ThoiGian'] is Timestamp
          ? (map['ThoiGian'] as Timestamp).toDate()
          : (map['ThoiGian'] != null
              ? DateTime.parse(map['ThoiGian'])
              : DateTime.now()),
      isDaDoc: map['IsDaDoc'] ?? false,
      maLienQuan: map['MaLienQuan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaThongBao': maThongBao,
      'MaNguoiNhan': maNguoiNhan,
      'TieuDe': tieuDe,
      'NoiDung': noiDung,
      'LoaiThongBao': loaiThongBao,
      'ThoiGian': Timestamp.fromDate(thoiGian),
      'IsDaDoc': isDaDoc,
      'MaLienQuan': maLienQuan,
    };
  }
}
