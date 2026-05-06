import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/people_selection/people_selection_screen.dart';
import 'features/bill_split/bill_split_screen.dart';
import 'features/summary/summary_screen.dart';
import 'features/history/history_screen.dart';
import 'features/history/history_detail_screen.dart';
import 'features/groups/groups_screen.dart';
import 'features/settings/settings_screen.dart';
import 'data/models/history_entry.dart';

class SplitlyApp extends ConsumerWidget {
  const SplitlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Splitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings_) {
        switch (settings_.name) {
          case AppRoutes.home:
            return _route(const HomeScreen());
          case AppRoutes.people:
            return _route(const PeopleSelectionScreen());
          case AppRoutes.split:
            return _route(const BillSplitScreen());
          case AppRoutes.summary:
            return _route(const SummaryScreen());
          case AppRoutes.history:
            return _route(const HistoryScreen());
          case AppRoutes.historyDetail:
            final entry = settings_.arguments as HistoryEntry;
            return _route(HistoryDetailScreen(entry: entry));
          case AppRoutes.groups:
            return _route(const GroupsScreen());
          case AppRoutes.settings:
            return _route(const SettingsScreen());
          default:
            return _route(const HomeScreen());
        }
      },
    );
  }

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);
}
