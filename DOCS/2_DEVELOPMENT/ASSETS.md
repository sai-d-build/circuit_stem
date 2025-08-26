# Asset Management Guide

**Project:** Circuit STEM
**Last Updated:** 2025-08-12 EST

---

This document provides a practical guide for adding new content and assets to the game.

## 1. How to Add a New Level

Adding a new level is a two-step process:

1.  **Create the Level JSON File:**
    -   In the `assets/levels/` directory, create a new file named `level_XX.json`, where `XX` is the next sequential number (e.g., `level_11.json`).
    -   The JSON file must conform to the structure defined in `lib/models/level_definition.dart`. It needs a unique `id`, `title`, grid dimensions (`rows`, `cols`), a list of `components`, and a list of `goals`.
    -   You can use an existing level file as a template.

2.  **Update the Level Manifest:**
    -   Open `assets/levels/level_manifest.json`.
    -   Add a new entry to the `levels` array for your new level. Make sure the `id` matches the one in your new JSON file.

    ```json
    {
      "levels": [
        // ... existing levels
        { "id": "level_11", "title": "My New Level" }
      ]
    }
    ```

## 2. How to Add New Images

1.  **File Format & Location:**
    -   Images should be in **SVG** or **PNG** format. SVG is preferred for scalable components.
    -   Place the new image file in the `assets/images/` directory.

2.  **Update Asset Manager:**
    -   The `AssetManager` (`lib/services/asset_manager.dart`) is responsible for loading all assets at startup.
    -   Open `lib/services/asset_manager.dart`.
    -   Locate the `_loadImages` or `_loadSvgs` method (which are called by `loadAllAssets`).
    -   Add the relative path of your new image to the appropriate list.

    ```dart
    // in lib/services/asset_manager.dart
    await _loadSvgs([
      // ... existing images
      'assets/images/my_new_image.svg',
    ]);
    ```

3.  **Update `pubspec.yaml`:**
    -   Ensure the `assets/images/` directory is listed under the `flutter:` -> `assets:` section. This is usually covered by the directory entry, but it's good to double-check.

## 3. How to Add New Audio Files

The process is similar to adding images.

1.  **File Format & Location:**
    -   Short sound effects should be in **WAV** format.
    -   Place the new audio file in the `assets/audio/` directory.

2.  **Update Asset Manager:**
    -   Open `lib/services/asset_manager.dart`.
    -   Locate the `loadAllAssets` method.
    -   Add the filename of your new audio file to the `FlameAudio.audioCache.loadAll()` list.

    ```dart
    // in lib/services/asset_manager.dart
    await FlameAudio.audioCache.loadAll([
      // ... existing audio files
      'my_new_sound.wav', // Note: path relative to assets/audio/
    ]);
    ```