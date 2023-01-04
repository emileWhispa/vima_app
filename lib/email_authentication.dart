import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as v1;
import 'package:vima_app/super_base.dart';

import 'forgot_password_screen.dart';

class EmailAuthentication extends StatefulWidget{
  final int index;
  const EmailAuthentication({super.key, this.index = 0});

  @override
  State<EmailAuthentication> createState() => _EmailAuthenticationState();
}

class _EmailAuthenticationState extends Superbase<EmailAuthentication> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _emailRegController = TextEditingController();
  final TextEditingController _passwordRegController = TextEditingController();
  final TextEditingController _passwordReg2Controller = TextEditingController();

  final _key = GlobalKey<FormState>();
  final _regKey = GlobalKey<FormState>();

  @override
  void initState(){
    index = widget.index;
    super.initState();
  }

  Future<void> validateAndLogin() async {
    if(_key.currentState?.validate()??false){
      setState(() {
        processing = true;
      });
      try{
        await Firebase.initializeApp();
        var credential = await v1.FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

        if(mounted){
          Navigator.pop(context,credential);
        }
      }on v1.FirebaseAuthException catch (e) {
        showSnack(e.message??"User not found");
      }

      setState(() {
        processing = false;
      });
    }
  }


  Future<void> validateAndRegister() async {
    if(_regKey.currentState?.validate()??false){
      setState(() {
        processing = true;
      });
      await Firebase.initializeApp();
      try{
        var credential = await v1.FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailRegController.text, password: _passwordRegController.text);
        if(mounted){
          Navigator.pop(context,credential);
        }
      }on v1.FirebaseAuthException catch (e) {
        showSnack(e.message ?? "User can't be created");
      }

      setState(() {
        processing = false;
      });
    }
  }

  int index = 0;
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    var image =
    Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Image.asset("assets/logo.png",height: 120,),
    );
    return Scaffold(
      body: processing ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image,
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ) : ListView(
        children: [
          image,
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              children: [
                Expanded(child: TextButton(style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    )),
                    backgroundColor: MaterialStateProperty.all(index == 0 ? Theme.of(context).colorScheme.secondary : null)
                ),onPressed: (){
                  setState(() {
                    index = 0;
                  });
                },child: Text("SIGN IN",textAlign: TextAlign.center,style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: index == 0 ? Theme.of(context).colorScheme.onSecondary : null
                ),),)),
                Expanded(child: TextButton(style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    )),
                    backgroundColor: MaterialStateProperty.all(index == 1 ? Theme.of(context).colorScheme.secondary : null)
                ),onPressed: (){
                  setState(() {
                    index = 1;
                  });
                },child: Text("REGISTER",textAlign: TextAlign.center,style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: index == 1 ? Theme.of(context).colorScheme.onSecondary : null
                ),),)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                index == 0 ? Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        validator: (s)=>s?.isNotEmpty == true ? emailExp.hasMatch(s!) ? null : "Valid email is required" : "Email address is required !",
                        decoration: InputDecoration(
                            hintText: "Email Address",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                            fillColor: Colors.blue.shade50
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        validator: (s)=>s?.isNotEmpty == true ? null : "Password is required !",
                        decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                            fillColor: Colors.blue.shade50
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35)
                          ))
                      ),onPressed: validateAndLogin, child: const Text("Sign In")),


                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: (){
                          push(const ForgotPasswordScreen());
                        }, child: const Text("Forgot password ?")),
                      )
                    ],
                  ),
                ) : Form(
                  key: _regKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailRegController,
                        validator: (s)=>s?.isNotEmpty == true ? emailExp.hasMatch(s!) ? null : "Valid email is required" : "Email address is required !",
                        decoration: InputDecoration(
                            hintText: "Email Address",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                            fillColor: Colors.blue.shade50
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        controller: _passwordRegController,
                        validator: (s)=>s?.isNotEmpty == true ? null : "Password is required !",
                        decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                            fillColor: Colors.blue.shade50
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        controller: _passwordReg2Controller,
                        validator: (s)=>s?.isNotEmpty == true ? s == _passwordRegController.text ? null : "Password confirmation has to be the same" : "Password is required !",
                        decoration: InputDecoration(
                            hintText: "Confirm Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: BorderSide.none
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                            fillColor: Colors.blue.shade50
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(style: ButtonStyle(
                          padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35)
                          ))
                      ),onPressed: validateAndRegister, child: const Text("Register")),


                    ],
                  ),
                ),   const SizedBox(height: 50),
              ],
            ),
          ),
          Center(child: TextButton(onPressed: goBack, child: const Text("Cancel")))
        ],
      ),
    );
  }
}