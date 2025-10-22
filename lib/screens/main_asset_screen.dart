import 'package:flutter/material.dart';

class MainAssetScreen extends StatefulWidget {
  const MainAssetScreen({super.key});

  @override
  State<MainAssetScreen> createState() => _MainAssetScreenState();
}

class _MainAssetScreenState extends State<MainAssetScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [];

  @override
  Widget build(BuildContext context) {
    final Scaffold topMainAssetScreen = Scaffold();

    return topMainAssetScreen;
  }
}
