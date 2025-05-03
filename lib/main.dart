import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'premiumize/premiumize_screen.dart';
import 'premiumize/premiumize_transfers_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/settings_initializer_provider.dart';
import 'manual/manual_screen.dart';
import 'manual/torrent_handler_service.dart';
import 'utils/registry_service.dart';
import 'utils/sidebar.dart';
import 'faq/faq_screen.dart';
import 'instructions/omdb_instructions_screen.dart';
import 'instructions/premiumize_instructions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const platform = MethodChannel('com.nimbus/args');
  static const eventChannel = EventChannel('com.nimbus/file_handler');

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    _setupEventChannel();
  }

  void _setupMethodChannel() async {
    try {
      platform.setMethodCallHandler((call) async {
        if (call.method == 'handleFile') {
          final filePath = call.arguments as String;
          if (filePath.isNotEmpty) {
            _handleInitialArguments(filePath);
          }
        }
        return null;
      });
      
      final arguments = await platform.invokeMethod<String>('getArguments');
      if (arguments != null && arguments.isNotEmpty) {
        _handleInitialArguments(arguments);
      }
    } catch (e) {
      Logger().e('Error in _setupMethodChannel', error: e);
    }
  }

  void _setupEventChannel() {
    eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is String) {
          _showProcessingFeedback(event);
        }
      },
    );
  }

  void _showProcessingFeedback(String filePath) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing file: $filePath'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleInitialArguments(String arguments) async {
    final handler = ref.read(torrentHandlerServiceProvider);
    try {
      await handler.handleIncomingTorrent(arguments);
    } catch (e) {
      Logger().e('Error handling initial arguments', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              body: Row(
                children: [
                  const Sidebar(),
                  Expanded(child: child),
                ],
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/premiumize',
              name: 'premiumize',
              builder: (context, state) => const PremiumizeScreen(),
            ),
            GoRoute(
              path: '/premiumize/transfers',
              name: 'premiumize_transfers',
              builder: (context, state) => const PremiumizeTransfersScreen(),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/manual',
              name: 'manual',
              builder: (context, state) => const ManualScreen(),
            ),
            GoRoute(
              path: '/faq',
              name: 'faq',
              builder: (context, state) => const FaqScreen(),
            ),
            GoRoute(
              path: '/instructions/omdb',
              name: 'omdb_instructions',
              builder: (context, state) => const OmdbInstructionsScreen(),
            ),
            GoRoute(
              path: '/instructions/premiumize',
              name: 'premiumize_instructions',
              builder: (context, state) => const PremiumizeInstructionsScreen(),
            ),
          ],
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Nimbus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              background: Colors.black,
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
              onBackground: Colors.white,
              primary: Colors.blue,
              onPrimary: Colors.white,
              secondary: Colors.blueAccent,
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
            ),
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIconColor: Colors.white70,
              suffixIconColor: Colors.white70,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          routerConfig: router,
          builder: (context, child) {
            return ref.watch(settingsInitializerProvider).when(
              data: (_) => child ?? const SizedBox.shrink(),
              loading: () => Material(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading Settings...',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) {
                return Material(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error Loading Settings',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
