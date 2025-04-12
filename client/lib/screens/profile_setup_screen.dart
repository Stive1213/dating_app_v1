import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart'; // Use relative import
import 'home_screen.dart'; // Use relative import
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileSetupScreen extends StatefulWidget {
  final String name;
  final String token;

  const ProfileSetupScreen({required this.name, required this.token});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  String? _gender;
  String? _selectedRegion;
  String? _selectedCity;
  File? _photo;
  String? _errorMessage;
  bool _isLoading = false;

  // Ethiopia regions and cities
  final Map<String, List<String>> _regionCities = {
    'Addis Ababa': ['Addis Ababa'],
    'Dire Dawa': ['Dire Dawa'],
    'Afar': ['Semera', 'Asaita'],
    'Amhara': ['Bahir Dar', 'Gondar', 'Debre Markos', 'Dessie'],
    'Oromia': ['Adama', 'Jimma', 'Shashamane', 'Bishoftu'],
    'Somali': ['Jijiga', 'Gode'],
    'Benishangul-Gumuz': ['Asosa'],
    'Gambella': ['Gambela'],
    'Sidama': ['Hawassa'],
    'Tigray': ['Mekelle', 'Adigrat', 'Axum'],
    'SNNPR': ['Arba Minch', 'Sodo'],
    'South West Ethiopia': ['Bonga', 'Mizan Teferi'],
    'Harari': ['Harar'],
    'Central Ethiopia': ['Welkite'],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService(); // Instantiate the class
      final response = await apiService.saveProfile(
        token: widget.token,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _gender!,
        bio: _bioController.text,
        location: '$_selectedRegion, $_selectedCity',
        photo: _photo,
      );

      if (response.containsKey('error')) {
        setState(() {
          _errorMessage = response['error'];
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()), // Add const for widget
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  value: _gender,
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedRegion,
                  items: _regionCities.keys
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                      _selectedCity = null; // Reset city when region changes
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a region';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCity,
                  items: _selectedRegion == null
                      ? []
                      : _regionCities[_selectedRegion]!
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                if (!kIsWeb) ...[
                  _photo == null
                      ? const Text('No photo selected')
                      : Image.file(_photo!, height: 100, width: 100, fit: BoxFit.cover),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Profile Photo'),
                  ),
                ] else
                  const Text('Photo upload not supported on web'),
                const SizedBox(height: 20.0),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitProfile,
                        child: const Text('Save Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}