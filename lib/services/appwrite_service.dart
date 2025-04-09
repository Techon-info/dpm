import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  final Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;

  AppwriteService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1') // Appwrite endpoint
        .setProject('67ded3d9003dccc1a1e6'); // Your Appwrite Project ID

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  // User Registration (Auth + Database)
  Future<models.User> registerUser(
    String email,
    String password,
    Map<String, dynamic> userData,
    String role,
  ) async {
    try {
      // Step 1: Create user in Appwrite Authentication
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: "${userData['first_name']} ${userData['last_name']}",
      );

      // Step 2: Determine the collection ID based on the user role
      String collectionId = (role == 'doctors')
          ? '67ded414000a1664b9d3' // Doctor Collection ID
          : '67ded40100179828ab8e'; // Patient Collection ID

      // Step 3: Prepare user data to be stored
      Map<String, dynamic> data = {
        'email': email,
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
        'password': password,
        'city': userData['city'],
        if (role == 'doctors') ...{
          'hospital_name': userData['hospital_name'],
          'designation': userData['designation'],
        },
        if (role == 'patients') ...{
          'country': userData['country'],
          'age': int.parse(userData['age']),
          'gender': userData['gender'],
        },
      };

      // Step 4: Store user details in the Appwrite Database
      await databases.createDocument(
        databaseId: '67ded3f80005c55371f9', // Database ID
        collectionId: collectionId,
        documentId: user.$id,
        data: data,
        permissions: [
          Permission.read(Role.any()), // Allow any user to read
          Permission.write(Role.any()), // Allow any user to write
        ],
      );

      print("User registration and data storage successful.");
      return user;
    } catch (e) {
      print("Error registering user: $e");
      throw Exception("Error storing user data: $e");
    }
  }

  // User Login
  Future<models.Session?> loginUser(String email, String password) async {
    try {
      return await account.createEmailPasswordSession(
          email: email, password: password);
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  // Get User Data from Database
  Future<models.Document?> getUserData(String userId, String role) async {
    try {
      String collectionId =
          (role == "doctors") ? '67ded414000a1664b9d3' : '67ded40100179828ab8e';

      return await databases.getDocument(
        databaseId: '67ded3f80005c55371f9',
        collectionId: collectionId,
        documentId: userId,
      );
    } catch (e) {
      print("Failed to get user data: $e");
      return null;
    }
  }

  // User Logout
  Future<void> logoutUser() async {
    try {
      await account.deleteSession(sessionId: 'current');
      print("User logged out successfully.");
    } catch (e) {
      print("Logout failed: $e");
      throw Exception("Logout failed: $e");
    }
  }

  // Get Current Logged-in User
  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Upload Wound Image (Allow any user to read & write)
  Future<String?> uploadWoundImage(File image, String userId) async {
    try {
      final response = await storage.createFile(
        bucketId: 'YOUR_BUCKET_ID', // Replace with your bucket ID
        fileId: ID.unique(),
        file: InputFile.fromPath(path: image.path),
        permissions: [
          Permission.read(Role.any()), // Allow any user to read
          Permission.write(Role.any()), // Allow any user to write
        ],
      );
      return response.$id;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  // List All Uploaded Images (Accessible by any user)
  Future<List<models.File>> listAllImages() async {
    try {
      final files = await storage.listFiles(bucketId: '67ded430003419eba777');
      return files.files;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  login(String text, String text2) {}

  listUserImages(String userId) {}
}
