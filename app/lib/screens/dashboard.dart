import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Biometrics and inputs
  int heartRate = 72;
  String weather = 'Sunny';
  String time = 'Morning';
  String mood = 'Energetic';

  bool isLoading = false;
  Map<String, dynamic>? recommendation;
  User? currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
      });
    });
    // Set time of day automatically
    final hour = DateTime.now().hour;
    if (hour < 12) {
      time = 'Morning';
    } else if (hour < 17) {
      time = 'Afternoon';
    } else {
      time = 'Evening';
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } catch (error) {
      debugPrint("Sign in error: \$error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed. Please check Firebase config.')),
      );
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> fetchRecommendation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // In production, use the actual Cloud Run URL
      final url = Uri.parse('http://127.0.0.1:8000/api/recommend');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'heart_rate': heartRate,
          'weather': weather,
          'time': time,
          'mood': mood,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendation = data['nudge'];
        });
      } else {
        debugPrint('Error from server: \${response.body}');
      }
    } catch (e) {
      debugPrint('Exception: \$e');
      // Set dummy data for layout testing if backend is unreachable
      setState(() {
        recommendation = {
          "south_indian_dish": {"name": "Masala Dosa", "why": "High carbs for morning energy."},
          "global_dish": {"name": "Oatmeal with Berries", "why": "Complex carbs and antioxidants."},
          "overall_rationale": "Circadian rhythm indicates need for slow-release energy."
        };
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Reactive background based on Weather
  BoxDecoration _getBackgroundDecoration() {
    Color startColor;
    Color endColor;

    switch (weather.toLowerCase()) {
      case 'rainy':
        startColor = Colors.blueGrey.shade800;
        endColor = Colors.blueGrey.shade400;
        break;
      case 'cloudy':
        startColor = Colors.grey.shade400;
        endColor = Colors.grey.shade200;
        break;
      case 'sunny':
      default:
        startColor = Colors.orange.shade200;
        endColor = Colors.yellow.shade100;
        break;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor, endColor],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NourishIQ Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          currentUser == null
              ? Semantics(
                  label: 'Sign in with Google button',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: _handleSignIn,
                    tooltip: 'Sign In',
                  ),
                )
              : Semantics(
                  label: 'Sign out button',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _handleSignOut,
                    tooltip: 'Sign Out',
                  ),
                ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _getBackgroundDecoration(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel (Controls / Inputs)
                Expanded(
                  flex: 1,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contextual Data',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          
                          // Biometrics
                          const Text('Heart Rate (bpm)', style: TextStyle(fontWeight: FontWeight.bold)),
                          Slider(
                            value: heartRate.toDouble(),
                            min: 40,
                            max: 180,
                            divisions: 140,
                            label: heartRate.toString(),
                            onChanged: (val) => setState(() => heartRate = val.toInt()),
                          ),

                          const SizedBox(height: 16),
                          const Text('Weather (Bengaluru)', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: weather,
                            isExpanded: true,
                            items: ['Sunny', 'Rainy', 'Cloudy'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => weather = val!),
                          ),

                          const SizedBox(height: 16),
                          const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: mood,
                            isExpanded: true,
                            items: ['Energetic', 'Stressed', 'Fatigued'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => mood = val!),
                          ),

                          const Spacer(),
                          
                          Semantics(
                            label: 'Generate Predictive Meal Nudge button',
                            button: true,
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                ),
                                onPressed: isLoading ? null : fetchRecommendation,
                                child: isLoading 
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Generate Nudge', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),

                // Right Panel (Bento Grid Output)
                Expanded(
                  flex: 2,
                  child: recommendation == null
                      ? const Center(child: Text('Enter context and generate nudge.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
                      : Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildBentoCard(
                                      title: 'South Indian Nudge',
                                      dishName: recommendation!['south_indian_dish']?['name'] ?? '',
                                      rationale: recommendation!['south_indian_dish']?['why'] ?? '',
                                      icon: Icons.restaurant,
                                      color: Colors.orange.shade100,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildBentoCard(
                                      title: 'Global Nudge',
                                      dishName: recommendation!['global_dish']?['name'] ?? '',
                                      rationale: recommendation!['global_dish']?['why'] ?? '',
                                      icon: Icons.public,
                                      color: Colors.blue.shade100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _buildBentoCard(
                                title: 'Circadian Rationale',
                                dishName: 'The Science',
                                rationale: recommendation!['overall_rationale'] ?? '',
                                icon: Icons.science,
                                color: Colors.green.shade100,
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String dishName,
    required String rationale,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.black87),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 24),
            Text(dishName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(rationale, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
