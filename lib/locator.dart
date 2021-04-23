import 'package:chat_app/repository/user_repository.dart';
import 'package:chat_app/services/fake_auth_service.dart';
import 'package:chat_app/services/firebase_auth_service.dart';
import 'package:chat_app/services/firebase_storage_service.dart';
import 'package:chat_app/services/firestore_db_service.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  /// note  : Factory şeklini kullanırsan her seferinde üretiyor.

  try{
    getIt.registerLazySingleton(() => FirebaseAuthService());
    getIt.registerLazySingleton(() => FirebaseStorageService());
    getIt.registerLazySingleton(() => FirestoreDBService());
    getIt.registerLazySingleton(() => FakeAuthenticationService());
    getIt.registerLazySingleton(() => UserRepository());
  }catch(e){

  }finally{
    print(111);
  }


}
