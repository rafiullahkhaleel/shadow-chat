import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  Future<File?> imagePicker(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<String> uploadImage(File imageFile, String filePath) async {
    final storageRef = FirebaseStorage.instance.ref().child(filePath);
    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadImageWithProgress(
    File imageFile,
    String filePath, {
    required Function(double) onProgress,
  }) async {
    final storageRef = FirebaseStorage.instance.ref().child(filePath);
    final uploadTask = storageRef.putFile(imageFile);

    // Listen to upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress(progress);
    });

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
