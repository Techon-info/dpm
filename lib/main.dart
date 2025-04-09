import 'dart:io';
import 'package:dpm/services/appwrite_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'rolescreen.dart';

void main() {
  runApp(Dpm());
}

class Dpm extends StatelessWidget {
  const Dpm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Roleselectionscreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AppwriteService _appwriteService = AppwriteService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? userId;

  void _login() async {
    final session = await _appwriteService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (session != null) {
      final user = await _appwriteService.getCurrentUser();
      setState(() {
        userId = user?.$id;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadScreen(userId: userId!)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.role} Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

class UploadScreen extends StatefulWidget {
  final String userId;
  const UploadScreen({super.key, required this.userId});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final AppwriteService _appwriteService = AppwriteService();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      final fileId = await _appwriteService.uploadWoundImage(
        _image!,
        widget.userId,
      );
      if (fileId != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image uploaded successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed')));
      }
    }
  }

  Future<void> _fetchImages() async {
    final images = await _appwriteService.listUserImages(widget.userId);
    print('User has ${images.length} images');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Wound Images')),
      body: Column(
        children: [
          _image == null ? Text('No image selected') : Image.file(_image!),
          ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
          ElevatedButton(onPressed: _uploadImage, child: Text('Upload Image')),
          ElevatedButton(
            onPressed: _fetchImages,
            child: Text('Fetch My Images'),
          ),
        ],
      ),
    );
  }
}
