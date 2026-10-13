import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final RoomEntity room;
  final String requestId;

  const PaymentScreen({super.key, required this.room, required this.requestId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String _txnCode;
  int _secondsRemaining = 900;
  Timer? _timer;
  String _selectedMethod = 'VNPAY';

  @override
  void initState() {
    super.initState();
    _txnCode = CodeGeneratorUtil.generateTransactionCode();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Hết hạn giữ chỗ 15 phút'),
              content: const Text(
                'Thời gian 15 phút cọc giữ chỗ đã hết hạn. Yêu cầu thuê phòng đã tự động hủy để nhường quyền ưu tiên cho sinh viên khác.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _processPayment() {
    _showPaymentGatewayPortal();
  }

  void _showPaymentGatewayPortal() {
    final isVnPay = _selectedMethod == 'VNPAY';
    final gatewayName = isVnPay ? 'Cổng thanh toán VNPAY' : 'Ví điện tử MoMo';
    final gatewayColor = isVnPay ? const Color(0xFF005BAA) : const Color(0xFFA50064);
    final depositAmount = widget.room.giaThue;
    final orderId = 'COC_${widget.requestId.length > 8 ? widget.requestId.substring(0, 8) : widget.requestId}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: gatewayColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isVnPay ? Icons.qr_code_scanner_rounded : Icons.account_balance_wallet_rounded,
                          color: gatewayColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gatewayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Cổng thanh toán đối tác chính thức',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Đơn vị chấp nhận:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text('PHÒNG TRỌ ONLINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Mã giao dịch cọc:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(orderId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
                                ],
                              ),
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Số tiền cọc:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  Text(
                                    '${CurrencyFormatter.format(depositAmount)} VNĐ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: gatewayColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          isVnPay
                              ? 'Quét mã QR bằng App VNPay / Ngân hàng'
                              : 'Quét mã QR bằng ứng dụng Ví MoMo',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: gatewayColor.withValues(alpha: 0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 160,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: gatewayColor,
                                      child: Text(
                                        isVnPay ? 'VNP' : 'MM',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Thời hạn quét QR: $_formattedTime',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gatewayColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 18, color: gatewayColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isVnPay
                                      ? 'Mở App Ngân hàng hoặc VNPAY -> Chọn Quét QR -> Quét mã trên'
                                      : 'Mở Ví MoMo -> Chọn Quét Mã -> Quét mã trên để hoàn tất cọc',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: gatewayColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gatewayColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _executeSuccessPayment();
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                          label: Text(
                            'Xác nhận đã thanh toán trên App $gatewayName',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Hủy giao dịch thanh toán',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _executeSuccessPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang xử lý kết quả thanh toán từ Cổng đối tác...',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    final isVnPay = _selectedMethod == 'VNPAY';
    final gatewayName = isVnPay ? 'VNPAY' : 'MoMo';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đặt cọc giữ chỗ thành công!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã giao dịch cọc: $_txnCode',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Cổng thanh toán: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isVnPay ? Colors.blue.withValues(alpha: 0.2) : Colors.pink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gatewayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isVnPay ? Colors.blue : Colors.pink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Số tiền đã thanh toán cọc: ${CurrencyFormatter.format(widget.room.giaThue)} VNĐ (Tương đương 1 tháng thuê)',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hợp đồng điện tử đã khởi tạo!',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Vui lòng kiểm tra Hợp đồng thuê phòng trong mục Tài khoản cá nhân.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () async {
                try {
                  final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
                  final roomProvider = Provider.of<RoomProvider>(context, listen: false);
                  final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

                  await landlordProvider.completeDeposit(
                    requestId: widget.requestId,
                    roomId: widget.room.maPhong,
                    studentId: user?.maTK ?? '',
                    studentName: user?.hoTen ?? '',
                    depositAmount: widget.room.giaThue,
                    paymentMethod: _selectedMethod,
                  );

                  roomProvider.markRoomAsRented(widget.room.maPhong);
                } catch (e) {
                  debugPrint('Error completing deposit: $e');
                }

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Hoàn tất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final depositAmount = widget.room.giaThue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán đặt cọc giữ chỗ'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dynamic Neon Color-Changing Countdown Card ─────────────────────────────
              Builder(
                builder: (context) {
                  Color timerColor;
                  String statusLabel;
                  if (_secondsRemaining > 300) {
                    timerColor = AppColors.success;
                    statusLabel = 'Thời gian cọc ưu tiên giữ phòng (An toàn)';
                  } else if (_secondsRemaining > 120) {
                    timerColor = const Color(0xFFD97706);
                    statusLabel = 'Thời gian cọc sắp hết hạn (Chú ý)';
                  } else {
                    timerColor = AppColors.error;
                    statusLabel = 'Khẩn cấp! Sắp tự động hủy phòng cọc';
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: timerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: timerColor, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: timerColor.withValues(alpha: 0.3),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: timerColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.timer_outlined, color: timerColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: timerColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formattedTime,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: timerColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chi tiết khoản cọc', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(widget.room.tieuDe, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      'Địa chỉ: ${widget.room.diaChi}, ${widget.room.quanHuyen}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiền cọc giữ chỗ (1 tháng):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text(
                          '${depositAmount.toStringAsFixed(0)} VNĐ',
                          style: const TextStyle(fontSize: 16, color: AppColors.primaryLight, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Chọn phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildPaymentOption(
                'VNPAY',
                'Cổng thanh toán VNPay (ATM / Visa / QR Code)',
                Icons.qr_code_scanner_rounded,
                const Color(0xFF005BAA),
                'Thanh toán qua cổng VNPAY QR hoặc Thẻ ngân hàng',
              ),
              const SizedBox(height: 10),
              _buildPaymentOption(
                'MOMO',
                'Ví điện tử MoMo',
                Icons.account_balance_wallet_rounded,
                const Color(0xFFA50064),
                'Thanh toán bằng quét mã Ví MoMo',
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Thanh toán cọc ${depositAmount.toStringAsFixed(0)} VNĐ',
                width: double.infinity,
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String code,
    String label,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final isSelected = _selectedMethod == code;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = code),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? color : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
