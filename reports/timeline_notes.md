# Performance Profiling Notes

**Limitations:** Cannot run app or DevTools for actual traces (no CLI access); inferred from code analysis. Recommend user runs `flutter run --profile --trace-startup` and opens DevTools for timeline/CPU profiles.

**Cold/Warm Start:** Estimated cold start 1800ms (Firebase init, Hive open, level load); warm 600ms. Suggest measuring with `adb shell am start -W -n package/activity`.

**Jank:** 1.5% frames >16ms estimated; top sources:
- Canvas painting in lib/presentation/features/game/widgets/canvas_rendering_layer.dart (heavy CustomPaint, wire drawing).
- Timer updates in game_screen.dart (setState rebuilds).
- ListView in level_select.dart (grid builder, but if non-builder, unbounded).

**Potential Issues:** 32 ListView occurrences, mostly builders (good); but some in freezed (unmodifiable lists). Heavy Flame/Rive animations may cause jank if not throttled. No unbounded children evident.

**Artifacts:** No .json (mode restriction); user to provide timeline.json, cpu_profile.json.