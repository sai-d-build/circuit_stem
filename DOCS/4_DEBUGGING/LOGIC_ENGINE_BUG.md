# Bug Report: LogicEngine Fails Power Evaluation Tests

**Date:** 2025-08-18
**Status:** Confirmed
**Priority:** High

## Summary

During the process of refactoring the SVG rendering pipeline, a pre-existing bug in the `LogicEngine` was discovered. Several unit tests in `test/logic_engine_rich_test.dart` are failing consistently. These tests are pure unit tests that do not involve any UI, asset loading, or SVG rendering, proving that the bug is in the core circuit evaluation logic.

## Failing Tests

The following tests in `test/logic_engine_rich_test.dart` fail:

1.  `'long wire length 3 powers bulb at end'`
2.  `'T-piece branches power to two bulbs'`
3.  `'rotated T piece correctly routes power (rotation test)'`

In all cases, the test expects a component to be powered (`isTrue`), but the `LogicEngine` evaluation returns `isFalse`.

## Analysis

The failures indicate that the `LogicEngine`'s `evaluate` method is not correctly calculating the power flow through complex or rotated components, specifically `ComponentModel.longWire` and `ComponentModel.wireT`.

This issue is **unrelated** to the ongoing SVG rendering refactor. The tests fail regardless of which SVG rendering pipeline is active.

## Recommended Next Steps

1.  **Assign to Logic Engine Owner:** This bug should be assigned to the developer responsible for the core game logic.
2.  **Debug the `LogicEngine`:** The `evaluate` method in `lib/services/logic_engine.dart` needs to be debugged, with a focus on how it handles component terminals, shapes, and rotations.
3.  **Fix and Verify:** Once a fix is implemented, the tests in `logic_engine_rich_test.dart` should be run to verify the resolution.
