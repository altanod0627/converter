import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Core app = Core();
AppColors color = AppColors();
Img img = Img();
Font font = Font();
late final FirebaseAuth auth;

class Core {
  Future<void> init() async {
    /// INIT FIREBASE CORE
    auth = FirebaseAuth.instanceFor(app: await Firebase.initializeApp());
  }
}

class AppColors {
  Color primaryColor = const Color(0xFF03A9F4);
}

class Img {
  static const String appIcon = 'app-icon.png';
}

class Font {
  static const String fontDashitseden = 'DashitsedenFont';
  static const String fontMongol = 'MongolFont';
}
