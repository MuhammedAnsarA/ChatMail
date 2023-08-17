// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wo_chat/api/apis.dart';
import 'package:wo_chat/helper/my_date_util.dart';

import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/models/message.dart';
import 'package:wo_chat/screens/chat_screen.dart';
import 'package:wo_chat/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --. no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // navigate chat screen
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(user: widget.user),
            ));
      },
      child: Card(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.04, vertical: 4),
          color: Colors.white,
          elevation: 0.6,
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(
                          user: widget.user,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.sizeOf(context).height * 0.3,
                      ),
                      child: CachedNetworkImage(
                        width: MediaQuery.sizeOf(context).height * 0.055,
                        height: MediaQuery.sizeOf(context).height * 0.055,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(
                            FontAwesomeIcons.user,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // username
                  title: Text(
                    widget.user.name,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),

                  // last message
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "Image"
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),

                  // last message time
                  trailing: _message == null
                      ? null //show nothing when no message is sent
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ?
                          //show for unread message
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          :
                          //message sent time
                          Text(
                              MyDateUtil.getLastMessageTime(
                                context: context,
                                time: _message!.sent,
                              ),
                              style: const TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
