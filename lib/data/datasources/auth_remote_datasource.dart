import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/email_service.dart';
import '../../core/utils/code_generator_util.dart';
import '../../core/utils/otp_generator.dart';
import '../../core/utils/password_hasher.dart';
import '../../core/utils/validators.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final FirebaseFirestore? _customFirestore;
  final Map<String, Map<String, dynamic>> _inMemoryUsers = {};

  AuthRemoteDatasource({FirebaseFirestore? firestore})
      : _customFirestore = firestore {
    _seedDefaultUsers();
  }

  void _seedDefaultUsers() {
    final passHash = PasswordHasher.hashPassword('123456');
    _inMemoryUsers['SV_DEMO_1'] = {
      'MaTK': 'SV_DEMO_1',
      'HoTen': 'Sinh viên Nguyễn Văn A',
      'Email': 'sv1@gmail.com',
      'SoDienThoai': '0912345678',
      'MatKhau': passHash,
      'VaiTro': AppConstants.roleStudent,
      'TrangThai': 'HOAT_DONG',
      'NgayDangKy': Timestamp.fromDate(DateTime.now()),
      'NgaySinh': Timestamp.fromDate(DateTime(2002, 5, 20)),
      'DiemUyTinhTrungBinh': 5.0,
      'SoLanNhapSaiOTP': 0,
    };
    _inMemoryUsers['CT_DEMO_1'] = {
      'MaTK': 'CT_DEMO_1',
      'HoTen': 'Chủ trọ Trần Văn B',
      'Email': 'chutro1@gmail.com',
      'SoDienThoai': '0988776655',
      'MatKhau': passHash,
      'VaiTro': AppConstants.roleLandlord,
      'TrangThai': 'HOAT_DONG',
      'NgayDangKy': Timestamp.fromDate(DateTime.now()),
      'NgaySinh': Timestamp.fromDate(DateTime(1985, 10, 10)),
      'SoCCCD': '001085123456',
      'DiaChiLienHe': '123 Đường Cầu Giấy, Hà Nội',
      'DiemUyTinhTrungBinh': 4.8,
      'SoLanNhapSaiOTP': 0,
    };
    _inMemoryUsers['ADMIN_DEMO_1'] = {
      'MaTK': 'ADMIN_DEMO_1',
      'HoTen': 'Quản trị viên Hệ thống',
      'Email': 'admin@gmail.com',
      'SoDienThoai': '0999888777',
      'MatKhau': passHash,
      'VaiTro': AppConstants.roleAdmin,
      'TrangThai': 'HOAT_DONG',
      'NgayDangKy': Timestamp.fromDate(DateTime.now()),
      'NgaySinh': Timestamp.fromDate(DateTime(1990, 1, 1)),
      'DiemUyTinhTrungBinh': 5.0,
      'SoLanNhapSaiOTP': 0,
    };
  }

  FirebaseFirestore? get _firestoreInstance {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore instance not yet initialized: $e');
      return null;
    }
  }

  /// Đăng nhập tài khoản
  Future<UserModel?> login({
    required String emailOrPhone,
    required String password,
  }) async {
    if (_inMemoryUsers.isEmpty) {
      _seedDefaultUsers();
    }
    final hashedPassword = PasswordHasher.hashPassword(password);

    // 1. Thử dùng Firestore nếu khả dụng
    if (_firestoreInstance != null) {
      try {
        final col = _firestoreInstance!.collection(AppConstants.colTaiKhoan);
        QuerySnapshot snapshot = await col
            .where('Email', isEqualTo: emailOrPhone.trim())
            .get();

        if (snapshot.docs.isEmpty) {
          snapshot = await col
              .where('SoDienThoai', isEqualTo: emailOrPhone.trim())
              .get();
        }

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          if (data['MatKhau'] != hashedPassword && password.isNotEmpty) {
            throw Exception('Mật khẩu không chính xác');
          }

          if (data['TrangThai'] == 'CHO_XAC_THUC') {
            final newOtp = OtpGenerator.generate6DigitOtp();
            final expiry = DateTime.now().add(const Duration(seconds: AppConstants.otpValidityDurationSeconds));
            await col.doc(doc.id).update({
              'CurrentOtp': newOtp,
              'OtpExpiryTime': Timestamp.fromDate(expiry),
            });
            await EmailService.sendOtpEmail(recipientEmail: data['Email'], otpCode: newOtp);
            throw Exception('CHO_XAC_THUC:${data['Email']}');
          }

          if (data['TrangThai'] == 'KHOA') {
            throw Exception('Tài khoản của bạn đã bị khóa do vi phạm điều khoản');
          }

          return UserModel.fromMap(data, doc.id);
        }
      } catch (e) {
        if (e.toString().contains('CHO_XAC_THUC:')) rethrow;
        debugPrint('Firestore query error, switching to fallback memory store: $e');
      }
    }

    // 2. Fallback sang In-Memory Store
    Map<String, dynamic>? foundData;
    String? foundId;

    _inMemoryUsers.forEach((id, data) {
      if (data['Email'] == emailOrPhone.trim() ||
          data['SoDienThoai'] == emailOrPhone.trim()) {
        foundData = data;
        foundId = id;
      }
    });

    if (foundData == null) {
      throw Exception('Tài khoản hoặc số điện thoại không tồn tại trong hệ thống');
    }

    if (foundData!['MatKhau'] != hashedPassword && password.isNotEmpty) {
      throw Exception('Mật khẩu không chính xác');
    }

    if (foundData!['TrangThai'] == 'CHO_XAC_THUC') {
      final newOtp = OtpGenerator.generate6DigitOtp();
      final expiry = DateTime.now().add(const Duration(seconds: AppConstants.otpValidityDurationSeconds));
      _inMemoryUsers[foundId!]!['CurrentOtp'] = newOtp;
      _inMemoryUsers[foundId!]!['OtpExpiryTime'] = Timestamp.fromDate(expiry);
      await EmailService.sendOtpEmail(recipientEmail: foundData!['Email'], otpCode: newOtp);
      throw Exception('CHO_XAC_THUC:${foundData!['Email']}');
    }

    if (foundData!['TrangThai'] == 'KHOA') {
      throw Exception('Tài khoản của bạn đã bị khóa do vi phạm điều khoản');
    }

    return UserModel.fromMap(foundData!, foundId!);
  }

  /// Đăng ký tài khoản mới (Check tuổi >= 18 theo QD01, thông tin CCCD cho Chủ trọ)
  Future<UserModel> register({
    required String hoTen,
    required String email,
    required String soDienThoai,
    required String password,
    required String vaiTro,
    required DateTime ngaySinh,
    String? soCCCD,
    String? diaChiLienHe,
  }) async {
    // 1. Kiểm tra tuổi >= 18 theo quy định QD01
    if (!Validators.isAtLeast18YearsOld(ngaySinh)) {
      throw Exception('Người dùng phải đủ từ 18 tuổi trở lên để đăng ký tài khoản');
    }

    if (vaiTro == AppConstants.roleLandlord) {
      if (soCCCD == null || soCCCD.trim().isEmpty) {
        throw Exception('Chủ trọ phải cung cấp Số giấy tờ CCCD/xác minh');
      }
      if (diaChiLienHe == null || diaChiLienHe.trim().isEmpty) {
        throw Exception('Chủ trọ phải cung cấp Địa chỉ liên hệ');
      }
    }

    final hashedPassword = PasswordHasher.hashPassword(password);
    final otpCode = OtpGenerator.generate6DigitOtp();
    final now = DateTime.now();
    final otpExpiry = now.add(const Duration(seconds: AppConstants.otpValidityDurationSeconds));


    // 2. Thử lưu vào Firestore nếu khả dụng
    if (_firestoreInstance != null) {
      try {
        final col = _firestoreInstance!.collection(AppConstants.colTaiKhoan);
        final emailCheck = await col.where('Email', isEqualTo: email.trim()).get();
        if (emailCheck.docs.isNotEmpty) {
          throw Exception('Địa chỉ Email này đã được đăng ký tài khoản khác');
        }

        final phoneCheck = await col.where('SoDienThoai', isEqualTo: soDienThoai.trim()).get();
        if (phoneCheck.docs.isNotEmpty) {
          throw Exception('Số điện thoại này đã được đăng ký tài khoản khác');
        }

        String generatedUserId;
        if (vaiTro == AppConstants.roleStudent) {
          generatedUserId = CodeGeneratorUtil.generateStudentCode();
        } else if (vaiTro == AppConstants.roleLandlord) {
          generatedUserId = CodeGeneratorUtil.generateLandlordCode();
        } else {
          generatedUserId = CodeGeneratorUtil.generateAdminCode();
        }

        final docRef = col.doc(generatedUserId);
        final newUser = UserModel(
          maTK: generatedUserId,
          hoTen: hoTen.trim(),
          email: email.trim(),
          soDienThoai: soDienThoai.trim(),
          matKhau: hashedPassword,
          vaiTro: vaiTro,
          trangThai: 'CHO_XAC_THUC',
          ngayDangKy: now,
          ngaySinh: ngaySinh,
          soCCCD: soCCCD?.trim(),
          diaChiLienHe: diaChiLienHe?.trim(),
          diemUyTinhTrungBinh: 5.0,
          soLanNhapSaiOTP: 0,
          thoiGianMoKhoaOTP: null,
          currentOtp: otpCode,
          otpExpiryTime: otpExpiry,
        );

        await docRef.set(newUser.toMap());
        // Lưu cả bản sao vào memory store
        _inMemoryUsers[generatedUserId] = newUser.toMap();

        // Gửi mã OTP tới địa chỉ Gmail của người dùng
        await EmailService.sendOtpEmail(recipientEmail: email.trim(), otpCode: otpCode);

        return newUser;
      } catch (e) {
        if (e.toString().contains('đã được đăng ký')) rethrow;
        debugPrint('Firestore register fallback: $e');
      }
    }

    // 3. Fallback lưu vào In-Memory Store
    _inMemoryUsers.forEach((id, data) {
      if (data['Email'] == email.trim()) {
        throw Exception('Địa chỉ Email này đã được đăng ký tài khoản khác');
      }
      if (data['SoDienThoai'] == soDienThoai.trim()) {
        throw Exception('Số điện thoại này đã được đăng ký tài khoản khác');
      }
    });

    String generatedUserId;
    if (vaiTro == AppConstants.roleStudent) {
      generatedUserId = CodeGeneratorUtil.generateStudentCode();
    } else if (vaiTro == AppConstants.roleLandlord) {
      generatedUserId = CodeGeneratorUtil.generateLandlordCode();
    } else {
      generatedUserId = CodeGeneratorUtil.generateAdminCode();
    }
    final newUser = UserModel(
      maTK: generatedUserId,
      hoTen: hoTen.trim(),
      email: email.trim(),
      soDienThoai: soDienThoai.trim(),
      matKhau: hashedPassword,
      vaiTro: vaiTro,
      trangThai: 'CHO_XAC_THUC',
      ngayDangKy: now,
      ngaySinh: ngaySinh,
      soCCCD: soCCCD?.trim(),
      diaChiLienHe: diaChiLienHe?.trim(),
      diemUyTinhTrungBinh: 5.0,
      soLanNhapSaiOTP: 0,
      thoiGianMoKhoaOTP: null,
      currentOtp: otpCode,
      otpExpiryTime: otpExpiry,
    );

    _inMemoryUsers[generatedUserId] = newUser.toMap();

    // Gửi mã OTP tới địa chỉ Gmail của người dùng
    await EmailService.sendOtpEmail(recipientEmail: email.trim(), otpCode: otpCode);

    return newUser;
  }

  /// Gửi / Cấp lại mã OTP 6 chữ số
  Future<String> sendOtp(String email) async {
    final newOtp = OtpGenerator.generate6DigitOtp();
    final now = DateTime.now();
    final expiry = now.add(const Duration(seconds: AppConstants.otpValidityDurationSeconds));

    // Gửi mã OTP mới tới địa chỉ Gmail của người dùng
    await EmailService.sendOtpEmail(recipientEmail: email.trim(), otpCode: newOtp);

    if (_firestoreInstance != null) {
      try {
        final col = _firestoreInstance!.collection(AppConstants.colTaiKhoan);
        final query = await col.where('Email', isEqualTo: email.trim()).get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final user = UserModel.fromMap(Map<String, dynamic>.from(doc.data() as Map), doc.id);
          if (user.isLockedOTP) {
            final remaining = user.thoiGianMoKhoaOTP!.difference(DateTime.now()).inMinutes + 1;
            throw Exception('Chức năng OTP đã bị khóa do nhập sai quá 3 lần. Vui lòng thử lại sau $remaining phút');
          }
          await col.doc(doc.id).update({
            'CurrentOtp': newOtp,
            'OtpExpiryTime': Timestamp.fromDate(expiry),
          });
          return newOtp;
        }
      } catch (e) {
        if (e.toString().contains('bị khóa')) rethrow;
      }
    }

    // Fallback In-Memory
    String? foundId;
    _inMemoryUsers.forEach((id, data) {
      if (data['Email'] == email.trim()) {
        foundId = id;
      }
    });

    if (foundId == null) {
      throw Exception('Không tìm thấy tài khoản để gửi OTP');
    }

    final user = UserModel.fromMap(_inMemoryUsers[foundId!]!, foundId!);
    if (user.isLockedOTP) {
      final remaining = user.thoiGianMoKhoaOTP!.difference(DateTime.now()).inMinutes + 1;
      throw Exception('Chức năng OTP đã bị khóa do nhập sai quá 3 lần. Vui lòng thử lại sau $remaining phút');
    }

    _inMemoryUsers[foundId!]!['CurrentOtp'] = newOtp;
    _inMemoryUsers[foundId!]!['OtpExpiryTime'] = Timestamp.fromDate(expiry);

    return newOtp;
  }

  /// Xác thực mã OTP 6 số (Xử lý sai 3 lần khóa 15 phút theo QD02)
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final now = DateTime.now();

    if (_firestoreInstance != null) {
      try {
        final col = _firestoreInstance!.collection(AppConstants.colTaiKhoan);
        final query = await col.where('Email', isEqualTo: email.trim()).get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final user = UserModel.fromMap(Map<String, dynamic>.from(doc.data() as Map), doc.id);

          if (user.isLockedOTP) {
            final remaining = user.thoiGianMoKhoaOTP!.difference(now).inMinutes + 1;
            throw Exception('Tính năng nhập OTP đang bị khóa. Vui lòng chờ $remaining phút nữa');
          }

          if (user.isOtpExpired) {
            throw Exception('Mã OTP đã hết hiệu lực 5 phút. Vui lòng bấm gửi lại mã OTP mới');
          }

          if (user.currentOtp != otp.trim()) {
            final updatedAttempts = user.soLanNhapSaiOTP + 1;
            DateTime? lockTime;
            if (updatedAttempts >= AppConstants.otpMaxAttempts) {
              lockTime = now.add(const Duration(seconds: AppConstants.otpLockoutDurationSeconds));
            }

            await col.doc(doc.id).update({
              'SoLanNhapSaiOTP': updatedAttempts,
              'ThoiGianMoKhoaOTP': lockTime != null ? Timestamp.fromDate(lockTime) : null,
            });

            if (updatedAttempts >= AppConstants.otpMaxAttempts) {
              throw Exception('Nhập sai OTP 3 lần liên tiếp. Chức năng OTP đã bị khóa trong 15 phút');
            } else {
              final remainingAttempts = AppConstants.otpMaxAttempts - updatedAttempts;
              throw Exception('Mã OTP không chính xác. Bạn còn $remainingAttempts lần thử');
            }
          }

          await col.doc(doc.id).update({
            'TrangThai': 'HOAT_DONG',
            'SoLanNhapSaiOTP': 0,
            'ThoiGianMoKhoaOTP': null,
            'CurrentOtp': null,
            'OtpExpiryTime': null,
          });

          return true;
        }
      } catch (e) {
        if (e.toString().contains('bị khóa') || e.toString().contains('không chính xác') || e.toString().contains('hết hiệu lực')) {
          rethrow;
        }
      }
    }

    // Fallback In-Memory
    String? foundId;
    _inMemoryUsers.forEach((id, data) {
      if (data['Email'] == email.trim()) {
        foundId = id;
      }
    });

    if (foundId == null) {
      throw Exception('Không tìm thấy tài khoản để xác thực OTP');
    }

    final user = UserModel.fromMap(_inMemoryUsers[foundId!]!, foundId!);

    if (user.isLockedOTP) {
      final remaining = user.thoiGianMoKhoaOTP!.difference(now).inMinutes + 1;
      throw Exception('Tính năng nhập OTP đang bị khóa. Vui lòng chờ $remaining phút nữa');
    }

    if (user.isOtpExpired) {
      throw Exception('Mã OTP đã hết hiệu lực 5 phút. Vui lòng bấm gửi lại mã OTP mới');
    }

    if (user.currentOtp != otp.trim()) {
      final updatedAttempts = user.soLanNhapSaiOTP + 1;
      DateTime? lockTime;
      if (updatedAttempts >= AppConstants.otpMaxAttempts) {
        lockTime = now.add(const Duration(seconds: AppConstants.otpLockoutDurationSeconds));
      }

      _inMemoryUsers[foundId!]!['SoLanNhapSaiOTP'] = updatedAttempts;
      _inMemoryUsers[foundId!]!['ThoiGianMoKhoaOTP'] = lockTime != null ? Timestamp.fromDate(lockTime) : null;

      if (updatedAttempts >= AppConstants.otpMaxAttempts) {
        throw Exception('Nhập sai OTP 3 lần liên tiếp. Chức năng OTP đã bị khóa trong 15 phút');
      } else {
        final remainingAttempts = AppConstants.otpMaxAttempts - updatedAttempts;
        throw Exception('Mã OTP không chính xác. Bạn còn $remainingAttempts lần thử');
      }
    }

    _inMemoryUsers[foundId!]!['TrangThai'] = 'HOAT_DONG';
    _inMemoryUsers[foundId!]!['SoLanNhapSaiOTP'] = 0;
    _inMemoryUsers[foundId!]!['ThoiGianMoKhoaOTP'] = null;
    _inMemoryUsers[foundId!]!['CurrentOtp'] = null;
    _inMemoryUsers[foundId!]!['OtpExpiryTime'] = null;

    return true;
  }

  /// Cập nhật thông tin tài khoản (Họ tên, SĐT, CCCD, Mật khẩu, v.v.)
  Future<void> updateUser(UserModel user) async {
    if (_firestoreInstance != null) {
      try {
        await _firestoreInstance!
            .collection(AppConstants.colTaiKhoan)
            .doc(user.maTK)
            .update(user.toMap());
      } catch (e) {
        debugPrint('Firestore updateUser notice: $e');
      }
    }
    _inMemoryUsers[user.maTK] = user.toMap();
  }
}
