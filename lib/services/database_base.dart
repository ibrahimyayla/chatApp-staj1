import 'package:chat_app/model/konusma.dart';
import 'package:chat_app/model/mesaj.dart';
import 'package:chat_app/model/systemUser.dart';

abstract class DBBase {
  Future<bool> saveUser(SystemUser user);
  Future<SystemUser> readUser(String userID);
  Future<bool> updateUserName(String userID, String yeniUserName);
  Future<bool> updateProfilFoto(SystemUser user, String profilFotoURL);
  Future<List<SystemUser>> getAllUser();
  Future<List<SystemUser>> getUserwithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi);
  Stream<List<Mesaj>> getMessages(String currentUserID, String konusulanUserID);
  Future<bool> saveMessage(SystemUser user,Mesaj kaydedilecekMesaj);
  Future<List<Konusma>> getAllConversations(String userID);
  Future<DateTime> saatiGoster(String userID);

/*  
  Future<List<SystemUser>> getUserwithPagination(
      SystemUser enSonGetirilenUser, int getirilecekElemanSayisi);
  */
}
