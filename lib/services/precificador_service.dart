import '../models/camada_calculo.dart';
import '../models/resultado_precificacao.dart';

class PrecificadorService {
  static ResultadoPrecificacao calcularPorCamadas({
    required double pesoPote,
    required List<CamadaCalculo> camadas,
    required double custoInsumos,
    required double custosExtras,
    required double margemLucroPercentual,
  }) {
    final pesoTotalCamadas = camadas.fold<double>(
      0,
          (total, camada) => total + camada.gramas,
    );

    final pesoConfere = (pesoTotalCamadas - pesoPote).abs() < 0.01;

    final custoMassa = camadas
        .where((camada) => camada.tipo.toLowerCase() == 'massa')
        .fold<double>(
      0,
          (total, camada) => total + camada.custoTotal,
    );

    final custoRecheio = camadas
        .where((camada) => camada.tipo.toLowerCase() == 'recheio')
        .fold<double>(
      0,
          (total, camada) => total + camada.custoTotal,
    );

    final custoOutros = camadas
        .where(
          (camada) =>
      camada.tipo.toLowerCase() != 'massa' &&
          camada.tipo.toLowerCase() != 'recheio',
    )
        .fold<double>(
      0,
          (total, camada) => total + camada.custoTotal,
    );

    final custoIngredientes = camadas.fold<double>(
      0,
          (total, camada) => total + camada.custoTotal,
    );

    final custoTotal = custoIngredientes + custoInsumos + custosExtras;

    final precoSugerido = custoTotal * (1 + margemLucroPercentual / 100);

    final lucroUnidade = precoSugerido - custoTotal;

    return ResultadoPrecificacao(
      custoMassa: custoMassa,
      custoRecheio: custoRecheio,
      custoOutros: custoOutros,
      custoIngredientes: custoIngredientes,
      custoTotal: custoTotal,
      precoSugerido: precoSugerido,
      lucroUnidade: lucroUnidade,
      pesoTotalCamadas: pesoTotalCamadas,
      pesoConfere: pesoConfere,
      camadas: camadas,
    );
  }
}