import 'package:firebase_storage/firebase_storage.dart';

class StoreConversionStorage {
  //firebase storage instance
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //upload image to firebase storage
  Future<String> uploadImage({
    required conversionImage,
    required userId,
  }) async {
    //storage reference
    Reference ref = _firebaseStorage
        .ref()
        .child("Conversions")
        .child("$userId/${DateTime.now()}");

    try {
      UploadTask task = ref.putFile(
        conversionImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      TaskSnapshot snapshot = await task;
      String url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (error) {
      print("Storage Service: $error");
      return "";
    }
  }
}
