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
  
  // Provider per i bloc degli inviti (ricevuti e inviati)
  Provider<List<InvitationListBloc>>(
    create: (_) => [
      InvitationListBloc(isForSentInvitations: false),
      InvitationListBloc(isForSentInvitations: true),
    ],
    dispose: (_, blocs) {
      for (final bloc in blocs) {
        bloc.close();
      }
    },
  ),
  
  // Add all Supabase repositories from ServiceLocator
  ...ServiceLocator.getProviders(),
];
