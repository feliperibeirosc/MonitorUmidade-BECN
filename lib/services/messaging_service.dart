import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessagingService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future initPushNotifications() async{
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );
  }

  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    checkTokenIsSaved(fCMToken.toString());
    initPushNotifications();
  }

  Future<void> checkTokenIsSaved(String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceUid = prefs.getString('deviceUID');
    if(deviceUid == null){
      const uuid = Uuid();
      deviceUid = uuid.v4();
      await prefs.setString('deviceUID', deviceUid);
      saveTokenToDatabase(token, deviceUid);
    }
  }

  Future<void> saveTokenToDatabase(String token, String deviceID) async{
    DatabaseReference devicesRef = FirebaseDatabase.instance.ref()
        .child('devices');
    devicesRef.child(deviceID).set(token);
  }
}