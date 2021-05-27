import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/model/konusma.dart';
import 'package:chat_app/model/mesaj.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/services/database_base.dart';
import 'package:chat_app/services/firebase_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tinycolor/tinycolor.dart';
class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(SystemUser user) async {
    ///note : addall diyerek map e eleman ekleyebiliyoruz.


    DocumentSnapshot _okunanUser =
        await _firebaseDB.doc("users/${user.userID}").get();
    if (_okunanUser.data() == null) {

      // print(user.userID);
      try {
        await _firebaseDB
            .collection("users")
            .doc(user.userID.toString())
            .set(user.toMap());
        return true;
      } catch (_) {
        // print("22");
        // print(_);
        // print("22");
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<SystemUser> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _firebaseDB.collection("users").doc(userID).get();
    Map<String, dynamic> _okunanUserBilgileriMap = _okunanUser.data();

    SystemUser _okunanUserNesnesi = SystemUser.fromMap(_okunanUserBilgileriMap);
    //print("Okunan user nesnesi :" + _okunanUserNesnesi.toString());
    return _okunanUserNesnesi;
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var users = await _firebaseDB
        .collection("users")
        .where("userName", isEqualTo: yeniUserName)
        .get();
    if (users.docs.length >= 1) {
      return false;
    } else {
      await _firebaseDB
          .collection("users")
          .doc(userID)
          .update({'userName': yeniUserName});
      return true;
    }
  }

  @override
  Future<bool> updateProfilFoto(SystemUser user, String profilFotoURL) async {
    PaletteGenerator paletteGenerator =await PaletteGenerator.fromImageProvider(
      NetworkImage(profilFotoURL),
    );
    if(paletteGenerator.dominantColor.color.isLight){
      if(user.imageHappy != 3){
        user.imageHappy++;
      }
    }else{
      if(user.imageHappy != 0){
        user.imageHappy--;
      }
    }

    await _firebaseDB
        .collection("users")
        .doc(user.userID)
        .update({'profilURL': profilFotoURL,'imageHappy':user.imageHappy});
    return true;
  }

  @override
  Future<List<SystemUser>> getAllUser() async {
    QuerySnapshot querySnapshot = await _firebaseDB.collection("users").get();
    List<SystemUser> tumKullanicilar = [];
    /*   for (DocumentSnapshot tekUser in querySnapshot.docs) {
      SystemUser _tekUser = SystemUser.fromMap(tekUser.data());
      tumKullanicilar.add(_tekUser);
      print("okunan user : " + tekUser.data().toString());
    }
 */
    /// map metodu ile
    tumKullanicilar = querySnapshot.docs
        .map((tekSatir) => SystemUser.fromMap(tekSatir.data()))
        .toList();
    return tumKullanicilar;
  }

/*
  @override
  Stream<Mesaj> getMessage(String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .doc(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        .doc(currentUserID)
        .snapshots();


    return snapShot.map((snapShot)=>Mesaj.fromMap(snapShot.data));
  }
*/

  @override
  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .doc(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        // .where("konusmaSahibi", isEqualTo: currentUserID)
      
        ///note : Orderby denilmediği zaman sıralı getirmiyor.
        .orderBy("date", descending: true)
        .limit(1)
        .snapshots();
    return snapShot.map((mesajListesi) =>
        mesajListesi.docs.map((mesaj) => Mesaj.fromMap(mesaj.data())).toList());
  }

  // Future<bool> saveMessage(Mesaj kaydedilecekMesaj) {}
  ///note : Canlı sohbet mesaj gönderme işlemi
  @override
  Future<bool> saveMessage(SystemUser user,Mesaj kaydedilecekMesaj) async {
    var _mesajID = _firebaseDB.collection("konusmalar").doc().id;

    /// mesaj gönderen için kayıt variable.
    var _myDocumentID =
        kaydedilecekMesaj.kimden + "--" + kaydedilecekMesaj.kime;

    /// mesaj alıcısı için kayıt variable.

    var _receiverDocumentID =
        kaydedilecekMesaj.kime + "--" + kaydedilecekMesaj.kimden;

    var _kaydedilecekMesajMapYapisi = kaydedilecekMesaj.toMap();

    await _firebaseDB
        .collection("konusmalar")
        .doc(_myDocumentID)
        .collection("mesajlar")
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection("konusmalar").doc(_myDocumentID).set({
      "konusma_sahibi": kaydedilecekMesaj.kimden,
      "kimle_konusuyor": kaydedilecekMesaj.kime,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    /// note : Mapi update diyerek güncelleyebiliyorsun.
    _kaydedilecekMesajMapYapisi.update("bendenMi", (deger) => false);
    _kaydedilecekMesajMapYapisi.update(
        "konusmaSahibi", (deger) => kaydedilecekMesaj.kime);

    await _firebaseDB
        .collection("konusmalar")
        .doc(_receiverDocumentID)
        .collection("mesajlar")
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection("konusmalar").doc(_receiverDocumentID).set({
      "konusma_sahibi": kaydedilecekMesaj.kime,
      "kimle_konusuyor": kaydedilecekMesaj.kimden,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });


    user = messageHappySetter(kaydedilecekMesaj.mesaj,user);
    await _firebaseDB
        .collection("users")
        .doc(kaydedilecekMesaj.kimden)
        .update({'messageHappy':user.messageHappy});

    return true;
  }


  messageHappySetter(String message,SystemUser user){

    List badText = ['salak','aptal','akılsız'];

    bool result = badText.where((element) => message.toLowerCase().contains(element)).isNotEmpty;
    if(result){
      if(user.messageHappy != 0){
        user.messageHappy--;
      }
    }else{
      if(user.messageHappy != 3){
        user.messageHappy++;
      }
    }
    return user;
  }

  @override
  Future<List<Konusma>> getAllConversations(String userID) async {
    try{
      QuerySnapshot querySnapshot = await _firebaseDB
          .collection("konusmalar")
          .where("konusma_sahibi", isEqualTo: userID)
          .orderBy("olusturulma_tarihi", descending: true)
          .get();
      print("query");
      print(querySnapshot);
      List<Konusma> tumKonusmalar = [];

      for (DocumentSnapshot tekKonusma in querySnapshot.docs) {
        Konusma _tekKonusma = Konusma.fromMap(tekKonusma.data());
        print("okunan konusma tarisi:" +
            _tekKonusma.olusturulma_tarihi.toDate().toString());
        tumKonusmalar.add(_tekKonusma);
      }

      return tumKonusmalar;
    }catch(e){
      print("hata");
      print(e);
    }


  }

  @override
  Future<DateTime> saatiGoster(String userID) async {
    await _firebaseDB.collection("server").doc(userID).set({
      "saat": FieldValue.serverTimestamp(),
    });

    var okunanMap = await _firebaseDB.collection("server").doc(userID).get();
    Timestamp okunanTarih = okunanMap.data()["saat"];
    return okunanTarih.toDate();
  }

  @override
  Future<List<SystemUser>> getUserwithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<SystemUser> _tumKullanicilar = [];

    if (enSonGetirilenUser == null) {
      _querySnapshot = await _firebaseDB
          .collection("users")
          .orderBy("userName")
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      _querySnapshot = await _firebaseDB
          .collection("users")
          .orderBy("userName")
          .startAfter([enSonGetirilenUser.userName])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      SystemUser _tekUser = SystemUser.fromMap(snap.data());
      _tumKullanicilar.add(_tekUser);
    }

    return _tumKullanicilar;
  }

  Future<List<Mesaj>> getMessagewithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Mesaj> _tumMesajlar = [];

    if (enSonGetirilenMesaj == null) {
      _querySnapshot = await _firebaseDB
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          // .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      _querySnapshot = await _firebaseDB
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          // .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .startAfter([enSonGetirilenMesaj.date])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Mesaj _tekMesaj = Mesaj.fromMap(snap.data());

      _tumMesajlar.add(_tekMesaj);
    }

    return _tumMesajlar;
  }
}
/*




  */ /*
  @override
  Stream<Mesaj> getMessage(String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .doc(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        .doc(currentUserID)
        .snapshots();


    return snapShot.map((snapShot)=>Mesaj.fromMap(snapShot.data));
  }
*/ /*

  @override
  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection("konusmalar")
        .doc(currentUserID + "--" + sohbetEdilenUserID)
        .collection("mesajlar")
        .where("konusmaSahibi", isEqualTo: currentUserID)
        .orderBy("date", descending: true)
        .limit(1)
        .snapshots();
    return snapShot.map((mesajListesi) => mesajListesi.documents
        .map((mesaj) => Mesaj.fromMap(mesaj.data))
        .toList());
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    var _mesajID = _firebaseDB.collection("konusmalar").doc().documentID;
    var _myDocumentID =
        kaydedilecekMesaj.kimden + "--" + kaydedilecekMesaj.kime;
    var _receiverDocumentID =
        kaydedilecekMesaj.kime + "--" + kaydedilecekMesaj.kimden;

    var _kaydedilecekMesajMapYapisi = kaydedilecekMesaj.toMap();

    await _firebaseDB
        .collection("konusmalar")
        .doc(_myDocumentID)
        .collection("mesajlar")
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection("konusmalar").doc(_myDocumentID).set({
      "konusma_sahibi": kaydedilecekMesaj.kimden,
      "kimle_konusuyor": kaydedilecekMesaj.kime,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    _kaydedilecekMesajMapYapisi.update("bendenMi", (deger) => false);
    _kaydedilecekMesajMapYapisi.update(
        "konusmaSahibi", (deger) => kaydedilecekMesaj.kime);

    await _firebaseDB
        .collection("konusmalar")
        .doc(_receiverDocumentID)
        .collection("mesajlar")
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB
        .collection("konusmalar")
        .doc(_receiverDocumentID)
        .set({
      "konusma_sahibi": kaydedilecekMesaj.kime,
      "kimle_konusuyor": kaydedilecekMesaj.kimden,
      "son_yollanan_mesaj": kaydedilecekMesaj.mesaj,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> saatiGoster(String userID) async {
    await _firebaseDB.collection("server").doc(userID).set({
      "saat": FieldValue.serverTimestamp(),
    });

    var okunanMap =
        await _firebaseDB.collection("server").doc(userID).get();
    Timestamp okunanTarih = okunanMap.data["saat"];
    return okunanTarih.toDate();
  }

  @override
  Future<List<SystemUser>> getUserwithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<SystemUser> _tumKullanicilar = [];

    if (enSonGetirilenUser == null) {
      _querySnapshot = await Firestore.instance
          .collection("users")
          .orderBy("userName")
          .limit(getirilecekElemanSayisi)
          .getDocuments();
    } else {
      _querySnapshot = await Firestore.instance
          .collection("users")
          .orderBy("userName")
          .startAfter([enSonGetirilenUser.userName])
          .limit(getirilecekElemanSayisi)
          .getDocuments();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.documents) {
      SystemUser _tekUser = SystemUser.fromMap(snap.data);
      _tumKullanicilar.add(_tekUser);
    }

    return _tumKullanicilar;
  }

  Future<List<Mesaj>> getMessagewithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Mesaj> _tumMesajlar = [];

    if (enSonGetirilenMesaj == null) {
      _querySnapshot = await Firestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .limit(getirilecekElemanSayisi)
          .getDocuments();
    } else {
      _querySnapshot = await Firestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + sohbetEdilenUserID)
          .collection("mesajlar")
          .where("konusmaSahibi", isEqualTo: currentUserID)
          .orderBy("date", descending: true)
          .startAfter([enSonGetirilenMesaj.date])
          .limit(getirilecekElemanSayisi)
          .getDocuments();

      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.documents) {
      Mesaj _tekMesaj = Mesaj.fromMap(snap.data);
      _tumMesajlar.add(_tekMesaj);
    }

    return _tumMesajlar;
  }

  Future<String> tokenGetir(String kime) async {
    DocumentSnapshot _token =
        await _firebaseDB.doc("tokens/" + kime).get();
    if (_token != null)
      return _token.data["token"];
    else
      return null;
  }*/
