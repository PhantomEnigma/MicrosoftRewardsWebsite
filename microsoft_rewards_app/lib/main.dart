import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'notifications/notification_service.dart';
import 'core/utils/error_handler.dart';
import 'core/di/injection_container.dart';
import 'core/theme/theme_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init(); // Dependency injection
  await NotificationService.init();

  Bloc.observer = _AppBlocObserver();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), 
      child: const MyApp(),
    ),
  );
}

class _AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint('Bloc Change: $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    ErrorHandler.logError('Bloc ${bloc.runtimeType}', error);
    super.onError(bloc, error, stackTrace);
  }
}
