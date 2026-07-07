import 'package:flutter/material.dart';

import '../models/insumo.dart';
import '../models/receita_base.dart';
import '../services/storage_service.dart';
import 'calculadora_bolo_page.dart';
import 'insumos_page.dart';
import 'receitas_base_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaAtual = 0;

  bool carregando = true;

  final List<ReceitaBase> receitasBase = [];
  final List<Insumo> insumos = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  Future<void> _carregarDadosLocais() async {
    final receitasSalvas = await StorageService.carregarReceitas();
    final insumosSalvos = await StorageService.carregarInsumos();

    setState(() {
      receitasBase.clear();
      insumos.clear();

      receitasBase.addAll(receitasSalvas ?? _receitasPadrao());
      insumos.addAll(insumosSalvos ?? _insumosPadrao());

      carregando = false;
    });
  }

  List<ReceitaBase> _receitasPadrao() {
    return [
      ReceitaBase(
        id: '1',
        nome: 'Massa de chocolate',
        tipo: 'Massa',
        custoTotal: 32,
        pesoProduzidoGramas: 1800,
        criadaEm: DateTime.now(),
      ),
      ReceitaBase(
        id: '2',
        nome: 'Recheio de brigadeiro',
        tipo: 'Recheio',
        custoTotal: 30,
        pesoProduzidoGramas: 1200,
        criadaEm: DateTime.now(),
      ),
    ];
  }

  List<Insumo> _insumosPadrao() {
    return [
      Insumo(
        id: '1',
        nome: 'Pote 250g',
        tipo: 'Embalagem',
        custoUnitario: 0.80,
        criadoEm: DateTime.now(),
      ),
      Insumo(
        id: '2',
        nome: 'Tampa',
        tipo: 'Embalagem',
        custoUnitario: 0.20,
        criadoEm: DateTime.now(),
      ),
      Insumo(
        id: '3',
        nome: 'Colher',
        tipo: 'Talher',
        custoUnitario: 0.15,
        criadoEm: DateTime.now(),
      ),
      Insumo(
        id: '4',
        nome: 'Etiqueta',
        tipo: 'Etiqueta',
        custoUnitario: 0.10,
        criadoEm: DateTime.now(),
      ),
    ];
  }

  Future<void> adicionarReceita(ReceitaBase receita) async {
    setState(() {
      receitasBase.add(receita);
    });

    await StorageService.salvarReceitas(receitasBase);
  }

  Future<void> removerReceita(String id) async {
    setState(() {
      receitasBase.removeWhere((receita) => receita.id == id);
    });

    await StorageService.salvarReceitas(receitasBase);
  }

  Future<void> adicionarInsumo(Insumo insumo) async {
    setState(() {
      insumos.add(insumo);
    });

    await StorageService.salvarInsumos(insumos);
  }

  Future<void> removerInsumo(String id) async {
    setState(() {
      insumos.removeWhere((insumo) => insumo.id == id);
    });

    await StorageService.salvarInsumos(insumos);
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final paginas = [
      CalculadoraBoloPage(
        receitasBase: receitasBase,
        insumos: insumos,
      ),
      ReceitasBasePage(
        receitas: receitasBase,
        onAdicionar: adicionarReceita,
        onRemover: removerReceita,
      ),
      InsumosPage(
        insumos: insumos,
        onAdicionar: adicionarInsumo,
        onRemover: removerInsumo,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: paginaAtual,
        children: paginas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaAtual,
        onDestinationSelected: (index) {
          setState(() {
            paginaAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Receitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Insumos',
          ),
        ],
      ),
    );
  }
}