import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.indigo[900],
        behavior: SnackBarBehavior.floating,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
