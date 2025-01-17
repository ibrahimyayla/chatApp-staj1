import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/services/auth_base.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<SystemUser> currentUser() async {
    try {
      User user = _firebaseAuth.currentUser;
      return Future.value(_userFromFirebase(user));
    } catch (e) {
      print("HATA CURRENT SystemUser" + e.toString());
      return null;
    }
  }

  SystemUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    } else {
      return SystemUser(userID: user.uid, email: user.email);
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final _facebookLogin = FacebookLogin();
      await _facebookLogin.logOut();

      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      _firebaseAuth.authStateChanges();

      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print("sign out hata:" + e.toString());
      return false;
    }
  }

  @override
  Future<SystemUser> singInAnonymously() async {
    try {
      UserCredential sonuc = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(sonuc.user);
    } catch (e) {
      print("anonim giris hata:" + e.toString());
      return null;
    }
  }

  void _onAuthStateChanged(User user) {
    // print("asdadsdas");
    // debugPrint(user.toString());
  }

  @override
  Future<SystemUser> signInWithGoogle() async {
    try {
      print("gegege");
      GoogleSignIn _googleSignIn = GoogleSignIn();
      GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
      print(_googleUser.id);

      print("gegege");
      String _googleUserEmail = _googleUser.email;
      _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
      if (_googleUser != null) {
        GoogleSignInAuthentication _googleAuth =
            await _googleUser.authentication;
        if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
          UserCredential sonuc = await _firebaseAuth.signInWithCredential(
              GoogleAuthProvider.credential(
                  idToken: _googleAuth.idToken,
                  accessToken: _googleAuth.accessToken));
          await sonuc.user.updateEmail(_googleUserEmail);
          User _user = sonuc.user;
          // print(sonuc.user.toString());
          // print("sonuc.user");
          return _userFromFirebase(_user);
        } else {
          print(99);
          return null;
        }
      } else {
        print(88);
        return null;
      }
    } catch (e) {
      print("signInWithGoogle eee");
      print(e);
      print("signInWithGoogle eee");

    }
  }

  @override
  Future<SystemUser> signInWithFacebook() async {
    debugPrint("geldi1");
    final _facebookLogin = FacebookLogin();

    FacebookLoginResult _faceResult =
        await _facebookLogin.logIn(['public_profile', 'email']);
    print("geldi");
    /* final _faceResult = await _facebookLogin.logIn(['email']);
    print("geldi");*/
    switch (_faceResult.status) {
      case FacebookLoginStatus.loggedIn:
        if (_faceResult.accessToken != null &&
            _faceResult.accessToken.isValid()) {
          UserCredential _firebaseResult = await _firebaseAuth
              .signInWithCredential(FacebookAuthProvider.credential(
                  _faceResult.accessToken.token));

          User _user = _firebaseResult.user;
          return _userFromFirebase(_user);
        } else {
          print("access token valid :" +
              _faceResult.accessToken.isValid().toString());
        }

        break;

      case FacebookLoginStatus.cancelledByUser:
        print("kullanıcı facebook girişi iptal etti");
        break;

      case FacebookLoginStatus.error:
        print("Hata cıktı :" + _faceResult.errorMessage);
        break;
    }

    return null;
  }

  @override
  Future<SystemUser> createUserWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
  }

  @override
  Future<SystemUser> signInWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
    /* try {
      UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: sifre);
      return _userFromFirebase(sonuc.user);
    } catch (e) {
      print("email giris hata:" + e.toString());
      return null;
    }*/
  }

/* @override
  Future<SystemUser> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount _googleUser = await _googleSignIn.signIn();

    if (_googleUser != null) {
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
        AuthResult sonuc = await _firebaseAuth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: _googleAuth.idToken,
                accessToken: _googleAuth.accessToken));
        FirebaseUser _user = sonuc.SystemUser;
        return _userFromFirebase(_user);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Future<SystemUser> signInWithFacebook() async {
    final _facebookLogin = FacebookLogin();

    FacebookLoginResult _faceResult =
        await _facebookLogin.logIn(['public_profile', 'email']);

    switch (_faceResult.status) {
      case FacebookLoginStatus.loggedIn:
        if (_faceResult.accessToken != null &&
            _faceResult.accessToken.isValid()) {
          AuthResult _firebaseResult = await _firebaseAuth.signInWithCredential(
              FacebookAuthProvider.getCredential(
                  accessToken: _faceResult.accessToken.token));

          FirebaseUser _user = _firebaseResult.SystemUser;
          return _userFromFirebase(_user);
        } else {
          */ /* print("access token valid :" +
              _faceResult.accessToken.isValid().toString());*/ /*
        }

        break;

      case FacebookLoginStatus.cancelledByUser:
        print("kullanıcı facebook girişi iptal etti");
        break;

      case FacebookLoginStatus.error:
        print("Hata cıktı :" + _faceResult.errorMessage);
        break;
    }

    return null;
  }
*/
/*  @override
  Future<SystemUser> createUserWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
  }

  @override
  Future<SystemUser> signInWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
  }*/
}
