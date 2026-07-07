class ReceitaBase {
  final String id;
  final String nome;
  final String tipo;
  final double custoTotal;
  final double pesoProduzidoGramas;
  final DateTime criadaEm;

  const ReceitaBase({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.custoTotal,
    required this.pesoProduzidoGramas,
    required this.criadaEm,
  });

  double get custoPorGrama {
    if (pesoProduzidoGramas <= 0) return 0;
    return custoTotal / pesoProduzidoGramas;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'custoTotal': custoTotal,
      'pesoProduzidoGramas': pesoProduzidoGramas,
      'criadaEm': criadaEm.toIso8601String(),
    };
  }

  factory ReceitaBase.fromJson(Map<String, dynamic> json) {
    return ReceitaBase(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'Outro',
      custoTotal: (json['custoTotal'] ?? 0).toDouble(),
      pesoProduzidoGramas: (json['pesoProduzidoGramas'] ?? 0).toDouble(),
      criadaEm: DateTime.tryParse(json['criadaEm'] ?? '') ?? DateTime.now(),
    );
  }
}