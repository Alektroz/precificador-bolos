import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../models/camada_calculo.dart';
import '../models/insumo.dart';
import '../models/receita_base.dart';
import '../models/resultado_precificacao.dart';
import '../services/precificador_service.dart';

class CalculadoraBoloPage extends StatefulWidget {
  final List<ReceitaBase> receitasBase;
  final List<Insumo> insumos;

  const CalculadoraBoloPage({
    super.key,
    required this.receitasBase,
    required this.insumos,
  });

  @override
  State<CalculadoraBoloPage> createState() => _CalculadoraBoloPageState();
}

class _CalculadoraBoloPageState extends State<CalculadoraBoloPage> {
  final TextEditingController _pesoPoteController =
  TextEditingController(text: '250');

  final TextEditingController _custosExtrasController =
  TextEditingController(text: '0,50');

  final TextEditingController _margemLucroController =
  TextEditingController(text: '100');

  final Set<String> _insumosSelecionadosIds = {};
  final List<_CamadaEdicao> _camadas = [];

  bool _selecaoInicialDeInsumosFeita = false;

  ResultadoPrecificacao resultado = ResultadoPrecificacao.vazio();

  @override
  void initState() {
    super.initState();

    _criarCamadasIniciais();
    _garantirCamadasValidas();
    _garantirInsumosSelecionados();

    resultado = _calcularResultadoAtual();
  }

  @override
  void didUpdateWidget(covariant CalculadoraBoloPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    _garantirCamadasValidas();
    _garantirInsumosSelecionados();

    resultado = _calcularResultadoAtual();
  }

  @override
  void dispose() {
    _pesoPoteController.dispose();
    _custosExtrasController.dispose();
    _margemLucroController.dispose();

    for (final camada in _camadas) {
      camada.dispose();
    }

    super.dispose();
  }

  void _criarCamadasIniciais() {
    if (_camadas.isNotEmpty) return;

    _camadas.addAll([
      _CamadaEdicao(
        id: '1',
        tipoPreferido: 'Massa',
        receitaId: _primeiraReceitaIdPorTipo('Massa'),
        gramasController: TextEditingController(text: '80'),
      ),
      _CamadaEdicao(
        id: '2',
        tipoPreferido: 'Recheio',
        receitaId: _primeiraReceitaIdPorTipo('Recheio'),
        gramasController: TextEditingController(text: '90'),
      ),
      _CamadaEdicao(
        id: '3',
        tipoPreferido: 'Massa',
        receitaId: _primeiraReceitaIdPorTipo('Massa'),
        gramasController: TextEditingController(text: '80'),
      ),
    ]);
  }

  List<ReceitaBase> _receitasPorTipo(String tipo) {
    return widget.receitasBase
        .where(
          (receita) => receita.tipo.toLowerCase() == tipo.toLowerCase(),
    )
        .toList();
  }

  String? _primeiraReceitaIdPorTipo(String tipo) {
    final receitas = _receitasPorTipo(tipo);

    if (receitas.isNotEmpty) {
      return receitas.first.id;
    }

    if (widget.receitasBase.isNotEmpty) {
      return widget.receitasBase.first.id;
    }

    return null;
  }

  ReceitaBase? _buscarReceitaPorId(String? id) {
    if (id == null) return null;

    try {
      return widget.receitasBase.firstWhere((receita) => receita.id == id);
    } catch (_) {
      return null;
    }
  }

  void _garantirCamadasValidas() {
    final idsExistentes = widget.receitasBase.map((receita) => receita.id).toSet();

    for (final camada in _camadas) {
      final receitaExiste = idsExistentes.contains(camada.receitaId);

      if (!receitaExiste) {
        camada.receitaId = _primeiraReceitaIdPorTipo(camada.tipoPreferido);
      }
    }
  }

  void _garantirInsumosSelecionados() {
    final idsExistentes = widget.insumos.map((insumo) => insumo.id).toSet();

    _insumosSelecionadosIds.removeWhere(
          (id) => !idsExistentes.contains(id),
    );

    if (!_selecaoInicialDeInsumosFeita) {
      _insumosSelecionadosIds.addAll(idsExistentes);
      _selecaoInicialDeInsumosFeita = true;
    }
  }

  double get _custoInsumosSelecionados {
    return widget.insumos
        .where((insumo) => _insumosSelecionadosIds.contains(insumo.id))
        .fold<double>(
      0,
          (total, insumo) => total + insumo.custoUnitario,
    );
  }

  List<CamadaCalculo> _montarCamadasParaCalculo() {
    return _camadas.map((camadaEdicao) {
      final receita = _buscarReceitaPorId(camadaEdicao.receitaId);

      return CamadaCalculo(
        nome: receita?.nome ?? 'Sem receita',
        tipo: receita?.tipo ?? camadaEdicao.tipoPreferido,
        gramas: converterParaDouble(camadaEdicao.gramasController.text),
        custoPorGrama: receita?.custoPorGrama ?? 0,
      );
    }).toList();
  }

  ResultadoPrecificacao _calcularResultadoAtual() {
    _garantirCamadasValidas();
    _garantirInsumosSelecionados();

    return PrecificadorService.calcularPorCamadas(
      pesoPote: converterParaDouble(_pesoPoteController.text),
      camadas: _montarCamadasParaCalculo(),
      custoInsumos: _custoInsumosSelecionados,
      custosExtras: converterParaDouble(_custosExtrasController.text),
      margemLucroPercentual: converterParaDouble(_margemLucroController.text),
    );
  }

  void calcularPreco() {
    setState(() {
      resultado = _calcularResultadoAtual();
    });
  }

