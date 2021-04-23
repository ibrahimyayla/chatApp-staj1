// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/app/konusmalarim_page.dart';
import 'package:chat_app/app/kullanicilar.dart';
import 'package:chat_app/app/my_custom_bottom_navi.dart';
import 'package:chat_app/app/profil.dart';
import 'package:chat_app/app/tab_items.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/viewModel/all_users_view_model.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  SystemUser user;

  Homepage({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    // NotificationHandler().initializeFCMNotification(context);
    /// note : id ile mesaj gönderme
/* {
    "notification": {
        "body": "this is a body",
        "title": "this is a title"
    },
    "priority": "high",
    "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
    },
    "to": "dBnoEDifRH26J8lKcS1_lL:APA91bHQIqbRxvdXJoV3tfuzV-GerTO_LAdQwvduyR3C1F-9pQwqdypAaf2Jlfj4_uMRmHor_W4XZJcTdJYABzE1_Oc-BZ2F-qqqUacaDK3oNQlRKYEAIdWSV5z7F0bWUUe1Poa9UPcW"
} */
    ///note : Topic ile mesaj gönderme
/*
{
    "notification": {
        "body": "this is a body",
        "title": "this is a title"
    },
    "priority": "high",
    "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
    },
    "to": "/topics/all"
} */

/* ///note : normal csm ile atınca notif. kısmında ek tanım olmadıgından özelleştirme olmuyor.
/// ama tanımlamaz isekte bildirim gözükmüyor. O yüzden özel kütüp. kullanıyıoruz.
    ///note : topicte belirtilen tüm beldirimlen kullanıcıya ulaşacak.
    _firebaseMessaging.subscribeToTopic("all");
    _firebaseMessaging.configure(
      ///note : Cloud messaging stabil olmadıgından kendi metodlarından sadece onBackgroundMessage kullanıyoruz.
      ///ve bildiirm geldiğinde bunlarla istediğimiz sayfaya direk yönlendiremiyoruz.

      /// note : Uygulama acıkken bildirim geldiğinde tetiklenir.
      onMessage: (Map<String, dynamic> message) async {
        PlatformDuyarliAlertDialog(
          baslik: message["notification"]["title"],
          icerik: message['notification']['body'],
          anaButonYazisi: 'Tamam',
        ).goster(context);
        print("onMessage: $message");
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      /// note : Bildirim geldiğinde notf. boş oluyor. datasında param. gönder.

      ///note : Bildirime tıklanıldıgında tetiklenir.

      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },

      /// note : uygulama simge durumuna küçültüldüğünde bild.
      onResume: (Map<String, dynamic> message) async {
        PlatformDuyarliAlertDialog(
          baslik: message["data"]["title"],
          icerik: message['data']['body'],
          anaButonYazisi: 'Tamam',
        ).goster(context);
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      print(token);
      /* assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText); */
    });
  } */
  }

  TabItem _currentTab = TabItem.Profil;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };
  Map<TabItem, Widget> tumSayfalar() {
    return {
      TabItem.Kullanicilar: ChangeNotifierProvider(
        create: (context) => AllUserViewModel(),
        child: KullanicilarPage(),
      ),
      TabItem.Konusmalarim: KonusmalarimPage(),
      TabItem.Profil: ProfilPage(),
    };
  }

  /// note : State değişmesinde build tetikleniyor.
  @override
  Widget build(BuildContext context) {
    /*_firebaseMessaging.getToken().then((String token) {
      print(token);
      */ /* assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText); */ /*
    });*/
    return WillPopScope(
      // onWillPop: () => Future.value(false),

      onWillPop: () async =>

          ///note : maybePop varsa çıkartıyor ve bize true değer döndürüyor
          ///yok ise false döndürüyor ve butonu aktif ediyoruz.
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: MyCustomBottomNavigation(
        navigatorKeys: navigatorKeys,
        sayfaOlusturucu: tumSayfalar(),
        currentTab: _currentTab,
        onSelectedTab: (secilenTab) {
          if (secilenTab == _currentTab) {
            ///note : rotayı baslangıca getirmek için
            navigatorKeys[secilenTab]
                .currentState
                .popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _currentTab = secilenTab;
            });
          }

          print("Seclien tab item :" + secilenTab.toString());
        },
      ),
    );
  }
}
