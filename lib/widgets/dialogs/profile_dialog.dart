// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.9),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.6,
        height: MediaQuery.sizeOf(context).height * 0.35,
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.075,
              left: MediaQuery.sizeOf(context).width * 0.09,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  MediaQuery.sizeOf(context).height * 0.25,
                ),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(
                      FontAwesomeIcons.user,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.04,
              top: MediaQuery.sizeOf(context).height * 0.02,
              width: MediaQuery.sizeOf(context).width * 0.55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewProfileScreen(user: user),
                      ));
                },
                shape: const CircleBorder(),
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.circleInfo,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
