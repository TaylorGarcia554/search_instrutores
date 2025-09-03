class CompraProcessamento {
  final int id; // Da CompraProcessamento
  final String data; // data que foi feita a compra created_at
  final String nome; // Nome do cliente
  final String telefone; // Telefone do cliente
  final int compraId; // ID da compra
  final int statusProcessamento;
  final String email;
  final int produto;

  CompraProcessamento({
    required this.nome,
    required this.data,
    required this.telefone,
    required this.id,
    required this.compraId,
    required this.statusProcessamento,
    required this.email,
    required this.produto,
  });

  factory CompraProcessamento.fromJson(Map<String, dynamic> json) {
    return CompraProcessamento(
      id: json['id'],
      compraId: json['compra_id'],
      data: json['created_at'],
      nome: json['compra']['cliente']['nome'],
      telefone: json['compra']['cliente']['telefone'],
      email: json['compra']['cliente']['email'],
      statusProcessamento: json['estado']['id'],
      produto: json['compra']['produto_id'],
    );
  }
}
