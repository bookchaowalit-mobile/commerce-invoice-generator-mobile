import 'package:flutter/material.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'data/draft_repository.dart';
import 'observability/crash_reporting.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  if (!crashReportingEnabled(sentryDsn)) {
    runApp(const InvoiceGeneratorApp());
    return;
  }
  await SentryFlutter.init(
    (options) => configureCrashReporting(options, dsn: sentryDsn),
    appRunner: () => runApp(const InvoiceGeneratorApp(crashReporting: true)),
  );
}

class InvoiceGeneratorApp extends StatelessWidget {
  const InvoiceGeneratorApp({super.key, this.crashReporting = false});

  final bool crashReporting;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: MainShell(crashReporting: crashReporting),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.crashReporting = false});

  final bool crashReporting;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(repository: deviceDraftRepository),
          AboutScreen(crashReporting: widget.crashReporting),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Invoice'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'About'),
        ],
      ),
    );
  }
}
