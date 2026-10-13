import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.maTK,
    required super.hoTen,
    required super.email,
    required super.soDienThoai,
    required super.matKhau,
    required super.vaiTro,
    required super.trangThai,
    required super.ngayDangKy,
    super.ngaySinh,
    super.soCCCD,
    super.diaChiLienHe,
    super.avatarUrl,
    super.diemUyTinhTrungBinh = 5.0,
    super.soLanNhapSaiOTP,
    super.thoiGianMoKhoaOTP,
    super.currentOtp,
    super.otpExpiryTime,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      maTK: id,
      hoTen: map['HoTen'] ?? '',
      email: map['Email'] ?? '',
      soDienThoai: map['SoDienThoai'] ?? '',
      matKhau: map['MatKhau'] ?? '',
      vaiTro: map['VaiTro'] ?? 'SINH_VIEN',
      trangThai: map['TrangThai'] ?? 'CHO_XAC_THUC',
      ngayDangKy: map['NgayDangKy'] is Timestamp
          ? (map['NgayDangKy'] as Timestamp).toDate()
          : (map['NgayDangKy'] != null
              ? DateTime.parse(map['NgayDangKy'])
              : DateTime.now()),
      ngaySinh: map['NgaySinh'] is Timestamp
          ? (map['NgaySinh'] as Timestamp).toDate()
          : (map['NgaySinh'] != null ? DateTime.tryParse(map['NgaySinh']) : null),
      soCCCD: map['SoCCCD'],
      diaChiLienHe: map['DiaChiLienHe'],
      avatarUrl: map['AvatarUrl'],
      diemUyTinhTrungBinh: (map['DiemUyTinhTrungBinh'] ?? 5.0).toDouble(),
      soLanNhapSaiOTP: map['SoLanNhapSaiOTP'] ?? 0,
      thoiGianMoKhoaOTP: map['ThoiGianMoKhoaOTP'] is Timestamp
          ? (map['ThoiGianMoKhoaOTP'] as Timestamp).toDate()
          : (map['ThoiGianMoKhoaOTP'] != null
              ? DateTime.tryParse(map['ThoiGianMoKhoaOTP'])
              : null),
      currentOtp: map['CurrentOtp'],
      otpExpiryTime: map['OtpExpiryTime'] is Timestamp
          ? (map['OtpExpiryTime'] as Timestamp).toDate()
          : (map['OtpExpiryTime'] != null
              ? DateTime.tryParse(map['OtpExpiryTime'])
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'MaTK': maTK,
      'HoTen': hoTen,
      'Email': email,
      'SoDienThoai': soDienThoai,
      'MatKhau': matKhau,
      'VaiTro': vaiTro,
      'TrangThai': trangThai,
      'NgayDangKy': Timestamp.fromDate(ngayDangKy),
      'NgaySinh': ngaySinh != null ? Timestamp.fromDate(ngaySinh!) : null,
      'SoCCCD': soCCCD,
      'DiaChiLienHe': diaChiLienHe,
      'AvatarUrl': avatarUrl,
      'DiemUyTinhTrungBinh': diemUyTinhTrungBinh,
      'SoLanNhapSaiOTP': soLanNhapSaiOTP,
      'ThoiGianMoKhoaOTP': thoiGianMoKhoaOTP != null
          ? Timestamp.fromDate(thoiGianMoKhoaOTP!)
          : null,
      'CurrentOtp': currentOtp,
      'OtpExpiryTime':
          otpExpiryTime != null ? Timestamp.fromDate(otpExpiryTime!) : null,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      maTK: entity.maTK,
      hoTen: entity.hoTen,
      email: entity.email,
      soDienThoai: entity.soDienThoai,
      matKhau: entity.matKhau,
      vaiTro: entity.vaiTro,
      trangThai: entity.trangThai,
      ngayDangKy: entity.ngayDangKy,
      ngaySinh: entity.ngaySinh,
      soCCCD: entity.soCCCD,
      diaChiLienHe: entity.diaChiLienHe,
      avatarUrl: entity.avatarUrl,
      diemUyTinhTrungBinh: entity.diemUyTinhTrungBinh,
      soLanNhapSaiOTP: entity.soLanNhapSaiOTP,
      thoiGianMoKhoaOTP: entity.thoiGianMoKhoaOTP,
      currentOtp: entity.currentOtp,
      otpExpiryTime: entity.otpExpiryTime,
    );
  }
}
