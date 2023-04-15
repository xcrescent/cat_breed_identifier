import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<File> imageFile;
  File? _image;
  String result = '';
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModelFile();
  }

  loadModelFile() async {
    String? output = await Tflite.loadModel(
      model: 'assets/models/model_unquant.tflite',
      labels: 'assets/models/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print(output);
  }

  doImageClassificationOnSelectedImage() async {
    var recognition = await Tflite.runModelOnImage(
      path: _image!.path,
      numResults: 2,
      threshold: 0.1,
      imageMean: 0.0,
      imageStd: 255.0,
      asynch: true,
    );
    print(recognition!.length.toString());
    setState(() {
      result = "";
    });
    recognition.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'];
      });
    });
  }

  selectPhoto() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassificationOnSelectedImage();
    });
  }

  capturePhoto() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassificationOnSelectedImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100,
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Stack(
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () => selectPhoto(),
                        onLongPress: capturePhoto,
                        child: Container(
                          child: _image != null
                              ? Image.file(
                                  _image!,
                                  height: 160,
                                  width: 400,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 140,
                                  height: 190,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 160,
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 35,
                    color: Colors.blueAccent,
                    backgroundColor: Colors.white60,
                    fontFamily: 'Brand Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
