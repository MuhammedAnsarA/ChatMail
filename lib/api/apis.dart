import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:wo_chat/models/chat_user.dart';
import 'package:wo_chat/models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

// for accessing cloud firestore database
  static FirebaseFirestore firstore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

// for storing self information
  static late ChatUser me;

// to return to current user
  static User get user => auth.currentUser!;

// for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

// for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("Push Token: $t");
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var res = await post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader:
              "key=AAAAFW2eYpg:APA91bGkGivZHglhU8MhUIq_a2AYdWfTRoVqFPzmvtzX15_sPUmmWUm-fla2qpQhSA57btJrGrqoBMw9EW39VSXSHGsB6FTxbkjzt0n5P5ASCjneAwVHJZXNCBmDR6z2lpaR2ahVrrCK"
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log("\nsendPushNotification: $e");
    }
  }

// for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firstore.collection("users").doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firstore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // user exists
      firstore
          .collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // user does not exists
      return false;
    }
  }

// for checking current user info
  static Future<void> getSelfInfo() async {
    await firstore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        // for setting user status to active
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

// for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: user.photoURL.toString(),
      about: "Hey, I'm using CHAT MAIL!",
      name: user.displayName.toString(),
      createdAt: time,
      isOnline: false,
      id: user.uid,
      lastActive: time,
      email: user.email.toString(),
      pushToken: "",
    );
    return await firstore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting ids of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firstore
        .collection("users")
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }

// for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log("\nUserIds: $userIds");
    return firstore
        .collection("users")
        .where("id", whereIn: userIds.isEmpty ? [""] : userIds)
        // .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firstore
        .collection("users")
        .doc(chatUser.id)
        .collection("my_users")
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firstore.collection("users").doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extention
    final ext = file.path.split(".").last;
// storage file ref with path
    final ref = storage.ref().child("profile_pictures/${user.uid}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {});
    me.image = await ref.getDownloadURL();
    await firstore.collection("users").doc(user.uid).update({
      "image": me.image,
    });
  }

  // for getting specific user in
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firstore
        .collection("users")
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firstore.collection("users").doc(user.uid).update({
      "is_online": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken,
    });
  }

//************** Chat Screen related APIs **************

  // chats (coollection) --> conversation_id (doc) --> messages (collection) --> message (doc)

// useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firstore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: "",
        type: type,
        sent: time,
        fromId: user.uid);

    final ref = firstore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "Image"));
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firstore
        .collection("chats/${getConversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last messages of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firstore
        .collection("chats/${getConversationID(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extention
    final ext = file.path.split(".").last;
// storage file ref with path
    final ref = storage.ref().child(
        "images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {});
    final imageUrl = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  // delete message
  static Future<void> deleteMessage(Message message) async {
    await firstore
        .collection("chats/${getConversationID(message.toId)}/messages/")
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firstore
        .collection("chats/${getConversationID(message.toId)}/messages/")
        .doc(message.sent)
        .update({"msg": updatedMsg});
  }
}
