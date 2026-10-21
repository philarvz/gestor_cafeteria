import 'package:flutter/material.dart';

import 'core/features/orders/ui/pantalla_pedidos.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor Cafeteria',
      theme: ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true),
      home: const PantallaPedidos(),
    );
  }
}
