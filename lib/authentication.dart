import 'package:flutter/material.dart';

class Authentication extends StatefulWidget{
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Image.asset("assets/home_image.png"),
          const Text("Login in to favorite an ad",textAlign: TextAlign.center,style: TextStyle(fontSize: 23,fontWeight: FontWeight.w600),),
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: OutlinedButton.icon(icon: Image.asset("assets/facebook.png"),onPressed: () {

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
            child: OutlinedButton.icon(icon: Image.asset("assets/google.png"),onPressed: () {

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
            ), label: const Text("Continue with Google")),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: OutlinedButton.icon(icon: Image.asset("assets/apple.png"),onPressed: () {

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
            child: OutlinedButton.icon(icon: Image.asset("assets/email.png"),onPressed: () {

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