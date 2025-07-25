import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:microsoft_automatic_rewards/features/search/presentation/pages/startup_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/strings.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: Strings.appTitle,
      themeMode: themeProvider.themeMode,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      home: BlocProvider(
        create: (context) => sl<SearchBloc>(),
        child: const StartupScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

