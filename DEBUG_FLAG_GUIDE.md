# 🔥 DEBUG FLAG GUIDE - Component Placement Investigation

## 🎯 HOW TO ENABLE DEBUG LOGS

Use these flags when running your Flutter app:

```bash
# Enable ALL debug logging for comprehensive investigations
flutter run -d chrome \
  --dart-define=DEBUG_COMPONENT_TYPES=true \
  --dart-define=DEBUG_INVENTORY=true \
  --dart-define=DEBUG_STATE_SYNC=true \
  --dart-define=DEBUG_DRAG_DROP=true \
  --dart-define=DEBUG_COORDINATES=true \
  --dart-define=DEBUG_GRID_STATE=true \
  --dart-define=DEBUG_LEVEL_INTEGRATION=true

# Enable only COMPONENT PLACEMENT debugging (minimal)
flutter run -d chrome \
  --dart-define=DEBUG_COMPONENT_TYPES=true \
  --dart-define=DEBUG_DRAG_DROP=true \
  --dart-define=DEBUG_GRID_STATE=true

# Quick debug for RESISTOR vs other component behavior
flutter run -d chrome \
  --dart-define=DEBUG_COMPONENT_TYPES=true \
  --dart-define=DEBUG_COORDINATES=true
```

## 📊 DEBUG FLAGS ADDED

### 🎯 Component Type Debugging
- **Flag**: `DEBUG_COMPONENT_TYPES=true`
- **Location**: GameCanvas, InteractionEngine, CircuitGrid
- **Purpose**: Track which components work vs fail and why
- **Logs**: Component placement attempts by type

### 📦 Inventory Debugging
- **Flag**: `DEBUG_INVENTORY=true`
- **Location**: InteractionEngine
- **Purpose**: Fix inventory never decreasing issue
- **Problem**: `_inventoryHas()` always returns true
- **Logs**: Inventory validation attempts

### 🔄 State Synchronization Debugging
- **Flag**: `DEBUG_STATE_SYNC=true`
- **Location**: CircuitGrid synchronization methods
- **Purpose**: Fix components invisible in UI despite placement
- **Problem**: Provider shows 4, UI shows 0
- **Logs**: State sync between interaction → unified providers

### 🎯 Drag-Drop Sequence Debugging
- **Flag**: `DEBUG_DRAG_DROP=true`
- **Location**: InteractionEngine, CircuitGrid
- **Purpose**: Track RESISTOR success vs other component failures
- **Logs**: Complete drag/drop sequence, component-specific behavior

### 📍 Coordinate Validation Debugging
- **Flag**: `DEBUG_COORDINATES=true`
- **Location**: InteractionEngine coordinate transformation
- **Purpose**: Debug visual vs level grid positioning (20x20 vs 6x8)
- **Logs**: Screen → grid coordinate conversion steps

### 🎨 Grid State Debugging
- **Flag**: `DEBUG_GRID_STATE=true`
- **Location**: GameCanvas component rendering
- **Purpose**: Visibility investigation (provider count vs UI)
- **Logs**: Component render state, positioning calculations

### 📋 Level Integration Debugging
- **Flag**: `DEBUG_LEVEL_INTEGRATION=true`
- **Location**: CanvasRenderingLayer, Wire Layer
- **Purpose**: Component visibility verification
- **Logs**: Rendering layer activity, visual state validation

## 🔍 SAMPLE DEBUG OUTPUT

### RESISTOR Works (Expected Output):
```
[WEB] INFO: ✅ COMPONENT SUCCESSFULLY PLACED | Context: {componentType: ComponentType.resistor, position: {row: 4, col: 8}, totalComponents: 1}
[WEB] INFO: 🔄 STATE SYNCHRONIZATION: Completed sync | Context: {total_components_after_sync: 1, component_types: [ComponentType.resistor]}
[WEB] INFO: 🎯 COMPONENT PLACEMENT ATTEMPT | Context: {componentType: ComponentType.resistor, position: {row: 4, col: 8}}
```

### Other Components Fail:
```
[WEB] DEBUG: 🎯 COMPONENT DROP ACCEPTED - CircuitGrid | Context: {componentType: ComponentType.wire, isOccupied: false}
[WEB] DEBUG: 🎯 DRAG LEAVE - CircuitGrid | Context: {reason: user_abandoned_drop}
```

## 🚨 KEY ISSUES TO INVESTIGATE

### 1. Component-Specific Failures
- **RESISTOR**: ✅ Works completely
- **WIRE/BATTERY**: ❌ User abandons drops despite acceptance
- **Cause**: Likely component configuration differences

### 2. Inventory Never Decreases
```dart
// Problem code in InteractionEngine
bool _inventoryHas(ComponentType type) {
  return true; // 🔴 ALWAYS RETURNS TRUE
}
```

### 3. Visual Synchronization Bug
- Provider: `components_count: 4` ✅
- UI Display: `components: 0` ❌
- State sync logs show proper propagation

## 🎯 TARGETED DEBUGGING COMMANDS

### For RESISTOR Success Analysis:
```bash
flutter run -d chrome \
  --dart-define=DEBUG_COMPONENT_TYPES=true \
  --dart-define=DEBUG_GRID_STATE=true
# Look for: component placement success sequence
```

### For Component Failure Diagnosis:
```bash
flutter run -d chrome \
  --dart-define=DEBUG_DRAG_DROP=true \
  --dart-define=DEBUG_COORDINATES=true
# Look for: user_abandoned_drop vs component accepted
```

### For Visual Sync Bug:
```bash
flutter run -d chrome \
  --dart-define=DEBUG_STATE_SYNC=true \
  --dart-define=DEBUG_GRID_STATE=true
# Look for: provider count vs UI count mismatch
```

## 📋 VERIFICATION STEPS

1. **START WITH**: `DEBUG_COMPONENT_TYPES=true + DEBUG_DRAG_DROP=true`
2. **COMPARE**: RESISTOR drag/drop sequence vs other components
3. **ANALYZE**: Coordinate transformations and validation steps
4. **VERIFY**: State synchronization completion
5. **CONFIRM**: Visual rendering of placed components

## 💡 EXPECTED FIX SEQUENCE

1. **Enable flags**: Component-level debugging first
2. **Reproduce issue**: RESISTOR works, others don't
3. **Find cause**: Component configuration vs interaction engine issue
4. **Apply fix**: State sync or component configuration patch
5. **Verify**: All components place and render correctly
6. **Monitor**: Inventory decrements appropriately

---

**🚀 Enable these flags and share the debug logs for precise diagnosis!**