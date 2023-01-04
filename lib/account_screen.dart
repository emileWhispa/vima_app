// ignore_for_file: prefer_const_constructors_in_immutables

import 'authentication.dart';
import 'super_base.dart';
import 'user_details.dart';
import 'package:flutter/material.dart';

import 'bezier_container.dart';
import 'json/user.dart';

class AccountScreen extends StatefulWidget {
  final bool fromAdd;

  const AccountScreen({Key? key, this.fromAdd = false}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends Superbase<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: -height * .10,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          User.user == null
              ? Authentication(
                  loginSuccessCallback: widget.fromAdd ? goBack : null,
                )
              : UserDetails(
                  user: User.user!,
                ),
        ],
      ),
    );
  }
}
