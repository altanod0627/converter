import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:converter/core/core.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Хэрэглэгч: ${auth.currentUser?.displayName ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: auth.signOut,
            color: Colors.white,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('peers').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if ((snapshot.data?.docs.length ?? 0) > 0) {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, i) => InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        peerId: snapshot.data!.docs[i].id,
                        peerUserId: snapshot.data?.docs[i]['peerId'],
                        peerUserName: snapshot.data?.docs[i]['peerName'],
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(snapshot.data?.docs[i]['peerName'])),
                      ],
                    ),
                  ),
                ),
                itemCount: snapshot.data?.docs.length,
              );
            } else {
              return const Center(child: Text('Хэрэглэгчийн чат олдсонгүй'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) => const UserSearchBottomSheet(),
          );
        },
      ),
    );
  }
}

class UserSearchBottomSheet extends StatefulWidget {
  const UserSearchBottomSheet({Key? key}) : super(key: key);

  @override
  State<UserSearchBottomSheet> createState() => _UserSearchBottomSheetState();
}

class _UserSearchBottomSheetState extends State<UserSearchBottomSheet> {
  TextEditingController controller = TextEditingController();

  List<QueryDocumentSnapshot> users = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Чатлах хүн хайх',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'name',
                        isEqualTo: controller.text,
                      )
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    users = querySnapshot.docs;
                    setState(() {});
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var user in users)
            InkWell(
              onTap: () {
                FirebaseFirestore.instance.collection('peers').where('peerId', isEqualTo: user['uid']).get().then((value) {
                  if (value.docs.isNotEmpty) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen(peerId: value.docs.first.id, peerUserId: user['uid'], peerUserName: user['name'])),
                    );
                  } else {
                    FirebaseFirestore.instance.collection('peers').add({
                      'fromId': auth.currentUser!.uid,
                      'peerId': user['uid'],
                      'peerName': user['name'],
                      'createdAt': DateTime.now(),
                    }).then((value) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(peerId: value.id, peerUserId: user['uid'], peerUserName: user['name'])),
                      );
                    });
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(user['name'] ?? '')),
                    const SizedBox(width: 10),
                    Icon(Icons.send, color: color.primaryColor),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
