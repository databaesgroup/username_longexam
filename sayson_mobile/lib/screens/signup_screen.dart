import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _fn = TextEditingController();
  final _ln = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _fn,
      _ln,
      _age,
      _gender,
      _contact,
      _email,
      _username,
      _password,
      _address
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = {
        "firstName": _fn.text.trim(),
        "lastName": _ln.text.trim(),
        "age": _age.text.trim(),
        "gender": _gender.text.trim(),
        "contactNumber": _contact.text.trim(),
        "email": _email.text.trim(),
        "username": _username.text.trim(),
        "password": _password.text,
        "address": _address.text.trim(),
        "isActive": true,
        "type": "admin"
      };
      await UserService().registerUser(body);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                    controller: _fn,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: _req),
                TextFormField(
                    controller: _ln,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: _req),
                TextFormField(
                    controller: _age,
                    decoration: const InputDecoration(labelText: 'Age')),
                TextFormField(
                    controller: _gender,
                    decoration: const InputDecoration(labelText: 'Gender')),
                TextFormField(
                    controller: _contact,
                    decoration:
                        const InputDecoration(labelText: 'Contact number')),
                TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _req),
                TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: _req),
                TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: _req),
                TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
