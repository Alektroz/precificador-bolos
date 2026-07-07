import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/insumo.dart';
import '../models/receita_base.dart';

class StorageService {
  static const String _chaveReceitas = 'receitas_base';
  static const String _chaveInsumos = 'insumos';

  static Future<void> salvarReceitas(List<ReceitaBase> receitas) async {
    final prefs = await SharedPreferences.getInstance();

    final listaJson = receitas.map((receita) => receita.toJson()).toList();

    await prefs.setString(_chaveReceitas, jsonEncode(listaJson));
  }

  static Future<List<ReceitaBase>?> carregarReceitas() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_chaveReceitas);

    if (dados == null) return null;

    final lista = jsonDecode(dados) as List<dynamic>;

    return lista
        .map((item) => ReceitaBase.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> salvarInsumos(List<Insumo> insumos) async {
    final prefs = await SharedPreferences.getInstance();

    final listaJson = insumos.map((insumo) => insumo.toJson()).toList();

    await prefs.setString(_chaveInsumos, jsonEncode(listaJson));
  }

  static Future<List<Insumo>?> carregarInsumos() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_chaveInsumos);

    if (dados == null) return null;

    final lista = jsonDecode(dados) as List<dynamic>;

    return lista
        .map((item) => Insumo.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}