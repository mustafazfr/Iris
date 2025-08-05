import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- GEREKLİ IMPORT'LARI EKLEDİĞİNİZDEN EMİN OLUN ---
import 'package:denemeye_devam/features/auth/screens/home_page.dart'; // Örnek yol
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:denemeye_devam/features/common/widgets/my_button.dart';
import 'package:denemeye_devam/features/common/widgets/custom_text_field.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // Font dosyanızı import edin
// Giriş sayfası import'u (varsayımsal)
// import 'package:denemeye_devam/features/auth/screens/login_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Görsele uygun olarak Ad ve Soyad için tek bir controller kullanıyoruz.
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitRegisterForm() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm alanlar doldurulmalıdır.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ad Soyad ayrıştırma
    if (!fullName.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen adınızı ve soyadınızı giriniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameParts = fullName.split(' ');
    final name = nameParts.first;
    final surname = nameParts.sublist(1).join(' ');


    FocusScope.of(context).unfocus();

    try {
      await authViewModel.signUp(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Lütfen e-postanıza gönderilen doğrulama linkine tıklayın.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Etiket ve Metin Alanı oluşturan yardımcı bir metot
  Widget _buildTextField(
      {required String label,
        required TextEditingController controller,
        required FocusNode focusNode,
        String hintText = '',
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodySmall(color: AppColors.textColorDark),
        ),
        const SizedBox(height: 8),
        CustomTextField( // Mevcut CustomTextField widget'ınızı kullanıyoruz
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          isFocused: focusNode.hasFocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          // Görselde prefix icon olmadığı için bu parametreleri kaldırıyoruz
          // prefixIcon: ...,
          // labelText: ...,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // TODO: Buraya kendi logo widget'ınızı ekleyin
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/iris_logo.jpg', height: 80),
                ),

                const SizedBox(height: 10),
                Text(
                  'Kayıt Ol',
                  textAlign: TextAlign.start,
                  style: AppFonts.h1Bold(color: AppColors.primaryColor),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Zaten bir hesabın var mı? '),
                        TextSpan(
                          text: 'Giriş Yap',
                          style: AppFonts.bodyMedium(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Giriş Yap sayfasına yönlendirme ekleyin
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomePage()),
                              );
                              print("Giriş Yap tıklandı!");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'İsim Soyisim',
                  controller: _fullNameController,
                  focusNode: _fullNameFocusNode,
                  hintText: 'John Doe',
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'E-posta',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  hintText: 'johndoe@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  label: 'Şifre',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: '••••••••••••••••',
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                Container(
                  height: 48,
                  child : MyCustomButton(
                    onPressed: _submitRegisterForm,
                    buttonText: 'Kayıt Ol',

                    // Butonunuzun stilini buradan ayarlayabilirsiniz
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Google ile devam et',
                        style: AppFonts.bodySmall(color: AppColors.textSecondary),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  // TODO: Google ile giriş fonksiyonunu buraya bağlayın
                  print('Google ile giriş yapılıyor...');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none, // Buton çevresini kaldırır
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Sütunun minimum yer kaplamasını sağlar
                  children: [
                    Image.asset('assets/google_logo.png', height: 40),
                    const SizedBox(height: 8), // Logo ile yazı arasına boşluk bırakır
                    Text(
                      'Google',
                      style: AppFonts.bodyMedium(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
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