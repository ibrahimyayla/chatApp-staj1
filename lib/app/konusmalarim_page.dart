import 'package:chat_app/app/kullanicilar.dart';
import 'package:chat_app/app/sysW/color.dart';
import 'package:chat_app/app/sysW/customCupertinoNavBar.dart';
import 'package:chat_app/viewModel/all_users_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/app/sohbet_page.dart';
import 'package:chat_app/model/konusma.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/viewModel/chat_view_model.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class KonusmalarimPage extends StatefulWidget {
  @override
  _KonusmalarimPageState createState() => _KonusmalarimPageState();
}

class _KonusmalarimPageState extends State<KonusmalarimPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);

    return CupertinoPageScaffold(
      navigationBar: navigationBarBuilder(context),
      child: FutureBuilder<List<Konusma>>(
        future: _userModel.getAllConversations(_userModel.user.userID),
        builder: (context, konusmaListesi) {
          print(konusmaListesi.hasData);
          if (!konusmaListesi.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var tumKonusmalar = konusmaListesi.data;
            if (tumKonusmalar.length > 0) {
              return RefreshIndicator(
                onRefresh: _konusmalarimListesiniYenile,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    var oankiKonusma = tumKonusmalar[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                          /*   builder: (context) => ChangeNotifierProvider(
                              builder: (context) => ChatViewModel(
                                  currentUser: _userModel.user,
                                  sohbetEdilenUser: User.idveResim(
                                      userID: oankiKonusma.kimle_konusuyor,
                                      profilURL:
                                          oankiKonusma.konusulanUserProfilURL)),
                              child: SohbetPage(),
                            ), */
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => ChatViewModel(
                                currentUser: _userModel.user,
                                sohbetEdilenUser: SystemUser.idveResim(
                                    userID: oankiKonusma.kimle_konusuyor,
                                    profilURL:
                                        oankiKonusma.konusulanUserProfilURL)),
                            child: SohbetPage(),
                          ),
                        ));
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(oankiKonusma.son_yollanan_mesaj),
                          subtitle: Text(oankiKonusma.konusulanUserName +
                              "  " +
                              oankiKonusma.aradakiFark),
                          leading: CircleAvatar(
                            /// note : Circle avatar arkasını saydamlaştırma için.
                            backgroundColor: Colors.grey.withAlpha(40),
                            backgroundImage:
                                NetworkImage(oankiKonusma.konusulanUserProfilURL),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: tumKonusmalar.length,
                ),
              );
            } else {
              /// note : refresh indicator scroll view olmadan kullanmak için
              /// scroll view olmadan kullanılmıyor yoksa.
              return RefreshIndicator(
                onRefresh: _konusmalarimListesiniYenile,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.supervised_user_circle,
                            color: Theme.of(context).primaryColor,
                            size: 120,
                          ),
                          Text(
                            "Henüz Konuşma Yok",
                            style: TextStyle(fontSize: 36),
                          )
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height - 150,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<Null> _konusmalarimListesiniYenile() async {
    /// note : Build metodu set state ile tekrardan yapıldıgı için sadece setState yaparak future' ı tekrardan çalıştırdık
    setState(() {});

    /// note : Bunu biraz bekleniyor izlenimi için yaptık gerek yoktu
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  CustomCupertinoNavigationBar navigationBarBuilder(BuildContext context) {
    return CustomCupertinoNavigationBar(
      // padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
      padding: EdgeInsetsDirectional.fromSTEB(8, 15, 15, 8),
      automaticallyImplyMiddle: true,
      automaticallyImplyLeading: true,
      leading: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          'Düzenle',
          style: TextStyle(color: Colors.white
              // fontWeight: FontWeight.
              ),
        ),
      ),
      trailing: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
              builder: (context) => ChangeNotifierProvider(
                  create: (_) => AllUserViewModel(), child: KullanicilarPage()),
              fullscreenDialog: true,
            ));
          },
          child: Container(
            child: Icon(
              CupertinoIcons.captions_bubble_fill,
              size: 22,
              color: Colors.white,
            ),
          )),
      height: 55,
      middle: Text(
        'Sohbetler',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: HexColor('128C7E'),
    );
  }
}
