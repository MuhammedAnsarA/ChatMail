// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:wo_chat/helper/dialogs.dart';

import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/screens/auth/login_screen.dart';

import '../api/apis.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile Screen",
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.indigo[900],
            onPressed: () async {
              Dialogs.showProgressbar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ));
                });
              });
            },
            icon: const Icon(
              Ionicons.log_out_outline,
              color: Colors.white,
              size: 28,
            ),
            label: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.03,
                    width: MediaQuery.sizeOf(context).width,
                  ),
                  Stack(
                    children: [
                      // profile picture
                      _image != null
                          ?
                          // local image
                          ClipRRect(
                              borderRadius: BorderRadius.circular(
                                MediaQuery.sizeOf(context).height * 0.1,
                              ),
                              child: Image.file(File(_image!),
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.sizeOf(context).height * 0.2,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.2))
                          :
                          // image from server
                          ClipRRect(
                              borderRadius: BorderRadius.circular(
                                MediaQuery.sizeOf(context).height * 0.1,
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: MediaQuery.sizeOf(context).height * 0.2,
                                height: MediaQuery.sizeOf(context).height * 0.2,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(
                                    FontAwesomeIcons.user,
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 0,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.pen,
                            color: Colors.indigo[900],
                            size: 19,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.03,
                  ),
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.01,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Ionicons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11)),
                        hintText: "Enter your name"),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Ionicons.information_circle_outline,
                          size: 28,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11)),
                        hintText: "Enter your about"),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.03,
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.indigo[900],
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, "Profile Updated Successfully!");
                        });
                      }
                    },
                    icon: const Icon(
                      FontAwesomeIcons.pen,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      "UPDATE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // bottom sheet picking profile picture for user

  void _showBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height * 0.03,
              bottom: MediaQuery.sizeOf(context).height * 0.05),
          children: [
            const Text(
              "Pick Profile Picture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(
                        MediaQuery.sizeOf(context).width * 0.3,
                        MediaQuery.sizeOf(context).height * 0.15,
                      )),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
// Pick an image.
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset("images/gallery.png"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(
                        MediaQuery.sizeOf(context).width * 0.3,
                        MediaQuery.sizeOf(context).height * 0.15,
                      )),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
// Pick an image.
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (image != null) {
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset("images/camera.png"),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
