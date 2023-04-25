import 'package:converter/core/core.dart';
import 'package:converter/core/custom_keyboard.dart';
import 'package:converter/core/word_model.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();
  List<String> sendHistory = [];
  List<WordModel> suggest = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    getLastSearch();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: app.isTraditionalKeyboard ? MongolOutlineInputBorder(borderRadius: BorderRadius.circular(5)) : OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      labelText: app.isTraditionalKeyboard ? 'ᠮᠧᠰᠰᠡᠵ ᠪᠢᠴᠢᠬᠦ' : 'Чат бичих',
      suffixIcon: IconButton(
        onPressed: search,
        icon: Icon(Icons.send, color: color.primaryColor),
      ),
    );

    double fontSize = 20;

    Widget chatSection = Expanded(
      child: ListView(
        controller: scrollController,
        children: [
          for (var item in sendHistory)
            Row(
              children: [
                LimitedBox(
                  maxWidth: MediaQuery.of(context).size.width * .6,
                  child: InkWell(
                    onLongPress: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Устгах уу?'),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Хаах'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        removeSearchString(item);
                                      },
                                      child: const Text('Устгах'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.primaryColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      child: RegExp(r'^[а-яөү ]+$').hasMatch(item) ? Text(item, style: const TextStyle(color: Colors.white)) : MongolText(item, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    List<Widget> children = [
      if (!app.isTraditionalKeyboard) chatSection,
      app.isTraditionalKeyboard
          ? Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  MongolTextField(
                    controller: controller,
                    decoration: decoration,
                    style: TextStyle(fontSize: fontSize),
                    autofocus: true,
                    showCursor: true,
                    readOnly: true,
                  ),
                  const SizedBox(width: 4),
                  LimitedBox(
                    maxWidth: 30,
                    child: ListView(
                      children: [
                        for (var item in suggest)
                          InkWell(
                            onTap: () => addText('${item.traditional} '),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black38)),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              margin: EdgeInsets.only(bottom: suggest.last == item ? 0 : 8),
                              child: Center(child: MongolText(item.traditional)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  LimitedBox(
                    maxHeight: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var item in suggest)
                          InkWell(
                            onTap: () => addText('${item.krill} '),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black38)),
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              margin: EdgeInsets.only(right: suggest.last == item ? 0 : 8),
                              child: Center(child: Text(item.krill)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: decoration,
                    style: TextStyle(fontSize: fontSize),
                    autofocus: true,
                    showCursor: true,
                    readOnly: true,
                  ),
                ],
              ),
            ),
      if (app.isTraditionalKeyboard) chatSection,
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: auth.signOut,
            color: Colors.white,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: app.isTraditionalKeyboard ? Row(children: children) : Column(children: children),
            ),
          ),
          CustomKeyboard(
            onTextInput: insertText,
            onBackspace: backspace,
            onChangeKeyboard: () {
              controller.clear();
              suggest = [];
              storage.setBool(SPKey.isTraditionalKeyboard.toString(), app.isTraditionalKeyboard);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void insertText(String myText) {
    controller.text = controller.text + myText;
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    suggestSearch();
  }

  void backspace() {
    if (controller.text.isNotEmpty) {
      controller.text = controller.text.substring(0, controller.text.length - 1);
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      suggestSearch();
    }
  }

  void suggestSearch() {
    suggest = [];
    String text = controller.text.split(' ').last;
    if (text.isNotEmpty) {
      suggest = app.words.where((element) => element.traditional.contains(text) || element.krill.contains(text)).toList();
    }

    setState(() {});
  }

  void addText(String text) {
    String full = '';

    for (var item in controller.text.split(' ')) {
      if (item != controller.text.split(' ').last) {
        full += '$item ';
      }
    }

    controller.text = full;
    insertText(text);
  }

  void search() {
    String string = '';
    List<String> texts = controller.text.trim().split(' ');

    for (var item in texts) {
      List<WordModel> words = app.words.where((element) => element.traditional == item || element.krill == item).toList();

      if (string.isNotEmpty) string += ' ';

      if (words.isNotEmpty) {
        string += app.isTraditionalKeyboard ? words.first.krill : words.first.traditional;
      }
    }
    controller.clear();
    if (string.isNotEmpty) {
      saveSendString(string);
    }
  }

  void saveSendString(String string) {
    String savedText = storage.getString(SPKey.sendText.toString()) ?? '';
    List<String> strings = savedText.split(',');
    if (!strings.contains(string)) {
      if (savedText.isNotEmpty) savedText += ',';

      savedText += string;
      if (savedText.isNotEmpty) {
        storage.setString(SPKey.sendText.toString(), savedText);
      }
    }
    getLastSearch();
  }

  void removeSearchString(String string) {
    String savedText = storage.getString(SPKey.sendText.toString()) ?? '';
    List<String> strings = savedText.split(',');
    strings.removeWhere((element) => element == string);
    String newSaved = strings.join(',');
    storage.setString(SPKey.sendText.toString(), newSaved);

    getLastSearch();
  }

  void getLastSearch() {
    sendHistory.clear();

    String savedText = storage.getString(SPKey.sendText.toString()) ?? '';
    if (savedText.isNotEmpty) {
      List<String> strings = savedText.split(',');
      for (var item in strings) {
        sendHistory.add(item);
      }
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }
}
