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
