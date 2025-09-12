# setState Occurrences (61 total)

Examples of worst offenders (in high-level parents, causing rebuilds):

1. lib/presentation/features/game/screens/game_screen.dart:73 - setState for timer update in main screen (rebuilds entire screen every second).
   Snippet: if (mounted) { setState(() { _elapsedTime += const Duration(seconds: 1); }); }

2. lib/presentation/features/auth/screens/login_screen.dart:61 - setState for loading in login screen (rebuilds form during auth).
   Snippet: setState(() { _isLoading = true; });

3. lib/presentation/features/onboarding/screens/onboarding_screen.dart:66 - setState for page change in onboarding (rebuilds all pages).
   Snippet: onPageChanged: (page) { setState(() => _currentPage = page); }

Recommend migrating to Riverpod notifiers to avoid full rebuilds.