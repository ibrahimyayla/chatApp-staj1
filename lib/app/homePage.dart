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

  }

  TabItem _currentTab = TabItem.Profil;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    // TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };
  Map<TabItem, Widget> tumSayfalar() {
    return {
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
