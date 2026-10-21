import 'dart:async';

import 'package:gestor_cafeteria/core/features/orders/domain/pedido.dart';

class RepositorioPedidosFalso {
  int _llamadas = 0;

  Future<List<Pedido>> obtener() async {
    await Future.delayed(const Duration(seconds: 2));
    _llamadas++;
    if (_llamadas == 1) {
      throw Exception('Sin conexion con el servicio de pedidos');
    }
    return const [
      Pedido(
        id: 101,
        productoId: 1,
        cliente: 'A1F3',
        producto: 'Latte',
      ),
      Pedido(
        id: 102,
        productoId: 2,
        cliente: 'B7X2',
        producto: 'Americano',
        estado: 'ready',
      ),
      Pedido(
        id: 103,
        productoId: 1,
        cliente: 'C9K4',
        producto: 'Latte',
      ),
      Pedido(
        id: 104,
        productoId: 3,
        cliente: 'D2M8',
        producto: 'Capuchino',
        estado: 'preparing',
      ),
      Pedido(
        id: 105,
        productoId: 2,
        cliente: 'E5Q1',
        producto: 'Americano',
        estado: 'delivered',
      ),
      Pedido(
        id: 106,
        productoId: 4,
        cliente: 'F8L7',
        producto: 'Mocha',
      ),
    ];
  }
}
