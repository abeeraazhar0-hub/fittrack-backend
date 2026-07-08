import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../services/api_service.dart';
import 'summary_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WorkoutScreen extends StatefulWidget {
  final FlutterTts _tts = FlutterTts();
  final Exercise exercise;
  final int userId;
  WorkoutScreen(
      {super.key, required this.exercise, required this.userId});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  CameraController? _cameraController;
  bool _cameraReady = false;
  int _sessionId = -1;
  int _repCount = 0;
  double _accuracy = 100.0;
  String _feedback = 'Get in position...';
  String _postureStatus = 'correct';
  bool _analyzing = false;
  Timer? _timer;
  String _lastSpokenFeedback = '';


  @override
  void initState() {
    super.initState();
    _startSession();
    _initCamera();
  }

  Future<void> _startSession() async {
    try {
      final id = await ApiService.startSession(
          widget.userId, widget.exercise.exerciseId);
      setState(() => _sessionId = id);
      debugPrint('Session started: $_sessionId');
    } catch (e) {
      debugPrint('Session error: $e');
      setState(() => _sessionId = -999);
    }
  }

  Future<void> _initCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint('Camera permission denied');
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera for workout
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras[0],
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() => _cameraReady = true);
      _timer = Timer.periodic(
          const Duration(milliseconds: 1000),
              (_) => _captureAndAnalyze());
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!_cameraReady || _analyzing || _sessionId <= 0) return;
    _analyzing = true;
    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final result = await ApiService.analyzeFrame(
          base64Image, widget.exercise.exerciseId, _sessionId);

      if (mounted) {
        final rawAccuracy =
        (result['accuracy_percent'] ?? 100.0).toDouble();
        final safeAccuracy =
        (rawAccuracy.isNaN || rawAccuracy.isInfinite)
            ? 100.0
            : rawAccuracy.clamp(0.0, 100.0);

        setState(() {
          _postureStatus = result['posture_status'] ?? 'correct';
          _feedback = result['feedback_message'] ?? 'Keep going!';
          _repCount = result['rep_count'] ?? 0;
          _accuracy = safeAccuracy;
        });

        _speak(_feedback);
      }
    } catch (e) {
      debugPrint('Analyze error: $e');
    } finally {
      _analyzing = false;
    }
  }

  void _speak(String text) async {
    if (text == _lastSpokenFeedback) return;
    _lastSpokenFeedback = text;
    await widget._tts.setLanguage('en-US');
    await widget._tts.setSpeechRate(0.5);
    await widget._tts.speak(text);
  }



  String get _safeAccuracyStr {
    if (_accuracy.isNaN || _accuracy.isInfinite) return '100%';
    return '${_accuracy.clamp(0.0, 100.0).toStringAsFixed(0)}%';
  }

  Future<void> _endWorkout() async {
    _timer?.cancel();
    _cameraController?.dispose();

    final safeReps = _repCount < 0 ? 0 : _repCount;
    final safeAccuracy =
    (_accuracy.isNaN || _accuracy.isInfinite)
        ? 100.0
        : _accuracy.clamp(0.0, 100.0);

    if (_sessionId <= 0) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(
              summary: SessionSummary(
                totalReps: safeReps,
                correctReps: safeReps,
                accuracyPercent: safeAccuracy,
                durationSeconds: 60,
              ),
              exerciseName: widget.exercise.name,
            ),
          ),
              (route) => false,
        );
      }
      return;
    }

    try {
      final summary = await ApiService.endSession(_sessionId);
      debugPrint('Summary — reps: ${summary.totalReps}, accuracy: ${summary.accuracyPercent}');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(
              summary: summary,
              exerciseName: widget.exercise.name,
            ),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('endSession failed: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryScreen(
              summary: SessionSummary(
                totalReps: safeReps,
                correctReps: safeReps,
                accuracyPercent: safeAccuracy,
                durationSeconds: 60,
              ),
              exerciseName: widget.exercise.name,
            ),
          ),
              (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    widget._tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera
          if (_cameraReady)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.white),
                    SizedBox(height: 16),
                    Text('Starting camera...',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.exercise.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _endWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        elevation: 8,
                      ),
                      child: const Text('Finish',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Rep counter
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_repCount',
                      style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const Text('reps',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),

          // Feedback bar
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _postureStatus == 'correct'
                    ? Colors.green.withOpacity(0.85)
                    : Colors.red.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _postureStatus == 'correct'
                        ? Icons.check_circle
                        : Icons.warning,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _feedback,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    _safeAccuracyStr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}