import 'package:chat_app/app/sysW/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/locator.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/app/landing_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    setupLocator();
  } catch (e) {
    debugPrint(e.toString());
  }
  runApp(MyApp());
}

///note : Navigator push dediğinde baska dala ayrıldıgın için viewmodel
///da sıkıntı olabiliyor. Kapsamın yeterli oldugundan emin ol.
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserModel(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryTextTheme: TextTheme(
                headline6: TextStyle(
                    color: Colors.white
                )
            ),

            primaryColor:HexColor('128C7E') ,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: LandingPage()),
    );
  }
}
