import 'package:flutter/material.dart';

import 'package:gestor_cafeteria/core/resultado.dart';
import 'package:gestor_cafeteria/core/features/orders/data/repositorio_pedidos_falso.dart';
import 'package:gestor_cafeteria/core/features/orders/domain/pedido.dart';

class PantallaPedidos extends StatefulWidget {
  const PantallaPedidos({super.key});

  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  final RepositorioPedidosFalso _repo = RepositorioPedidosFalso();
  Resultado<List<Pedido>> _estado = const Cargando();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _estado = const Cargando());
    try {
      final datos = await _repo.obtener();
      if (!mounted) return;
      setState(() => _estado = Exito(datos));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _estado = const Error('No pudimos cargar los pedidos'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: switch (_estado) {
        Cargando() => const Center(child: CircularProgressIndicator()),
        Exito(datos: final pedidos) => _ListaPedidos(pedidos: pedidos),
        Error(mensaje: final m) => _EstadoError(
          mensaje: m,
          onReintentar: _cargar,
        ),
      },
    );
  }
}

class _ListaPedidos extends StatelessWidget {
  const _ListaPedidos({required this.pedidos});

  final List<Pedido> pedidos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pedidos.length,
      itemBuilder: (context, i) {
        final p = pedidos[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('Pedido #${p.id} · ${p.producto}'),
            subtitle: Text('Cliente ${p.cliente} · ${p.estado}'),
          ),
        );
      },
    );
  }
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
