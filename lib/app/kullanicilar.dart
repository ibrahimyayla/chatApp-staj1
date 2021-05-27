import 'package:chat_app/app/color_page.dart';
import 'package:chat_app/app/sysW/color.dart';
import 'package:chat_app/app/sysW/customCupertinoNavBar.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/app/sohbet_page.dart';
import 'package:chat_app/viewModel/all_users_view_model.dart';
import 'package:chat_app/viewModel/chat_view_model.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:provider/provider.dart';

class KullanicilarPage extends StatefulWidget {
  @override
  _KullanicilarPageState createState() => _KullanicilarPageState();
}

class _KullanicilarPageState extends State<KullanicilarPage> {
  ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  /*  bool _hasMore = false;
  int _getirilecekElemanSayisi = 10;
  SystemUser _enSonGetirilenUser; */

  @override
  void initState() {
    super.initState();

    /// note : Build metodu çalıştıktan sonra init state içindeki bu kod sayesinde buildten sonra
    /// bunu çalıştırır.
    /* SchedulerBinding.instance.addPostFrameCallback((_) {
      getUser();
    }); */
    // getUser();
    _scrollController.addListener(_listeScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    // final _tumKullanicilarViewModel = Provider.of<AllUserViewModel>(context);
    return CupertinoPageScaffold(
      navigationBar: navigationBarBuilder(context),
      child: Consumer<AllUserViewModel>(
        ///model ağaca enjekte edilen nesneyi temsil ediyor.
        builder: (context, model, child) {
          if (model.state == AllUserViewState.Busy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (model.state == AllUserViewState.Loaded) {
            return RefreshIndicator(
              onRefresh: model.refresh,
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  /// burası her zaman calısıyor ama is loading false oldugu için gösterilmiyor.
/* if (index == _tumKullanicilar.length) {
                        return _yeniElemanlarYukleniyorIndicator();
                      } */
                  if (model.kullanicilarListesi.length == 1) {
                    return _kullaniciYokUi();
                  } else if (model.hasMoreLoading &&
                      index == model.kullanicilarListesi.length) {
                    return _yeniElemanlarYukleniyorIndicator();
                    // return null;
                  } else {
                    return _userListeElemaniOlustur(index);
                  }
                },

                // itemCount: model.kullanicilarListesi.length + 1);
                // itemCount: model.kullanicilarListesi.length);
                itemCount: model.hasMoreLoading
                    ? model.kullanicilarListesi.length + 1
                    : model.kullanicilarListesi.length,
              ),
            );
          }
          return null;
        },

        ///note : child ile güncellenmesini istemediklerini tanımlayabiliyorsun.
      ),
    );
  }
  
  CustomCupertinoNavigationBar navigationBarBuilder(BuildContext context) {
    return CustomCupertinoNavigationBar(
      padding: EdgeInsetsDirectional.fromSTEB(8, 15, 15, 8),
      automaticallyImplyLeading: false,

      trailing: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Vazgeç',
            style: TextStyle(color: Colors.white
              // fontWeight: FontWeight.
            ),
          )
      ),
      height: 55,
      middle: Text(
        'Yeni Sohbet',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: HexColor('128C7E'),
    );
  }

  Widget _userListeElemaniOlustur(int index) {
    // var _oankiUser = _tumKullanicilar[index];
    final _userModel = Provider.of<UserModel>(context, listen: false);
    final _tumKullanicilarViewModel =
        Provider.of<AllUserViewModel>(context, listen: false);
    final SystemUser _oankiUser = _tumKullanicilarViewModel.kullanicilarListesi[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ChatViewModel>(
                  create: (context) => ChatViewModel(
                      currentUser: _userModel.user,
                      sohbetEdilenUser: _oankiUser),
                  child: SohbetPage(),
                )));
      },
      child: Card(
        child: ListTile(
          title: Text(_oankiUser.userName),
          subtitle: Text(_oankiUser.email),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.withAlpha(40),
            backgroundImage: NetworkImage(_oankiUser.profilURL),
          ),
          trailing: happyStatus(_oankiUser),
        ),
      ),
    );
  }

  happyStatus(SystemUser user){
    num happy = user.imageHappy + user.messageHappy;
    if(happy<=6 && happy > 4){
      return Icon(
        Icons.sentiment_very_satisfied,
      );
    }
    else if(happy <=4 && happy > 2){
      return Icon(
        Icons.sentiment_neutral,
      );
    }
    else{
      return Icon(
        Icons.sentiment_very_dissatisfied,
      );
    }
  }

  void _listeScrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // getUser();
      print("Listenin en altındayız");
      dahaFazlaKullaniciGetir();
    }
  }

  _yeniElemanlarYukleniyorIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  void dahaFazlaKullaniciGetir() async {
    if (_isLoading == false) {
      _isLoading = true;
      final _tumKullanicilarViewModel =
          Provider.of<AllUserViewModel>(context, listen: false);
      await _tumKullanicilarViewModel.dahaFazlaUserGetir();
      _isLoading = false;
    }
  }

  Widget _kullaniciYokUi() {
    final _kullanicilarModel = Provider.of<AllUserViewModel>(context);
    return RefreshIndicator(
      onRefresh: _kullanicilarModel.refresh,
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
                  "Henüz Kullanıcı Yok",
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
