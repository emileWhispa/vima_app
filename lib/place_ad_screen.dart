import 'package:flutter/material.dart';
import 'package:vima_app/authentication.dart';
import 'package:vima_app/super_base.dart';

class PlaceAdScreen extends StatefulWidget{
  const PlaceAdScreen({super.key});

  @override
  State<PlaceAdScreen> createState() => _PlaceAdScreenState();
}

class _PlaceAdScreenState extends Superbase<PlaceAdScreen> {
  @override
  Widget build(BuildContext context) {
    return loggedOut ? const Authentication() : const Scaffold();
  }
}

