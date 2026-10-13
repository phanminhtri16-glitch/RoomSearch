class AppConstants {

  static const String appName = 'RoomSearch';

  // Quy định độ tuổi tối thiểu (18 tuổi)
  static const int minUserAge = 18;

  // Quy định OTP: Hiệu lực 5 phút (300s), nhập sai max 3 lần khóa 15 phút (900s), gửi lại chờ 15s
  static const int otpValidityDurationSeconds = 300; // 5 phút
  static const int otpMaxAttempts = 3;
  static const int otpLockoutDurationSeconds = 900; // 15 phút
  static const int otpResendCooldownDurationSeconds = 15; // 15 giây chờ gửi lại

  // Cấu hình Gmail SMTP gửi mã OTP (Cho Native: Android / iOS / Desktop)
  static const String gmailSenderEmail = 'phanminhtri16@gmail.com';
  static const String gmailAppPassword = 'zlak dyla ctqz jeup'; // Mật khẩu ứng dụng 16 ký tự của Google
  static const String gmailSmtpHost = 'smtp.gmail.com';
  static const int gmailSmtpPort = 587;

  // Cấu hình EmailJS HTTPS REST API (Cho Web khi trình duyệt không dùng được TCP Socket)
  static const String emailjsServiceId = '';
  static const String emailjsTemplateId = '';
  static const String emailjsPublicKey = '';

  // Quy định đăng tin: Tối thiểu 3 ảnh, giá >= 500.000 VNĐ
  static const int minListingImages = 3;
  static const double minListingPrice = 500000.0;
  static const int maxRejectionResubmissions = 3;

  // Quy định yêu cầu thuê: Tối đa 5 yêu cầu đang ở trạng thái 'Chờ xử lý' cùng lúc
  static const int maxPendingRequestsPerStudent = 5;

  // Quy định thời gian giữ chỗ & thanh toán cọc: 15 phút (900s)
  static const int depositPaymentPriorityDurationSeconds = 900; // 15 phút

  // Quy định đánh giá & yêu thích
  static const int maxFavoriteRoomsPerStudent = 50;
  static const int minStayDaysForReview = 7;
  static const int minReviewLength = 20; // Tối thiểu 20 ký tự
  static const int maxChatMessageLength = 1000;

  // Roles
  static const String roleStudent = 'SINH_VIEN';
  static const String roleLandlord = 'CHU_TRO';
  static const String roleAdmin = 'ADMIN';

  // Collection names in Firestore
  static const String colTaiKhoan = 'TAI_KHOAN';
  static const String colPhongTro = 'PHONG_TRO';
  static const String colYeuCauThue = 'YEU_CAU_THUE';
  static const String colGiaoDichDatCoc = 'GIAO_DICH_DAT_COC';
  static const String colDanhGia = 'DANH_GIA';
  static const String colPhongYeuThich = 'PHONG_YEU_THICH';
  static const String colTinNhan = 'TIN_NHAN';
  static const String colHopDong = 'HOP_DONG';
  static const String colThamSo = 'THAM_SO';

  // Hình ảnh phòng trọ mẫu (Giữ lại để sử dụng khi đăng tin/kiểm thử)
  static const List<String> sampleRoomImages = [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
    'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
    'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
  ];
}
