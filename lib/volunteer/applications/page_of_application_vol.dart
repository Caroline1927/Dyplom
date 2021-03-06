

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wol_pro_1/Refugee/SettingRefugee.dart';
import 'package:wol_pro_1/cash/screen_with_applications.dart';
import 'package:wol_pro_1/volunteer/home/applications_vol.dart';
import 'package:wol_pro_1/volunteer/home/settings_home_vol.dart';
import 'package:http/http.dart' as http;
import '../../service/local_push_notifications.dart';
import '../new_screen_with_applications.dart';

String date = '';

String? Id_Of_current_application ='';
// DateTime date = DateTime.now();
class PageOfApplication extends StatefulWidget {
  const PageOfApplication({Key? key}) : super(key: key);

  @override
  State<PageOfApplication> createState() => _PageOfApplicationState();
}

var ID_of_vol_application;
class _PageOfApplicationState extends State<PageOfApplication> {

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? token = " ";

  @override
  void initState() {
    super.initState();

    // requestPermission();
    //
    // loadFCM();
    //
    // listenFCM();

    // getToken();

    // FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  void sendPushMessage() async {
    print("SSSSSSSSSSSSSSSSSSSsEEEEEEEEEENNNNNNNNNNNNNNNNNNNNDDDDDDDDDDDDDDDDDDDDD");
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key = AAAADY1uR1I:APA91bEruiKUQtfsFz0yWjEovi9GAF9nkGYfmW9H2lU6jrtdCGw2C1ZdEczYXvovHMPqQBYSrDnYsbhsyk-kcCBi6Wht_YrGcSKXw4vk0UUNRlwN9UdM_4rhmf_6hd_xyAXbBsgyx12L  ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'The volunteer has chosen your application to help you.',
              'title': 'Application is accepted'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "$token_ref",
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


  final CollectionReference applications =
  FirebaseFirestore.instance.collection('applications');

  String status_updated='Application is accepted';
  String volID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(49, 72, 103, 0.8),
        elevation: 0.0,
        title: Text('Application Info',style: TextStyle(fontSize: 16),),

      ),
      body: Container(
          color: Color.fromRGBO(234, 191, 213, 0.8),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .where('title', isEqualTo: card_title_vol)
                .where('category', isEqualTo: card_category_vol)
                .where('comment', isEqualTo: card_comment_vol)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              return ListView.builder(
                  itemCount: !streamSnapshot.hasData? 1:streamSnapshot.data?.docs.length,
                  itemBuilder: (ctx, index) {

                    print("WWWWWWWHHHHHAAAAAAATTTTT");
              if (streamSnapshot.hasData){
              switch (streamSnapshot.connectionState){
                case ConnectionState.waiting:
                  return  Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Awaiting data...'),
                        )
                      ]

                  );
                case ConnectionState.active:
                  return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                // "Title",
                                streamSnapshot.data?.docs[index]['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black,),textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5,left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                  streamSnapshot.data?.docs[index]['category'],
                                  style: TextStyle(color: Colors.grey,fontSize: 14),textAlign: TextAlign.center,),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30,left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(streamSnapshot.data?.docs[index]['comment'],style: TextStyle(color: Colors.grey,fontSize: 14),textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:20,bottom: 20),
                            child: SizedBox(
                              height: 50,
                              width: 300,
                              child: MaterialButton(
                                  child: Text("Accept",style: TextStyle(color: Colors.white),),
                                  color: Color.fromRGBO(18, 56, 79, 0.8),

                                  onPressed: () {
                                    sendPushMessage();
                                    date = DateTime.now().toString();
                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"status": status_updated});
                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"volunteerID": volID});
                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"date": date});
                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"token_vol": token_vol});
                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"volunteer_name": current_name_Vol});

                                    FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(streamSnapshot.data?.docs[index].id).update({"application_accepted": true});
                                   //  FirebaseFirestore.instance
                                   //      .collection('applications')
                                   //      .doc(streamSnapshot.data?.docs[index].id).update({"Id": streamSnapshot.data?.docs[index].id});
                                   //  print(streamSnapshot.data?.docs[index].id);
                                   // print("AAAAAAAAAAA ${FirebaseFirestore.instance
                                   //  .collection('applications').doc().id}");



                                   Id_Of_current_application = streamSnapshot.data?.docs[index].id;
                                   ID_of_vol_application=streamSnapshot.data?.docs[index].id;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ApplicationsOfVolunteer()),
                                    );

                              }
                              ),
                            ),
                          )
                        ],
                      );}}
              return Center(
                child: Padding(padding: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      SpinKitChasingDots(
                        color: Colors.brown,
                        size: 50.0,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                            "Waiting...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,fontSize: 24,color: Colors.black,)
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20),)
                    ],
                  ),
                ),
              );
                  });
            },
          ),
        ),

    );
  }
}
