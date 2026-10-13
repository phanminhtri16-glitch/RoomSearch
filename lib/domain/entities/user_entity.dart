class UserEntity {
  final String maTK;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String matKhau;
  final String vaiTro; // 'SINH_VIEN', 'CHU_TRO', 'ADMIN'
  final String trangThai; // 'CHO_XAC_THUC', 'HOAT_DONG', 'KHOA'
  final DateTime ngayDangKy;
  final DateTime? ngaySinh;
  final int soLanNhapSaiOTP;
  final DateTime? thoiGianMoKhoaOTP;
  final String? currentOtp;
  final DateTime? otpExpiryTime;

  final String? soCCCD;
  final String? diaChiLienHe;
  final String? avatarUrl;
  final double diemUyTinhTrungBinh;

  UserEntity({
    required this.maTK,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.matKhau,
    required this.vaiTro,
    required this.trangThai,
    required this.ngayDangKy,
    this.ngaySinh,
    this.soCCCD,
    this.diaChiLienHe,
    this.avatarUrl,
    this.diemUyTinhTrungBinh = 5.0,
    this.soLanNhapSaiOTP = 0,
    this.thoiGianMoKhoaOTP,
    this.currentOtp,
    this.otpExpiryTime,
  });

  UserEntity copyWith({
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? matKhau,
    String? vaiTro,
    String? trangThai,
    String? soCCCD,
    String? diaChiLienHe,
    String? avatarUrl,
    double? diemUyTinhTrungBinh,
  }) {
    return UserEntity(
      maTK: maTK,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      matKhau: matKhau ?? this.matKhau,
      vaiTro: vaiTro ?? this.vaiTro,
      trangThai: trangThai ?? this.trangThai,
      ngayDangKy: ngayDangKy,
      ngaySinh: ngaySinh,
      soCCCD: soCCCD ?? this.soCCCD,
      diaChiLienHe: diaChiLienHe ?? this.diaChiLienHe,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      diemUyTinhTrungBinh: diemUyTinhTrungBinh ?? this.diemUyTinhTrungBinh,
      soLanNhapSaiOTP: soLanNhapSaiOTP,
      thoiGianMoKhoaOTP: thoiGianMoKhoaOTP,
      currentOtp: currentOtp,
      otpExpiryTime: otpExpiryTime,
    );
  }

  bool get isLockedOTP {
    if (thoiGianMoKhoaOTP == null) return false;
    return DateTime.now().isBefore(thoiGianMoKhoaOTP!);
  }

  bool get isOtpExpired {
    if (otpExpiryTime == null) return true;
    return DateTime.now().isAfter(otpExpiryTime!);
  }
}
