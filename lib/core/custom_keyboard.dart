import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongol/mongol.dart';

import 'core.dart';

class CustomKeyboard extends StatefulWidget {
  const CustomKeyboard({Key? key, required this.onTextInput, required this.onBackspace, required this.onChangeKeyboard}) : super(key: key);

  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onChangeKeyboard;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.primaryColor,
      child: Column(
        children: [
          for (var item in app.isTraditionalKeyboard ? consts.traditionalKeyboard : consts.krillKeyboard) buildRow(item),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        app.isTraditionalKeyboard = !app.isTraditionalKeyboard;
                      });
                      widget.onChangeKeyboard();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(Icons.language, color: color.primaryColor),
                    ),
                  ),
                ),
              ),
              textKey(' ', flex: 3),
              Expanded(child: BackspaceKey(onBackspace: backspaceHandler)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRow(List<String> letters) {
    return Row(
      children: [
        for (var item in letters) textKey(item),
      ],
    );
  }

  Widget textKey(String char, {flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(0.5),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => textInputHandler(char),
            child: SizedBox(
              height: 50,
              child: Center(
                child: app.isTraditionalKeyboard
                    ? MongolText(
                        char,
                        style: TextStyle(color: color.primaryColor, fontSize: 20),
                      )
                    : Text(
                        char,
                        style: TextStyle(color: color.primaryColor, fontSize: 20),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void textInputHandler(String text) {
    HapticFeedback.heavyImpact();
    widget.onTextInput.call(text);
  }

  void backspaceHandler() {
    HapticFeedback.heavyImpact();
    widget.onBackspace.call();
  }
}

class BackspaceKey extends StatefulWidget {
  const BackspaceKey({Key? key, required this.onBackspace}) : super(key: key);

  final VoidCallback onBackspace;

  @override
  State<BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<BackspaceKey> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onBackspace.call(),
      onLongPress: () {
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          widget.onBackspace.call();
        });
      },
      onLongPressUp: () {
        if (timer != null) {
          timer!.cancel();
          timer = null;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(0.1),
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: Icon(Icons.backspace_outlined, color: color.primaryColor)),
          ),
        ),
      ),
    );
  }
}
