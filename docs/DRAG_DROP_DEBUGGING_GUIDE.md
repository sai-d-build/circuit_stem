# Drag-Drop Debugging Guide for Circuit STEM

## Overview
This guide provides systematic debugging procedures for the drag-drop system in Circuit STEM. It includes best practices, debugging workflows, and troubleshooting techniques.

## Table of Contents
1. [Debug Dashboard](#debug-dashboard)
2. [Console Logging](#console-logging)
3. [Visual Indicators](#visual-indicators)
4. [Systematic Debugging Workflow](#systematic-debugging-workflow)
5. [Common Issues & Solutions](#common-issues--solutions)
6. [Performance Debugging](#performance-debugging)
7. [Testing Procedures](#testing-procedures)

## Debug Dashboard

### Real-time Information Display
The debug dashboard (top-left corner) shows:
- **🎯 INTERACTION STATE**: Current mode, validation status, selected component
- **📊 GRID STATE**: Component counts, grid dimensions, occupancy
- **🔧 COMPONENTS BY TYPE**: Breakdown of placed components
- **📦 INVENTORY SUMMARY**: Available/used counts, utilization percentage
- **📋 COMPONENT INVENTORY**: Individual component availability
- **❌ ERROR**: Any error messages
- **⚡ PERFORMANCE**: System metrics

### Dashboard Features
- **Color-coded status**: Green=valid, Red=error
- **Scrollable content**: All information visible
- **Real-time updates**: Refreshes with state changes
- **Compact display**: Organized sections with clear headers

## Console Logging

### Structured Log Format
All logs follow this format:
```
🎯 ===== [EVENT TYPE] =====
- Key: value pairs
- Detailed context information
- Timestamp for performance tracking
- Level ID for multi-level debugging
```

### Log Categories

#### 1. Drag Start Logs
```
🎯 ===== DRAG STARTED =====
- Component details (name, type, cost)
- Inventory counts (available/total/used)
- Game state before drag
- Timestamp and level ID
```

#### 2. Canvas Interaction Logs
```
🎯 ===== CANVAS DRAG START =====
- RenderBox status
- Coordinate validation
- Component acceptance/rejection
```

#### 3. Placement Logs
```
🎯 ===== COMPONENT PLACEMENT SUCCESS =====
- Grid position (row,col)
- Component type and ID
- Inventory before/after
- Grid state summary
```

#### 4. Wire Placement Logs
```
🎯 ===== WIRE PLACEMENT SUCCESS =====
- Network details (segments, length)
- Port connections
- Wire placement count
```

## Visual Indicators

### Component Palette
- **Green Border**: Draggable component
- **Blue Border**: Selected component
- **Red Border**: Exhausted component
- **Gray Border**: Non-draggable component
- **Inventory Count**: X/Y format (available/total)
- **Tooltip**: Detailed status information

### Grid Components
- **Type Label**: BAT, LED, WIR, etc. (top-right)
- **Grid Position**: (row,col) coordinates (bottom-left)
- **Selection Highlight**: Blue border when selected

### Debug Overlay
- **Status Indicator**: Green/red circle for system health
- **Real-time Updates**: All information refreshes live
- **Scrollable Content**: No information cutoff

## Systematic Debugging Workflow

### Phase 1: Initial Assessment
1. **Check Debug Dashboard**
   - Verify interaction mode
   - Check component counts
   - Review error messages

2. **Examine Console Logs**
   - Look for 🎯 markers
   - Check timestamps for sequence
   - Verify state transitions

3. **Visual Inspection**
   - Component color coding
   - Inventory displays
   - Grid position indicators

### Phase 2: Drag Operation Analysis
1. **Start Drag**
   - Check palette visual indicators
   - Verify console "DRAG STARTED" log
   - Confirm inventory counts

2. **Canvas Interaction**
   - Look for "CANVAS DRAG START" log
   - Check RenderBox status
   - Verify coordinate validation

3. **Drop Operation**
   - Check "COMPONENT PLACEMENT" logs
   - Verify inventory updates
   - Confirm grid state changes

### Phase 3: State Validation
1. **Pre-Operation State**
   - Component counts
   - Inventory levels
   - Grid occupancy

2. **Post-Operation State**
   - State change verification
   - Inventory decrementation
   - Grid updates

3. **Consistency Checks**
   - Total counts match
   - No orphaned components
   - Valid grid positions

## Common Issues & Solutions

### Issue 1: Component Not Draggable
**Symptoms**: Component shows gray/red border, no drag feedback
**Debug Steps**:
1. Check inventory count (X/Y format)
2. Verify component selection
3. Check console for availability errors
**Solutions**:
- Ensure component is selected first
- Check inventory availability
- Verify component is unlocked

### Issue 2: Drag Rejected by Canvas
**Symptoms**: Drag ends without placement, no success log
**Debug Steps**:
1. Check "CANVAS DRAG START" log
2. Verify RenderBox attachment
3. Check coordinate validation
**Solutions**:
- Ensure canvas is properly initialized
- Check grid bounds
- Verify component compatibility

### Issue 3: Inventory Not Updating
**Symptoms**: Component placed but inventory unchanged
**Debug Steps**:
1. Check "PLACEMENT SUCCESS" log
2. Verify inventory before/after counts
3. Check palette state updates
**Solutions**:
- Ensure placement service is called
- Verify state notifier updates
- Check provider subscriptions

### Issue 4: Grid Position Incorrect
**Symptoms**: Component appears at wrong location
**Debug Steps**:
1. Check grid coordinates in logs
2. Verify coordinate transformation
3. Check component positioning
**Solutions**:
- Validate coordinate system
- Check grid bounds
- Verify positioning calculations

## Performance Debugging

### Metrics to Monitor
- **Drag responsiveness**: Time from start to visual feedback
- **Placement speed**: Time from drop to confirmation
- **UI update frequency**: State change propagation
- **Memory usage**: Component count impact

### Performance Logs
```
🎯 PERFORMANCE METRICS
- Operation duration
- Component count impact
- Memory usage trends
- Frame rate stability
```

### Optimization Checks
1. **Throttling**: 16ms update intervals
2. **Caching**: Coordinate transformations cached
3. **RepaintBoundary**: UI isolation
4. **State efficiency**: Minimal rebuilds

## Testing Procedures

### Manual Testing Checklist
- [ ] Component selection works
- [ ] Drag feedback appears
- [ ] Canvas accepts drops
- [ ] Inventory updates correctly
- [ ] Grid positions accurate
- [ ] Visual indicators correct
- [ ] Console logs complete
- [ ] Error handling works

### Automated Testing
```dart
// Example test structure
void main() {
  test('Drag-drop workflow', () {
    // 1. Setup component palette
    // 2. Select draggable component
    // 3. Start drag operation
    // 4. Verify canvas interaction
    // 5. Complete drop
    // 6. Verify placement success
    // 7. Check inventory updates
    // 8. Validate grid state
  });
}
```

### Integration Testing
1. **Full Workflow Test**
   - Palette → Canvas → Placement
   - State consistency
   - UI updates

2. **Error Scenario Testing**
   - Invalid drops
   - Inventory exhaustion
   - Grid conflicts

3. **Performance Testing**
   - Multiple rapid operations
   - Large component counts
   - Memory leak detection

## Best Practices

### 1. Always Check Debug Dashboard First
- Quick overview of system state
- Immediate identification of issues
- Real-time monitoring

### 2. Use Console Logs for Detailed Analysis
- Structured information
- Timestamp tracking
- State transition verification

### 3. Visual Indicators for Quick Diagnosis
- Color-coded status
- Inventory visibility
- Position confirmation

### 4. Systematic Investigation
- Start with symptoms
- Follow data flow
- Check each component
- Verify state consistency

### 5. Performance Monitoring
- Response time tracking
- Memory usage analysis
- Frame rate stability

## Troubleshooting Quick Reference

| Symptom | First Check | Likely Cause | Solution |
|---------|-------------|--------------|----------|
| Not draggable | Visual indicators | Not selected/low inventory | Select component first |
| Drag rejected | Console logs | Invalid coordinates | Check grid bounds |
| No placement log | Debug dashboard | State update failure | Check provider subscriptions |
| Wrong position | Grid coordinates | Coordinate error | Validate transformation |
| Inventory stuck | Before/after logs | Update failure | Check state notifier |

## Emergency Debugging

### When Everything Breaks
1. **Check browser console** for JavaScript errors
2. **Verify provider initialization** in main.dart
3. **Check network tab** for asset loading
4. **Clear browser cache** and reload
5. **Check Flutter DevTools** for widget tree

### Critical Error Recovery
1. **Hot restart** the application
2. **Check provider scopes** are properly nested
3. **Verify import statements** are correct
4. **Check for circular dependencies**
5. **Validate state initialization**

This debugging guide provides a comprehensive framework for diagnosing and resolving drag-drop issues in Circuit STEM. Use the debug dashboard as your primary tool, console logs for detailed analysis, and visual indicators for quick diagnosis.