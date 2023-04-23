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
  List<WordModel> searchList = [];
  List<WordModel> lastSearchList = [];

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
      labelText: app.isTraditionalKeyboard ? 'ᠬᠠᠶᠢᠬᠤ' : 'Хайх үг',
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                controller.clear();
                search();
              },
              icon: const Icon(Icons.clear, color: Colors.black),
            )
          : null,
    );

    double fontSize = 20;

    List<Widget> children = [
      app.isTraditionalKeyboard
          ? Container(
              margin: const EdgeInsets.only(right: 16),
              child: MongolTextField(
                controller: controller,
                decoration: decoration,
                style: TextStyle(fontSize: fontSize),
                autofocus: true,
                showCursor: true,
                readOnly: true,
              ),
            )
          : Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: controller,
                decoration: decoration,
                style: TextStyle(fontSize: fontSize),
                autofocus: true,
                showCursor: true,
                readOnly: true,
              ),
            ),
      Expanded(
        child: ListView(
          children: [
            for (var item in (searchList.isNotEmpty
                ? searchList
                : controller.text.isEmpty
                    ? lastSearchList
                    : []))
              ListTile(
                title: app.isTraditionalKeyboard ? MongolText(item.traditional) : Text(item.krill),
                contentPadding: const EdgeInsets.only(left: 16),
                trailing: searchList.isEmpty
                    ? IconButton(
                        onPressed: () => removeSearchWord(item),
                        icon: const Icon(Icons.delete_outline, color: Colors.black),
                      )
                    : null,
                onTap: () {
                  saveSearchWord(item);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return Container(
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(item.krill, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black38))),
                                    padding: const EdgeInsets.only(right: 16),
                                    child: MongolText(item.traditional, style: const TextStyle(fontSize: 30)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(item.spell),
                                            const SizedBox(width: 4),
                                            Text('(${item.spellEnglish})', style: const TextStyle(color: Colors.black38)),
                                          ],
                                        ),
                                        Text(item.description),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
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
              search();
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
    search();
  }

  void backspace() {
    if (controller.text.isNotEmpty) {
      controller.text = controller.text.substring(0, controller.text.length - 1);
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
    search();
  }

  void search() {
    if (controller.text.isNotEmpty) {
      if (app.isTraditionalKeyboard) {
        searchList = app.words.where((element) => element.traditional.contains(controller.text)).toList();
      } else {
        searchList = app.words.where((element) => element.krill.contains(controller.text)).toList();
      }
    } else {
      searchList.clear();
      getLastSearch();
    }
    setState(() {});
  }

  void saveSearchWord(WordModel word) {
    if (app.isTraditionalKeyboard) {
      String savedTraditional = storage.getString(SPKey.savedTraditional.toString()) ?? '';
      if (!savedTraditional.contains(word.traditional)) {
        if (savedTraditional.isNotEmpty) savedTraditional += ',';

        savedTraditional += word.traditional;
        storage.setString(SPKey.savedTraditional.toString(), savedTraditional);
      }
    } else {
      String savedKrill = storage.getString(SPKey.savedKrill.toString()) ?? '';
      if (!savedKrill.contains(word.krill)) {
        if (savedKrill.isNotEmpty) savedKrill += ',';

        savedKrill += word.krill;
        storage.setString(SPKey.savedKrill.toString(), savedKrill);
      }
    }

    setState(() {});
  }

  void removeSearchWord(WordModel word) {
    if (app.isTraditionalKeyboard) {
      String savedTraditional = storage.getString(SPKey.savedTraditional.toString()) ?? '';
      List<String> strings = savedTraditional.split(',');
      strings.removeWhere((element) => element == word.traditional);
      String newSaved = strings.join(',');
      storage.setString(SPKey.savedTraditional.toString(), newSaved);
    } else {
      String savedKrill = storage.getString(SPKey.savedKrill.toString()) ?? '';
      List<String> strings = savedKrill.split(',');
      strings.removeWhere((element) => element == word.krill);
      String newSaved = strings.join(',');
      storage.setString(SPKey.savedKrill.toString(), newSaved);
    }

    getLastSearch();
  }

  void getLastSearch() {
    lastSearchList.clear();

    if (app.isTraditionalKeyboard) {
      String savedTraditional = storage.getString(SPKey.savedTraditional.toString()) ?? '';
      if (savedTraditional.isNotEmpty) {
        List<String> strings = savedTraditional.split(',');
        for (var item in strings) {
          List<WordModel> word = app.words.where((element) => element.traditional == item).toList();
          if (word.isNotEmpty) {
            lastSearchList.add(word.first);
          }
        }
      }
    } else {
      String savedKrill = storage.getString(SPKey.savedKrill.toString()) ?? '';
      if (savedKrill.isNotEmpty) {
        List<String> strings = savedKrill.split(',');
        for (var item in strings) {
          List<WordModel> word = app.words.where((element) => element.krill == item).toList();
          if (word.isNotEmpty) {
            lastSearchList.add(word.first);
          }
        }
      }
    }

    setState(() {});
  }
}
