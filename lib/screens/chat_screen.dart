import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:converter/core/core.dart';
import 'package:converter/core/custom_keyboard.dart';
import 'package:converter/core/word_model.dart';
import 'package:flutter/material.dart';
import 'package:mongol/mongol.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.peerId, required this.peerUserId, required this.peerUserName}) : super(key: key);

  final String peerId;
  final String peerUserId;
  final String peerUserName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<String> sendHistory = [];
  List<WordModel> suggest = [];
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

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
      suffixIcon: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IconButton(
              onPressed: submit,
              icon: Icon(Icons.send, color: color.primaryColor),
            ),
    );

    double fontSize = 20;

    Widget chatSection = Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('messages').where('peerId', isEqualTo: widget.peerId).orderBy('createdAt', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              if ((snapshot.data?.docs.length ?? 0) > 0) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, i) => LimitedBox(
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
                                          removeSearchString(snapshot.data?.docs[i]['peerId']);
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
                      child: Row(
                        mainAxisAlignment: snapshot.data?.docs[i]['fromId'] == auth.currentUser!.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: snapshot.data?.docs[i]['fromId'] == auth.currentUser!.uid ? color.primaryColor : Colors.black38,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            child: RegExp(r'^[а-яөү .,]+$').hasMatch(snapshot.data?.docs[i]['message'])
                                ? Text(snapshot.data?.docs[i]['message'], style: const TextStyle(color: Colors.white))
                                : MongolText(snapshot.data?.docs[i]['message'], style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: Text('Хэрэглэгчийн чат олдсонгүй'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
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
        title: Text(widget.peerUserName, style: const TextStyle(color: Colors.white, fontSize: 14)),
        centerTitle: true,
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

  void submit() {
    String string = '';
    List<String> texts = controller.text.trim().split(' ');

    for (var item in texts) {
      List<WordModel> words = app.words.where((element) => element.traditional == item || element.krill == item).toList();

      if (string.isNotEmpty) string += ' ';

      if (words.isNotEmpty) {
        string += app.isTraditionalKeyboard ? words.first.krill : words.first.traditional;
      }
    }

    if (string.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      FirebaseFirestore.instance.collection('messages').add({
        'fromId': auth.currentUser!.uid,
        'fromName': auth.currentUser!.displayName,
        'peerId': widget.peerId,
        'peerUserId': widget.peerUserId,
        'peerUserName': widget.peerUserName,
        'message': string,
        'createdAt': DateTime.now(),
      }).then((value) {
        controller.clear();
        setState(() {
          isLoading = false;
        });
      });

      // saveSendString(string);
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
