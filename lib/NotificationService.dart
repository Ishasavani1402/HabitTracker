// ignore_for_file: file_names, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';


class FlutterNotification {
  final firebasemessage = FirebaseMessaging.instance;

  void handlemessage(RemoteMessage? message) {
    if (message == null) return;

    // navigatorkey.currentState?.pushNamed(
    //   '/HomeScreen',
    //   arguments: message,
    // );
  }

  Future initpushnotifiction() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.instance.getInitialMessage().then(handlemessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handlemessage);
    FirebaseMessaging.onBackgroundMessage(handlebackgroundmessage);
  }

  Future<void> initNotification() async {
    await firebasemessage.requestPermission();
    final ftoken = await firebasemessage.getToken();
    print("ftoken : $ftoken");
    initpushnotifiction();
  }
}

Future<void> handlebackgroundmessage(RemoteMessage message) async {
  print("title : ${message.notification?.title}");
  print("body : ${message.notification?.body}");
  print("payload : ${message.data}");
}
