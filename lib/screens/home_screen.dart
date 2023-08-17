import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wo_chat/helper/dialogs.dart';
import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/screens/profile_screen.dart';
import 'package:wo_chat/widgets/chat_user_card.dart';

import '../api/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];

  // for storing searched status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active ...resume-online...pause-offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("resume")) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains("pause")) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is presssed then close search
        // or else simple close current ssccreen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 18, top: 7, bottom: 10),
              child: Image.asset(
                "images/speech_bubble.png",
                fit: BoxFit.cover,
              ),
            ),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Name or Email",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      // search logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.name.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text(
                    "CHAT MAIL",
                  ),
            actions: [
              // search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? FontAwesomeIcons.solidCircleXmark
                      : FontAwesomeIcons.magnifyingGlass,
                  size: 22,
                ),
              ),

              // more features button
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIs.me),
                      ));
                },
                icon: const Icon(
                  FontAwesomeIcons.solidCircleUser,
                  size: 25,
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.indigo[900],
              onPressed: () {
                _addChatUserDialog();
              },
              icon: const Icon(
                FontAwesomeIcons.commentDots,
                color: Colors.white,
                size: 21,
              ),
              label: const Text(
                "New Chat",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUserId(),

            // get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                //c
                // return const Center(
                //   child: CircularProgressIndicator(),
                // );
                // if some or all data is load then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    // get only those user, whos ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.sizeOf(context).height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                                child: Text(
                              "No chat found!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ));
                          }
                      }
                    },
                  );
              }
            },                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
          ),
        ),
      ),
    );
  }

// for adding new chat user
  void _addChatUserDialog() {
    String email = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.userPlus,
              color: Colors.indigo[900],
            ),
            const Text(
              "    Add User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            )
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: "Email Id",
            prefixIcon: Icon(
              FontAwesomeIcons.solidEnvelope,
              color: Colors.indigo[900],
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.indigo[900],
                fontSize: 16,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(
                        context, "User does not exists CHAT MAIL!");
                  }
                });
              }
            },
            child: Text(
              "Add",
              style: TextStyle(
                color: Colors.indigo[900],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
