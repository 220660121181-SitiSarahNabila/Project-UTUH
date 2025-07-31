import 'package:ulin_atuhfront/services/api_service.dart'; // Sesuaikan path
import 'package:provider/provider.dart';
import 'package:ulin_atuhfront/providers/user_provider.dart'; // Sesuaikan path
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ulin_atuhfront/models/user_model.dart'; // Sesuaikan path

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State <LoginPage>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  } 

  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Email tidak boleh kosong');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      Fluttertoast.showToast(msg: 'Masukkan email yang valid');
      return false;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(msg: 'Kata sandi tidak boleh kosong');
      return false;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: 'Kata sandi minimal 6 karakter');
      return false;
    }
    return true; // Placeholder
  }

  void prosesLogin() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Pengecekan 'mounted' penting untuk menghindari error jika user meninggalkan halaman saat proses login
      if (!mounted) return;

      if (response['statusCode'] == 200) {
        final userData = response['data']; 
        
        // PERBAIKAN PENTING: Hentikan proses jika data pengguna null
        if (userData == null) {
          Fluttertoast.showToast(msg: 'Data pengguna tidak ditemukan dari server.');
          // Jangan lupa set _isLoading ke false di sini
          setState(() => _isLoading = false); 
          return; 
        }
        
        // Pastikan userData adalah Map sebelum memanggil fromJson
        if (userData is Map<String, dynamic>) {
          final UserModel loggedInUser = UserModel.fromJson(userData);

          // Panggil UserProvider untuk menyimpan data pengguna
          Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);

          Fluttertoast.showToast(msg: 'Login berhasil');
          
          // Navigasi ke HomePage
          Navigator.pushReplacementNamed(context, '/home');
        } else {
           Fluttertoast.showToast(msg: 'Format data pengguna dari server tidak valid.');
        }

      } else {
        // Tampilkan pesan error dari API
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Login gagal. Silakan coba lagi.', 
        );
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = const Color(0xFF4399CD);
    final lightBlueGradient = LinearGradient(
      colors: [const Color(0xFF5EA1D6), const Color(0xFF2F7DBD)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: blueColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset('assets/images/logo.png'), // Pastikan path asset benar
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [ BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4),),],
                ),
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Masuk Akun', style: TextStyle(color: blueColor, fontFamily: "Poppins", fontWeight: FontWeight.w800, fontSize: 24)),
                    const SizedBox(height: 24),
                    
                    // Email Field
                    Align(alignment: Alignment.centerLeft, child: Text('Email', style: TextStyle(color: Colors.grey[700], fontFamily: "Poppins", fontWeight: FontWeight.w600))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Email',
                        // --- TAMBAHKAN IKON DI SINI ---
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        // -----------------------------
                        filled: true, fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    Align(alignment: Alignment.centerLeft, child: Text('Kata Sandi', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontFamily: "Poppins"))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, 
                      decoration: InputDecoration(
                        hintText: 'Masukkan Kata Sandi',
                        // --- TAMBAHKAN IKON DI SINI ---
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        // -----------------------------
                        filled: true, fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); },
                        ),
                      ),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _isLoading ? null : prosesLogin, 
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(gradient: lightBlueGradient, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0xFF2F7DBD), offset: Offset(0, 4), blurRadius: 4)]),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('LOGIN', style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                        ),
                      ),
                    ),

                    // Tombol Daftar
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        children: <TextSpan>[
                          const TextSpan(text: 'Belum punya akun? '),
                          TextSpan(
                            text: 'Daftar di sini',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signup');
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}