import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:pine/di/dependency_injector_helper.dart';
import 'package:pine/utils/mapper.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:topdeck_app_flutter/state_management/cubit/decks/decks_cubit.dart';
import 'package:topdeck_app_flutter/di/service_locator.dart';
import 'package:topdeck_app_flutter/repositories/auth_repository.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/repositories/elo_repository.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/match_repository.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_invitation_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/repositories/match_invitation_repository.dart';
import 'package:topdeck_app_flutter/state_management/cubit/theme/theme_cubit.dart';
part 'blocs.dart';
part 'mappers.dart';
part 'providers.dart';
part 'repositories.dart';

class DependencyInjector extends StatelessWidget {
  const DependencyInjector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DependencyInjectorHelper(
      repositories: _repositories,
      providers: _providers,
      blocs: _blocs,
      mappers: _mappers,
      child: child);
}
