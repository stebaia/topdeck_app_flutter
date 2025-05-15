part of 'dependency_injector.dart';

final List<RepositoryProvider> _repositories = [
  RepositoryProvider<DeckRepository>(
    create: (context) => Provider.of<DeckRepository>(context, listen: false),
  ),
];
