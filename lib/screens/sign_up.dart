import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/widget/form_input_auth.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: FormInputAuth(
                emailCtrl: emailCtrl,
                passCtrl: passCtrl,
                confirmPassCtrl: confirmPassCtrl,
                onPressed: () async {
                  await signUp(context, emailCtrl.text, confirmPassCtrl.text);
                },
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'str_btn_login'.tr,
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (context.mounted) {
        Navigator.pop(context, userCredential.user?.email);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
