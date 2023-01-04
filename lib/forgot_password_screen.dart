import 'super_base.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget{
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends Superbase<ForgotPasswordScreen> {

  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;

  final _key = GlobalKey<FormState>();

  void sendResetLink()async{

    if(_key.currentState?.validate()??false) {
      try {
        setState(() {
          _loading = true;
        });
        await Firebase.initializeApp();
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text);

        showSnack("Check your Email has been sent !!");
        goBack();
        setState(() {
          _loading = false;
        });
      } on Exception catch (_) {
        showSnack(_.toString());
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot password"),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
              decoration: InputDecoration(
                  hintText: "Email Address",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(35),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                  fillColor: Colors.red.shade50
              ),
            ),
            const SizedBox(height: 20),
            _loading ? const Center(
              child: CircularProgressIndicator(),
            ) : ElevatedButton(style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35)
                ))
            ),onPressed: sendResetLink, child: const Text("Send Reset Link")),

          ],
        ),
      ),
    );
  }
}