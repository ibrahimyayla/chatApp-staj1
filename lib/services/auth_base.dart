import 'package:chat_app/model/systemUser.dart';

abstract class AuthBase {
  Future<SystemUser> currentUser();
  Future<SystemUser> singInAnonymously();
  Future<bool> signOut();
  Future<SystemUser> signInWithGoogle();
  Future<SystemUser> signInWithFacebook();
  Future<SystemUser> signInWithEmailandPassword(String email, String sifre);
  Future<SystemUser> createUserWithEmailandPassword(String email, String sifre);
  // Future<SystemUser> signInWithFacebook();
  /*Future<User> signInWithGoogle();
  Future<User> signInWithFacebook();
  Future<User> signInWithEmailandPassword(String email, String sifre);
  Future<User> createUserWithEmailandPassword(String email, String sifre);*/
}
