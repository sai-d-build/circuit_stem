# Packaging & Build Size

**Release Sizes:** Estimated AAB 20MB, APK arm64 15MB (Flame/Rive, Firebase deps); no ABI splits configured.

**Obfuscation:** No --obfuscate in build.yaml; no ProGuard/R8 custom.

**Configs:** Standard pubspec; suggest flutter build appbundle --split-debug-info for shrinking.

Limitation: Cannot build; user to run `flutter build appbundle --release` for sizes.