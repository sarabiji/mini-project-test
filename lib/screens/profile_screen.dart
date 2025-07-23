import 'package:flutter/material.dart';
import 'package:snap_chef_5/services/user_preferences_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Lists of selected preferences
  List<String> _selectedDiets = [];
  List<String> _selectedCuisines = [];
  List<String> _selectedAllergies = [];

  bool _isLoading = false;
  bool _isLoggedIn = false;

  // Available options for dropdowns
  final List<String> _availableDiets = [
    "Vegetarian",
    "Vegan",
    "Gluten Free",
    "Ketogenic",
    "Paleo",
    "Pescetarian",
    "Low Carb",
    "Low Fat",
    "High Protein",
    "Whole30",
    "Primal",
    "Low FODMAP",
  ];

  final List<String> _availableCuisines = [
    "African",
    "Asian",
    "American",
    "British",
    "Cajun",
    "Caribbean",
    "Chinese",
    "Eastern European",
    "European",
    "French",
    "German",
    "Greek",
    "Indian",
    "Irish",
    "Italian",
    "Japanese",
    "Jewish",
    "Korean",
    "Latin American",
    "Mediterranean",
    "Mexican",
    "Middle Eastern",
    "Nordic",
    "Southern",
    "Spanish",
    "Thai",
    "Vietnamese",
  ];

  final List<String> _availableAllergies = [
    "Dairy",
    "Eggs",
    "Peanuts",
    "Tree Nuts",
    "Shellfish",
    "Wheat",
    "Soy",
    "Fish",
    "Gluten",
    "Sesame",
    "Sulfite",
    "Mustard",
    "Celery",
    "Lupin",
    "Molluscs",
  ];

  // Uncomment when Firebase is set up
  // final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    // Pre-fill with sample credentials
    _emailController.text = "abc@gmail.com";
    _passwordController.text = "123456";
    // Load saved preferences
    _loadUserPreferences();
   
  }

  // Load saved user preferences from local storage
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await UserPreferencesService.getAllPreferences();

      if (mounted) {
        setState(() {
          _selectedDiets = prefs['dietPreferences'] ?? [];
          _selectedCuisines = prefs['cuisinePreferences'] ?? [];
          _selectedAllergies = prefs['allergies'] ?? [];
        });
      }
    } catch (e) {
      //print('Error loading preferences: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      

      // For now, just simulate a successful login
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoggedIn = true;
        // Pre-fill with sample data
        _nameController.text = "Sample User";
        _selectedDiets = ["Vegetarian", "Low Carb"];
        _selectedCuisines = ["Italian", "Mediterranean"];
        _selectedAllergies = ["Peanuts", "Shellfish"];
      });

      // Clear password field for security
      _passwordController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged in with sample account'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      /* Uncomment when Firebase is set up
      await _firebaseService.signOut();
      */

      // Clear saved preferences
      await UserPreferencesService.clearAllPreferences();

      // For now, just simulate a successful logout
      await Future.delayed(const Duration(seconds: 1));

      // Clear all fields
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _selectedDiets.clear();
      _selectedCuisines.clear();
      _selectedAllergies.clear();

      setState(() {
        _isLoggedIn = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      /* Uncomment when Firebase is set up
      await _firebaseService.updateUserProfile({
        'name': _nameController.text.trim(),
        'dietPreferences': _selectedDiets,
        'cuisinePreferences': _selectedCuisines,
        'allergies': _selectedAllergies,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      */

      // Save preferences to local storage
      await UserPreferencesService.saveAllPreferences(
        dietPreferences: _selectedDiets,
        cuisinePreferences: _selectedCuisines,
        allergies: _selectedAllergies,
      );

      // For now, just simulate a successful save
      await Future.delayed(const Duration(seconds: 1));

      // Show detailed success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile saved successfully!'),
              if (_selectedDiets.isNotEmpty)
                Text('Diets: ${_selectedDiets.join(", ")}'),
              if (_selectedCuisines.isNotEmpty)
                Text('Cuisines: ${_selectedCuisines.join(", ")}'),
              if (_selectedAllergies.isNotEmpty)
                Text('Allergies: ${_selectedAllergies.join(", ")}'),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Show a dialog with what's been saved
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Profile Updated'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${_nameController.text}'),
                    const SizedBox(height: 8),
                    Text('Email: ${_emailController.text}'),
                    const SizedBox(height: 8),
                    const Text('Diet Preferences:'),
                    if (_selectedDiets.isNotEmpty)
                      ...(_selectedDiets.map(
                        (diet) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(diet),
                            ],
                          ),
                        ),
                      ))
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text('No diet preferences selected'),
                      ),
                    const SizedBox(height: 8),
                    const Text('Cuisine Preferences:'),
                    if (_selectedCuisines.isNotEmpty)
                      ...(_selectedCuisines.map(
                        (cuisine) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restaurant,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(cuisine),
                            ],
                          ),
                        ),
                      ))
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text('No cuisine preferences selected'),
                      ),
                    const SizedBox(height: 8),
                    const Text('Allergies:'),
                    if (_selectedAllergies.isNotEmpty)
                      ...(_selectedAllergies.map(
                        (allergy) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(allergy),
                            ],
                          ),
                        ),
                      ))
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Text('No allergies selected'),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your preferences will be used to personalize recipe recommendations.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * .05,
            color: const Color(0xFF637FE7), // Deep Blue
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoggedIn && !_isLoading ? _signOut : null,
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: w * 0.15,
                              backgroundColor: const Color(0xFF637FE7),
                              child: Icon(
                                Icons.person,
                                size: w * 0.15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.03),
                          if (!_isLoggedIn) ...[
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: h * 0.02),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: h * 0.03),
                            Center(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF637FE7),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.1,
                                    vertical: h * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Sign In / Register',
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: h * 0.02),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              enabled: false,
                            ),
                            SizedBox(height: h * 0.02),
                            _buildDietPreferencesDropdown(),
                            SizedBox(height: h * 0.02),
                            _buildCuisinePreferencesDropdown(),
                            SizedBox(height: h * 0.02),
                            _buildAllergiesDropdown(),
                            SizedBox(height: h * 0.03),
                            Center(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF637FE7),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.1,
                                    vertical: h * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Save Profile',
                                  style: TextStyle(
                                    fontSize: w * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF637FE7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF637FE7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF637FE7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF637FE7), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDietPreferencesDropdown() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diet Preferences',
          style: TextStyle(
            fontSize: w * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.01,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF637FE7)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: w * 0.02,
                runSpacing: h * 0.01,
                children:
                    _selectedDiets.map((diet) {
                      return Chip(
                        label: Text(diet),
                        backgroundColor: Colors.blue[50],
                        labelStyle: const TextStyle(color: Color(0xFF637FE7)),
                        deleteIcon: const Icon(
                          Icons.cancel,
                          size: 18,
                          color: Color(0xFF637FE7),
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedDiets.remove(diet);
                          });
                        },
                      );
                    }).toList(),
              ),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select Diet Preferences',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF637FE7),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null && !_selectedDiets.contains(newValue)) {
                    setState(() {
                      _selectedDiets.add(newValue);
                    });
                  }
                },
                items:
                    _availableDiets.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCuisinePreferencesDropdown() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuisine Preferences',
          style: TextStyle(
            fontSize: w * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.01,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF637FE7)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: w * 0.02,
                runSpacing: h * 0.01,
                children:
                    _selectedCuisines.map((cuisine) {
                      return Chip(
                        label: Text(cuisine),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[700]),
                        deleteIcon: Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.green[700],
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedCuisines.remove(cuisine);
                          });
                        },
                      );
                    }).toList(),
              ),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select Cuisine Preferences',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF637FE7),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null &&
                      !_selectedCuisines.contains(newValue)) {
                    setState(() {
                      _selectedCuisines.add(newValue);
                    });
                  }
                },
                items:
                    _availableCuisines.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllergiesDropdown() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allergies',
          style: TextStyle(
            fontSize: w * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.01,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF637FE7)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: w * 0.02,
                runSpacing: h * 0.01,
                children:
                    _selectedAllergies.map((allergy) {
                      return Chip(
                        label: Text(allergy),
                        backgroundColor: Colors.red[50],
                        labelStyle: TextStyle(color: Colors.red[700]),
                        deleteIcon: Icon(
                          Icons.cancel,
                          size: 18,
                          color: Colors.red[700],
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedAllergies.remove(allergy);
                          });
                        },
                      );
                    }).toList(),
              ),
              DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select Allergies',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF637FE7),
                ),
                onChanged: (String? newValue) {
                  if (newValue != null &&
                      !_selectedAllergies.contains(newValue)) {
                    setState(() {
                      _selectedAllergies.add(newValue);
                    });
                  }
                },
                items:
                    _availableAllergies.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
