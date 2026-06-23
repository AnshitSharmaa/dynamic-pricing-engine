import 'package:flutter/material.dart';
import 'dashboard_page.dart';

void main() {
  runApp(const PricingApp());
}

class PricingApp extends StatelessWidget {
  const PricingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic Pricing Engine',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const DashboardPage(),
    );
  }
}
