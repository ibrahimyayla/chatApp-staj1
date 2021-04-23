import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:chat_app/locator.dart';
import 'package:chat_app/model/konusma.dart';
import 'package:chat_app/model/mesaj.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/repository/user_repository.dart';
import 'package:chat_app/services/auth_base.dart';

enum ViewState { Idle, Busy }

class UserModel extends AuthBase with ChangeNotifier {
  ViewState _state = ViewState.Idle;
  UserRepository _userRepository = getIt<UserRepository>();
  SystemUser _user;
  String emailHataMesaji;
  String sifreHataMesaji;

  SystemUser get user => _user;

  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  UserModel() {
    try{
      currentUser();

    }catch(e){
      print("asdasd");
    }
  }

  @override
  Future<SystemUser> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      return _user;
    } catch (_) {
      debugPrint("hata " + _);
      return null;
    } finally {
      /// ne olursa olsun işlem olduktan sonra boşa çıkarıyoruz.
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      _user = null;
      return await _userRepository.signOut();
    } catch (_) {
      debugPrint("hata " + _);
      return false;
    } finally {
      /// ne olursa olsun işlem olduktan sonra boşa çıkarıyoruz.
      state = ViewState.Idle;
    }
  }

  @override
  Future<SystemUser> singInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.singInAnonymously();
      return _user;
    } catch (_) {
      debugPrint("hata " + _);
      return null;
    } finally {
      /// ne olursa olsun işlem olduktan sonra boşa çıkarıyoruz.
      state = ViewState.Idle;
    }
  }

  @override
  Future<SystemUser> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      return _user;
    } catch (_) {
      debugPrint("hata " + _);
      return null;
    } finally {
      /// ne olursa olsun işlem olduktan sonra boşa çıkarıyoruz.
      state = ViewState.Idle;
    }
  }

  @override
  Future<SystemUser> signInWithFacebook() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithFacebook();
      return _user;
    } catch (_) {
      debugPrint("hata " + _);
      return null;
    } finally {
      /// ne olursa olsun işlem olduktan sonra boşa çıkarıyoruz.
      state = ViewState.Idle;
    }
  }

  @override
  Future<SystemUser> createUserWithEmailandPassword(
      String email, String sifre) async {
    if (_emailSifreKontrol(email, sifre)) {
      try {
        state = ViewState.Busy;
        _user =
            await _userRepository.createUserWithEmailandPassword(email, sifre);
        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else
      return null;
  }

  @override
  Future<SystemUser> signInWithEmailandPassword(
      String email, String sifre) async {
    if (_emailSifreKontrol(email, sifre)) {
      try {
        state = ViewState.Busy;
        _user = await _userRepository.signInWithEmailandPassword(email, sifre);
        print("user   " + _user.toString());
        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else
      return null;
  }

  bool _emailSifreKontrol(String email, String sifre) {
    var sonuc = true;

    if (sifre.length < 6) {
      sifreHataMesaji = "En az 6 karakter olmalı";
      sonuc = false;
    } else
      sifreHataMesaji = null;
    if (!email.contains('@')) {
      emailHataMesaji = "Geçersiz email adresi";
      sonuc = false;
    } else
      emailHataMesaji = null;
    return sonuc;
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var sonuc = await _userRepository.updateUserName(userID, yeniUserName);
    if (sonuc) {
      _user.userName = yeniUserName;
    }
    return sonuc;
  }

  Future<String> uploadFile(
      String userID, String fileType, File profilFoto) async {
    var indirmeLinki =
        await _userRepository.uploadFile(userID, fileType, profilFoto);
    return indirmeLinki;
  }

  Future<List<SystemUser>> getAllUser() async {
    var tumKullaniciListesi = await _userRepository.getAllUsers();
    return tumKullaniciListesi;
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    return _userRepository.getMessages(currentUserID, sohbetEdilenUserID);
  }

  /* Future<bool> saveMessage(Mesaj kaydedilecekMesaj) {
    return _userRepository.saveMessage(kaydedilecekMesaj);
  } */

  Future<List<Konusma>> getAllConversations(String userID) {
    return _userRepository.getAllConversations(userID);
  }

  Future<List<SystemUser>> getUserWithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi) async {
    return await _userRepository.getUserWithPagination(
        enSonGetirilenUser, getirilecekElemanSayisi);
  }

  /* Future<List<SystemUser>> getAllUser(String email,String sifre) {
    if (_emailSifreKontrol(email, sifre)) {
              try {
        state = ViewState.Busy;
        SystemUser _user = await _userRepository.signInWithEmailandPassword(email, sifre);
        print("user   " + _user.toString());
        return [];
      } finally {
        state = ViewState.Idle;
      }
    } else
      return null;
  } */

}
