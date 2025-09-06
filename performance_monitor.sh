#!/bin/bash

# GameCanvas Refactoring Performance Monitoring Script
# This script benchmarks the performance improvements from the GameCanvas refactoring

echo "🚀 ===== GameCanvas Refactoring Performance Monitoring ====="
echo "📅 $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from project root."
    exit 1
fi

print_info "Starting performance monitoring..."

# Clean and get dependencies
print_info "Cleaning Flutter project..."
flutter clean > /dev/null 2>&1
print_status "Flutter clean completed"

print_info "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_status "Dependencies updated"

# Run static analysis
print_info "Running static analysis..."
ANALYSIS_OUTPUT=$(flutter analyze 2>&1)
ANALYSIS_ISSUES=$(echo "$ANALYSIS_OUTPUT" | grep -c "error\|warning\|info")
print_info "Static analysis completed with $ANALYSIS_ISSUES issues"

# Build performance test
print_info "Building performance test..."
BUILD_START=$(date +%s)
flutter build apk --release > /dev/null 2>&1
BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))
print_status "Build completed in ${BUILD_TIME}s"

# Run unit tests performance
print_info "Running unit tests performance..."
TEST_START=$(date +%s)
flutter test --coverage > /dev/null 2>&1
TEST_END=$(date +%s)
TEST_TIME=$((TEST_END - TEST_START))
print_status "Unit tests completed in ${TEST_TIME}s"

# Run integration tests performance
print_info "Running integration tests performance..."
INTEGRATION_START=$(date +%s)
flutter test test/integration/ > /dev/null 2>&1
INTEGRATION_END=$(date +%s)
INTEGRATION_TIME=$((INTEGRATION_END - INTEGRATION_START))
print_status "Integration tests completed in ${INTEGRATION_TIME}s"

# Code metrics
print_info "Analyzing code metrics..."

# Count lines of code
TOTAL_LOC=$(find lib -name "*.dart" -exec wc -l {} \; | awk '{sum += $1} END {print sum}')
GAMECANVAS_LOC=$(wc -l < lib/presentation/features/game/widgets/game_canvas.dart)
SERVICE_FILES=$(find lib/application/services -name "*.dart" | wc -l)
SERVICE_LOC=$(find lib/application/services -name "*.dart" -exec wc -l {} \; | awk '{sum += $1} END {print sum}')

print_info "Code metrics calculated"

# Performance summary
echo ""
echo "📊 ===== PERFORMANCE SUMMARY ====="
echo "Build Time: ${BUILD_TIME}s"
echo "Unit Test Time: ${TEST_TIME}s"
echo "Integration Test Time: ${INTEGRATION_TIME}s"
echo "Static Analysis Issues: $ANALYSIS_ISSUES"
echo ""
echo "📏 ===== CODE METRICS ====="
echo "Total Lines of Code: $TOTAL_LOC"
echo "GameCanvas Lines: $GAMECANVAS_LOC"
echo "Service Files: $SERVICE_FILES"
echo "Service Lines: $SERVICE_LOC"
echo ""

# Performance assessment
echo "🎯 ===== PERFORMANCE ASSESSMENT ====="

if [ $BUILD_TIME -lt 60 ]; then
    print_status "Build Performance: EXCELLENT (< 60s)"
elif [ $BUILD_TIME -lt 120 ]; then
    print_status "Build Performance: GOOD (< 120s)"
else
    print_warning "Build Performance: NEEDS IMPROVEMENT (> 120s)"
fi

if [ $TEST_TIME -lt 30 ]; then
    print_status "Unit Test Performance: EXCELLENT (< 30s)"
elif [ $TEST_TIME -lt 60 ]; then
    print_status "Unit Test Performance: GOOD (< 60s)"
else
    print_warning "Unit Test Performance: NEEDS IMPROVEMENT (> 60s)"
fi

if [ $INTEGRATION_TIME -lt 15 ]; then
    print_status "Integration Test Performance: EXCELLENT (< 15s)"
elif [ $INTEGRATION_TIME -lt 30 ]; then
    print_status "Integration Test Performance: GOOD (< 30s)"
else
    print_warning "Integration Test Performance: NEEDS IMPROVEMENT (> 30s)"
fi

if [ $GAMECANVAS_LOC -lt 1000 ]; then
    print_status "GameCanvas Size: EXCELLENT (< 1000 lines)"
elif [ $GAMECANVAS_LOC -lt 1400 ]; then
    print_status "GameCanvas Size: GOOD (< 1400 lines)"
else
    print_warning "GameCanvas Size: NEEDS IMPROVEMENT (> 1400 lines)"
fi

echo ""
print_info "Performance monitoring completed!"
echo "📈 Results saved to performance_results_$(date +%Y%m%d_%H%M%S).log"

# Save results to log file
LOG_FILE="performance_results_$(date +%Y%m%d_%H%M%S).log"
cat > "$LOG_FILE" << EOF
GameCanvas Refactoring Performance Results
==========================================

Timestamp: $(date)
Build Time: ${BUILD_TIME}s
Unit Test Time: ${TEST_TIME}s
Integration Test Time: ${INTEGRATION_TIME}s
Static Analysis Issues: $ANALYSIS_ISSUES

Code Metrics:
- Total Lines of Code: $TOTAL_LOC
- GameCanvas Lines: $GAMECANVAS_LOC
- Service Files: $SERVICE_FILES
- Service Lines: $SERVICE_LOC

Assessment:
$(if [ $BUILD_TIME -lt 60 ]; then echo "- Build Performance: EXCELLENT"; elif [ $BUILD_TIME -lt 120 ]; then echo "- Build Performance: GOOD"; else echo "- Build Performance: NEEDS IMPROVEMENT"; fi)
$(if [ $TEST_TIME -lt 30 ]; then echo "- Unit Test Performance: EXCELLENT"; elif [ $TEST_TIME -lt 60 ]; then echo "- Unit Test Performance: GOOD"; else echo "- Unit Test Performance: NEEDS IMPROVEMENT"; fi)
$(if [ $INTEGRATION_TIME -lt 15 ]; then echo "- Integration Test Performance: EXCELLENT"; elif [ $INTEGRATION_TIME -lt 30 ]; then echo "- Integration Test Performance: GOOD"; else echo "- Integration Test Performance: NEEDS IMPROVEMENT"; fi)
$(if [ $GAMECANVAS_LOC -lt 1000 ]; then echo "- GameCanvas Size: EXCELLENT"; elif [ $GAMECANVAS_LOC -lt 1400 ]; then echo "- GameCanvas Size: GOOD"; else echo "- GameCanvas Size: NEEDS IMPROVEMENT"; fi)
EOF

print_status "Performance results saved to $LOG_FILE"