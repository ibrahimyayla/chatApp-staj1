import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/app/hata_exception.dart';
import 'package:chat_app/common_widget/platform_duyarli_alert_dialog.dart';
import 'package:chat_app/common_widget/social_log_in_button.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:provider/provider.dart';

enum FormType { Register, LogIn }

class EmailSifreLoginPage extends StatefulWidget {
  @override
  _EmailSifreLoginPageState createState() => _EmailSifreLoginPageState();
}

class _EmailSifreLoginPageState extends State<EmailSifreLoginPage> {
  String _email, _sifre;
  String _butonText, _linkText;
  var _formType = FormType.LogIn;

  final _formKey = GlobalKey<FormState>();
  void _formSubmit() async {
    _formKey.currentState.save();
    //debugPrint("email :" + _email + " şifre:" + _sifre);
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_formType == FormType.LogIn) {
      try {
        SystemUser _girisYapanUser =
            await _userModel.signInWithEmailandPassword(_email, _sifre);

        if (_girisYapanUser != null)
          print("Oturum açan user id:" + _girisYapanUser.userID.toString());
      } catch (e) {
        print(e.code);
        Hatalar.goster(e.code.toString());

        PlatformDuyarliAlertDialog(
          baslik: "Oturum Açma HATA",
          icerik: Hatalar.goster(e.code),
          anaButonYazisi: 'Tamam',
        ).goster(context);
      }
    } else {
      try {
        SystemUser _olusturulanUser =
            await _userModel.createUserWithEmailandPassword(_email, _sifre);
        if (_olusturulanUser != null)
          print("Oturum açan user id:" + _olusturulanUser.userID.toString());
      } on FirebaseAuthException catch (e) {
        print(e.code);
        Hatalar.goster(e.code.toString());
        /*showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Kullanıcı Oluşturma Hatası"),
                content: Text(Hatalar.goster(e.code)),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Tamam"))
                ],
              );
            });*/
        PlatformDuyarliAlertDialog(
          baslik: "Kullanıcı Oluşturma HATA",
          icerik: Hatalar.goster(e.code),
          anaButonYazisi: 'Tamam',
        ).goster(context);
      }
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.LogIn ? FormType.Register : FormType.LogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context, listen: true);
    _butonText = _formType == FormType.LogIn ? "Giriş Yap " : "Kayıt Ol";
    _linkText = _formType == FormType.LogIn
        ? "Hesabınız Yok Mu? Kayıt Olun"
        : "Hesabınız Var Mı? Giriş Yapın";
    if (_userModel.user != null) {
      /// note : Sayfa geçişinde hata alırsan dene.
      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
      });
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
      ),
      body: _userModel.state == ViewState.Idle
          ? SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        errorText: _userModel.emailHataMesaji != null
                            ? _userModel.emailHataMesaji
                            : null,
                        prefixIcon: Icon(Icons.mail),
                        hintText: 'Email adresinizi giriniz.',
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (String girilenEmail) {
                        _email = girilenEmail;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),

                        /// note : İnput hata mesajı özelleştirme
                        errorText: _userModel.sifreHataMesaji != null
                            ? _userModel.sifreHataMesaji
                            : null,
                        hintText: 'Parolanızı giriniz',
                        labelText: 'Sifre',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (String girilenSifre) {
                        _sifre = girilenSifre;
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SocialLoginButton(
                      butonText: _butonText,
                      butonColor: Theme.of(context).primaryColor,
                      radius: 10,

                      /// note : Stful widgette context degeri atamana gerek yok
                      /// sayfada tamammen geçerli
                      onPressed: () => _formSubmit(),
                    ),
                    SizedBox(
                      height: 8,
                    ),

                    ///note : Parolamı unuttum vs. için buton !!!
                    FlatButton(
                      onPressed: () => _degistir(),
                      child: Text(_linkText),
                    )
                  ],
                ),
              ),
            ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
