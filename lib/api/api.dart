import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/detail.dart';
import '../models/list.dart';
import '../utils/constants.dart';

class PokeApiException implements Exception {
  final int? statusCode;
  final String message;

  const PokeApiException({this.statusCode, required this.message});

  @override
  String toString() => 'PokeApiException($statusCode): $message';
}

class PokemonApiService {
  PokemonApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = ApiConstants.baseUrl;

  static const int defaultLimit = AppConfig.apiDefaultLimit;

  static const int maxLimit = AppConfig.apiMaxLimit;

  final http.Client _client;

  Future<PokemonListResponse> getPokemonList({int limit = defaultLimit, int offset = 0}) async {
    assert(limit > 0 && limit <= maxLimit, 'limit must be 1-$maxLimit');
    final uri = Uri.parse('$_baseUrl/pokemon/').replace(queryParameters: {'limit': limit.toString(), 'offset': offset.toString()});
    final raw = await _get(uri);
    return PokemonListResponse.fromJson(raw);
  }

  Future<PokemonDetail> getPokemonById(int id) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$id/');
    final raw = await _get(uri);
    return PokemonDetail.fromJson(raw);
  }

  Future<PokemonDetail> getPokemonByName(String name) async {
    final uri = Uri.parse('$_baseUrl/pokemon/${name.toLowerCase()}/');
    final raw = await _get(uri);
    return PokemonDetail.fromJson(raw);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 404) {
        throw const PokeApiException(statusCode: 404, message: 'Not found');
      }

      throw PokeApiException(statusCode: response.statusCode, message: 'Unexpected status ${response.statusCode}');
    } on SocketException {
      throw const PokeApiException(message: 'No internet connection');
    } on FormatException catch (e) {
      throw PokeApiException(message: 'JSON parse error: $e');
    }
  }

  void dispose() => _client.close();
}

class PokemonPaginator {
  final PokemonApiService _api;
  int? _totalCount;

  int? get totalCount => _totalCount;
  final int pageSize;

  PokemonPaginator({required PokemonApiService api, this.pageSize = AppConfig.listPageSize}) : _api = api;

  Future<PokemonListResponse> fetchPage(int offset) async {
    final response = await _api.getPokemonList(limit: pageSize, offset: offset);
    _totalCount = response.count;
    return response;
  }

  int getNextOffset(int currentOffset, int count) {
    return currentOffset + count;
  }

  bool hasMore(int currentTotal, int apiTotalCount) {
    return currentTotal < apiTotalCount;
  }
}