  void _adicionarCamada() {
    setState(() {
      _camadas.add(
        _CamadaEdicao(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tipoPreferido: 'Outro',
          receitaId: widget.receitasBase.isNotEmpty
              ? widget.receitasBase.first.id
              : null,
          gramasController: TextEditingController(text: '0'),
        ),
      );

      resultado = _calcularResultadoAtual();
    });
  }

  void _removerCamada(_CamadaEdicao camada) {
    if (_camadas.length <= 1) return;

    setState(() {
      _camadas.remove(camada);
      camada.dispose();
      resultado = _calcularResultadoAtual();
    });
  }

  @override
  Widget build(BuildContext context) {
    final temReceitas = widget.receitasBase.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Precificador de Bolos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Montagem por camadas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (!temReceitas)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cadastre pelo menos uma receita-base na aba Receitas.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            _campoNumero(
              label: 'Peso do pote em gramas',
              controller: _pesoPoteController,
            ),

            const SizedBox(height: 8),

            ..._camadas.asMap().entries.map((entry) {
              final index = entry.key;
              final camada = entry.value;

              return _cardCamada(
                numero: index + 1,
                camada: camada,
              );
            }),

            OutlinedButton.icon(
              onPressed: _adicionarCamada,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar camada'),
            ),

            const SizedBox(height: 24),

            const Text(
              'Insumos usados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _listaInsumos(),

            const SizedBox(height: 16),

            const Text(
              'Custos extras e margem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _campoNumero(
              label: 'Custos extras por unidade',
              controller: _custosExtrasController,
            ),

            _campoNumero(
              label: 'Margem de lucro desejada (%)',
              controller: _margemLucroController,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: calcularPreco,
              child: const Text('Calcular preço de venda'),
            ),

            const SizedBox(height: 24),

            _cardResumo(),
          ],
        ),
      ),
    );
  }

  Widget _cardCamada({
    required int numero,
    required _CamadaEdicao camada,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Camada $numero',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_camadas.length > 1)
                  IconButton(
                    onPressed: () => _removerCamada(camada),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: camada.receitaId,
              decoration: const InputDecoration(
                labelText: 'Receita da camada',
                border: OutlineInputBorder(),
              ),
              items: widget.receitasBase.map((receita) {
                return DropdownMenuItem<String>(
                  value: receita.id,
                  child: Text(
                    '${receita.nome} — ${receita.tipo}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: widget.receitasBase.isEmpty
                  ? null
                  : (id) {
                camada.receitaId = id;
                calcularPreco();
              },
            ),

            const SizedBox(height: 12),

            _campoNumero(
              label: 'Quantidade em gramas',
              controller: camada.gramasController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoNumero({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => calcularPreco(),
      ),
    );
  }

  Widget _listaInsumos() {
    if (widget.insumos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Nenhum insumo cadastrado. Cadastre na aba Insumos.',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: Column(
        children: widget.insumos.map((insumo) {
          final selecionado = _insumosSelecionadosIds.contains(insumo.id);

          return CheckboxListTile(
            value: selecionado,
            title: Text(insumo.nome),
            subtitle: Text(
              '${insumo.tipo} • ${formatarMoeda(insumo.custoUnitario)}',
            ),
            onChanged: (valor) {
              setState(() {
                if (valor == true) {
                  _insumosSelecionadosIds.add(insumo.id);
                } else {
                  _insumosSelecionadosIds.remove(insumo.id);
                }

                resultado = _calcularResultadoAtual();
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _cardResumo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Resumo do cálculo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (!resultado.pesoConfere)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Atenção: as camadas somam '
                      '${resultado.pesoTotalCamadas.toStringAsFixed(0)}g, '
                      'mas o pote informado possui ${_pesoPoteController.text}g.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const Text(
              'Detalhamento das camadas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ...resultado.camadas.asMap().entries.map((entry) {
              final index = entry.key;
              final camada = entry.value;

              return _linhaResumo(
                'Camada ${index + 1}: ${camada.nome} '
                    '(${camada.gramas.toStringAsFixed(0)}g)',
                formatarMoeda(camada.custoTotal),
              );
            }),

            const Divider(height: 32),

            _linhaResumo(
              'Peso total das camadas',
              '${resultado.pesoTotalCamadas.toStringAsFixed(0)}g',
            ),

            _linhaResumo(
              'Custo de massa',
              formatarMoeda(resultado.custoMassa),
            ),

            _linhaResumo(
              'Custo de recheio',
              formatarMoeda(resultado.custoRecheio),
            ),

            if (resultado.custoOutros > 0)
              _linhaResumo(
                'Outras camadas',
                formatarMoeda(resultado.custoOutros),
              ),

            _linhaResumo(
              'Ingredientes',
              formatarMoeda(resultado.custoIngredientes),
            ),

            _linhaResumo(
              'Insumos',
              formatarMoeda(_custoInsumosSelecionados),
            ),

            _linhaResumo(
              'Custo total por unidade',
              formatarMoeda(resultado.custoTotal),
            ),

            const Divider(height: 32),

            _linhaResumo(
              'Preço sugerido de venda',
              formatarMoeda(resultado.precoSugerido),
              destaque: true,
            ),

            _linhaResumo(
              'Lucro por unidade',
              formatarMoeda(resultado.lucroUnidade),
              destaque: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaResumo(
      String titulo,
      String valor, {
        bool destaque = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: destaque ? 17 : 15,
                fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: destaque ? 17 : 15,
                fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CamadaEdicao {
  final String id;
  final String tipoPreferido;
  String? receitaId;
  final TextEditingController gramasController;

  _CamadaEdicao({
    required this.id,
    required this.tipoPreferido,
    required this.receitaId,
    required this.gramasController,
  });

  void dispose() {
    gramasController.dispose();
  }
}