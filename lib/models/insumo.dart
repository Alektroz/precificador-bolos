class Insumo {
  final String id;
  final String nome;
  final String tipo;
  final double custoUnitario;
  final DateTime criadoEm;

  const Insumo({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.custoUnitario,
    required this.criadoEm,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'custoUnitario': custoUnitario,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'Outro',
      custoUnitario: (json['custoUnitario'] ?? 0).toDouble(),
      criadoEm: DateTime.tryParse(json['criadoEm'] ?? '') ?? DateTime.now(),
    );
  }
}