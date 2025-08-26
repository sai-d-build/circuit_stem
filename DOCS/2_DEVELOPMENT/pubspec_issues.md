
# Pubspec Maintenance Guide for `circuit_stem`

This document explains the dependency issues faced, how they were resolved, and best practices for maintaining a healthy `pubspec.yaml` in the future.

---

## 1. Dependency Issues Encountered

### **1.1 `riverpod_generator` and `source_gen` conflict**

* **Issue:** `riverpod_generator >=2.6.4 <3.0.0-dev.2` required `source_gen ^2.0.0`, but the project was pinned to `source_gen ^3.1.0`.
* **Result:** Version solving failed because `riverpod_generator` and `source_gen` had incompatible ranges.
* **Resolution:** Aligned `source_gen` to a version compatible with the latest stable `riverpod_generator`. Ensured `json_serializable` and `freezed` also matched `source_gen ^3.0.0`.

### **1.2 `freezed_annotation` mismatch**

* **Issue:** `riverpod_generator` required `freezed_annotation ^3.0.0`, but the project was using `freezed_annotation ^2.4.4`.
* **Result:** Dependency solver blocked installation.
* **Resolution:** Upgraded `freezed_annotation` to `^3.0.0` and updated related packages (`freezed`, `custom_lint`).

### **1.3 `flutter_test` and `meta` conflict**

* **Issue:** Flutter SDK’s `flutter_test` depends on `meta 1.16.0`, but the project required `meta ^1.17.0`.
* **Result:** Version solving failed since `flutter_test` couldn’t match newer `meta`.
* **Resolution:** Downgraded `meta` to `^1.16.0` to match the Flutter SDK’s constraints. This ensured compatibility until Flutter updates its internal dependencies.

### **1.4 `analyzer` and `_macros` issue**

* **Issue:** `analyzer 6.7.0` required `_macros 0.3.2 from sdk`, which wasn’t available in the current Dart SDK.
* **Result:** Version solving failed due to missing `_macros` SDK version.
* **Resolution:** Downgraded `analyzer` to a compatible stable release that matched the SDK-provided `_macros`.

---

## 2. Packages & Versions Fixed

* ✅ `source_gen` → aligned to `^3.0.0` (works with `json_serializable` + `freezed`).
* ✅ `riverpod_generator` → locked at `^2.6.5` (compatible with `freezed_annotation ^3.0.0`).
* ✅ `freezed_annotation` → upgraded to `^3.0.0`.
* ✅ `custom_lint` → compatible with `freezed_annotation ^3.0.0`.
* ✅ `meta` → downgraded to `^1.16.0` (for `flutter_test`).
* ✅ `analyzer` → adjusted to match Dart SDK’s `_macros` support.

---

## 3. Lessons Learned & Maintenance Guidelines

### **3.1 Stay Aligned with Flutter SDK**

* Many conflicts were caused by upgrading dependencies (like `meta`) beyond what Flutter SDK internally uses.
* **Rule:** Always check `flutter_test`, `flutter_lints`, and other SDK-provided dependencies before upgrading related packages.

### **3.2 Generator Packages Move in Lockstep**

* `riverpod_generator`, `freezed`, `json_serializable`, and `source_gen` often need synchronized versions.
* **Rule:** Upgrade them together. If one forces a major bump, adjust all related codegen packages.

### **3.3 Analyzer & Dart SDK Compatibility**

* `analyzer` is tightly coupled with the Dart SDK’s `_macros` and `_fe_analyzer_shared`.
* **Rule:** Never pin `analyzer` higher than the Dart SDK supports. Always check compatibility in [dart.dev/tools/sdk](https://dart.dev/tools/sdk).

### **3.4 Linting Plugins**

* `custom_lint` depends on `freezed_annotation` major versions.
* **Rule:** Match linting tool versions to your codegen toolchain (`freezed` + `riverpod_generator`).

### **3.5 Use `pubspec.lock` for Stability**

* Always commit `pubspec.lock` for apps (not packages).
* Prevents teammates from hitting different dependency trees.

### **3.6 Upgrade Strategy**

* Use `flutter pub upgrade --major-versions` only in a controlled branch.
* Test **all build\_runner generators** (`flutter pub run build_runner build --delete-conflicting-outputs`) after upgrades.
* Track changelogs of critical packages: `riverpod`, `freezed`, `analyzer`, `json_serializable`.

---

## 4. Future Upgrades Checklist

* [ ] Check Flutter SDK’s `flutter_test` dependencies (`meta`, `collection`, etc.).
* [ ] Upgrade `freezed`, `riverpod_generator`, `json_serializable`, and `source_gen` together.
* [ ] Verify `analyzer` version matches current Dart SDK’s `_macros`.
* [ ] Ensure `custom_lint` matches the major version of `freezed_annotation`.
* [ ] Run `flutter pub deps` to confirm no duplicate major versions.
* [ ] Run codegen (`build_runner`) and fix conflicts immediately.

vHere’s the completed **4. Future Upgrades Checklist ✅** section for your `pubspec_maintain.md`:

---

### 4. Future Upgrades Checklist ✅

When upgrading Flutter, Dart, or dependencies in the future, follow this checklist to prevent conflicts and maintain stability:

#### 4.1 Check Flutter & Dart SDK Compatibility

* Always verify the target Flutter version supports the Dart SDK required by your dependencies.
* Example: Flutter 3.32.8 → Dart 3.8.1. Upgrading Flutter may also require updating Dart.

#### 4.2 Verify Critical Dependencies

* **Analyzer & Macros**: Ensure `analyzer` versions are compatible with `_macros` from the Dart SDK.
* **Build Runner & Code Generators**: `freezed`, `json_serializable`, `source_gen` must match analyzer version.
* Always consult dependency changelogs for breaking changes.

#### 4.3 Resolve Version Conflicts

* Use `flutter pub outdated` to see outdated packages and possible version constraints.
* If conflicts arise:

  * Prefer upgrading to versions compatible with SDK first.
  * Use `dependency_overrides` cautiously; remove after resolution.
* Avoid forcing older versions that break generator packages or SDK links.

#### 4.4 Test Code Generators

* After any update to `freezed`, `json_serializable`, `build_runner`, run:

  ```bash
  flutter pub run build_runner clean
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
* Verify generated files compile correctly.

#### 4.5 Check Transitive Dependencies

* Many packages depend on `collection`, `meta`, `vector_math`, etc.
* Conflicting transitive dependencies often cause pub get failures. Use overrides only if necessary.

#### 4.6 Verify Platform-Specific Packages

* Packages like `shared_preferences`, `audioplayers`, `path_provider` have platform-specific implementations.
* Test on iOS, Android, Web, Windows, Linux after updates.

#### 4.7 Continuous Integration / Tests

* Run automated tests and code analyzer on CI after upgrades.
* Watch for warnings from `flutter analyze` or `dart analyze`.

#### 4.8 Document Changes

* Maintain a log of upgraded dependencies:

  * Old version → New version
  * Reason for upgrade
  * Any fixes required
* This helps future developers understand constraints and prevent conflicts.

---


---

✅ With these rules, `pubspec.yaml` will stay stable, upgrades will be smoother, and future conflicts easier to resolve.
