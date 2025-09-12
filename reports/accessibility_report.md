# Accessibility, Localization & UX

**Localized Strings:** 0% (no .arb/intl setup; all hardcoded in UI, e.g., login_screen.dart 'Password'). Recommend intl for RTL/multi-lang.

**Accessibility Issues:** 14 Semantics occurrences in accessibility/ (good for canvas/button); missing labels on game components, small touch targets in palette, color contrast low for neon (recommend WCAG check).

**RTL:** No support (no Directionality.rtl).

**Screenshots:** No (limitation); suggest TalkBack/VoiceOver test on key screens (game, login).

Issues: {"file":"lib/presentation/features/game/widgets/canvas_rendering_layer.dart","issue":"no semantics for components"}.