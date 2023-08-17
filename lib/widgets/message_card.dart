import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:ionicons/ionicons.dart';

import 'package:wo_chat/api/apis.dart';
import 'package:wo_chat/helper/my_date_util.dart';
import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/models/message.dart';

import '../helper/dialogs.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    required this.message,
    required this.user,
  }) : super(key: key);

  final Message message;
  final ChatUser user;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _sendMessage() : _receivedMessage(),
    );
  }

  Widget _receivedMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              MediaQuery.sizeOf(context).height * 0.025,
            ),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: MediaQuery.sizeOf(context).height * 0.05,
              height: MediaQuery.sizeOf(context).height * 0.05,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(
                  FontAwesomeIcons.user,
                ),
              ),
            ),
          ),
        ),
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.sizeOf(context).width * .005
                : MediaQuery.sizeOf(context).width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * .04,
                vertical: MediaQuery.sizeOf(context).height * .01),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomRight: Radius.circular(17))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),

        //message time
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.sizeOf(context).width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _sendMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: MediaQuery.sizeOf(context).width * .04),

            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            //for adding some space
            const SizedBox(width: 2),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),

        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.sizeOf(context).width * .005
                : MediaQuery.sizeOf(context).width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * .04,
                vertical: MediaQuery.sizeOf(context).height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border:
                    Border.all(color: const Color.fromARGB(255, 218, 255, 176)),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomLeft: Radius.circular(17))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: MediaQuery.sizeOf(context).height * 0.015,
                horizontal: MediaQuery.sizeOf(context).width * 0.4,
              ),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),

            widget.message.type == Type.text
                ? // copy option
                _OptionItem(
                    icon: Icon(
                      Ionicons.copy_outline,
                      color: Colors.indigo[900],
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);

                        Dialogs.showSnackbar(context, "Text Copied!");
                      });
                    },
                  )
                : // copy option
                _OptionItem(
                    icon: Icon(
                      FontAwesomeIcons.solidFloppyDisk,
                      size: 24,
                      color: Colors.indigo[900],
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(
                          widget.message.msg,
                          albumName: "CHAT MAIL",
                        ).then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, "Image Successfully Saved!");
                          }
                        });
                      } catch (e) {
                        Text("ErrorWhileSavingImage: $e");
                      }
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black12,
                endIndent: MediaQuery.sizeOf(context).width * 0.04,
                indent: MediaQuery.sizeOf(context).width * 0.04,
              ),
            // edit option
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: Icon(
                  FontAwesomeIcons.pen,
                  size: 21,
                  color: Colors.indigo[900],
                ),
                name: "Edit Message",
                onTap: () {
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
              ),

            // delete option
            if (isMe)
              _OptionItem(
                icon: Icon(
                  FontAwesomeIcons.trash,
                  size: 21,
                  color: Colors.indigo[900],
                ),
                name: "Delete Message",
                onTap: () async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    // for hiding bottom sheet
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, "Message Deleted!");
                  });
                },
              ),
            Divider(
              color: Colors.black12,
              endIndent: MediaQuery.sizeOf(context).width * 0.04,
              indent: MediaQuery.sizeOf(context).width * 0.04,
            ),
            // sent time
            _OptionItem(
              icon: const Icon(
                Ionicons.eye,
                color: Colors.red,
              ),
              name:
                  "Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
              onTap: () {},
            ),

            // read time
            _OptionItem(
              icon: const Icon(
                Ionicons.eye,
                color: Colors.green,
              ),
              name: widget.message.read.isEmpty
                  ? "Read At: Not seen yet"
                  : "Read At ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  // dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.message,
              color: Colors.indigo[900],
            ),
            const Text(
              "  Update Message",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
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
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
              Dialogs.showSnackbar(context, "Message Updated!");
            },
            child: Text(
              "Update",
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

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.sizeOf(context).width * 0.05,
          top: MediaQuery.sizeOf(context).height * 0.015,
          bottom: MediaQuery.sizeOf(context).height * 0.015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                "     $name",
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
