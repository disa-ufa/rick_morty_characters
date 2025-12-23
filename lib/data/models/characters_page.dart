import 'character.dart';

class CharactersPage {
  final List<Character> results;
  final bool hasNext;

  const CharactersPage({
    required this.results,
    required this.hasNext,
  });
}
