import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class SystemUser {
  final String userID;
  String email;
  String userName;
  String profilURL;
  num messageHappy;
  num imageHappy;
  DateTime createdAt;
  DateTime updatedAt;
  int seviye;

  SystemUser({@required this.userID, @required this.email});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'messageHappy': messageHappy ?? 2,
      'imageHappy': imageHappy ?? 2,

      /// olustururken bos kalmasın diye kendimiz olusturduk.
      'userName':
          userName ?? email.substring(0, email.indexOf('@')) + randomSayiUret(),

      /// note : Null is bunu yap dart dilinde
      'profilURL': profilURL ??
          'https://thumbs.dreamstime.com/b/default-avatar-photo-placeholder-profile-picture-default-avatar-photo-placeholder-profile-picture-eps-file-easy-to-edit-125707135.jpg',

      /// note : Db saatini alma kodu.
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'seviye': seviye ?? 1,
    };
  }

  SystemUser.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilURL = map['profilURL'],
        messageHappy = map['messageHappy'],
        imageHappy = map['imageHappy'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        seviye = map['seviye'];

  SystemUser.idveResim({@required this.userID, @required this.profilURL});

  @override
  String toString() {
    return 'User{userID: $userID, email: $email, userName: $userName, profilURL: $profilURL, createdAt: $createdAt, updatedAt: $updatedAt, seviye: $seviye, messageHappy: $messageHappy, imageHappy: $imageHappy}';
  }

  String randomSayiUret() {
    int rastgeleSayi = Random().nextInt(999999);
    return rastgeleSayi.toString();
  }
}
