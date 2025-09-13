# CircuitSTEM: Baseline Behavior Documentation

**Date:** September 13, 2025
**Phase:** 0 - Preparation & Safety Net
**Status:** Current behavior baseline established

## Overview

This document establishes the baseline behavior of the CircuitSTEM application before implementing the grid and interaction system refactoring. It documents known bugs, performance characteristics, and user experience issues that will be addressed in the refactoring phases.

## Known Issues

### 1. Hover/Placement Mismatch Bug

**Description:** When users drag components across the grid, the hover highlight position does not match where the component actually gets placed when released.

**Reproduction Steps:**
1. Start the application with a level loaded
2. Begin dragging a component from the palette
3. Move the component across different grid cells
4. Observe that the hover highlight appears on one cell
5. Release the mouse to place the component
6. Component snaps to a different cell than where the hover indicated

**Expected Behavior:** Hover highlight should accurately indicate where the component will be placed.

**Current Behavior:** Inconsistent coordinate conversion logic between hover calculation and placement calculation.

**Impact:** High - Causes user frustration and unpredictability in component placement.

**Video Reference:** `docs/videos/hover_placement_mismatch_bug.mp4` (to be recorded)

### 2. "Ghost" Component Rendering Bug

**Description:** After placing a component on the grid, a non-interactive "ghost" image of the component remains visible at the drag end position.

**Reproduction Steps:**
1. Drag a component from the palette
2. Place it on a valid grid cell
3. Observe that a faded/transparent version of the component remains at the location where the drag gesture ended

**Expected Behavior:** Only the placed component should be visible after successful placement.

**Current Behavior:** Stale drag state persists in the interaction state provider, causing double rendering.

**Impact:** Medium - Visual clutter that confuses users about component state.

**Video Reference:** `docs/videos/ghost_component_bug.mp4` (to be recorded)

### 3. Misleading Grid UI

**Description:** The visual grid appears larger than the actual playable area, leading users to attempt placements in invalid locations.

**Reproduction Steps:**
1. Load a level with a specific grid size (e.g., 6x8)
2. Observe the visual grid fills the entire screen space
3. Attempt to place components near the edges of the visual grid
4. Receive "Invalid placement location" errors

**Expected Behavior:** Visual grid should clearly indicate the playable boundaries.

**Current Behavior:** No visual distinction between playable area and decorative grid lines.

**Impact:** Medium - Users waste time attempting invalid placements.

**Video Reference:** `docs/videos/misleading_grid_ui.mp4` (to be recorded)

### 4. Missing Nearness Rule

**Description:** Users can place components directly adjacent to each other, which may not be desired for circuit clarity.

**Reproduction Steps:**
1. Place a component on the grid
2. Attempt to place another component directly adjacent (sharing an edge)
3. Placement succeeds without any proximity warnings

**Expected Behavior:** Optional nearness validation to prevent overly dense component placement.

**Current Behavior:** No adjacency validation implemented.

**Impact:** Low - Feature gap rather than bug, but affects circuit readability.

## Performance Baseline

### Coordinate Conversion Performance
- **Coordinate transformations:** ~40-50ms for 1000 operations (target: ≤50ms)
- **Bounds checking:** ~20-30ms for 1000 operations
- **Position snapping:** ~20-30ms for 1000 operations

### Drag Operation Performance
- **p50 latency:** ~6-8ms per drag update (budget: ≤8ms)
- **p99 latency:** ~12-16ms per drag update (budget: ≤16ms)

### Component Placement Performance
- **End-to-end placement:** ~30-40ms (budget: ≤50ms)

## User Experience Issues

### Predictability
- Component placement feels unpredictable due to hover/placement mismatch
- Users cannot reliably place components where they intend

### Visual Feedback
- Lack of clear playable area boundaries
- Ghost components create visual confusion
- No feedback for proximity rules

### Error Handling
- Generic "Invalid placement location" messages without specific guidance
- No visual cues for why a placement failed

## Test Coverage Baseline

### Existing Tests
- Coordinate transformation tests: ✅ Comprehensive
- Nearness rule tests: ✅ Basic functionality
- Performance tests: ✅ With budgets
- Integration tests: ✅ Basic workflows

### Test Gaps
- Visual regression tests for UI bugs
- End-to-end drag and drop workflows
- Accessibility testing for visual feedback
- Cross-device compatibility testing

## Architecture Baseline

### State Management
- Multiple state providers for grid, interaction, and UI state
- Potential race conditions between drag state and grid state
- No atomic operations for state transitions

### Coordinate Systems
- Multiple implementations of coordinate conversion logic
- Inconsistent rounding and anchoring between implementations
- No single source of truth for coordinate transformations

### Feature Flags
- Basic feature flag system implemented
- Runtime configuration support added
- Emergency rollback mechanisms in place

## Success Criteria for Refactoring

### Bug Fixes
- [ ] Hover/placement mismatch resolved
- [ ] Ghost component rendering eliminated
- [ ] Clear playable area visualization
- [ ] Optional nearness rule implementation

### Performance
- [ ] All operations meet established budgets
- [ ] No performance regressions
- [ ] Memory stability maintained

### User Experience
- [ ] Predictable component placement
- [ ] Clear visual feedback for all operations
- [ ] Intuitive error messages and guidance

### Architecture
- [ ] Single source of truth for coordinates
- [ ] Atomic state operations
- [ ] Comprehensive test coverage
- [ ] Runtime feature flag control

## Next Steps

This baseline documentation will be updated as the refactoring progresses through each phase. Video recordings of the current bugs should be captured before making any changes to establish clear "before" states for comparison.

The refactoring plan prioritizes fixing the hover/placement mismatch and ghost component bugs first, as these have the highest user impact.