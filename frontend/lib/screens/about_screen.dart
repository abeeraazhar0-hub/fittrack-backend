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
                        style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
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
                    title: 'Our Mission',
                    child: const Text(
                      'FitTrack BI makes professional fitness coaching accessible to everyone. Using AI-powered posture detection and real-time feedback, we help users exercise safely and effectively from home — no personal trainer required.',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                          height: 1.6),
                    ),
                  ),
                  // const SizedBox(height: 14),
                  // const SizedBox(height: 14),
                  //
                  const SizedBox(height: 14),
                  _card(
                    title: 'Tech Stack',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Flutter',
                        'FastAPI',
                        'MediaPipe',
                        'OpenCV',
                        'PostgreSQL',
                        'Power BI',
                        'Python',
                      ]
                          .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9E75)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1D9E75)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                                color: Color(0xFF0F6E56),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _card(
                    title: 'Key Features',
                    child: Column(
                      children: [
                        _featureRow('🤖',
                            'AI-powered real-time posture detection'),
                        _featureRow(
                            '🔢', 'Automatic repetition counting'),
                        _featureRow('📊',
                            'Power BI progress dashboards'),
                        _featureRow(
                            '🔐', 'Secure JWT authentication'),
                        _featureRow('📱',
                            'Cross-platform Flutter web app'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '© 2025 FitTrack BI • IIUI',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 12),
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

  Widget _teamCard(String initial, String name, String role) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBF9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8F5EE)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF1D9E75),
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11)),
          ],
        ),
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
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}