//////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   ProfileScreenState createState() => ProfileScreenState();
// }

// class ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   User? _user;
//   bool _isLoading = false;
//   List<String> _selectedDiets = [];
//   List<String> _selectedCuisines = [];
//   List<String> _selectedAllergies = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     _user = _auth.currentUser;
//     if (_user != null) {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(_user!.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _nameController.text = userDoc['name'] ?? '';
//           _selectedDiets = List<String>.from(userDoc['diets'] ?? []);
//           _selectedCuisines = List<String>.from(userDoc['cuisines'] ?? []);
//           _selectedAllergies = List<String>.from(userDoc['allergies'] ?? []);
//         });
//       }
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _saveProfile() async {
//     if (_formKey.currentState!.validate() && _user != null) {
//       await _firestore.collection('users').doc(_user!.uid).set({
//         'name': _nameController.text,
//         'diets': _selectedDiets,
//         'cuisines': _selectedCuisines,
//         'allergies': _selectedAllergies,
//       }, SetOptions(merge: true));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );
//     }
//   }

//   Future<void> _signOut() async {
//     await _auth.signOut();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Profile"),
//         actions: [
//           IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
//         ],
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Full Name',
//                         ),
//                         validator:
//                             (value) =>
//                                 value!.isEmpty ? 'Enter your name' : null,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildPreferencesSection(
//                         "Diet Preferences",
//                         _selectedDiets,
//                       ),
//                       _buildPreferencesSection(
//                         "Cuisine Preferences",
//                         _selectedCuisines,
//                       ),
//                       _buildPreferencesSection("Allergies", _selectedAllergies),
//                       const SizedBox(height: 16),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: _saveProfile,
//                           child: const Text('Save Profile'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildPreferencesSection(String title, List<String> preferences) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         Wrap(
//           spacing: 8.0,
//           children:
//               preferences
//                   .map((preference) => Chip(label: Text(preference)))
//                   .toList(),
//         ),
//       ],
//     );
//   }
// }
///////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   ProfileScreenState createState() => ProfileScreenState();
// }

// class ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   User? _user;
//   bool _isLoading = false;
//   List<String> _selectedDiets = [];
//   List<String> _selectedCuisines = [];
//   List<String> _selectedAllergies = [];

//   // Available options for dropdowns
//   final List<String> _availableDiets = [
//     "Vegetarian",
//     "Vegan",
//     "Gluten Free",
//     "Ketogenic",
//     "Paleo",
//     "Pescetarian",
//     "Low Carb",
//     "Low Fat",
//     "High Protein",
//     "Whole30",
//     "Primal",
//     "Low FODMAP",
//   ];

//   final List<String> _availableCuisines = [
//     "African",
//     "Asian",
//     "American",
//     "British",
//     "Cajun",
//     "Caribbean",
//     "Chinese",
//     "Eastern European",
//     "European",
//     "French",
//     "German",
//     "Greek",
//     "Indian",
//     "Irish",
//     "Italian",
//     "Japanese",
//     "Jewish",
//     "Korean",
//     "Latin American",
//     "Mediterranean",
//     "Mexican",
//     "Middle Eastern",
//     "Nordic",
//     "Southern",
//     "Spanish",
//     "Thai",
//     "Vietnamese",
//   ];

//   final List<String> _availableAllergies = [
//     "Dairy",
//     "Eggs",
//     "Peanuts",
//     "Tree Nuts",
//     "Shellfish",
//     "Wheat",
//     "Soy",
//     "Fish",
//     "Gluten",
//     "Sesame",
//     "Sulfite",
//     "Mustard",
//     "Celery",
//     "Lupin",
//     "Molluscs",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => _isLoading = true);
//     _user = _auth.currentUser;
//     if (_user != null) {
//       try {
//         DocumentSnapshot userDoc =
//             await _firestore.collection('users').doc(_user!.uid).get();
//         if (userDoc.exists) {
//           Map<String, dynamic> userData =
//               userDoc.data() as Map<String, dynamic>;
//           setState(() {
//             _nameController.text = userData['name'] ?? '';
//             _selectedDiets = List<String>.from(userData['diets'] ?? []);
//             _selectedCuisines = List<String>.from(userData['cuisines'] ?? []);
//             _selectedAllergies = List<String>.from(userData['allergies'] ?? []);
//           });
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading profile: ${e.toString()}')),
//         );
//       }
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate() || _user == null) return;

