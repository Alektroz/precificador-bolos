import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../models/receita_base.dart';

class ReceitasBasePage extends StatelessWidget {
  final List<ReceitaBase> receitas;
  final ValueChanged<ReceitaBase> onAdicionar;
  final ValueChanged<String> onRemover;

  const ReceitasBasePage({
    super.key,
    required this.receitas,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas-base'),
        centerTitle: true,
      ),
      body: receitas.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma receita-base cadastrada ainda.\n\n'
                'Toque no botão + para cadastrar massa, recheio ou cobertura.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: receitas.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final receita = receitas[index];

          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(
                receita.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo: ${receita.tipo}'),
                    Text(
                      'Custo total: ${formatarMoeda(receita.custoTotal)}',
                    ),
                    Text(
                      'Peso produzido: '
                          '${receita.pesoProduzidoGramas.toStringAsFixed(0)}g',
                    ),
                    Text(
                      'Custo por grama: '
                          '${formatarMoeda(receita.custoPorGrama)}',
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemover(receita.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirDialogNovaReceita(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirDialogNovaReceita(BuildContext context) async {
    final novaReceita = await showDialog<ReceitaBase>(
      context: context,
      builder: (dialogContext) {
        final nomeController = TextEditingController();
        final custoTotalController = TextEditingController();
        final pesoProduzidoController = TextEditingController();

        String tipoSelecionado = 'Massa';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova receita-base'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da receita',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: tipoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Massa',
                          child: Text('Massa'),
                        ),
                        DropdownMenuItem(
                          value: 'Recheio',
                          child: Text('Recheio'),
                        ),
                        DropdownMenuItem(
                          value: 'Cobertura',
                          child: Text('Cobertura'),
                        ),
                        DropdownMenuItem(
                          value: 'Outro',
                          child: Text('Outro'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor == null) return;

                        setDialogState(() {
                          tipoSelecionado = valor;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: custoTotalController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Custo total da receita',
                        hintText: 'Ex: 32,00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: pesoProduzidoController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso produzido em gramas',
                        hintText: 'Ex: 1800',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nome = nomeController.text.trim();
                    final custoTotal =
                    converterParaDouble(custoTotalController.text);
                    final pesoProduzido =
                    converterParaDouble(pesoProduzidoController.text);

                    if (nome.isEmpty ||
                        custoTotal <= 0 ||
                        pesoProduzido <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Preencha nome, custo total e peso produzido corretamente.',
                          ),
                        ),
                      );
                      return;
                    }

                    final receita = ReceitaBase(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nome: nome,
                      tipo: tipoSelecionado,
                      custoTotal: custoTotal,
                      pesoProduzidoGramas: pesoProduzido,
                      criadaEm: DateTime.now(),
                    );

                    Navigator.of(dialogContext).pop(receita);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (novaReceita != null) {
      onAdicionar(novaReceita);
    }
  }
}