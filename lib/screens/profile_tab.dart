import 'package:flutter/material.dart';
import 'package:budget_tracker/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileTab extends StatelessWidget {
  ProfileTab({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Atsijungti'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _signOutButton(),
    );
  }
}
