import 'package:flutter/material.dart';

import '../core/formatadores.dart';
import '../models/insumo.dart';

class InsumosPage extends StatelessWidget {
  final List<Insumo> insumos;
  final ValueChanged<Insumo> onAdicionar;
  final ValueChanged<String> onRemover;

  const InsumosPage({
    super.key,
    required this.insumos,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insumos'),
        centerTitle: true,
      ),
      body: insumos.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum insumo cadastrado ainda.\n\n'
                'Toque no botão + para cadastrar pote, tampa, colher, etiqueta ou embalagem.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: insumos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final insumo = insumos[index];

          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(
                insumo.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo: ${insumo.tipo}'),
                    Text(
                      'Custo unitário: ${formatarMoeda(insumo.custoUnitario)}',
                    ),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onRemover(insumo.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirDialogNovoInsumo(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirDialogNovoInsumo(BuildContext context) async {
    final novoInsumo = await showDialog<Insumo>(
      context: context,
      builder: (dialogContext) {
        final nomeController = TextEditingController();
        final custoController = TextEditingController();

        String tipoSelecionado = 'Embalagem';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo insumo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do insumo',
                        hintText: 'Ex: Pote 250g',
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
                          value: 'Embalagem',
                          child: Text('Embalagem'),
                        ),
                        DropdownMenuItem(
                          value: 'Talher',
                          child: Text('Talher'),
                        ),
                        DropdownMenuItem(
                          value: 'Etiqueta',
                          child: Text('Etiqueta'),
                        ),
                        DropdownMenuItem(
                          value: 'Decoração',
                          child: Text('Decoração'),
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
                      controller: custoController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Custo unitário',
                        hintText: 'Ex: 0,80',
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
                    final custo = converterParaDouble(custoController.text);

                    if (nome.isEmpty || custo <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Preencha o nome e o custo unitário corretamente.',
                          ),
                        ),
                      );
                      return;
                    }

                    final insumo = Insumo(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nome: nome,
                      tipo: tipoSelecionado,
                      custoUnitario: custo,
                      criadoEm: DateTime.now(),
                    );

                    Navigator.of(dialogContext).pop(insumo);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (novoInsumo != null) {
      onAdicionar(novoInsumo);
    }
  }
}