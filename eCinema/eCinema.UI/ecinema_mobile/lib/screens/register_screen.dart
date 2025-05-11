import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecinema_mobile/models/user.dart';
import 'package:ecinema_mobile/providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final newUser = User(
      fullName: _fullNameCtrl.text.trim(),
      userName: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      confirmPassword: _confirmPwdCtrl.text,
      phoneNumber: _phoneCtrl.text.trim(),
    );

    try {
      await context.read<UserProvider>().register(newUser);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              title: const Text('Uspješno'),
              content: const Text(
                'Registracija uspješna! Molimo prijavite se.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('U redu'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Registracija nije uspjela'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('U redu'),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decor(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.9),
    suffixIcon:
        label.contains('Lozinka')
            ? IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
            : null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _fullNameCtrl,
                      decoration: _decor('Ime i prezime', Icons.person),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Obavezno'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: _decor('Korisničko ime', Icons.person),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Obavezno'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decor('Email', Icons.email),
                      validator:
                          (v) =>
                              (v == null || !v.contains('@'))
                                  ? 'Unesite ispravan email'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: _decor('Lozinka', Icons.lock),
                      validator:
                          (v) =>
                              (v == null || v.length < 6)
                                  ? 'Najmanje 6 znakova'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPwdCtrl,
                      obscureText: _obscure,
                      decoration: _decor('Potvrdi lozinku', Icons.lock),
                      validator:
                          (v) =>
                              v != _passwordCtrl.text
                                  ? 'Lozinke se ne poklapaju'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _decor('Broj telefona', Icons.phone),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _loading ? null : _register,
                        child:
                            _loading
                                ? const CircularProgressIndicator()
                                : const Text('Registruj se'),
                      ),
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
}
