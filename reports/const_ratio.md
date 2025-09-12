# Const Usage Analysis

Total \bconst\b occurrences in lib/*.dart: 300+ (high in freezed generated code, colors, static widgets).

Heuristic ratio: ~0.25 (25% of widgets use const; strong in domain/entities (immutable with freezed), theme definitions, but low in dynamic UI like game screens/widgets where build methods create non-const instances frequently, e.g., Container, Text without const).

List of widgets lacking const (examples):
- lib/presentation/features/game/screens/game_screen.dart: Many non-const layers (CanvasRenderingLayer, etc.) in build – should be const where possible.
- lib/presentation/features/auth/screens/login_screen.dart: Form fields, buttons non-const.
- lib/presentation/features/onboarding/screens/onboarding_screen.dart: PageView children non-const.

Recommend adding const to all stateless widget constructors and static elements to improve performance.