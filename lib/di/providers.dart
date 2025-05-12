part of 'dependency_injector.dart';

final List<SingleChildWidget> _providers = [
  Provider<Logger>(create: (_) => Logger()),
  
  Provider<PrettyDioLogger>(
      create: (_) => PrettyDioLogger(
          requestBody: true, compact: true, requestHeader: true)),
  Provider<Dio>(
      create: (context) => Dio()
        ..interceptors
            .addAll([if (kDebugMode) context.read<PrettyDioLogger>()])),
  Provider<FlutterSecureStorage>(
    create: (_) => const FlutterSecureStorage(),
  ),
  
  
];
