import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_model.dart';

Core app = Core();
AppColors color = AppColors();
Img img = Img();
Font font = Font();
Consts consts = Consts();

late final FirebaseAuth auth;
late final SharedPreferences storage;

class Core {
  bool isTraditionalKeyboard = false;
  List<WordModel> words = [];

  Future<void> init() async {
    /// INIT FIREBASE CORE
    auth = FirebaseAuth.instanceFor(app: await Firebase.initializeApp());

    storage = await SharedPreferences.getInstance();

    if (storage.containsKey(SPKey.isTraditionalKeyboard.toString())) {
      isTraditionalKeyboard = storage.getBool(SPKey.isTraditionalKeyboard.toString())!;
    }

    String data = await rootBundle.loadString('assets/json/words.json');
    final jsonResult = jsonDecode(data);
    for (var item in jsonResult) {
      words.add(WordModel.fromJson(item));
    }
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

class Consts {
  List<List<String>> krillKeyboard = [
    ['ф', 'ц', 'у', 'ж', 'э', 'н', 'г', 'ш', 'ү', 'з', 'к'],
    ['й', 'ы', 'б', 'ө', 'а', 'х', 'р', 'о', 'л', 'д', 'п'],
    ['я', 'ч', 'ё', 'с', 'м', 'и', 'т', 'ь', 'в', 'е', 'ю'],
  ];

  List<List<String>> traditionalKeyboard = [
    ['ᠣ‍', 'ᠸ‍', 'ᠡ‍', 'ᠷ‍', 'ᠲ‍', 'ᠶ‍', 'ᠦ', 'ᠢ', 'ᠥ', 'ᠫ'],
    ['ᠠ', 'ᠰ', 'ᠳ', 'ᠹ', 'ᠭ', 'ᠬ', 'ᠵ', 'ᠺ', 'ᠯ'],
    ['ᠽ', 'ᠱ', 'ᠴ', 'ᠤ', 'ᠪ', 'ᠨ', 'ᠮ'],
  ];
}

enum SPKey { savedKrill, savedTraditional, isTraditionalKeyboard }
