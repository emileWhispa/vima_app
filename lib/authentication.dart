import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vima_app/super_base.dart';
import 'package:firebase_auth/firebase_auth.dart' as v1;

import 'json/user.dart';
import 'navigation_helper.dart';

class Authentication extends StatefulWidget{
  final bool fromAdd;
  final VoidCallback? loginSuccessCallback;
  const Authentication({super.key,this.fromAdd = false, this.loginSuccessCallback});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends Superbase<Authentication> {


  Future<void> validateAndLogin(String email,String password) async {
      setState(() {
        processing = true;
      });
      try{
        await Firebase.initializeApp();
        var credential = await v1.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

        await officialAuth(credential);
      }on v1.FirebaseAuthException catch (e) {
        showSnack(e.message??"User not found");
      }

      setState(() {
        processing = false;
      });
  }


  Future<void> validateAndRegister(String email,String password) async {
      setState(() {
        processing = true;
      });
      await Firebase.initializeApp();
      try{
        var credential = await v1.FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await officialAuth(credential);
      }on v1.FirebaseAuthException catch (e) {
        showSnack(e.message ?? "User can't be created");
      }

      setState(() {
        processing = false;
      });
  }

  int index = 0;
  bool processing = false;

  Future<v1.UserCredential?> signInWithGoogle() async {
    await Firebase.initializeApp();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    setState(() {
      processing = googleUser != null;
    });
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if( googleAuth == null ) return null;

    // Create a new credential
    final credential = v1.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await v1.FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<void> officialAuth(v1.UserCredential? credential,{Map<String, dynamic>? map})async {

    if(credential == null || credential.user == null){
      return Future.value();
    }

    var token = await credential.user?.getIdToken();

    var provider = credential.user?.providerData.isNotEmpty == true ? credential.user!.providerData[0].providerId : null;
    await ajax(url: "api/auth/firebase/user",method: "POST",map: {
      "token":token,
      "picture":map?['picture']?['url'] ?? credential.user?.photoURL,
      "email": map?['email'] ?? credential.user?.email,
      "firebaseUid":credential.user?.uid,
      "providerId":provider,
      "username":credential.user?.displayName,
      "phone":credential.user?.phoneNumber,
    },onValue: (object,url){

      var user = User.fromJson(object['data']['user']);
      User.user = user;
      save("user", object['data']['user']);
      saveVal("token", object['data']['token']);
      Superbase.tokenValue = object['data']['token'];
      widget.loginSuccessCallback?.call();
      NavigationHelper.key.currentState?.refresh(user);
    },error: (s,v){

    });
    setState(() {
      processing = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: processing ? const Center(child: CircularProgressIndicator(),) : ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Image.asset("assets/home_image.png"),
          const Text("Login in to favorite an ad",textAlign: TextAlign.center,style: TextStyle(fontSize: 23,fontWeight: FontWeight.w600),),
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: OutlinedButton.icon(icon: Image.asset("assets/facebook.png",height: 20),onPressed: () {

            },style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 12),
              side: const BorderSide(
                  color: Color(0xff3287C2)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 17)
            ), label: const Text("Continue with Facebook")),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton.icon(icon: Image.asset("assets/google.png",height: 20),onPressed: ()async=>officialAuth(await signInWithGoogle()),style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 12),
              side: const BorderSide(
                  color: Color(0xff3287C2)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 17)
            ), label: const Text("Continue with Google")),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton.icon(icon: Image.asset("assets/apple.png",fit: BoxFit.fitHeight,height: 20),onPressed: () {

            },style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 12),
              side: const BorderSide(
                  color: Color(0xff3287C2)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 17)
            ), label: const Text("Continue with Apple")),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton.icon(icon: Image.asset("assets/email.png",height: 20,),onPressed: () {

            },style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 12),
              side: const BorderSide(
                  color: Color(0xff3287C2)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 17)
            ), label: const Text("Continue with Email")),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextButton(onPressed: (){}, child: const Text("Don’t have an account? Create one")),
          ),
          
          const Text("By signing up I agree to the Terms and conditions and privacy policy",textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}