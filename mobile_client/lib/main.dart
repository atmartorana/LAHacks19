import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';



List<CameraDescription> cameras;
var unique_id = "ABCDEFG.jpg";
var location = new Location();
var url = 'http://165.227.54.34:3000/found';
Future<void> main() async {
  final FirebaseStorage storage = await FirebaseStorage();
  cameras = await availableCameras();
  runApp(BaseCameraApp(storage: storage));
}


class CameraApp extends StatefulWidget {
  CameraApp({this.storage});
  final FirebaseStorage storage;
  @override
  _CameraAppState createState() => _CameraAppState();
}


class BaseCameraApp extends StatelessWidget {
  BaseCameraApp({this.storage});
  final FirebaseStorage storage;

  @override
  Widget build(BuildContext context) {
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
    return MaterialApp(
      home: CameraApp(storage: storage),
    );
  }
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String imagePath;

  Future<void> _uploadFile(String filePath, LocationData currentLocation) async {

    final log = Logger('_uploadFile');

    final File file = File(filePath);
    final StorageReference ref =
      widget.storage.ref().child(unique_id);
    String locationString = "${currentLocation.latitude}:${currentLocation.longitude}";
    showInSnackBar('location:' + locationString);
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentType: 'image/jpeg',
        customMetadata: <String, String> {'location': locationString},
      ),
    );

    String bucketName = await ref.getBucket();
    String fileName = unique_id;
    //make a request to endpoint
    http.post(url, body: {'bucketName': bucketName, 'fileName': fileName, 'location':locationString}).then((response){
      log.info(response.body);
      showInSnackBar(response.body);
    });


  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }


  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
          controller.value.isInitialized &&
          !controller.value.isRecordingVideo
          ? onTakePictureButtonPressed
          : null,
        )
      ],
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }


  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();


  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    LocationData currentLocation = await location.getLocation();
    if (controller.value.isTakingPicture) {
  // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);

    } on CameraException catch (e) {
      //_showCameraException(e);
      return null;
    }
    _uploadFile(filePath, currentLocation);
    return filePath;
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('App Test'),
          ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                  ? Colors.redAccent
                  : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),

        ],
      ),
    );
  }

}