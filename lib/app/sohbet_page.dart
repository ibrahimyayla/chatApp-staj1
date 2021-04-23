import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/model/mesaj.dart';
import 'package:chat_app/viewModel/chat_view_model.dart';
import 'package:chat_app/viewModel/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SohbetPage extends StatefulWidget {
  /*  SystemUser currentUser;
  SystemUser sohbetEdilenUser;
  const SohbetPage({
    Key key,
    this.currentUser,
    this.sohbetEdilenUser,
  }) : super(key: key); */

  SohbetPage({Key key}) : super(key: key);

  @override
  SohbetPageState createState() {
    return SohbetPageState();
  }
}

class SohbetPageState extends State<SohbetPage> {
  var _mesajController = TextEditingController();
  bool _isLoading = false;

  /// note : Chat vs. için scrolu en sona alma convert yapıp terside yapabilirsin.
  ScrollController _scrollController = ScrollController();

  SohbetPageState();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _chatModel = Provider.of<ChatViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Sohbet"),
      ),
      body: _chatModel.state == ChatViewState.Busy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                children: <Widget>[
                  _buildMesajListesi(),
                  _buildYeniMesajGir(),
                ],
              ),
            ),
    );
  }

  Widget _buildMesajListesi() {
    final _chatModel = Provider.of<ChatViewModel>(context, listen: false);

    return Consumer<ChatViewModel>(
      builder: (context, chatModel, child) {
        return Expanded(
          child: ListView.builder(

              /// note : Reverse verildiği zaman en sondan başlıyor.""
              reverse: true,
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (chatModel.hasMoreLoading &&
                    chatModel.mesajlarListesi.length == index) {
                  return _yeniElemanlarYukleniyorIndicator();
                } else
                  return _konusmaBalonuOlustur(
                      chatModel.mesajlarListesi[index]);
              },
              itemCount: chatModel.hasMoreLoading
              ? chatModel.mesajlarListesi.length + 1
              : chatModel.mesajlarListesi.length,
        ));
      },
    );
  }

  Widget _buildYeniMesajGir() {
    final _chatModel = Provider.of<ChatViewModel>(context, listen: false);

    return Container(
      margin: EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _mesajController,
              cursorColor: Colors.blueGrey,
              style: new TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: "Mesajınızı Yazın",
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: FloatingActionButton(
                onPressed: () async {
                  if (_mesajController.text.trim().length > 0) {
                    Mesaj _kaydedilecekMesaj = Mesaj(
                        kimden: _chatModel.currentUser.userID,
                        kime: _chatModel.sohbetEdilenUser.userID,
                        bendenMi: true,
                        mesaj: _mesajController.text);
              
                    var sonuc =
                        await _chatModel.saveMessage(_kaydedilecekMesaj,_chatModel.currentUser);
                        true;
                    if (sonuc) {
                      _mesajController.clear();
                      _scrollController.animateTo(
                          // _scrollController.position.maxScrollExtent,
                          0.0,
                          curve: Curves.easeOut,
                          duration: Duration(milliseconds: 300));
                    }
                  }
                },
                elevation: 0,
                backgroundColor: Colors.blue,
                child: Icon(Icons.navigation, size: 35, color: Colors.white),
              ))
        ],
      ),
    );
  }

  String _saatDakikaGoster(Timestamp date) {
    var _formatter = DateFormat.Hm();

    /// note : Tarih formatlamak için intl paketi kuruldu
    var _formatlanmisTarih = _formatter.format(date.toDate());
    return _formatlanmisTarih;
  }

  Widget _konusmaBalonuOlustur(Mesaj oankiMesaj) {
    Color _gelenMesajRenk = Colors.blue;

    ///note : Temada bulunan rengi almak için örnek.
    Color _gidenMesajRenk = Theme.of(context).primaryColor;
    final _chatModel = Provider.of<ChatViewModel>(context);

    var _saatDakikaDegeri = "";

    try {
      _saatDakikaDegeri = _saatDakikaGoster(oankiMesaj.date ?? Timestamp(1, 1));
    } catch (e) {
      print("hata var:" + e.toString());
    }
    var _benimMesajimMi = oankiMesaj.bendenMi;
    if (_benimMesajimMi) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ///note : Flexible veya Expanded ile taşma problemini çözüyoruz.
                Flexible(
                  child: Container(
                    /// note : Container tasarım için BoxDecoration!
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gidenMesajRenk,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(4),
                    child: Text(
                      oankiMesaj.mesaj,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.grey.withAlpha(40),

                  /// note :backgroundImage de networkImage yada assert
                  backgroundImage:
                      // NetworkImage(_chatModel.sohbetEdilenUser.profilURL),
                      NetworkImage(_chatModel.sohbetEdilenUser.profilURL),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gelenMesajRenk,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(4),
                    child: Text(oankiMesaj.mesaj),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            )
          ],

          /// note : Chat balon için crossAxisALignMent!!
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      eskiMesajlariGetir();
    }
  }

  void eskiMesajlariGetir() async {
    final _chatModel = Provider.of<ChatViewModel>(context,listen: false);
    if (_isLoading == false) {
      _isLoading = true;
      await _chatModel.dahaFazlaMesajGetir();
      _isLoading = false;
    }
  }

  Widget _yeniElemanlarYukleniyorIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
