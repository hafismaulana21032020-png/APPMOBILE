import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../cart/domain/services/cart_service.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_nav_helper.dart';
import '../../domain/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final user = UserService.instance;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _birthDateController = TextEditingController(text: user.birthDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onSelectBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(2000, 5, 18);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBrown,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (pickedDate != null) {
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final formatted =
          '${pickedDate.day} ${months[pickedDate.month - 1]} ${pickedDate.year}';
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  void _onChangePhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined,
                      color: AppColors.primaryBrown),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka kamera...'),
                        backgroundColor: AppColors.primaryBrown,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primaryBrown),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka galeri...'),
                        backgroundColor: AppColors.primaryBrown,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSaveProfile() {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Email tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!AppValidators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    UserService.instance.updateProfile(
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan profil berhasil disimpan!'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.inputBorderColor,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: Icon(
                prefixIcon,
                size: 20,
                color: AppColors.secondaryText,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: suffixIcon,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserService.instance, CartService.instance]),
      builder: (context, _) {
        final user = UserService.instance;
        final cartCount = CartService.instance.totalItemCount;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Bar (Back button + Profil Akun)
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.inputBorderColor,
                            width: 1.0,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.darkText,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Profil Akun',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Top Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.inputBorderColor,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar dengan badge kamera
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1EAE4),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5D4037),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _onChangePhoto,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBrown,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Nama, Badge & Ubah Foto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7EFE6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.memberBadge,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _onChangePhoto,
                                child: const Text(
                                  'Ubah foto profil',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section Title: Informasi pribadi
                  const Text(
                    'Informasi pribadi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pastikan datamu selalu terbaru.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  _buildFormField(
                    label: 'Nama lengkap',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Color(0xFF0F9D58),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormField(
                    label: 'Nomor telepon',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildFormField(
                    label: 'Tanggal lahir',
                    controller: _birthDateController,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _onSelectBirthDate,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Verification Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: Color(0xFF0F9D58),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Email terverifikasi. Data pribadimu tersimpan aman dan tidak ditampilkan ke pengguna lain.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF2E6A4F),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Simpan perubahan Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onSaveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Simpan perubahan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          bottomNavigationBar: HomeBottomNavBar(
            currentIndex: 3,
            orderBadgeCount: cartCount,
            onTap: (index) => handleSecondaryBottomNavTap(
              context,
              index,
              currentIndex: 3,
              popOnCurrent: true,
            ),
          ),
        );
      },
    );
  }
}

