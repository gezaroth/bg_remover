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

  void saveImage() {
    var time = DateTime.now().millisecondsSinceEpoch;
    var path = "storage/emulated/0/Download/image-$time.jpg";
    var file = File(path);
    var pic = image;
    file.writeAsBytes(pic!);
  }

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
