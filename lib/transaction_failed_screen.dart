import 'super_base.dart';
import 'package:flutter/material.dart';

class TransactionFailedScreen extends StatefulWidget{
  const TransactionFailedScreen({Key? key}) : super(key: key);

  @override
  State<TransactionFailedScreen> createState() => _TransactionFailedScreenState();
}

class _TransactionFailedScreenState extends Superbase<TransactionFailedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/failed_icon.png"),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Your payment has failed",textAlign: TextAlign.center,style: TextStyle(
                  color: Color(0xffA90202),
                  fontSize: 26,
                  fontWeight: FontWeight.w500
              ),),
            ),
            const Text("Your card was denied"),
            const SizedBox(height: 30,),
            OutlinedButton(onPressed: goBack, child: const Text("Go Back"))
          ],
        ),
      ),
    );
  }
}