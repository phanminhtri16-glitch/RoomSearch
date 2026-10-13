import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _cccdController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _selectedRole = AppConstants.roleStudent;

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _cccdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(1940);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'CHỌN NGÀY SINH (ĐỦ 18 TUỔI TRỞ LÊN)',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
        _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ngày sinh để kiểm tra độ tuổi'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!Validators.isAtLeast18YearsOld(_selectedBirthDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn phải từ 18 tuổi trở lên để đăng ký tài khoản'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        hoTen: _hoTenController.text.trim(),
        email: _emailController.text.trim(),
        soDienThoai: _phoneController.text.trim(),
        password: _passwordController.text,
        vaiTro: _selectedRole,
        ngaySinh: _selectedBirthDate!,
        soCCCD: _selectedRole == AppConstants.roleLandlord
            ? _cccdController.text.trim()
            : null,
        diaChiLienHe: _selectedRole == AppConstants.roleLandlord
            ? _addressController.text.trim()
            : null,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OtpVerificationScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Điền thông tin bên dưới để trải nghiệm ứng dụng',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Role selector
                    const Text(
                      'Bạn là:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Sinh viên',
                            subtitle: 'Tìm trọ',
                            icon: Icons.school_outlined,
                            isSelected: _selectedRole == AppConstants.roleStudent,
                            onTap: () => setState(() => _selectedRole = AppConstants.roleStudent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Chủ trọ',
                            subtitle: 'Đăng tin',
                            icon: Icons.home_work_outlined,
                            isSelected: _selectedRole == AppConstants.roleLandlord,
                            onTap: () => setState(() => _selectedRole = AppConstants.roleLandlord),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Full name
                    CustomTextField(
                      label: 'Họ và tên',
                      hint: 'Nhập đầy đủ họ và tên',
                      controller: _hoTenController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.validateFullName,
                    ),

                    // Email
                    CustomTextField(
                      label: 'Địa chỉ Email',
                      hint: 'nguyenvana@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),

                    // Phone
                    CustomTextField(
                      label: 'Số điện thoại',
                      hint: '0912345678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: Validators.validatePhone,
                    ),

                    // Birth date
                    CustomTextField(
                      label: 'Ngày sinh (Người dùng >= 18 tuổi)',
                      hint: 'Chọn ngày/tháng/năm sinh',
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectBirthDate(context),
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: (_) => Validators.validateBirthDate(_selectedBirthDate),
                    ),

                    // Password
                    CustomTextField(
                      label: 'Mật khẩu',
                      hint: 'Tối thiểu 6 ký tự',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.validatePassword,
                    ),

                    if (_selectedRole == AppConstants.roleLandlord) ...[
                      CustomTextField(
                        label: 'Số giấy tờ CCCD / Xác minh',
                        hint: 'Ví dụ: 001200123456',
                        controller: _cccdController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập số giấy tờ CCCD/xác minh';
                          }
                          if (val.trim().length < 9 || val.trim().length > 12) {
                            return 'Số CCCD/CMND không hợp lệ (9 - 12 chữ số)';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: 'Địa chỉ liên hệ chính thức',
                        hint: 'Nhập địa chỉ nhà / văn phòng của Chủ trọ',
                        controller: _addressController,
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập địa chỉ liên hệ của Chủ trọ';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    CustomButton(
                      text: 'Tiếp tục (Nhận mã OTP)',
                      width: double.infinity,
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã có tài khoản? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                AppGradients.primary.createShader(bounds),
                            child: const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primary : null,
                color: isSelected ? null : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}
