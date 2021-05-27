import 'dart:io';

import 'package:chat_app/locator.dart';
import 'package:chat_app/model/konusma.dart';
import 'package:chat_app/model/mesaj.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/services/auth_base.dart';
import 'package:chat_app/services/fake_auth_service.dart';
import 'package:chat_app/services/firebase_auth_service.dart';
import 'package:chat_app/services/firebase_storage_service.dart';
import 'package:chat_app/services/firestore_db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tinycolor/tinycolor.dart';

enum AppMode { DEBUG, RELEASE }

class UserRepository extends AuthBase {
  FirebaseAuthService _firebaseAuthService = getIt<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      getIt<FakeAuthenticationService>();
  FirestoreDBService _firestoreDBService = getIt<FirestoreDBService>();
  FirebaseStorageService _firebaseStorageService =
      getIt<FirebaseStorageService>();
  List<SystemUser> tumKullaniciListesi = [];
  AppMode appMode = AppMode.RELEASE;
  @override
  Future<SystemUser> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      SystemUser _user = await _firebaseAuthService.currentUser();
      return await _firestoreDBService.readUser(_user.userID);
    }
  }

  @override
  Future<bool> signOut() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<SystemUser> singInAnonymously() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.singInAnonymously();
    } else {
      return await _firebaseAuthService.singInAnonymously();
    }
  }

  @override
  Future<SystemUser> signInWithGoogle() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithGoogle();
    } else {
      print("gel");
      SystemUser _user = await _firebaseAuthService.signInWithGoogle();
      print(_user);
      print("_user");
      bool _sonuc = await _firestoreDBService.saveUser(_user);
      print(_sonuc);
      return _user != null ? _user : null;
    }
  }

  @override
  Future<SystemUser> signInWithFacebook() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithFacebook();
    } else {
      SystemUser _user = await _firebaseAuthService.signInWithFacebook();
      // print("111");
      // print(_user.toString());
      // print("111");
      bool _sonuc = await _firestoreDBService.saveUser(_user);
      // print(_sonuc);
      return _user != null ? _user : null;
    }
  }

  @override
  Future<SystemUser> createUserWithEmailandPassword(
      String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.createUserWithEmailandPassword(
          email, sifre);
    } else {
      print("createUserWithEmailandPassword");
      SystemUser _user = await _firebaseAuthService
          .createUserWithEmailandPassword(email, sifre);
      bool _sonuc = await _firestoreDBService.saveUser(_user);

      return _sonuc ? await _firestoreDBService.readUser(_user.userID) : null;
    }
  }

  @override
  Future<SystemUser> signInWithEmailandPassword(
      String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithEmailandPassword(
          email, sifre);
    } else {
      SystemUser _user =
          await _firebaseAuthService.signInWithEmailandPassword(email, sifre);
      return await _firestoreDBService.readUser(_user.userID);
    }
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName) async {
    if (appMode == AppMode.DEBUG) {
      return false;
    } else {
      return await _firestoreDBService.updateUserName(userID, yeniUserName);
    }
  }

  @override
  Future<String> uploadFile(
      SystemUser user, String fileType, File profilFoto) async {
    if (appMode == AppMode.DEBUG) {
      return "dosya_indirme_linki";
    } else {
      var profilFotoURL = await _firebaseStorageService.uploadFile(
          user.userID, fileType, profilFoto);
      await _firestoreDBService.updateProfilFoto(user, profilFotoURL);
      return profilFotoURL;
    }
  }


  Future<List<SystemUser>> getAllUsers() async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      /// tum kullanıcılar sınıftaki degiskene atılıyor.
      tumKullaniciListesi = await _firestoreDBService.getAllUser();
      // print(tumKullaniciListesi.toString());
      return tumKullaniciListesi;
    }
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    if (appMode == AppMode.DEBUG) {
      /// note : Boş stream göndermek için.
      return Stream.empty();
    } else {
      return _firestoreDBService.getMessages(currentUserID, sohbetEdilenUserID);
    }
  }

  Future<List<Mesaj>> getMessageWithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      return await _firestoreDBService.getMessagewithPagination(currentUserID,
          sohbetEdilenUserID, enSonGetirilenMesaj, getirilecekElemanSayisi);
    }
  }

  Future<bool> saveMessage(
      Mesaj kaydedilecekMesaj, SystemUser currentUser) async {
    if (appMode == AppMode.DEBUG) {
      /// note : Boş stream göndermek için.
      return Future.value(true);
    } else {
      return await _firestoreDBService.saveMessage(currentUser,kaydedilecekMesaj);
    }
  }

  Future<List<Konusma>> getAllConversations(String userID) async {
    if (appMode == AppMode.DEBUG) {
      /// note : Boş stream göndermek için.
      // return Future.value(true);
      return null;
    } else {
      print(userID);
      print("userID");
      var konusmaListesi =
          await _firestoreDBService.getAllConversations(userID);
      print("konusma");
      print(konusmaListesi);
      ///kullanıcı giriş yaptıgında saati dbye yazıyoruz.Telefon saatini kullanmıyoruz.
      DateTime _zaman = await _firestoreDBService.saatiGoster(userID);
      for (var oankiKonusma in konusmaListesi) {
        var userListesindekiKullanici =
            listedeUserBul(oankiKonusma.kimle_konusuyor);

        if (userListesindekiKullanici != null) {
          print("VERILER LOCAL CACHEDEN OKUNDU");
          oankiKonusma.konusulanUserName = userListesindekiKullanici.userName;
          oankiKonusma.konusulanUserProfilURL =
              userListesindekiKullanici.profilURL;
          oankiKonusma.sonOkunmaZamani = _zaman;
          timeago.setLocaleMessages("tr", timeago.TrMessages());

          /// aradaki fark sistemde bulunan saati ile mesajı gösterme zamanı arasındaki fark oluyor.
          var duration =
              _zaman.difference(oankiKonusma.olusturulma_tarihi.toDate());
          oankiKonusma.aradakiFark =
              timeago.format(_zaman.subtract(duration), locale: "tr");
        } else {
          print("VERILER VERITABANINDAN OKUNDU");
          /*print(
              "aranılan user daha önceden veritabanından getirilmemiş, o yüzden veritabanından bu degeri okumalıyız");*/
          var _veritabanindanOkunanUser =
              await _firestoreDBService.readUser(oankiKonusma.kimle_konusuyor);
          oankiKonusma.konusulanUserName = _veritabanindanOkunanUser.userName;
          oankiKonusma.konusulanUserProfilURL =
              _veritabanindanOkunanUser.profilURL;
          oankiKonusma.sonOkunmaZamani = _zaman;
          var duration =
              _zaman.difference(oankiKonusma.olusturulma_tarihi.toDate());

          timeago.setLocaleMessages("tr", timeago.TrMessages());

          /// note : Ne kadar önce oldugunu veren bir kütüp. Timeago
          oankiKonusma.aradakiFark =
              timeago.format(_zaman.subtract(duration), locale: "tr");
        }
        timeagoHesapla(oankiKonusma, _zaman);

        // timeagoHesapla(oankiKonusma, _zaman);
      }

      return konusmaListesi;
    }
  }

  void timeagoHesapla(Konusma oankiKonusma, DateTime zaman) {
    oankiKonusma.sonOkunmaZamani = zaman;

    timeago.setLocaleMessages("tr", timeago.TrMessages());

    var _duration = zaman.difference(oankiKonusma.olusturulma_tarihi.toDate());
    oankiKonusma.aradakiFark =
        timeago.format(zaman.subtract(_duration), locale: "tr");
  }

  SystemUser listedeUserBul(String userID) {
    for (int i = 0; i < tumKullaniciListesi.length; i++) {
      if (tumKullaniciListesi[i].userID == userID) {
        return tumKullaniciListesi[i];
      }
    }

    return null;
  }

  Future<List<SystemUser>> getUserWithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      List<SystemUser> _userList = await _firestoreDBService
          .getUserwithPagination(enSonGetirilenUser, getirilecekElemanSayisi);
      tumKullaniciListesi.addAll(_userList);
      return _userList;
      /* return _firestoreDBService.getUserwithPagination(
          enSonGetirilenUser, getirilecekElemanSayisi); */
    }
  }
}
