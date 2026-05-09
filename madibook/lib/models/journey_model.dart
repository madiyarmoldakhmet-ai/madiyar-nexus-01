import 'package:flutter/material.dart';

/// A milestone in Madi's personal journey / project history.
class JourneyMilestone {
  final String title;
  final String description;
  final DateTime date;
  final String category; // "FPV Piloting", "Robotics", "Hacking", "Madibook"
  final IconData icon;
  final String? imageUrl;
  final List<String> tags;

  const JourneyMilestone({
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.icon,
    this.imageUrl,
    this.tags = const [],
  });

  /// Demo journey data for Madiyar.
  static List<JourneyMilestone> get madiJourney => [
        JourneyMilestone(
          title: 'First FPV Build',
          description:
              'Built my first FPV racing drone from scratch. Soldered ESCs, '
              'flashed Betaflight, and crashed it 47 times before the first clean lap. '
              'That\'s when I learned: iteration beats perfection.',
          date: DateTime(2021, 3, 15),
          category: 'FPV Piloting',
          icon: Icons.flight_rounded,
          tags: ['Drone', 'Betaflight', 'Hardware'],
        ),
        JourneyMilestone(
          title: 'Robotics Competition — 1st Place',
          description:
              'Led a team of 4 to build an autonomous line-following robot '
              'with obstacle avoidance. Won first place at the regional robotics '
              'olympiad. The robot used Arduino Mega + ultrasonic sensors.',
          date: DateTime(2021, 11, 8),
          category: 'Robotics',
          icon: Icons.smart_toy_rounded,
          tags: ['Arduino', 'Sensors', 'Competition'],
        ),
        JourneyMilestone(
          title: 'CTF Hacking — First Flag',
          description:
              'Captured my first flag in a Capture The Flag cybersecurity '
              'competition. Learned about SQL injection, XSS, and buffer overflows. '
              'Security isn\'t about breaking things — it\'s about understanding systems deeply.',
          date: DateTime(2022, 2, 20),
          category: 'Hacking',
          icon: Icons.security_rounded,
          tags: ['CTF', 'Cybersecurity', 'Pentesting'],
        ),
        JourneyMilestone(
          title: 'Learned Python & Automation',
          description:
              'Automated my school homework submission system with Python + Selenium. '
              'Teachers were confused when assignments arrived at 3 AM with perfect formatting. '
              'That\'s when I realized: code is leverage.',
          date: DateTime(2022, 6, 1),
          category: 'Hacking',
          icon: Icons.code_rounded,
          tags: ['Python', 'Automation', 'Selenium'],
        ),
        JourneyMilestone(
          title: 'FPV Freestyle — Mountain Session',
          description:
              'Flew my 5-inch freestyle quad through the Almaty mountains at 120 km/h. '
              'Captured cinematic footage that got 50K views on YouTube. '
              'The feeling of flying is addictive.',
          date: DateTime(2022, 9, 14),
          category: 'FPV Piloting',
          icon: Icons.terrain_rounded,
          tags: ['Freestyle', 'Cinematic', 'GoPro'],
        ),
        JourneyMilestone(
          title: 'Advanced Robotics — ROS Integration',
          description:
              'Upgraded from Arduino to ROS (Robot Operating System). Built a '
              'differential-drive robot with LIDAR mapping and SLAM navigation. '
              'The future is autonomous.',
          date: DateTime(2023, 1, 10),
          category: 'Robotics',
          icon: Icons.precision_manufacturing_rounded,
          tags: ['ROS', 'LIDAR', 'SLAM'],
        ),
        JourneyMilestone(
          title: 'Started Learning Flutter',
          description:
              'Decided to go full-stack mobile. Built my first Flutter app in a weekend — '
              'a simple to-do list that I immediately deleted because to-do apps are boring. '
              'The real mission was just beginning.',
          date: DateTime(2023, 5, 22),
          category: 'Madibook',
          icon: Icons.phone_android_rounded,
          tags: ['Flutter', 'Dart', 'Mobile'],
        ),
        JourneyMilestone(
          title: 'Bug Bounty — First Payout',
          description:
              'Found a critical IDOR vulnerability in a fintech platform. '
              'Reported responsibly, received my first bug bounty payout. '
              'Ethical hacking pays — literally.',
          date: DateTime(2023, 8, 30),
          category: 'Hacking',
          icon: Icons.bug_report_rounded,
          tags: ['Bug Bounty', 'IDOR', 'Responsible Disclosure'],
        ),
        JourneyMilestone(
          title: 'Madibook — The Vision',
          description:
              'Conceived the idea for Madibook: a "Human Library" where people '
              'exchange knowledge using Madi-Credits. No money, no gatekeepers — '
              'just humans teaching humans. The mission: make education free and peer-to-peer.',
          date: DateTime(2024, 1, 15),
          category: 'Madibook',
          icon: Icons.auto_awesome_rounded,
          tags: ['P2P', 'Education', 'Vision'],
        ),
        JourneyMilestone(
          title: 'Madibook MVP — Architecture Complete',
          description:
              'Built the production-ready MVP: MVVM architecture, matching algorithm, '
              'credit system, premium UI with glassmorphism. The foundation is set. '
              'Now it\'s time to build the Endless Learning Ecosystem.',
          date: DateTime(2024, 5, 8),
          category: 'Madibook',
          icon: Icons.rocket_launch_rounded,
          tags: ['MVP', 'Flutter', 'Production'],
        ),
      ];
}
