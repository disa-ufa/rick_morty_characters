import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:rick_morty_characters/data/models/character.dart';
import 'package:rick_morty_characters/data/models/characters_page.dart';

class RickMortyApi {
  RickMortyApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://rickandmortyapi.com/api';

  Future<CharactersPage> fetchCharacters({int page = 1}) async {
    // cache-buster: чтобы браузер не отдавал ответ из кэша
    final ts = DateTime.now().millisecondsSinceEpoch;

    final uri = Uri.parse('$_baseUrl/character?page=$page&_ts=$ts');

    final res = await _client.get(
      uri,
      headers: const {
        // на web помогает избежать “магического” кэша
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;

    final info = (jsonMap['info'] as Map).cast<String, dynamic>();
    final hasNext = info['next'] != null;

    final results = (jsonMap['results'] as List).cast<Map<String, dynamic>>();
    final characters = results.map(Character.fromJson).toList();

    return CharactersPage(results: characters, hasNext: hasNext);
  }
}
