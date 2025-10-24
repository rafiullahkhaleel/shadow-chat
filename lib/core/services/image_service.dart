import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageService{
  Future<File?> imagePicker(ImageSource source)async{
    final image = await ImagePicker().pickImage(source: source);
    if(image != null){
      return File(image.path);
    }
    return null;
  }
}