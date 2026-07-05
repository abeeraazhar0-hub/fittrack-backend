import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF1D9E75),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text('💪', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text('FitTrack BI',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Version 1.0.0  •  IIUI 2025',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card(
                    title: 'What is FitTrack BI?',
                    child: const Text(
                      'We built FitTrack BI as our final year project at IIUI. The idea was simple — most people can\'t afford a personal trainer, but that shouldn\'t stop them from working out correctly. So we used AI to do the coaching: it watches your form, counts your reps, and tells you what to fix in real time.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                          height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _card(
                    title: 'What it can do',
                    child: Column(
                      children: [
                        _featureRow('🤖', 'Detects your posture in real time using your camera'),
                        _featureRow('🔢', 'Counts reps automatically — no manual logging'),
                        _featureRow('📊', 'Shows your progress through visual dashboards'),
                        _featureRow('🔐', 'Keeps your data secure with JWT authentication'),
                        _featureRow('📱', 'Works on Android and the web'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '© 2025 FitTrack BI • IIUI',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D9E75))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _featureRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF444444))),
          ),
        ],
      ),
    );
  }
}