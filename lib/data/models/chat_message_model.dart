import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.maTinNhan,
    required super.maNguoiGui,
    required super.maNguoiNhan,
    required super.maPhong,
    required super.noiDung,
    required super.thoiGian,
    super.imageUrl,
    super.isDaXem,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      maTinNhan: id,
      maNguoiGui: map['MaNguoiGui'] ?? '',
      maNguoiNhan: map['MaNguoiNhan'] ?? '',
      maPhong: map['MaPhong'] ?? '',
      noiDung: map['NoiDung'] ?? '',
      thoiGian: map['ThoiGian'] is Timestamp
          ? (map['ThoiGian'] as Timestamp).toDate()
          : (map['ThoiGian'] != null
              ? DateTime.parse(map['ThoiGian'])
              : DateTime.now()),
      imageUrl: map['ImageUrl'],
      isDaXem: map['IsDaXem'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaTinNhan': maTinNhan,
      'MaNguoiGui': maNguoiGui,
      'MaNguoiNhan': maNguoiNhan,
      'MaPhong': maPhong,
      'NoiDung': noiDung,
      'ThoiGian': Timestamp.fromDate(thoiGian),
      'ImageUrl': imageUrl,
      'IsDaXem': isDaXem,
    };
  }
}
