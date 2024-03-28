import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bg_remover/api_client.dart';
import 'package:bg_remover/widgets/dashed_border.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenshotController controller = ScreenshotController();
  var value = 0.5;
  var loaded = false;
  var removedbg = false;
  var isLoading = false;
  Uint8List? image;
  String imagePath = '';

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (img != null) {
      imagePath = img.path;
      loaded = true;
      setState(() {});
    } else {
      //
    }
  }

  downloadImage() async {
    var perm = await Permission.storage.request();

    var folderName = "BGRemover";
    var fileName = "${DateTime.now().millisecondsSinceEpoch}.png";

    if (perm.isGranted) {
      final directory = Directory("storage/emulated/0");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await controller.captureAndSave(directory.path,
          delay: const Duration(milliseconds: 100),
          fileName: fileName,
          pixelRatio: 1.0);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloades to ${directory.path}")));
    }
  }

  void saveImage() async {
    // Request permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, proceed with saving image
      try {
        String directory = (await getExternalStorageDirectory())!.path;
        String fileName =
            DateTime.now().microsecondsSinceEpoch.toString() + ".png";

        // Capture and save image
        controller.captureAndSave(directory, fileName: fileName);
      } catch (e) {
        print('Error saving image: $e');
      }
    } else {
      // Permission denied or restricted
      print('Permission to access storage was not granted.');

      if (status.isPermanentlyDenied) {
        // Handle case where permission is permanently denied by showing a dialog or navigating to app settings
        print('Storage permission is permanently denied.');
      }
    }
  }

  // void saveImage() async {
  //   bool isGranted = await Permission.storage.status.isGranted;
  //   if (!isGranted) {
  //     isGranted = await Permission.storage.request().isGranted;
  //   }

  //   if (isGranted) {
  //     String directory = (await getExternalStorageDirectory())!.path;
  //     String fileName =
  //         DateTime.now().microsecondsSinceEpoch.toString() + ".png";
  //     controller.captureAndSave(directory, fileName: fileName);
  //   }
  // }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        image = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      image = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                saveImage();
              },
              icon: const Icon(Icons.save))
        ],
        leading: const Icon(Icons.sort_rounded),
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Background remover',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Center(
        child: (image != null)
            ? GestureDetector(
                onTap: () {
                  getImage(ImageSource.gallery);
                },
                child: Screenshot(
                  controller: controller,
                  child: Image.memory(
                    image!,
                  ),
                ),
              )
            : loaded
                ? GestureDetector(
                    onTap: () {
                      getImage(ImageSource.gallery);
                    },
                    child: Image.file(
                      File(imagePath),
                    ),
                  )
                : DashedBorder(
                    padding: const EdgeInsets.all(40),
                    color: Colors.grey,
                    radius: 12,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        child: const Text("Remove background"),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              image = await ApiClient().removeBgApi(imagePath);
              if (image != null) {
                setState(() {
                  removedbg = true;
                  isLoading = false;
                });
              }
            },
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Remove background"),
          ),
        ),
      ),
    );
  }
}
