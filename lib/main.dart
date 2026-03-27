import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemon/ui/styles.dart';
import 'package:pokemon/utils/providers.dart';
import 'package:pokemon/screens/pokemon_list_screen.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pokemon/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: _AppRoot()));
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  @override
  void initState() {
    super.initState();
    ref.read(appInitializerProvider).init();
  }

  @override
  Widget build(BuildContext context) => const PokemonApp();
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(colorSchemeSeed: ColorPalette.primary, useMaterial3: true),
      builder: (context, child) {
        return ConnectivityOverlay(child: child!);
      },
      home: const PokemonListScreen(),
    );
  }
}

class ConnectivityOverlay extends ConsumerWidget {
  const ConnectivityOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: connectivityStatus.when(
            data: (status) {
              if (status == InternetStatus.connected) {
                return const SizedBox.shrink();
              }

              return Material(
                color: ColorPalette.primaryDark,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off_rounded, color: ColorPalette.white, size: 16),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            AppStrings.noInternetMessage,
                            style: TextStyle(color: ColorPalette.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
