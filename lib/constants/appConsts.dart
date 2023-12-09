import 'dart:io';

import 'package:collabDocs/api/appApi.dart';
import 'package:collabDocs/constants/appColors.dart';
import 'package:collabDocs/providers/myProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class AppConstants {
  static dynamic DateFormatter(String date) {
    return DateFormat("dd MMM yyyy hh:mm a")
        .format(DateTime.tryParse(date)!.toLocal());
  }

  static bool kIsEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

  static SnackBar kSnackbarMsg({required String msg}) {
    return SnackBar(
      content: Text(msg),
      showCloseIcon: true,
      backgroundColor: kPrimaryColor(),
      behavior: SnackBarBehavior.floating,
      shape: StadiumBorder(),
    );
  }

  static ImagePick(
      ref, ImageSource imageSource, BuildContext context, state) async {
    ref.read(showSkeleton.notifier).update((state) => true);
    state;
    XFile? imageFile = await ImagePicker().pickImage(source: imageSource);
    Navigator.pop(context);
    imageFile != null ? await CropImage(ref, imageFile, context) : null;

    ref.read(showSkeleton.notifier).update((state) => false);
  }

  static CropImage(ref, XFile source, context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: source.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: kPrimaryColor(),
            activeControlsWidgetColor: kPrimaryColor(),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    await AppApi()
        .uploadImage(ref, imageFile: File(croppedFile!.path), context: context);
  }
}
