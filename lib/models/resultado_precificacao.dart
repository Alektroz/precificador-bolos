import 'camada_calculo.dart';

class ResultadoPrecificacao {
  final double custoMassa;
  final double custoRecheio;
  final double custoOutros;
  final double custoIngredientes;
  final double custoTotal;
  final double precoSugerido;
  final double lucroUnidade;
  final double pesoTotalCamadas;
  final bool pesoConfere;
  final List<CamadaCalculo> camadas;

  const ResultadoPrecificacao({
    required this.custoMassa,
    required this.custoRecheio,
    required this.custoOutros,
    required this.custoIngredientes,
    required this.custoTotal,
    required this.precoSugerido,
    required this.lucroUnidade,
    required this.pesoTotalCamadas,
    required this.pesoConfere,
    required this.camadas,
  });

  factory ResultadoPrecificacao.vazio() {
    return const ResultadoPrecificacao(
      custoMassa: 0,
      custoRecheio: 0,
      custoOutros: 0,
      custoIngredientes: 0,
      custoTotal: 0,
      precoSugerido: 0,
      lucroUnidade: 0,
      pesoTotalCamadas: 0,
      pesoConfere: true,
      camadas: [],
    );
  }
}