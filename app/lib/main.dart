import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NourishIQState(),
      child: const NourishIQApp(),
    ),
  );
}

class NourishIQState extends ChangeNotifier {
  int heartRate = 75;
  String mood = 'Energetic';
  String weather = 'Sunny';
  String location = 'Bengaluru';

  bool isAgentThinking = false;
  Map<String, dynamic>? recommendation;
  String? errorMessage;

  void updateHeartRate(int newRate) {
    heartRate = newRate;
    notifyListeners();
  }

  void updateMood(String newMood) {
    mood = newMood;
    notifyListeners();
  }

  void updateWeather(String newWeather) {
    weather = newWeather;
    notifyListeners();
  }

  Future<void> fetchRecommendation() async {
    isAgentThinking = true;
    errorMessage = null;
    notifyListeners();

    // Trigger Semantics Announcement for Screen Readers
    SemanticsService.announce("Gemini 3.1 Agent is deep-thinking your meal nudge.", TextDirection.ltr);

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/recommend');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'heart_rate': heartRate,
          'mood': mood,
          'weather': weather,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        recommendation = data;
        SemanticsService.announce("New agentic recommendation loaded.", TextDirection.ltr);
      } else {
        errorMessage = data['error'] ?? 'An unknown error occurred';
        SemanticsService.announce("Error generating recommendation.", TextDirection.ltr);
      }
    } catch (e) {
      errorMessage = 'Failed to connect to the backend: \$e';
      SemanticsService.announce("Connection error.", TextDirection.ltr);
    } finally {
      isAgentThinking = false;
      notifyListeners();
    }
  }
}

class NourishIQApp extends StatelessWidget {
  const NourishIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NourishIQ 3.1',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF005C53),
          onPrimary: Colors.white,
          secondary: Color(0xFF003844),
          onSecondary: Colors.white,
          background: Color(0xFFF0F4F8),
          surface: Colors.white,
          onSurface: Color(0xFF1E1E1E),
          error: Color(0xFFB00020),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF1E1E1E), fontSize: 14),
          titleLarge: TextStyle(color: Color(0xFF005C53), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NourishIQState>();

    // Agentic Chat Overlay - Neon Glow Orb (Dynamic Island Style)
    Widget buildAgenticOrb() {
      if (!state.isAgentThinking) return const SizedBox.shrink();
      
      return Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Semantics(
            label: 'Agent is thinking',
            liveRegion: true,
            child: FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.tealAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Gemini 3.1 Deep Think...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Material 3 Adaptive Scaffold for Bento Grid
    Widget adaptiveBody = AdaptiveScaffold(
      useDrawer: false,
      smallBreakpoint: const WidthBreakpoint(end: 700),
      mediumBreakpoint: const WidthBreakpoint(begin: 700, end: 1000),
      largeBreakpoint: const WidthBreakpoint(begin: 1000),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      ],
      body: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBioStateCard(context, state),
              const SizedBox(height: 16),
              _buildWeatherSyncCard(context, state),
              const SizedBox(height: 16),
              _buildPredictedMealCard(context, state),
            ],
          ),
        ),
      ),
      largeBody: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildBioStateCard(context, state),
                  const SizedBox(height: 16),
                  _buildWeatherSyncCard(context, state),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: _buildPredictedMealCard(context, state),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Semantics(
          label: 'Application Title',
          header: true,
          child: Text('NourishIQ 3.1 Agentic UI'),
        ),
      ),
      body: Stack(
        children: [
          adaptiveBody,
          buildAgenticOrb(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isAgentThinking ? null : () => state.fetchRecommendation(),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate Agentic Nudge'),
      ),
    );
  }

  Widget _buildBioStateCard(BuildContext context, NourishIQState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Bio-State', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Heart Rate (bpm)'),
            Slider(
              value: state.heartRate.toDouble(),
              min: 40,
              max: 180,
              divisions: 140,
              label: state.heartRate.toString(),
              onChanged: (val) => state.updateHeartRate(val.toInt()),
            ),
            const SizedBox(height: 16),
            const Text('Mood'),
            DropdownButton<String>(
              value: state.mood,
              isExpanded: true,
              items: ['Energetic', 'Stressed', 'Fatigued'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => state.updateMood(val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSyncCard(BuildContext context, NourishIQState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agentic Weather Hook', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Simulated Location: \${state.location}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: state.weather,
              items: ['Sunny', 'Rainy', 'Cloudy'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => state.updateWeather(val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictedMealCard(BuildContext context, NourishIQState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agentic Recommendation', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 32),
            if (state.errorMessage != null)
              Text(state.errorMessage!, style: const TextStyle(color: Colors.red))
            else if (state.recommendation == null)
              const Center(child: Text('Waiting for deep-think execution.'))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agent Reasoning Chain:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                        const SizedBox(height: 8),
                        Text("1. Circadian: \${state.recommendation!['reasoning_chain']?['step_1_circadian_analysis'] ?? ''}", style: const TextStyle(fontSize: 13)),
                        Text("2. Weather: \${state.recommendation!['reasoning_chain']?['step_2_weather_impact'] ?? ''}", style: const TextStyle(fontSize: 13)),
                        Text("3. Bio-Markers: \${state.recommendation!['reasoning_chain']?['step_3_biomarker_correlation'] ?? ''}", style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDishSection(context, 'Local Nudge', state.recommendation!['south_indian_dish']?['name'] ?? '', state.recommendation!['south_indian_dish']?['why'] ?? ''),
                  const SizedBox(height: 16),
                  _buildDishSection(context, 'Global Alternative', state.recommendation!['global_dish']?['name'] ?? '', state.recommendation!['global_dish']?['why'] ?? ''),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishSection(BuildContext context, String category, String name, String why) {
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(why),
        ],
      ),
    );
  }
}
