double converterParaDouble(String valor) {
  final valorTratado = valor.replaceAll(',', '.').trim();
  return double.tryParse(valorTratado) ?? 0;
}

String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}