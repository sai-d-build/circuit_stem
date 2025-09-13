# CircuitSTEM: Rollback Procedures

**Date:** September 13, 2025
**Phase:** 0 - Preparation & Safety Net
**Status:** Rollback procedures documented

## Overview

This document outlines the rollback procedures for the CircuitSTEM grid and interaction system refactoring. The refactoring uses runtime feature flags to enable safe, gradual rollout and emergency rollback capabilities.

## Feature Flags Overview

The refactoring uses the following feature flags in `FeatureFlagService`:

- `unified_coords`: Enables unified coordinate service (default: false)
- `nearness_rule`: Enables component nearness validation (default: false)
- `shadow_mode_validation`: Enables shadow-mode diffing for validation (default: false)
- `atomic_placement`: Enables atomic placement transactions (default: false)

## Emergency Rollback Procedures

### Automated Emergency Rollback

The system includes automated emergency rollback triggers:

```dart
// Trigger emergency rollback programmatically
FeatureFlagService.instance.rollbackToSafeDefaults();

// Or rollback to V3 implementation
FeatureFlagService.instance.rollbackToV3();
```

**When to trigger emergency rollback:**
- Performance degradation > 20% from baseline
- Critical bugs reported in production
- Memory usage > 90%
- Coordinate conversion accuracy < 95%

### Manual Rollback Steps

#### Step 1: Immediate Flag Deactivation
```dart
// Disable all refactoring features
FeatureFlagService.instance.setFlag('unified_coords', false);
FeatureFlagService.instance.setFlag('nearness_rule', false);
FeatureFlagService.instance.setFlag('shadow_mode_validation', false);
FeatureFlagService.instance.setFlag('atomic_placement', false);
```

#### Step 2: Clear Cached State
```dart
// Clear any cached coordinate transformations
UnifiedCoordinateService().clearCache();

// Clear component placement caches
ComponentCacheManager().clearCache();
```

#### Step 3: Restart Application
Force a clean application restart to ensure all cached state is cleared and legacy code paths are active.

## Rollback Scenarios

### Scenario 1: Performance Regression

**Detection:** CI performance budgets exceeded or runtime monitoring alerts.

**Procedure:**
1. Trigger automated emergency rollback
2. Monitor performance metrics for 1 hour
3. If performance recovers, investigate root cause
4. Gradually re-enable features one by one

### Scenario 2: Functional Regression

**Detection:** User reports of bugs or failed tests.

**Procedure:**
1. Disable problematic feature flag
2. Deploy hotfix with flag disabled
3. Investigate and fix the issue
4. Re-enable feature with fix

### Scenario 3: Coordinate Conversion Issues

**Detection:** Shadow-mode validation shows discrepancies > 5%.

**Procedure:**
1. Disable `unified_coords` flag
2. Fall back to legacy coordinate conversion
3. Debug and fix coordinate service
4. Re-enable with validation

## Monitoring and Alerts

### Performance Monitoring
- Drag operation latency (p50 ≤ 8ms, p99 ≤ 16ms)
- Component placement latency (≤ 50ms)
- Frame rate stability
- Memory usage

### Functional Monitoring
- Coordinate conversion accuracy
- Component placement success rate
- User interaction error rates
- Shadow-mode validation discrepancies

### Alert Thresholds
- Performance degradation: > 15% from baseline
- Error rate increase: > 10%
- Coordinate accuracy: < 98%
- Memory usage: > 85%

## Rollback Testing

### Pre-Rollback Validation
Before rolling back, verify:
1. Legacy code paths are functional
2. Performance returns to baseline
3. User experience is acceptable
4. No data loss occurs

### Post-Rollback Validation
After rollback, monitor:
1. System stability for 24 hours
2. User feedback and error reports
3. Performance metrics return to baseline
4. Feature flag status in monitoring

## Recovery Procedures

### Gradual Feature Re-enablement
After successful rollback:

1. **Phase 1:** Re-enable `unified_coords` only
2. **Phase 2:** Add `nearness_rule` if coordinate service is stable
3. **Phase 3:** Enable `atomic_placement` for state management improvements
4. **Phase 4:** Enable `shadow_mode_validation` for ongoing monitoring

### A/B Testing Approach
For high-risk features:
1. Enable for 10% of users
2. Monitor for 24 hours
3. Gradually increase to 50%, then 100%
4. Maintain rollback capability throughout

## Communication Plan

### Internal Communication
- Slack alerts for automated rollbacks
- Email notifications for manual rollbacks
- Dashboard updates for monitoring status

### User Communication
- Status page updates for outages
- In-app notifications for temporary feature disabling
- Release notes for rollback reasons

## Lessons Learned Documentation

After each rollback incident:
1. Document root cause analysis
2. Update risk assessments
3. Improve monitoring and alerting
4. Enhance testing procedures
5. Update rollback procedures based on experience

## Contact Information

**Technical Lead:** Development Team
**On-call Engineer:** SRE Team
**Product Owner:** Product Team

**Emergency Contacts:**
- Primary: +1-XXX-XXX-XXXX
- Secondary: +1-XXX-XXX-XXXX
- Slack: #circuitstem-emergency

## Appendix: Feature Flag Status Commands

### Check Current Status
```dart
final status = FeatureFlagService.instance.getStatusReport();
print('Feature Flag Status: ${status}');
```

### Force Safe State
```dart
FeatureFlagService.instance.rollbackToSafeDefaults();
```

### Enable Specific Feature
```dart
FeatureFlagService.instance.setFlag('unified_coords', true);
```

### Monitor Feature Usage
```dart
// Check which features are active
print('Unified Coords: ${FeatureFlagService.instance.unifiedCoords}');
print('Nearness Rule: ${FeatureFlagService.instance.nearnessRule}');