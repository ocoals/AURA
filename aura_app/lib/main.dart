import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? '';

  if (sentryDsn.isNotEmpty && sentryDsn != 'your-sentry-dsn-here') {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = 'development';
      },
      appRunner: () => runApp(
        const ProviderScope(child: AuraApp()),
      ),
    );
  } else {
    runApp(const ProviderScope(child: AuraApp()));
  }
}
