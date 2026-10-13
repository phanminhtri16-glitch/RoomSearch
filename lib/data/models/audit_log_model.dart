import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log_entity.dart';

class AuditLogModel extends AuditLogEntity {
  AuditLogModel({
    required super.maLog,
    required super.adminId,
    required super.adminEmail,
    required super.userId,
    required super.userEmail,
    required super.hanhDong,
    required super.lyDo,
    required super.trangThaiTruoc,
    required super.trangThaiSau,
    required super.thoiGian,
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogModel(
      maLog: id,
      adminId: map['AdminId'] ?? '',
      adminEmail: map['AdminEmail'] ?? '',
      userId: map['UserId'] ?? '',
      userEmail: map['UserEmail'] ?? '',
      hanhDong: map['HanhDong'] ?? '',
      lyDo: map['LyDo'] ?? '',
      trangThaiTruoc: map['TrangThaiTruoc'] ?? '',
      trangThaiSau: map['TrangThaiSau'] ?? '',
      thoiGian: map['ThoiGian'] is Timestamp
          ? (map['ThoiGian'] as Timestamp).toDate()
          : (map['ThoiGian'] != null ? DateTime.tryParse(map['ThoiGian'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AdminId': adminId,
      'AdminEmail': adminEmail,
      'UserId': userId,
      'UserEmail': userEmail,
      'HanhDong': hanhDong,
      'LyDo': lyDo,
      'TrangThaiTruoc': trangThaiTruoc,
      'TrangThaiSau': trangThaiSau,
      'ThoiGian': Timestamp.fromDate(thoiGian),
    };
  }
}
