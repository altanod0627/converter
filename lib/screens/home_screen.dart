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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: (auth.currentUser?.displayName ?? '').isNotEmpty
            ? Text(
                'Нэвтэрсэн: ${auth.currentUser?.displayName ?? ''}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )
            : null,
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
        stream: FirebaseFirestore.instance.collection('peers').where('userIds', arrayContains: auth.currentUser!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if ((snapshot.data?.docs.length ?? 0) > 0) {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, i) => Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peerId: snapshot.data!.docs[i].id,
                          peerUserId: snapshot.data?.docs[i]['fromUserId'] == auth.currentUser!.uid ? snapshot.data?.docs[i]['peerUserId'] : snapshot.data?.docs[i]['fromUserId'],
                          peerUserName: snapshot.data?.docs[i]['fromUserId'] == auth.currentUser!.uid ? snapshot.data?.docs[i]['peerUserName'] : snapshot.data?.docs[i]['fromUserName'],
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(snapshot.data?.docs[i]['fromUserId'] == auth.currentUser!.uid ? snapshot.data?.docs[i]['peerUserName'] : snapshot.data?.docs[i]['fromUserName']),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: Text('Хэрэглэгч олдсонгүй'));
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
  bool isLoading = false;

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
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Чатлах хүн хайх',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        users.clear();

                        CollectionReference userRef = FirebaseFirestore.instance.collection('users');
                        var snapshot = await userRef.where('name', isEqualTo: controller.text).get();
                        users.addAll(snapshot.docs);
                        var snapshot2 = await userRef.where('email', isEqualTo: controller.text).get();
                        users.addAll(snapshot2.docs);

                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
            ],
          ),
          const SizedBox(height: 10),
          for (var user in users)
            InkWell(
              onTap: () {
                FirebaseFirestore.instance.collection('peers').where('peerUserId', isEqualTo: user['uid']).get().then((value) {
                  if (value.docs.isNotEmpty) {
                    openChat(value.docs.first.id, user['uid'], user['name']);
                  } else {
                    FirebaseFirestore.instance.collection('peers').add({
                      'userIds': [auth.currentUser!.uid, user['uid']],
                      'fromUserId': auth.currentUser!.uid,
                      'fromUserName': auth.currentUser!.displayName,
                      'peerUserId': user['uid'],
                      'peerUserName': user['name'],
                      'createdAt': DateTime.now(),
                    }).then((value) {
                      openChat(value.id, user['uid'], user['name']);
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

  void openChat(String peerId, String peerUserId, String peerUserName) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(peerId: peerId, peerUserId: peerUserId, peerUserName: peerUserName)),
    );
  }
}
