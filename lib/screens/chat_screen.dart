// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:wo_chat/helper/my_date_util.dart';

import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/screens/view_profile_screen.dart';
import 'package:wo_chat/widgets/message_card.dart';

import '../api/apis.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];
// for handling message text changes
  final _textController = TextEditingController();

  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if search is on & back button is presssed then close search
          // or else simple close current ssccreen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Colors.grey[300],
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.sizeOf(context).height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                  user: widget.user,
                                );
                              },
                            );
                          } else {
                            return const Center(
                                child: Text(
                              "Say Hello!! 👋",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ));
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 227, 241, 244),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user),
              ));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                const SizedBox(
                  height: 7,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    FontAwesomeIcons.arrowLeft,
                    color: Colors.indigo[900],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.sizeOf(context).height * 0.3,
                  ),
                  child: CachedNetworkImage(
                    width: MediaQuery.sizeOf(context).height * 0.05,
                    height: MediaQuery.sizeOf(context).height * 0.05,
                    fit: BoxFit.cover,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(
                        FontAwesomeIcons.user,
                        color: Colors.indigo[900],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? "Online"
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.01,
        horizontal: MediaQuery.sizeOf(context).width * 0.025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: Icon(
                      FontAwesomeIcons.solidFaceSmile,
                      color: Colors.indigo[900],
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: TextStyle(
                          color: Colors.indigo[900],
                        ),
                        border: InputBorder.none),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an multiple image.
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      // uploading & sending image one by one
                      for (var i in images) {
                        setState(() => _isUploading = true);
                        APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(
                      FontAwesomeIcons.image,
                      color: Colors.indigo[900],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        setState(() => _isUploading = true);
                        APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(
                      FontAwesomeIcons.camera,
                      color: Colors.indigo[900],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.02,
                  )
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: MaterialButton(
              color: Colors.indigo[900],
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    //on first message (add user to my_user collection of chat user)
                    APIs.sendFirstMessage(
                      widget.user,
                      _textController.text,
                      Type.text,
                    );
                  } else {
                    // simply send message
                    APIs.sendMessage(
                      widget.user,
                      _textController.text,
                      Type.text,
                    );
                  }
                  _textController.text = "";
                }
              },
              minWidth: 0,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 10, left: 10),
              child: const Center(
                child: Icon(
                  Ionicons.send,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
