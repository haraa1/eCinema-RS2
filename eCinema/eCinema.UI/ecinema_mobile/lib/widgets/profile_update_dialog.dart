import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class ProfileUpdateDialog extends StatefulWidget {
  const ProfileUpdateDialog({Key? key}) : super(key: key);

  @override
  State<ProfileUpdateDialog> createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneNumberController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  static const List<String> _languages = [
    'English',
    'Bosnian',
    'Croatian',
    'Serbian',
  ];
  String? _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().current;
    _phoneNumberController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    if (user?.preferredLanguage != null &&
        _languages.contains(user!.preferredLanguage)) {
      _selectedLanguage = user.preferredLanguage;
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.current;

    String? currentPassword =
        _currentPasswordController.text.isNotEmpty
            ? _currentPasswordController.text
            : null;
    String? newPassword =
        _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null;
    String? confirmNewPassword =
        _confirmNewPasswordController.text.isNotEmpty
            ? _confirmNewPasswordController.text
            : null;
    String? phoneNumber = _phoneNumberController.text;
    String? preferredLanguage = _selectedLanguage;

    if (preferredLanguage == currentUser?.preferredLanguage) {
      preferredLanguage = null;
    }
    if (phoneNumber == currentUser?.phoneNumber) {
      phoneNumber = null;
    }

    try {
      await userProvider.updateProfile(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil uspješno ažuriran!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška: ${e.toString()}')));
      }
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
    final currentUser = context.watch<UserProvider>().current;
    if (currentUser == null) {
      return const AlertDialog(
        title: Text("Greška"),
        content: Text("Korisnik nije prijavljen."),
      );
    }

    return AlertDialog(
      title: const Text('Ažuriraj Profil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Broj telefona'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Text(
                "Promjena lozinke (opcionalno)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Trenutna lozinka',
                ),
                obscureText: true,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nova lozinka'),
                obscureText: true,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      _currentPasswordController.text.isEmpty) {
                    return 'Unesite trenutnu lozinku.';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Lozinka mora imati barem 6 karaktera.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Potvrdi novu lozinku',
                ),
                obscureText: true,
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return 'Lozinke se ne podudaraju.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Odustani'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Sačuvaj'),
        ),
      ],
    );
  }
}
