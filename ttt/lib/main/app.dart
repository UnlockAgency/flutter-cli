import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/screens/errors/error_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ttt/main/routing/routes.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatelessWidget {
  App({super.key});

  final _navigatorKey = GlobalKey<NavigatorState>();

  late final _goRouter = _router();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp.router(
        routerConfig: _goRouter,
        title: 'ttt',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: AppColors.primary,
          primaryColor: AppColors.primary,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.primary,
            selectionHandleColor: AppColors.primary,
            selectionColor: AppColors.primary.withAlpha(100),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.primary.shade50,
            hintStyle: const TextStyle(color: Colors.black45),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusInput),
              borderSide: BorderSide(color: AppColors.primary.shade50),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusInput),
              borderSide: BorderSide(color: AppColors.primary.shade50),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusInput),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  GoRouter _router() {
    return GoRouter(
      navigatorKey: _navigatorKey,
      observers: [routeObserver],
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
      ),
      // redirect: (context, state) async {
      //   if (await LoginService.of(context).isLoggedIn) {
      //     return state.location;
      //   }
      //   return '/login';
      // },
      routes: routes,
    );
  }
}
