import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vima_app/email_authentication.dart';
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

  void goToEmailAuth({int index = 0 }) async {
    var cred = await push<v1.UserCredential>(EmailAuthentication(index: index,));
    if(cred != null){
      officialAuth(cred);
    }
  }

  Future<void> officialAuth(v1.UserCredential? credential,{Map<String, dynamic>? map})async {

    if(credential == null || credential.user == null){
      return Future.value();
    }

    setState(() {
      processing = true;
    });

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


  Future<v1.UserCredential?> _facebookLogin() async {
    await Firebase.initializeApp();
    await FacebookAuth.instance.logOut();
    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile
    setState(() {
      processing = true;
    });
    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {

      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      v1.OAuthCredential credential = v1.FacebookAuthProvider.credential(result.accessToken!.token);
      return await v1.FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      return null;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<v1.UserCredential?> signInWithApple() async {
    await Firebase.initializeApp();
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = v1.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await v1.FirebaseAuth.instance.signInWithCredential(oauthCredential);
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
            child: OutlinedButton.icon(icon: Image.asset("assets/facebook.png",height: 20),onPressed: () async {
              officialAuth(await _facebookLogin(),map: await FacebookAuth.instance.getUserData());
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
            child: OutlinedButton.icon(icon: Image.asset("assets/apple.png",fit: BoxFit.fitHeight,height: 20),onPressed: () async {
              officialAuth(await signInWithApple());
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
            child: OutlinedButton.icon(icon: Image.asset("assets/email.png",height: 20,),onPressed: goToEmailAuth,style: OutlinedButton.styleFrom(
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
          Navigator.canPop(context) ? TextButton(onPressed: (){
            goBack();
          }, child: const Text("Cancel")) : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextButton(onPressed: ()=>goToEmailAuth(index: 1), child: const Text("Don’t have an account? Create one")),
          ),
          
          const Text("By signing up I agree to the Terms and conditions and privacy policy",textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}