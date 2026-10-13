import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/code_generator_util.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/entities/deposit_transaction_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/rental_request_entity.dart';
import '../../domain/entities/review_entity.dart';
import 'badge_counter_provider.dart';
import 'room_provider.dart';

class LandlordProvider with ChangeNotifier {
  final FirebaseFirestore? _customFirestore;
  BadgeCounterNotifier? _badgeCounterNotifier;

  LandlordProvider({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  void setBadgeCounterNotifier(BadgeCounterNotifier? notifier) {
    _badgeCounterNotifier = notifier;
    _syncNotificationCount();
  }

  void _syncNotificationCount() {
    if (_badgeCounterNotifier == null) return;
    int unreadCount = _notifications.where((n) => !n.isDaDoc).length;
    _badgeCounterNotifier!.setNotificationCount(unreadCount);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Requests
  List<RentalRequestEntity> _rentalRequests = [];
  List<RentalRequestEntity> get rentalRequests => _rentalRequests;

  // Contracts
  List<ContractEntity> _contracts = [];
  List<ContractEntity> get contracts => _contracts;

  // Reviews
  List<ReviewEntity> _reviews = [];
  List<ReviewEntity> get reviews => _reviews;

  // Transactions
  List<DepositTransactionEntity> _transactions = [];
  List<DepositTransactionEntity> get transactions => _transactions;

  // Notifications
  List<NotificationEntity> _notifications = [];
  List<NotificationEntity> get notifications => _notifications;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isDaDoc).length;

  /// Load initial mock / firestore data for Landlord
  Future<void> fetchLandlordData(String landlordId) async {
    _setLoading(true);
    try {
      if (_firestore != null) {
        // 1. YeuCauThue
        try {
          final reqSnapshot = await _firestore!
              .collection('YeuCauThue')
              .get();
          if (reqSnapshot.docs.isNotEmpty) {
            _rentalRequests = reqSnapshot.docs
                .map((doc) {
                  final map = doc.data();
                  return RentalRequestEntity(
                    maYeuCau: doc.id,
                    maSV: map['MaSV'] ?? 'SV_001',
                    tenSV: map['TenSV'],
                    maChuTro: map['MaChuTro'],
                    maPhong: map['MaPhong'] ?? 'P101',
                    ngayMuonVaoO: map['NgayMuonVaoO'] is Timestamp
                        ? (map['NgayMuonVaoO'] as Timestamp).toDate()
                        : DateTime.now().add(const Duration(days: 5)),
                    thoiHanThue: map['ThoiHanThue'] ?? 6,
                    soNguoiO: map['SoNguoiO'] ?? 2,
                    ghiChu: map['GhiChu'] ?? '',
                    trangThai: map['TrangThai'] ?? 'CHO_XU_LY',
                    ngayTao: map['NgayTao'] is Timestamp
                        ? (map['NgayTao'] as Timestamp).toDate()
                        : DateTime.now().subtract(const Duration(hours: 12)),
                    lyDoTuChoi: map['LyDoTuChoi'],
                  );
                })
                .where((r) =>
                    r.maChuTro == landlordId ||
                    r.maSV == landlordId ||
                    landlordId == 'STUDENT_1' ||
                    landlordId == 'LANDLORD_1' ||
                    landlordId == 'CURRENT_USER' ||
                    r.maSV == 'SV_CURRENT')
                .toList();
          }
        } catch (e) {
          debugPrint('Error fetching requests from firestore: $e');
        }

        // 2. HOP_DONG
        try {
          final contractSnapshot = await _firestore!
              .collection('HOP_DONG')
              .where('MaChuTro', isEqualTo: landlordId)
              .get();
          if (contractSnapshot.docs.isNotEmpty) {
            _contracts = contractSnapshot.docs.map((doc) {
              final map = doc.data();
              return ContractEntity(
                maHopDong: doc.id,
                maYeuCau: map['MaYeuCau'] ?? '',
                maPhong: map['MaPhong'] ?? '',
                maSV: map['MaSV'] ?? '',
                maChuTro: map['MaChuTro'] ?? landlordId,
                ngayBatDau: map['NgayBatDau'] is Timestamp
                    ? (map['NgayBatDau'] as Timestamp).toDate()
                    : DateTime.now(),
                ngayKetThuc: map['NgayKetThuc'] is Timestamp
                    ? (map['NgayKetThuc'] as Timestamp).toDate()
                    : DateTime.now().add(const Duration(days: 180)),
                giaThueHangThang: (map['GiaThueHangThang'] ?? 3000000).toDouble(),
                tienCoc: (map['TienCoc'] ?? 3000000).toDouble(),
                trangThai: map['TrangThai'] ?? 'HIEU_LUC',
              );
            }).toList();
          }
        } catch (e) {
          debugPrint('Error fetching contracts from firestore: $e');
        }

        // 3. GIAO_DICH_DAT_COC
        try {
          final txnSnapshot = await _firestore!
              .collection('GIAO_DICH_DAT_COC')
              .get();
          if (txnSnapshot.docs.isNotEmpty) {
            _transactions = txnSnapshot.docs.map((doc) {
              final map = doc.data();
              return DepositTransactionEntity(
                maGiaoDich: doc.id,
                maYeuCau: map['MaYeuCau'] ?? '',
                soTienCoc: (map['SoTienCoc'] ?? 3000000).toDouble(),
                phuongThuc: map['PhuongThuc'] ?? 'VNPAY',
                trangThai: map['TrangThai'] ?? 'THANH_CONG',
                ngayGiaoDich: map['NgayGiaoDich'] is Timestamp
                    ? (map['NgayGiaoDich'] as Timestamp).toDate()
                    : DateTime.now(),
              );
            }).toList();
          }
        } catch (e) {
          debugPrint('Error fetching transactions from firestore: $e');
        }

        // 4. DANH_GIA
        try {
          final reviewSnapshot = await _firestore!
              .collection('DANH_GIA')
              .get();
          if (reviewSnapshot.docs.isNotEmpty) {
            _reviews = reviewSnapshot.docs.map((doc) {
              final map = doc.data();
              return ReviewEntity(
                maDanhGia: doc.id,
                maPhong: map['MaPhong'] ?? '',
                maSV: map['MaSV'] ?? '',
                tenSV: map['TenSV'] ?? 'Sinh viên',
                diem: (map['Diem'] ?? 5.0).toDouble(),
                noiDung: map['NoiDung'] ?? '',
                ngayDanhGia: map['NgayDanhGia'] is Timestamp
                    ? (map['NgayDanhGia'] as Timestamp).toDate()
                    : DateTime.now(),
                isHiddenByAdmin: map['IsHiddenByAdmin'] ?? false,
              );
            }).toList();
          }
        } catch (e) {
          debugPrint('Error fetching reviews from firestore: $e');
        }

        // 5. THONG_BAO
        try {
          final notifSnapshot = await _firestore!
              .collection('THONG_BAO')
              .where('MaNguoiNhan', isEqualTo: landlordId)
              .get();
          if (notifSnapshot.docs.isNotEmpty) {
            _notifications = notifSnapshot.docs.map((doc) {
              final map = doc.data();
              String rawContent = map['NoiDung'] ?? '';
              if (rawContent.contains('#')) {
                rawContent = rawContent.replaceAllMapped(RegExp(r'#([A-Za-z0-9_-]+)'), (match) {
                  final code = match.group(1)!;
                  if (code.startsWith('TN-') || code.startsWith('YC-') || code.startsWith('HD-') || code.startsWith('TXN-')) {
                    return '#$code';
                  }
                  return '#${CodeGeneratorUtil.formatRoomDisplayCode(code)}';
                });
              }
              return NotificationEntity(
                maThongBao: doc.id,
                maNguoiNhan: map['MaNguoiNhan'] ?? landlordId,
                tieuDe: map['TieuDe'] ?? '',
                noiDung: rawContent,
                loaiThongBao: map['LoaiThongBao'] ?? 'KHAC',
                thoiGian: map['ThoiGian'] is Timestamp
                    ? (map['ThoiGian'] as Timestamp).toDate()
                    : DateTime.now(),
                isDaDoc: map['IsDaDoc'] ?? false,
                maLienQuan: map['MaLienQuan'],
              );
            }).toList();
          }
        } catch (e) {
          debugPrint('Error fetching notifications from firestore: $e');
        }
      } else {
        _loadMockRequests();
        _loadMockContracts();
        _loadMockReviews();
        _loadMockTransactions();
        _loadMockNotifications();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _loadMockRequests() {
    _rentalRequests = [];
  }

  void _loadMockContracts() {
    _contracts = [];
  }

  void _loadMockReviews() {
    _reviews = [];
  }

  void _loadMockTransactions() {
    _transactions = [];
  }

  void _loadMockNotifications() {
    _notifications = [];
  }

  /// Thêm mới phiếu yêu cầu thuê từ Sinh viên (Sinh mã chuẩn YC-YYYYMMDD-XXX)
  Future<bool> addRentalRequest(RentalRequestEntity request) async {
    final formattedReqCode = request.maYeuCau.startsWith('YC-')
        ? request.maYeuCau
        : CodeGeneratorUtil.generateRequestCode();

    final newReq = RentalRequestEntity(
      maYeuCau: formattedReqCode,
      maSV: request.maSV,
      tenSV: request.tenSV,
      maChuTro: request.maChuTro,
      maPhong: request.maPhong,
      ngayMuonVaoO: request.ngayMuonVaoO,
      thoiHanThue: request.thoiHanThue,
      soNguoiO: request.soNguoiO,
      ghiChu: request.ghiChu,
      trangThai: request.trangThai,
      ngayTao: request.ngayTao,
    );

    _rentalRequests.insert(0, newReq);

    // Tạo thông báo mới cho Chủ trọ
    final cleanStudent = (newReq.tenSV != null && newReq.tenSV!.trim().isNotEmpty && !newReq.tenSV!.startsWith('SV'))
        ? newReq.tenSV!
        : 'Sinh viên 1';
    final displayRoomCode = CodeGeneratorUtil.formatRoomDisplayCode(newReq.maPhong);

    final notif = NotificationEntity(
      maThongBao: CodeGeneratorUtil.generateNotificationCode(),
      maNguoiNhan: newReq.maChuTro ?? 'LANDLORD_1',
      tieuDe: 'Yêu cầu thuê phòng mới',
      noiDung:
          '$cleanStudent vừa gửi phiếu yêu cầu thuê phòng mã #$displayRoomCode. Vui lòng phản hồi trong 48h.',
      loaiThongBao: 'YEU_CAU_MOI',
      thoiGian: DateTime.now(),
      isDaDoc: false,
      maLienQuan: newReq.maYeuCau,
    );
    _notifications.insert(0, notif);
    _syncNotificationCount();

    if (_firestore != null) {
      try {
        await _firestore!.collection('YeuCauThue').doc(newReq.maYeuCau).set({
          'MaSV': newReq.maSV,
          'TenSV': newReq.tenSV,
          'MaChuTro': newReq.maChuTro,
          'MaPhong': newReq.maPhong,
          'NgayMuonVaoO': Timestamp.fromDate(newReq.ngayMuonVaoO),
          'ThoiHanThue': newReq.thoiHanThue,
          'SoNguoiO': newReq.soNguoiO,
          'GhiChu': newReq.ghiChu,
          'TrangThai': newReq.trangThai,
          'NgayTao': Timestamp.fromDate(newReq.ngayTao),
        });
      } catch (e) {
        debugPrint('Error saving rental request to firestore: $e');
      }
    }

    _syncNotificationCount();
    notifyListeners();
    return true;
  }

  /// Kiểm tra xem phòng đã có phiếu thuê nào đang được chấp nhận/chờ cọc/đã cọc còn hiệu lực hay chưa
  bool hasActiveAcceptedRequestForRoom(String roomId, {String? excludeRequestId}) {
    return _rentalRequests.any((r) {
      if (excludeRequestId != null && r.maYeuCau == excludeRequestId) return false;
      final isSameRoom = r.maPhong == roomId;
      final isAccepted = r.trangThai == 'CHO_THANH_TOAN' ||
          r.trangThai == 'DA_CHAP_NHAN' ||
          r.trangThai == 'DA_COC';
      if (!isSameRoom || !isAccepted) return false;

      // Nếu phiếu là DA_COC nhưng hợp đồng liên quan đến phòng đó không còn HIEU_LUC (đã DA_THANH_LY) -> Không bị kẹt
      if (r.trangThai == 'DA_COC') {
        final hasActiveContract = _contracts.any((c) => c.maPhong == roomId && c.trangThai == 'HIEU_LUC');
        if (!hasActiveContract) return false;
      }

      return true;
    });
  }

  /// Chấp nhận yêu cầu thuê
  Future<bool> acceptRentalRequest(String requestId) async {
    final index = _rentalRequests.indexWhere((r) => r.maYeuCau == requestId);
    if (index != -1) {
      final old = _rentalRequests[index];

      // Nếu phòng đã có 1 phiếu thuê được chấp nhận chờ cọc/đã cọc -> từ chối chấp nhận thêm phiếu khác
      if (hasActiveAcceptedRequestForRoom(old.maPhong, excludeRequestId: requestId)) {
        return false;
      }

      _rentalRequests[index] = RentalRequestEntity(
        maYeuCau: old.maYeuCau,
        maSV: old.maSV,
        tenSV: old.tenSV,
        maChuTro: old.maChuTro,
        maPhong: old.maPhong,
        ngayMuonVaoO: old.ngayMuonVaoO,
        thoiHanThue: old.thoiHanThue,
        soNguoiO: old.soNguoiO,
        ghiChu: old.ghiChu,
        trangThai: 'CHO_THANH_TOAN',
        ngayTao: old.ngayTao,
      );

      if (_firestore != null) {
        try {
          await _firestore!.collection('YeuCauThue').doc(requestId).update({
            'TrangThai': 'CHO_THANH_TOAN',
          });
        } catch (e) {
          debugPrint('Error updating request status in firestore: $e');
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Kiểm tra xem Sinh viên đã gửi nhận xét đánh giá cho phòng trọ này chưa
  bool hasReviewedRoom({
    required String studentId,
    required String roomId,
  }) {
    return _reviews.any((r) => r.maPhong == roomId && (r.maSV == studentId || studentId == 'SV_CURRENT'));
  }

  /// Thêm nhận xét đánh giá phòng mới từ Sinh viên & Tự động cập nhật số sao trung bình trên PHONG_TRO
  Future<bool> addReview(ReviewEntity review, {RoomProvider? roomProvider}) async {
    final formattedRevCode = review.maDanhGia.startsWith('REV-')
        ? review.maDanhGia
        : CodeGeneratorUtil.generateReviewCode();

    final finalReview = ReviewEntity(
      maDanhGia: formattedRevCode,
      maPhong: review.maPhong,
      maSV: review.maSV,
      tenSV: review.tenSV,
      diem: review.diem,
      noiDung: review.noiDung,
      ngayDanhGia: review.ngayDanhGia,
      isHiddenByAdmin: review.isHiddenByAdmin,
    );

    final existingIndex = _reviews.indexWhere((r) => r.maPhong == finalReview.maPhong && r.maSV == finalReview.maSV);
    if (existingIndex != -1) {
      _reviews[existingIndex] = finalReview;
    } else {
      _reviews.insert(0, finalReview);
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection('DANH_GIA').doc(finalReview.maDanhGia).set({
          'MaDanhGia': finalReview.maDanhGia,
          'MaPhong': finalReview.maPhong,
          'MaSV': finalReview.maSV,
          'TenSV': finalReview.tenSV,
          'Diem': finalReview.diem,
          'NoiDung': finalReview.noiDung,
          'NgayDanhGia': Timestamp.fromDate(finalReview.ngayDanhGia),
          'IsHiddenByAdmin': finalReview.isHiddenByAdmin,
        });
      } catch (e) {
        debugPrint('Error adding review to firestore: $e');
      }
    }

    // Tính toán lại số lượng bài đánh giá và trung bình số sao cho phòng
    final activeReviews = _reviews.where((r) => r.maPhong == finalReview.maPhong && !r.isHiddenByAdmin).toList();
    final count = activeReviews.length;
    final totalScore = activeReviews.fold<double>(0.0, (acc, r) => acc + r.diem);
    final avgScore = count > 0 ? double.parse((totalScore / count).toStringAsFixed(1)) : 0.0;

    if (_firestore != null) {
      try {
        await _firestore!.collection('PHONG_TRO').doc(finalReview.maPhong).update({
          'DiemDanhGiaTB': avgScore,
          'CountLuotDanhGia': count,
        });
      } catch (e) {
        debugPrint('Error updating room rating in firestore: $e');
      }
    }

    if (roomProvider != null) {
      roomProvider.updateRoomRating(finalReview.maPhong, avgScore, count);
    }

    notifyListeners();
    return true;
  }

  /// Từ chối yêu cầu thuê (Nhập lý do bắt buộc)
  Future<bool> rejectRentalRequest(String requestId, String reason) async {
    if (reason.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập lý do từ chối cụ thể';
      return false;
    }
    final index = _rentalRequests.indexWhere((r) => r.maYeuCau == requestId);
    if (index != -1) {
      final old = _rentalRequests[index];
      _rentalRequests[index] = RentalRequestEntity(
        maYeuCau: old.maYeuCau,
        maSV: old.maSV,
        tenSV: old.tenSV,
        maChuTro: old.maChuTro,
        maPhong: old.maPhong,
        ngayMuonVaoO: old.ngayMuonVaoO,
        thoiHanThue: old.thoiHanThue,
        soNguoiO: old.soNguoiO,
        ghiChu: old.ghiChu,
        trangThai: 'TU_CHOI',
        ngayTao: old.ngayTao,
        lyDoTuChoi: reason.trim(),
      );

      if (_firestore != null) {
        try {
          await _firestore!.collection('YeuCauThue').doc(requestId).update({
            'TrangThai': 'TU_CHOI',
            'LyDoTuChoi': reason.trim(),
          });
        } catch (e) {
          debugPrint('Error updating request status in firestore: $e');
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Hủy yêu cầu thuê (Do Sinh viên thực hiện)
  Future<bool> cancelRentalRequest(String requestId) async {
    final index = _rentalRequests.indexWhere((r) => r.maYeuCau == requestId);
    if (index != -1) {
      final old = _rentalRequests[index];
      _rentalRequests[index] = RentalRequestEntity(
        maYeuCau: old.maYeuCau,
        maSV: old.maSV,
        tenSV: old.tenSV,
        maChuTro: old.maChuTro,
        maPhong: old.maPhong,
        ngayMuonVaoO: old.ngayMuonVaoO,
        thoiHanThue: old.thoiHanThue,
        soNguoiO: old.soNguoiO,
        ghiChu: old.ghiChu,
        trangThai: 'DA_HUY',
        ngayTao: old.ngayTao,
      );

      if (_firestore != null) {
        try {
          await _firestore!.collection('YeuCauThue').doc(requestId).update({
            'TrangThai': 'DA_HUY',
          });
        } catch (e) {
          debugPrint('Error updating request status in firestore: $e');
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Kiểm tra Sinh viên đã có phiếu yêu cầu thuê đang hoạt động (Chờ xử lý / Đã chấp nhận) cho phòng này chưa
  bool hasActiveRequestForRoom({
    required String studentId,
    required String studentName,
    required String roomId,
  }) {
    final targetCode = CodeGeneratorUtil.formatRoomDisplayCode(roomId);
    return _rentalRequests.any((r) {
      final rCode = CodeGeneratorUtil.formatRoomDisplayCode(r.maPhong);
      final isSameRoom = (r.maPhong == roomId) || (rCode == targetCode);
      final isSameStudent = (studentId.isNotEmpty && r.maSV == studentId) ||
          r.maSV == 'SV_CURRENT' ||
          (studentName.isNotEmpty && r.tenSV == studentName);
      final isActiveStatus = r.trangThai == 'CHO_XU_LY' ||
          r.trangThai == 'CHO_THANH_TOAN' ||
          r.trangThai == 'DA_CHAP_NHAN';
      return isSameRoom && isSameStudent && isActiveStatus;
    });
  }

  /// Xử lý hoàn tất cọc thành công (Sinh mã hợp đồng chuẩn, bỏ tự động review giả)
  Future<bool> completeDeposit({
    required String requestId,
    required String roomId,
    required String studentId,
    required String studentName,
    double depositAmount = 3000000,
    String paymentMethod = 'VNPAY',
  }) async {
    final index = _rentalRequests.indexWhere((r) => r.maYeuCau == requestId);
    if (index != -1) {
      final old = _rentalRequests[index];
      _rentalRequests[index] = RentalRequestEntity(
        maYeuCau: old.maYeuCau,
        maSV: old.maSV,
        tenSV: old.tenSV,
        maChuTro: old.maChuTro,
        maPhong: old.maPhong,
        ngayMuonVaoO: old.ngayMuonVaoO,
        thoiHanThue: old.thoiHanThue,
        soNguoiO: old.soNguoiO,
        ghiChu: old.ghiChu,
        trangThai: 'DA_COC',
        ngayTao: old.ngayTao,
      );

      final now = DateTime.now();
      final landlordId = old.maChuTro ?? 'LANDLORD';

      // 1. Tạo Hợp đồng điện tử mới (Mã chuẩn HD-YYYYMMDD-XXX)
      final contractCode = CodeGeneratorUtil.generateContractCode();
      final newContract = ContractEntity(
        maHopDong: contractCode,
        maYeuCau: requestId,
        maPhong: roomId,
        maSV: studentId.isNotEmpty ? studentId : old.maSV,
        maChuTro: landlordId,
        ngayBatDau: old.ngayMuonVaoO,
        ngayKetThuc: old.ngayMuonVaoO.add(Duration(days: 30 * old.thoiHanThue)),
        giaThueHangThang: depositAmount,
        tienCoc: depositAmount,
        trangThai: 'HIEU_LUC',
      );
      _contracts.insert(0, newContract);

      // 2. Tạo Giao dịch cọc mới (Mã chuẩn TXN-YYYYMMDD-XXX)
      final txnCode = CodeGeneratorUtil.generateTransactionCode();
      final newTxn = DepositTransactionEntity(
        maGiaoDich: txnCode,
        maYeuCau: requestId,
        soTienCoc: depositAmount,
        phuongThuc: paymentMethod,
        trangThai: 'THANH_CONG',
        ngayGiaoDich: now,
      );
      _transactions.insert(0, newTxn);

      // 3. Tạo thông báo mới cho Chủ trọ
      final cleanStudentName = (studentName.trim().isNotEmpty && !studentName.startsWith('SV'))
          ? studentName
          : 'Sinh viên 1';
      final displayRoomCode = CodeGeneratorUtil.formatRoomDisplayCode(roomId);

      final notifCode = CodeGeneratorUtil.generateNotificationCode();
      final newNotif = NotificationEntity(
        maThongBao: notifCode,
        maNguoiNhan: landlordId,
        tieuDe: 'Đặt cọc giữ chỗ thành công',
        noiDung: '$cleanStudentName đã thanh toán tiền cọc thành công cho phòng trọ mã #$displayRoomCode. Hợp đồng điện tử mã #$contractCode đã được khởi tạo.',
        loaiThongBao: 'COC_THANH_CONG',
        thoiGian: now,
        isDaDoc: false,
        maLienQuan: requestId,
      );
      _notifications.insert(0, newNotif);
      _syncNotificationCount();

      if (_firestore != null) {
        try {
          await _firestore!.collection('YeuCauThue').doc(requestId).update({
            'TrangThai': 'DA_COC',
          });

          await _firestore!.collection('HOP_DONG').doc(newContract.maHopDong).set({
            'MaHopDong': newContract.maHopDong,
            'MaYeuCau': newContract.maYeuCau,
            'MaPhong': newContract.maPhong,
            'MaSV': newContract.maSV,
            'MaChuTro': newContract.maChuTro,
            'NgayBatDau': Timestamp.fromDate(newContract.ngayBatDau),
            'NgayKetThuc': Timestamp.fromDate(newContract.ngayKetThuc),
            'GiaThueHangThang': newContract.giaThueHangThang,
            'TienCoc': newContract.tienCoc,
            'TrangThai': newContract.trangThai,
          });

          await _firestore!.collection('GIAO_DICH_DAT_COC').doc(newTxn.maGiaoDich).set({
            'MaGiaoDich': newTxn.maGiaoDich,
            'MaYeuCau': newTxn.maYeuCau,
            'SoTienCoc': newTxn.soTienCoc,
            'PhuongThuc': newTxn.phuongThuc,
            'TrangThai': newTxn.trangThai,
            'NgayGiaoDich': Timestamp.fromDate(newTxn.ngayGiaoDich),
          });

          await _firestore!.collection('PHONG_TRO').doc(roomId).update({
            'TrangThaiThue': 'DA_CHO_THUE',
          });
        } catch (e) {
          debugPrint('Error updating deposit status in firestore: $e');
        }
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Xác nhận trả phòng / Đăng lại phòng (Chuyển Hợp đồng về DA_THANH_LY & Giải phóng cọc cũ)
  Future<bool> terminateContractAndRelistRoom(String roomId, String landlordId) async {
    // 1. Cập nhật Hợp đồng sang DA_THANH_LY
    for (int i = 0; i < _contracts.length; i++) {
      if (_contracts[i].maPhong == roomId && _contracts[i].trangThai == 'HIEU_LUC') {
        final oldC = _contracts[i];
        _contracts[i] = ContractEntity(
          maHopDong: oldC.maHopDong,
          maYeuCau: oldC.maYeuCau,
          maPhong: oldC.maPhong,
          maSV: oldC.maSV,
          maChuTro: oldC.maChuTro,
          ngayBatDau: oldC.ngayBatDau,
          ngayKetThuc: oldC.ngayKetThuc,
          giaThueHangThang: oldC.giaThueHangThang,
          tienCoc: oldC.tienCoc,
          trangThai: 'DA_THANH_LY',
        );

        if (_firestore != null) {
          try {
            await _firestore!.collection('HOP_DONG').doc(oldC.maHopDong).update({
              'TrangThai': 'DA_THANH_LY',
            });
          } catch (e) {
            debugPrint('Error updating contract status to DA_THANH_LY: $e');
          }
        }
      }
    }

    // 2. Cập nhật các phiếu yêu cầu cũ liên quan sang DA_THANH_LY
    for (int i = 0; i < _rentalRequests.length; i++) {
      if (_rentalRequests[i].maPhong == roomId &&
          (_rentalRequests[i].trangThai == 'DA_COC' ||
           _rentalRequests[i].trangThai == 'CHO_THANH_TOAN' ||
           _rentalRequests[i].trangThai == 'DA_CHAP_NHAN')) {
        final oldR = _rentalRequests[i];
        _rentalRequests[i] = RentalRequestEntity(
          maYeuCau: oldR.maYeuCau,
          maSV: oldR.maSV,
          tenSV: oldR.tenSV,
          maChuTro: oldR.maChuTro,
          maPhong: oldR.maPhong,
          ngayMuonVaoO: oldR.ngayMuonVaoO,
          thoiHanThue: oldR.thoiHanThue,
          soNguoiO: oldR.soNguoiO,
          ghiChu: oldR.ghiChu,
          trangThai: 'DA_THANH_LY',
          ngayTao: oldR.ngayTao,
          lyDoTuChoi: oldR.lyDoTuChoi,
        );

        if (_firestore != null) {
          try {
            await _firestore!.collection('YeuCauThue').doc(oldR.maYeuCau).update({
              'TrangThai': 'DA_THANH_LY',
            });
          } catch (e) {
            debugPrint('Error updating request status to DA_THANH_LY: $e');
          }
        }
      }
    }

    // 3. Chuyển trạng thái phòng về CON_TRONG
    if (_firestore != null) {
      try {
        await _firestore!.collection('PHONG_TRO').doc(roomId).update({
          'TrangThaiThue': 'CON_TRONG',
        });
      } catch (e) {
        debugPrint('Error updating room status to CON_TRONG: $e');
      }
    }

    notifyListeners();
    return true;
  }

  /// Kiểm tra Sinh viên đã cọc thuê thành công phòng trọ này và hợp đồng còn HIEU_LUC hay chưa
  bool hasDepositedRoom({
    required String studentId,
    required String studentName,
    required String roomId,
  }) {
    final targetCode = CodeGeneratorUtil.formatRoomDisplayCode(roomId);
    return _rentalRequests.any((r) {
      final rCode = CodeGeneratorUtil.formatRoomDisplayCode(r.maPhong);
      final isSameRoom = (r.maPhong == roomId) || (rCode == targetCode);
      final isSameStudent = (studentId.isNotEmpty && r.maSV == studentId) ||
          r.maSV == 'SV_CURRENT' ||
          (studentName.isNotEmpty && r.tenSV == studentName);
      final isDeposited = r.trangThai == 'DA_COC';
      if (!isSameRoom || !isSameStudent || !isDeposited) return false;

      // Chỉ tính nếu hợp đồng vẫn đang HIEU_LUC
      final hasActiveContract = _contracts.any((c) =>
          (c.maPhong == roomId || CodeGeneratorUtil.formatRoomDisplayCode(c.maPhong) == targetCode) &&
          c.trangThai == 'HIEU_LUC');
      return hasActiveContract;
    });
  }

  /// Đánh dấu tất cả thông báo là đã đọc (đồng bộ Firestore + Riverpod app state)
  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((n) => NotificationEntity(
              maThongBao: n.maThongBao,
              maNguoiNhan: n.maNguoiNhan,
              tieuDe: n.tieuDe,
              noiDung: n.noiDung,
              loaiThongBao: n.loaiThongBao,
              thoiGian: n.thoiGian,
              isDaDoc: true,
              maLienQuan: n.maLienQuan,
            ))
        .toList();
    _syncNotificationCount();
    notifyListeners();

    if (_firestore != null) {
      try {
        for (var notif in _notifications) {
          _firestore!
              .collection('THONG_BAO')
              .doc(notif.maThongBao)
              .update({'IsDaDoc': true});
        }
      } catch (e) {
        debugPrint('Error updating IsDaDoc in firestore: $e');
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
