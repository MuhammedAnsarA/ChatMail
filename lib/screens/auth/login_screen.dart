// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wo_chat/helper/dialogs.dart';
import 'package:wo_chat/screens/home_screen.dart';

import '../../api/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    Navigator.pop(context);
    _signInWithGoogle().then((user) async {
      if (user != null) {
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      Dialogs.showSnackbar(context, "Something went wrong check internet");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.sizeOf(context).height * .40,
            left: MediaQuery.sizeOf(context).width * .35,
            width: MediaQuery.sizeOf(context).width * .3,
            child: Image.asset("images/speech_bubble.png"),
          ),
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * .12,
            left: MediaQuery.sizeOf(context).width * .05,
            width: MediaQuery.sizeOf(context).width * .9,
            height: MediaQuery.sizeOf(context).height * .07,
            child: Center(
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.indigo[900],
                  ),
                ),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset(
                  "images/google.png",
                  height: MediaQuery.sizeOf(context).width * .055,
                  fit: BoxFit.cover,
                ),
                label: const Text(
                  "Login with Google",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
