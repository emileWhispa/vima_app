import 'super_base.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget{
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends Superbase<ChangePasswordScreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> validateAndChange() async {
    if(_formKey.currentState?.validate()??false){
      setState(() {
        loading = true;
      });
      await Firebase.initializeApp();
      var user = FirebaseAuth.instance.currentUser;
      if( user != null){
        try{
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email!, password: _oldController.text);
          await user.updatePassword(_newController.text);
          goBack();
          showSnack("Password updated successfully");
        } on FirebaseAuthException catch(e){
          showSnack(e.message??"");
        }
      }


      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change password"),),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20),children: [

          TextFormField(
            obscureText: true,
            controller: _oldController,
            validator: (s)=>s?.isNotEmpty == true ? null : "Old Password is required !",
            decoration: InputDecoration(
                hintText: "Old Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide.none
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                fillColor: Colors.red.shade50
            ),
          ),
          const SizedBox(height: 20,),

          TextFormField(
            obscureText: true,
            controller: _newController,
            validator: (s)=>s?.isNotEmpty == true ? null : "New Password is required !",
            decoration: InputDecoration(
                hintText: "New Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide.none
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                fillColor: Colors.red.shade50
            ),
          ),
          const SizedBox(height: 20,),

          TextFormField(
            obscureText: true,
            controller: _confirmController,
            validator: (s)=>s?.isNotEmpty == true ? _newController.text != _confirmController.text ? "Confirm password has to be the same !" : null : "Confirm Password is required !",
            decoration: InputDecoration(
                hintText: "Confirm Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide.none
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                fillColor: Colors.red.shade50
            ),
          ),
          const SizedBox(height: 20,),

          Center(
            child: loading ? const CircularProgressIndicator() : ElevatedButton(style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50,vertical: 15)),
                elevation: MaterialStateProperty.all(2),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35)
                ))
            ),onPressed: validateAndChange, child: const Text("Update Password")),
          ),
        ],),
      ),
    );
  }
}