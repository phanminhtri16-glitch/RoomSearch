class CodeGeneratorUtil {
  static String _formatDatePrefix() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static int _roomSeqCounter = 1;
  static int _msgSeqCounter = 1;
  static int _studentSeqCounter = 1;
  static int _landlordSeqCounter = 1;
  static int _adminSeqCounter = 1;
  static int _contractSeqCounter = 1;
  static int _requestSeqCounter = 1;
  static int _txnSeqCounter = 1;
  static int _reviewSeqCounter = 1;
  static int _notifSeqCounter = 1;
  static int _reportSeqCounter = 1;

  static String _formatSeq(int seq) => seq.toString().padLeft(3, '0');

  /// Mã tin nhắn quy tắc: TN-YYYYMMDD-001
  static String generateMessageCode() {
    return 'TN-${_formatDatePrefix()}-${_formatSeq(_msgSeqCounter++)}';
  }

  /// Mã sinh viên: SV-YYYYMMDD-001
  static String generateStudentCode() {
    return 'SV-${_formatDatePrefix()}-${_formatSeq(_studentSeqCounter++)}';
  }

  /// Mã chủ trọ: CT-YYYYMMDD-001
  static String generateLandlordCode() {
    return 'CT-${_formatDatePrefix()}-${_formatSeq(_landlordSeqCounter++)}';
  }

  /// Mã admin: AD-YYYYMMDD-001
  static String generateAdminCode() {
    return 'AD-${_formatDatePrefix()}-${_formatSeq(_adminSeqCounter++)}';
  }

  /// Chuyển đổi tên Quận/Huyện sang Mã tiền tố quy tắc
  static String getDistrictPrefix(String? district) {
    if (district == null || district.trim().isEmpty) return 'PT';
    final d = district.toLowerCase();
    if (d.contains('cầu giấy')) return 'CG';
    if (d.contains('đống đa')) return 'DD';
    if (d.contains('ba đình')) return 'BD';
    if (d.contains('thanh xuân')) return 'TX';
    if (d.contains('hai bà trưng')) return 'HBT';
    if (d.contains('hoàng mai')) return 'HM';
    if (d.contains('nam từ liêm')) return 'NTL';
    if (d.contains('bắc từ liêm')) return 'BTL';
    if (d.contains('tây hồ')) return 'TH';
    if (d.contains('long biên')) return 'LB';
    if (d.contains('hà đông')) return 'HD';
    if (d.contains('quận 1') || d.contains('q1')) return 'Q1';
    if (d.contains('quận 3') || d.contains('q3')) return 'Q3';
    if (d.contains('quận 5') || d.contains('q5')) return 'Q5';
    if (d.contains('quận 7') || d.contains('q7')) return 'Q7';
    if (d.contains('quận 10') || d.contains('q10')) return 'Q10';
    if (d.contains('bình thạnh')) return 'BTH';
    if (d.contains('thủ đức')) return 'TD';
    if (d.contains('tân bình')) return 'TB';
    if (d.contains('gò vấp')) return 'GV';
    return 'PT';
  }

  /// Mã phòng trọ theo quy tắc: P-[MÃ_QUẬN]-[YYYYMMDD]-[MÃ_STT_TĂNG_DẦN]
  /// Ví dụ: P-CG-20260808-001 (Quận Cầu Giấy), P-Q7-20260808-002 (Quận 7)
  static String generateRoomCode({String? district, int? customSeq}) {
    final prefix = getDistrictPrefix(district);
    final datePrefix = _formatDatePrefix();
    final seq = customSeq ?? (_roomSeqCounter++);
    final seqStr = _formatSeq(seq);
    return 'P-$prefix-$datePrefix-$seqStr';
  }

  /// Chuyển đổi mã phòng thô (như Firestore doc ID 1CQJugggp8fkEPPnUsC) thành mã phòng chuẩn quy tắc
  /// Ví dụ: "1CQJugggp8fkEPPnUsC" -> "P-PT-20260808-015"
  static String formatRoomDisplayCode(String rawRoomId, {String? district}) {
    final clean = rawRoomId.trim();
    if (clean.isEmpty) return 'P-PT-${_formatDatePrefix()}-001';
    if (clean.startsWith('P-')) return clean;

    final prefix = getDistrictPrefix(district);
    final datePrefix = _formatDatePrefix();

    int seq = 1;
    final match = RegExp(r'(\d+)$').firstMatch(clean);
    if (match != null) {
      seq = int.tryParse(match.group(1)!) ?? 1;
    } else {
      seq = (clean.hashCode.abs() % 900) + 1;
    }

    return 'P-$prefix-$datePrefix-${_formatSeq(seq)}';
  }

  /// Mã hợp đồng: HD-YYYYMMDD-001
  static String generateContractCode() {
    return 'HD-${_formatDatePrefix()}-${_formatSeq(_contractSeqCounter++)}';
  }

  /// Chuyển đổi mã hợp đồng thô (như HD_178590615276) thành mã hợp đồng chuẩn quy tắc HD-YYYYMMDD-001
  static String formatContractDisplayCode(String rawContractId) {
    final clean = rawContractId.trim();
    if (clean.isEmpty) return 'HD-${_formatDatePrefix()}-001';
    if (clean.startsWith('HD-') && clean.contains('-2026')) return clean;

    final match = RegExp(r'(\d+)$').firstMatch(clean);
    int seq = 1;
    if (match != null) {
      seq = int.tryParse(match.group(1)!) ?? 1;
    } else {
      seq = (clean.hashCode.abs() % 900) + 1;
    }
    return 'HD-${_formatDatePrefix()}-${_formatSeq(seq)}';
  }

  /// Chuyển đổi mã sinh viên thô (như Firebase Auth UID NjdS5rlfaberKPoQ9xql) thành tên sinh viên quy tắc chuẩn (Sinh viên 1, Sinh viên 2)
  static String formatStudentDisplayCode(String rawStudentId) {
    final clean = rawStudentId.trim();
    if (clean.isEmpty) return 'Sinh viên 1';
    if (clean.startsWith('Sinh viên')) {
      if (clean.contains('72')) return 'Sinh viên 1';
      return clean;
    }

    final match = RegExp(r'(\d+)$').firstMatch(clean);
    int seq = 1;
    if (match != null) {
      seq = int.tryParse(match.group(1)!) ?? 1;
      if (seq > 10) seq = 1;
    } else {
      seq = (clean.hashCode.abs() % 2) + 1;
    }
    return 'Sinh viên $seq';
  }

  /// Mã phiếu yêu cầu thuê: YC-YYYYMMDD-001
  static String generateRequestCode() {
    return 'YC-${_formatDatePrefix()}-${_formatSeq(_requestSeqCounter++)}';
  }

  /// Mã giao dịch đặt cọc: TXN-YYYYMMDD-001
  static String generateTransactionCode() {
    return 'TXN-${_formatDatePrefix()}-${_formatSeq(_txnSeqCounter++)}';
  }

  /// Mã bài đánh giá: DG-YYYYMMDD-001
  static String generateReviewCode() {
    return 'DG-${_formatDatePrefix()}-${_formatSeq(_reviewSeqCounter++)}';
  }

  /// Mã thông báo: TB-YYYYMMDD-001
  static String generateNotificationCode() {
    return 'TB-${_formatDatePrefix()}-${_formatSeq(_notifSeqCounter++)}';
  }

  /// Mã báo cáo: BC-YYYYMMDD-001
  static String generateReportCode() {
    return 'BC-${_formatDatePrefix()}-${_formatSeq(_reportSeqCounter++)}';
  }
}
