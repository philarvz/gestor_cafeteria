class Pedido {
  const Pedido({
    required this.id,
    required this.productoId,
    required this.cliente,
    required this.producto,
    this.estado = 'pending',
  });

  final int id;
  final int productoId;
  final String cliente;
  final String producto;
  final String estado;
}
