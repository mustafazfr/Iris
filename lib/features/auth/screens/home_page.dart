import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- GEREKLİ IMPORT'LARI EKLEDİĞİNİZDEN EMİN OLUN ---
import 'package:denemeye_devam/features/auth/screens/register_page.dart';
import 'package:denemeye_devam/features/common/widgets/custom_text_field.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await authViewModel.signIn(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField(
      {required String label,
        required TextEditingController controller,
        required FocusNode focusNode,
        Widget? suffixIcon,
        String hintText = '',
        bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodySmall(color: AppColors.textColorDark),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          isFocused: focusNode.hasFocus,
          obscureText: obscureText,
          keyboardType: label == 'E-posta' ? TextInputType.emailAddress : TextInputType.text,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // --- DEĞİŞİKLİK BURADA BAŞLIYOR ---
        // Tüm kaydırılabilir alanı bir Center widget'ı ile sarmalıyoruz.
        // Bu, içerik ekrandan kısaysa onu dikeyde ortalar.
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              // mainAxisAlignment.center'ı buraya da ekleyebiliriz ancak
              // dıştaki Center bu işi zaten yapıyor.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Logo
                Image.asset('assets/iris_logo.jpg', height: 80),
                const SizedBox(height: 22),

                // Başlık
                Text(
                  'Seni yeniden görmek güzel!',
                  style: AppFonts.h3Bold(color: AppColors.textColorDark),
                ),
                const SizedBox(height: 0),

                // Kayıt Ol Yönlendirmesi
                RichText(
                  text: TextSpan(
                    style: AppFonts.h6Regular(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Hesabın yok mu ? '),
                      TextSpan(
                        text: 'Kayıt Ol',
                        style: AppFonts.bodyMedium(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Alanları
                _buildTextField(
                  label: 'E-posta',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Şifre',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    }),
                  ),
                ),
                const SizedBox(height: 32),

                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Giriş Yap', style: AppFonts.h6SemiBold(color: AppColors.textColorDark)),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifremi Unuttum Butonu
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Şifremi unuttum mantığını uygulayın
                    },
                    child: Text(
                      'Şifremi Unuttum',
                      style: AppFonts.bodyMedium(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ayırıcı
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Veya şununla giriş yap',
                        style: AppFonts.bodySmall(color: AppColors.textSecondary),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google ile Giriş
                Center(
                  child: InkWell(
                    onTap: () {
                      // TODO: Google ile giriş mantığını uygulayın
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.asset('assets/google_logo.png', height: 32),
                          const SizedBox(height: 8),
                          Text('Google', style: AppFonts.poppinsBold()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}