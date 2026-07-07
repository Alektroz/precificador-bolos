class CamadaCalculo {
  final String nome;
  final String tipo;
  final double gramas;
  final double custoPorGrama;

  const CamadaCalculo({
    required this.nome,
    required this.tipo,
    required this.gramas,
    required this.custoPorGrama,
  });

  double get custoTotal => gramas * custoPorGrama;
}