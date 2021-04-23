import 'package:chat_app/model/systemUser.dart';
import 'package:chat_app/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "123123123123123213123123123";

  @override
  Future<SystemUser> currentUser() async {
    return await Future.value(
        SystemUser(userID: userID, email: "fakeuser@fake.com"));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<SystemUser> singInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2),
        () => SystemUser(userID: userID, email: "fakeuser@fake.com"));
  }

  @override
  Future<SystemUser> signInWithGoogle() async {
    /// note: async gecikmeli cevap için.
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "google_user_id_123456", email: "fakeuser@fake.com"));
  }

  /// note : Facebook dev. dan test user olusturduk.
  /// sorun olursa facebook.logout dene
  @override
  Future<SystemUser> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "100057094876181",
            email: "wcnppfsjma_1604343738@tfbnw.net"));
  }

  @override
  Future<SystemUser> createUserWithEmailandPassword(
      String email, String sifre) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "created_user_id_123456", email: "fakeuser@fake.com"));
  }

  @override
  Future<SystemUser> signInWithEmailandPassword(
      String email, String sifre) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "signIn_user_id_123456", email: "fakeuser@fake.com"));
  }

  /* @override
  Future<SystemUser> signInWithGoogle() async {
    /// note: async gecikmeli cevap için.
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "google_user_id_123456", email: "fakeuser@fake.com"));
  }

  @override
  Future<SystemUser> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => SystemUser(
            userID: "facebook_user_id_123456", email: "fakeuser@fake.com"));
  }
*/

}
