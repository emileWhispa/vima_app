import 'package:flutter/material.dart';
import 'super_base.dart';

class SuccessScreen extends StatefulWidget{
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends Superbase<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/success_icon.png"),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Your Payment request was processed successfully",textAlign: TextAlign.center,style: TextStyle(
                color: Color(0xff02A95C),
                fontSize: 26,
                fontWeight: FontWeight.w500
              ),),
            ),
            const Text("Thanks for using e-gura"),
            const SizedBox(height: 30,),
            OutlinedButton(onPressed: goBack, child: const Text("Go Back"))
          ],
        ),
      ),
    );
  }
}