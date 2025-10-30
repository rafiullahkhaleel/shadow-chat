import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService{
  Future<File?> imagePicker(ImageSource source)async{
    final image = await ImagePicker().pickImage(source: source);
    if(image != null){
      return File(image.path);
    }
    return null;
  }
  Future<String> uploadImage(File imageFile, String filePath)async{
    final storageRef = FirebaseStorage.instance.ref().child(filePath);
    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }
}