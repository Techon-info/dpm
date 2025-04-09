import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final AppwriteService _appwrite = AppwriteService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _appwrite
          .registerUser(_emailController.text, _passwordController.text, {
            'username': _usernameController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'hospital': _hospitalController.text,
            'city': _cityController.text,
            'country': _countryController.text,
            'age': _ageController.text,
            'gender': _genderController.text,
          }, 'patients');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient Registration Successful")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/images/patient.png', width: 150),
              const SizedBox(height: 15),
              _buildTextField("Username", Icons.person, _usernameController),
              _buildTextField("First Name", Icons.person, _firstNameController),
              _buildTextField("Last Name", Icons.person, _lastNameController),
              _buildTextField(
                "Hospital",
                Icons.local_hospital,
                _hospitalController,
              ),
              _buildTextField("City", Icons.location_city, _cityController),
              _buildTextField("Country", Icons.flag, _countryController),
              _buildTextField(
                "Age",
                Icons.cake,
                _ageController,
                isNumber: true,
              ),
              _buildTextField("Gender", Icons.wc, _genderController),
              _buildTextField(
                "Email",
                Icons.email,
                _emailController,
                isEmail: true,
              ),
              _buildTextField(
                "Password",
                Icons.lock,
                _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Register",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType:
            isEmail
                ? TextInputType.emailAddress
                : isNumber
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (isEmail &&
              !RegExp(
                r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
              ).hasMatch(value)) {
            return "Enter a valid email";
          }
          if (isNumber && int.tryParse(value) == null) {
            return "Enter a valid number";
          }
          if (isPassword && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }
}
