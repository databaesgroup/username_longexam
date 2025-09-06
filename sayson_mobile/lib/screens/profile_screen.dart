import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser> _future;

  @override
  void initState() {
    super.initState();
    _future = UserService().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<AppUser>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final u = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: CircleAvatar(
                  child: Text(u.firstName.isNotEmpty
                      ? u.firstName[0].toUpperCase()
                      : '?'),
                ),
                title: Text(u.fullName,
                    style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text(u.type),
              ),
              const Divider(),
              _row('Email', u.email),
              _row('Username', u.username),
              _row('Type', u.type),
              _row('Active', u.isActive ? 'Yes' : 'No'),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) =>
      ListTile(title: Text(k), subtitle: Text(v));
}
