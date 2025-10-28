import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // CLIPPER BAWAH
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: FooterClipper(),
              child: Container(
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ISI KONTEN
          SafeArea(
            child: SingleChildScrollView( // <-- Tambahkan SingleChildScrollView
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Back
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.only(top: 10, right: 100),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 40),

                  // Judul
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Masukkan email dan password baru Anda. Pastikan konfirmasi password sesuai.",
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 30),

                  // Form Input
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            errorStyle: const TextStyle(fontSize: 12, height: 2, color: Colors.red),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!RegExp(r'^[\w\.\-]+@gmail\.com$').hasMatch(value)) {
                              return "Format email tidak valid (@gmail.com)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Baru dengan toggle mata
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: !showNewPassword,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Password Baru",
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            errorStyle: const TextStyle(fontSize: 12, height: 2, color: Colors.red),
                            suffixIcon: IconButton(
                              icon: Icon(showNewPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  showNewPassword = !showNewPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Password wajib diisi";
                            if (value.length < 8) return "Password minimal 8 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Konfirmasi Password dengan toggle mata
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !showConfirmPassword,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Konfirmasi Password",
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            errorStyle: const TextStyle(fontSize: 12, height: 2, color: Colors.red),
                            suffixIcon: IconButton(
                              icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value != newPasswordController.text) return "Password tidak sama";
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Reset Password
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF48FB1), Color(0xFF7E57C2)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => isLoading = true);
                                        try {
                                          await AuthService().resetPassword(
                                            emailController.text.trim(),
                                            newPasswordController.text.trim(),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Password berhasil diubah!"),
                                              backgroundColor: Colors.purple,
                                            ),
                                          );
                                          Navigator.pop(context);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          setState(() => isLoading = false);
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Reset Password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}

// CLIPPER BAGIAN BAWAH
class FooterClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 100, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}