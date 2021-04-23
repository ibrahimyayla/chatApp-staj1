import 'package:chat_app/app/sign_in/email_sifre_giris_ve_kayit.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/app/homePage.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:provider/provider.dart';


class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*final _userModel = Provider.of<UserModel>(context);
    if (_userModel.user == null) {

      return SignInPage();
    } else {
      return Homepage(
        user: _userModel.user,
      );
    }*/
    final _userModel = Provider.of<UserModel>(context, listen: true);
    // "listen" default olarak "true " kabul edildigi icin bunu yazmaya da bilisiniz
    if (_userModel.state == ViewState.Idle) {
      if (_userModel.user == null) {
        /// note : Callbackler gönderilidiğinde tanımlandığı blockta çalışıyor
        /// unutma. Sadece fluttera özel değil.
        return EmailSifreLoginPage();
      } else {
        print("buraya geldi");
        return Homepage(user: _userModel.user);
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
