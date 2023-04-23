import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class Storage {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadFile(
    String filePath,
    String fileName,
  ) async {
    File file = File(filePath);
    String downloadURL = '';

    try {
      await _firebaseStorage
          .ref('user_profile_images/$fileName')
          .putFile(file)
          .then((taskSnapshot) async {
        downloadURL = await taskSnapshot.ref.getDownloadURL();
      });
    } on FirebaseException catch (e) {
      print(e);
    }

    return downloadURL;
  }
}
