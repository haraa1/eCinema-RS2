import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/user.dart';
import 'package:ecinema_desktop/models/role.dart';
import 'package:ecinema_desktop/providers/user_provider.dart';
import 'package:ecinema_desktop/providers/role_provider.dart';
import 'package:flutter/services.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final _userProvider = UserProvider();
  final _roleProvider = RoleProvider();

  List<Role> _roles = [];
  List<int> _selectedRoleIds = [];
  bool _isLoadingRoles = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    _loadRoles().then((_) {
      if (widget.user != null) {
        _usernameController.text = widget.user!.userName ?? "";
        _emailController.text = widget.user!.email ?? "";
        _phoneController.text = widget.user!.phoneNumber ?? "";

        _selectedRoleIds = List<int>.from(widget.user!.roleIds ?? []);
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final result = await _roleProvider.get();
      if (mounted) {
        setState(() {
          _roles = result.result;
          _isLoadingRoles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error loading roles: $e");
        setState(() => _isLoadingRoles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri učitavanju uloga: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Map<String, dynamic> request = {
      "userName": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "roleIds": _selectedRoleIds,
    };

    if (_passwordController.text.isNotEmpty) {
      request["password"] = _passwordController.text;
      request["confirmPassword"] = _confirmPasswordController.text;
    }

    try {
      String successMessage;
      if (!isEditMode) {
        await _userProvider.insert(request);
        successMessage = "Korisnik uspješno dodan.";
      } else {
        await _userProvider.update(widget.user!.id!, request);
        successMessage = "Podaci o korisniku uspješno ažurirani.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri spremanju korisnika: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRoles && _roles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? "Uredi Korisnika" : "Dodaj Korisnika"),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            semanticsLabel: "Učitavanje uloga...",
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Uredi Korisnika" : "Dodaj Korisnika"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: "Korisničko ime",
                controller: _usernameController,
                requiredErrorMsg: "Unesite korisničko ime.",
              ),
              _buildTextField(
                label: "Email adresa",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                requiredErrorMsg: "Unesite email adresu.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Unesite validnu email adresu.';
                  }
                  return null;
                },
              ),

              _buildTextField(
                label:
                    isEditMode
                        ? "Nova lozinka (ostavi prazno ako se ne mijenja)"
                        : "Lozinka",
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
                requiredErrorMsg: isEditMode ? null : "Unesite lozinku.",
                customValidator: (value) {
                  if (isEditMode && (value == null || value.isEmpty))
                    return null;
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Lozinka mora imati najmanje 6 karaktera.';
                  }

                  if (_confirmPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: isEditMode ? "Potvrdi novu lozinku" : "Potvrdi lozinku",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                ),

                requiredErrorMsg:
                    _passwordController.text.isNotEmpty
                        ? "Potvrdite lozinku."
                        : null,
                customValidator: (value) {
                  if (_passwordController.text.isNotEmpty &&
                      value != _passwordController.text) {
                    return 'Lozinke se ne podudaraju.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                label: "Broj telefona (npr. 061123456)",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                requiredErrorMsg: "Unesite broj telefona.",
                customValidator: (value) {
                  if (value == null || value.isEmpty) return null;

                  final phoneRegex = RegExp(r"^(06\d{1})\d{6,7}$");
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Unesite validan broj telefona (npr. 061123456).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                "Uloge korisnika",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _buildRoleSelectionField(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoadingRoles ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditMode ? "Spremi promjene" : "Dodaj korisnika"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? requiredErrorMsg,
    String? Function(String?)? customValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        validator: (value) {
          final val = value?.trim() ?? '';
          if (requiredErrorMsg != null && val.isEmpty) {
            return requiredErrorMsg;
          }
          if (customValidator != null) {
            return customValidator(val);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRoleSelectionField() {
    return FormField<List<int>>(
      initialValue: _selectedRoleIds,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Odaberite barem jednu ulogu.';
        }
        return null;
      },
      builder: (FormFieldState<List<int>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_roles.isEmpty && !_isLoadingRoles)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Nema dostupnih uloga.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ..._roles.map((role) {
              return CheckboxListTile(
                title: Text(role.name ?? "Nepoznata uloga"),
                value: field.value?.contains(role.id) ?? false,
                onChanged:
                    _isLoadingRoles
                        ? null
                        : (bool? selected) {
                          if (role.id == null) return;
                          final currentSelected = List<int>.from(
                            field.value ?? [],
                          );
                          if (selected == true) {
                            currentSelected.add(role.id!);
                          } else {
                            currentSelected.remove(role.id);
                          }
                          field.didChange(currentSelected);
                          setState(() {
                            _selectedRoleIds = currentSelected;
                          });
                        },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }).toList(),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
