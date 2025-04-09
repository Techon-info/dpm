import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class DoctorPatientDetails extends StatefulWidget {
  const DoctorPatientDetails({super.key});

  @override
  _DoctorPatientDetailsState createState() => _DoctorPatientDetailsState();
}

class _DoctorPatientDetailsState extends State<DoctorPatientDetails> {
  late Client _client;
  late Databases _database;
  late Storage _storage;

  List<Map<String, dynamic>> patients = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _fetchPatients();
  }

  void _initializeAppwrite() {
    _client =
        Client()
          ..setEndpoint('https://cloud.appwrite.io/v1')
          ..setProject('67ded3d9003dccc1a1e6');

    _database = Databases(_client);
    _storage = Storage(_client);
  }

  Future<void> _fetchPatients() async {
    try {
      final result = await _database.listDocuments(
        databaseId: '67ded3f80005c55371f9',
        collectionId: '67ded40100179828ab8e',
      );

      setState(() {
        patients =
            result.documents.map((doc) {
              return {
                "id": doc.$id,
                "name": doc.data['first_name'] ?? 'Unknown Name',
              };
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching patients: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateToPatientPage(BuildContext context, String name, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PatientDetailsPage(patientName: name, patientId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor's Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    title: Text(patient["name"]),
                    subtitle: Text("ID: ${patient["id"]}"),
                    onTap:
                        () => _navigateToPatientPage(
                          context,
                          patient["name"],
                          patient["id"],
                        ),
                  );
                },
              ),
    );
  }
}

class PatientDetailsPage extends StatefulWidget {
  final String patientName;
  final String patientId;

  const PatientDetailsPage({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late Client _client;
  late Storage _storage;

  String? latestImageUrl;
  bool _isLoading = true;

  static const String bucketId =
      '67ded430003419eba777'; // ✅ Use correct bucket ID

  @override
  void initState() {
    super.initState();
    _initializeAppwrite();
    _fetchLatestImage();
  }

  void _initializeAppwrite() {
    _client =
        Client()
          ..setEndpoint('https://cloud.appwrite.io/v1')
          ..setProject('67ded3d9003dccc1a1e6');

    _storage = Storage(_client);
  }

  Future<void> _fetchLatestImage() async {
    try {
      final result = await _storage.listFiles(bucketId: bucketId);
      final filtered =
          result.files
              .where((file) => file.name.startsWith(widget.patientId))
              .toList();

      if (filtered.isNotEmpty) {
        filtered.sort((a, b) => b.$createdAt.compareTo(a.$createdAt));
        final fileId = filtered.first.$id;

        setState(() {
          latestImageUrl =
              'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=67ded3d9003dccc1a1e6';
          _isLoading = false;
        });
      } else {
        setState(() {
          latestImageUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching image: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.patientName}", style: TextStyle(fontSize: 18)),
            Text(
              "Patient ID: ${widget.patientId}",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              "Latest Wound Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : latestImageUrl != null
                ? Image.network(latestImageUrl!)
                : const Text("No image uploaded"),
          ],
        ),
      ),
    );
  }
}
