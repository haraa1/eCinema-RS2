import 'package:flutter/material.dart';
import 'package:ecinema_desktop/models/user.dart';
import 'package:ecinema_desktop/models/role.dart';
import 'package:ecinema_desktop/providers/user_provider.dart';
import 'package:ecinema_desktop/providers/role_provider.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.userName ?? "";
      _emailController.text = widget.user!.email ?? "";
      _phoneController.text = widget.user!.phoneNumber ?? "";
      _selectedRoleIds = List.from(widget.user!.roleIds ?? []);
    }
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final result = await _roleProvider.get();
    setState(() => _roles = result.result);
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "userName": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "confirmPassword": _confirmPasswordController.text,
      "phoneNumber": _phoneController.text,
      "roleIds": _selectedRoleIds,
    };

    try {
      if (widget.user == null) {
        await _userProvider.insert(request);
      } else {
        await _userProvider.update(widget.user!.id!, request);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving user: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Uredi Korisnika" : "Dodaj Korisnika"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Username", _usernameController),
              _buildField("Email", _emailController),
              _buildField("Password", _passwordController, obscure: true),
              _buildField(
                "Confirm Password",
                _confirmPasswordController,
                obscure: true,
              ),
              _buildField("Phone Number", _phoneController),
              const SizedBox(height: 16),
              const Text(
                "Odaberi uloge",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._roles.map((role) {
                return CheckboxListTile(
                  title: Text(role.name ?? ''),
                  value: _selectedRoleIds.contains(role.id),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedRoleIds.add(role.id!);
                      } else {
                        _selectedRoleIds.remove(role.id);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: Text(isEdit ? "Spasi" : "Dodaj korisnika"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required field' : null,
      ),
    );
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
}