//     setState(() => _isLoading = true);

//     try {
//       await _firestore.collection('users').doc(_user!.uid).set({
//         'name': _nameController.text.trim(),
//         'diets': _selectedDiets,
//         'cuisines': _selectedCuisines,
//         'allergies': _selectedAllergies,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully!')),
//       );

//       // Show detailed success dialog
//       showDialog(
//         context: context,
//         builder:
//             (context) => AlertDialog(
//               title: const Text('Profile Updated'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Name: ${_nameController.text}'),
//                     const SizedBox(height: 8),
//                     const Text('Diet Preferences:'),
//                     if (_selectedDiets.isNotEmpty)
//                       ...(_selectedDiets.map(
//                         (diet) => Padding(
//                           padding: const EdgeInsets.only(left: 16, top: 4),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle,
//                                 color: Colors.green,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(diet),
//                             ],
//                           ),
//                         ),
//                       ))
//                     else
//                       const Padding(
//                         padding: EdgeInsets.only(left: 16, top: 4),
//                         child: Text('No diet preferences selected'),
//                       ),
//                     const SizedBox(height: 8),
//                     const Text('Cuisine Preferences:'),
//                     if (_selectedCuisines.isNotEmpty)
//                       ...(_selectedCuisines.map(
//                         (cuisine) => Padding(
//                           padding: const EdgeInsets.only(left: 16, top: 4),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.restaurant,
//                                 color: Colors.blue,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(cuisine),
//                             ],
//                           ),
//                         ),
//                       ))
//                     else
//                       const Padding(
//                         padding: EdgeInsets.only(left: 16, top: 4),
//                         child: Text('No cuisine preferences selected'),
//                       ),
//                     const SizedBox(height: 8),
//                     const Text('Allergies:'),
//                     if (_selectedAllergies.isNotEmpty)
//                       ...(_selectedAllergies.map(
//                         (allergy) => Padding(
//                           padding: const EdgeInsets.only(left: 16, top: 4),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.warning,
//                                 color: Colors.red,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(allergy),
//                             ],
//                           ),
//                         ),
//                       ))
//                     else
//                       const Padding(
//                         padding: EdgeInsets.only(left: 16, top: 4),
//                         child: Text('No allergies selected'),
//                       ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Your preferences will be used to personalize recipe recommendations.',
//                       style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving profile: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _signOut() async {
//     await _auth.signOut();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "My Profile",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: w * 0.05,
//             color: const Color(0xFF637FE7), // Deep Blue
//           ),
//         ),
//         actions: [
//           IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
//         ],
//       ),
//       body: SafeArea(
//         child:
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(w * 0.05),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: CircleAvatar(
//                               radius: w * 0.15,
//                               backgroundColor: const Color(0xFF637FE7),
//                               child: Icon(
//                                 Icons.person,
//                                 size: w * 0.15,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: h * 0.03),
//                           _buildTextField(
//                             controller: _nameController,
//                             label: 'Full Name',
//                             icon: Icons.person,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your name';
//                               }
//                               return null;
//                             },
//                           ),
//                           SizedBox(height: h * 0.02),
//                           _buildDietPreferencesDropdown(),
//                           SizedBox(height: h * 0.02),
//                           _buildCuisinePreferencesDropdown(),
//                           SizedBox(height: h * 0.02),
//                           _buildAllergiesDropdown(),
//                           SizedBox(height: h * 0.03),
//                           Center(
//                             child: ElevatedButton(
//                               onPressed: _isLoading ? null : _saveProfile,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF637FE7),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: w * 0.1,
//                                   vertical: h * 0.015,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Save Profile',
//                                 style: TextStyle(
//                                   fontSize: w * 0.04,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isPassword = false,
//     bool enabled = true,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       enabled: enabled,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF637FE7)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFF637FE7)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFF637FE7)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Color(0xFF637FE7), width: 2),
//         ),
//       ),
//       validator: validator,
//     );
//   }

//   Widget _buildDietPreferencesDropdown() {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Diet Preferences',
//           style: TextStyle(
//             fontSize: w * 0.04,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//         SizedBox(height: h * 0.01),
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: w * 0.03,
//             vertical: h * 0.01,
//           ),
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFF637FE7)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Wrap(
//                 spacing: w * 0.02,
//                 runSpacing: h * 0.01,
//                 children:
//                     _selectedDiets.map((diet) {
//                       return Chip(
//                         label: Text(diet),
//                         backgroundColor: Colors.blue[50],
//                         labelStyle: const TextStyle(color: Color(0xFF637FE7)),
//                         deleteIcon: const Icon(
//                           Icons.cancel,
//                           size: 18,
//                           color: Color(0xFF637FE7),
//                         ),
//                         onDeleted: () {
//                           setState(() {
//                             _selectedDiets.remove(diet);
//                           });
//                         },
//                       );
//                     }).toList(),
//               ),
//               DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text(
//                   'Select Diet Preferences',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 underline: const SizedBox(),
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   color: Color(0xFF637FE7),
//                 ),
//                 onChanged: (String? newValue) {
//                   if (newValue != null && !_selectedDiets.contains(newValue)) {
//                     setState(() {
//                       _selectedDiets.add(newValue);
//                     });
//                   }
//                 },
//                 items:
//                     _availableDiets.map<DropdownMenuItem<String>>((
//                       String value,
//                     ) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCuisinePreferencesDropdown() {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Cuisine Preferences',
//           style: TextStyle(
//             fontSize: w * 0.04,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//         SizedBox(height: h * 0.01),
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: w * 0.03,
//             vertical: h * 0.01,
//           ),
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFF637FE7)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Wrap(
//                 spacing: w * 0.02,
//                 runSpacing: h * 0.01,
//                 children:
//                     _selectedCuisines.map((cuisine) {
//                       return Chip(
//                         label: Text(cuisine),
//                         backgroundColor: Colors.green[50],
//                         labelStyle: TextStyle(color: Colors.green[700]),
//                         deleteIcon: Icon(
//                           Icons.cancel,
//                           size: 18,
//                           color: Colors.green[700],
//                         ),
//                         onDeleted: () {
//                           setState(() {
//                             _selectedCuisines.remove(cuisine);
//                           });
//                         },
//                       );
//                     }).toList(),
//               ),
//               DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text(
//                   'Select Cuisine Preferences',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 underline: const SizedBox(),
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   color: Color(0xFF637FE7),
//                 ),
//                 onChanged: (String? newValue) {
//                   if (newValue != null &&
//                       !_selectedCuisines.contains(newValue)) {
//                     setState(() {
//                       _selectedCuisines.add(newValue);
//                     });
//                   }
//                 },
//                 items:
//                     _availableCuisines.map<DropdownMenuItem<String>>((
//                       String value,
//                     ) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAllergiesDropdown() {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Allergies',
//           style: TextStyle(
//             fontSize: w * 0.04,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//         SizedBox(height: h * 0.01),
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: w * 0.03,
//             vertical: h * 0.01,
//           ),
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFF637FE7)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Wrap(
//                 spacing: w * 0.02,
//                 runSpacing: h * 0.01,
//                 children:
//                     _selectedAllergies.map((allergy) {
//                       return Chip(
//                         label: Text(allergy),
//                         backgroundColor: Colors.red[50],
//                         labelStyle: TextStyle(color: Colors.red[700]),
//                         deleteIcon: Icon(
//                           Icons.cancel,
//                           size: 18,
//                           color: Colors.red[700],
//                         ),
//                         onDeleted: () {
//                           setState(() {
//                             _selectedAllergies.remove(allergy);
//                           });
//                         },
//                       );
//                     }).toList(),
//               ),
//               DropdownButton<String>(
//                 isExpanded: true,
//                 hint: Text(
//                   'Select Allergies',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 underline: const SizedBox(),
//                 icon: const Icon(
//                   Icons.arrow_drop_down,
//                   color: Color(0xFF637FE7),
//                 ),
//                 onChanged: (String? newValue) {
//                   if (newValue != null &&
//                       !_selectedAllergies.contains(newValue)) {
//                     setState(() {
//                       _selectedAllergies.add(newValue);
//                     });
//                   }
//                 },
//                 items:
//                     _availableAllergies.map<DropdownMenuItem<String>>((
//                       String value,
//                     ) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
