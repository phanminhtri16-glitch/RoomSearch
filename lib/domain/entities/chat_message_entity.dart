class ChatMessageEntity {
  final String maTinNhan;
  final String maNguoiGui;
  final String maNguoiNhan;
  final String maPhong;
  final String noiDung; // Tối đa 1000 ký tự
  final DateTime thoiGian;

  final String? imageUrl;
  final bool isDaXem;

  ChatMessageEntity({
    required this.maTinNhan,
    required this.maNguoiGui,
    required this.maNguoiNhan,
    required this.maPhong,
    required this.noiDung,
    required this.thoiGian,
    this.imageUrl,
    this.isDaXem = false,
  });
}
