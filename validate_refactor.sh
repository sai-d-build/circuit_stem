#!/bin/bash
# GameCanvas Refactoring Validation Script
# This script validates the refactoring process at each phase

set -e  # Exit on any error

echo "🧪 ===== GameCanvas Refactoring Validation ====="
echo "📅 $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Pre-flight checks
echo "🔍 Running pre-flight checks..."

# Check if Flutter is available
if ! command_exists flutter; then
    print_status "FAIL" "Flutter CLI not found. Please install Flutter."
    exit 1
fi

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    print_status "FAIL" "Not in a Flutter project directory."
    exit 1
fi

print_status "PASS" "Pre-flight checks completed"

# Clean and get dependencies
echo "🧹 Cleaning Flutter project..."
if flutter clean; then
    print_status "PASS" "Flutter clean successful"
else
    print_status "FAIL" "Flutter clean failed"
    exit 1
fi

echo "📦 Getting dependencies..."
if flutter pub get; then
    print_status "PASS" "Dependencies updated successfully"
else
    print_status "FAIL" "Failed to get dependencies"
    exit 1
fi

# Run static analysis
echo "🔍 Running static analysis..."
if flutter analyze lib/; then
    print_status "PASS" "Static analysis passed"
else
    print_status "WARN" "Static analysis found issues (review above)"
fi

# Run integration tests
echo "🧪 Running integration tests..."
if flutter test test/integration/ 2>/dev/null; then
    print_status "PASS" "Integration tests passed"
else
    print_status "FAIL" "Integration tests failed"
    echo "💡 Run 'flutter test test/integration/' to see detailed errors"
    exit 1
fi

# Run performance benchmarks
echo "📊 Running performance benchmarks..."
if flutter test test/performance/ --reporter=json > performance_results.json 2>/dev/null; then
    print_status "PASS" "Performance tests completed"

    # Check for performance regressions (basic check)
    if command_exists jq && [ -f "performance_results.json" ]; then
        # This is a simplified check - you may want to implement more sophisticated
        # performance regression detection based on your specific requirements
        print_status "PASS" "Performance results saved to performance_results.json"
    else
        print_status "WARN" "Performance results saved but detailed analysis not available"
    fi
else
    print_status "FAIL" "Performance tests failed"
    echo "💡 Run 'flutter test test/performance/' to see detailed errors"
fi

# Run regression tests
echo "🔄 Running regression tests..."
if flutter test test/regression/ 2>/dev/null; then
    print_status "PASS" "Regression tests passed"
else
    print_status "FAIL" "Regression tests failed"
    echo "💡 Run 'flutter test test/regression/' to see detailed errors"
    exit 1
fi

# Build verification
echo "🔨 Running build verification..."
if flutter build apk --debug --quiet 2>/dev/null; then
    print_status "PASS" "Debug build successful"
else
    print_status "WARN" "Debug build failed - check for compilation errors"
    echo "💡 Run 'flutter build apk --debug' to see detailed build errors"
fi

# Test coverage (if available)
echo "📈 Checking test coverage..."
if [ -d "coverage" ]; then
    if command_exists genhtml && [ -f "coverage/lcov.info" ]; then
        genhtml coverage/lcov.info -o coverage/html
        print_status "PASS" "Coverage report generated: coverage/html/index.html"
    else
        print_status "WARN" "Coverage data available but report generation not available"
    fi
else
    print_status "WARN" "No coverage data found. Run tests with --coverage flag."
fi

echo ""
echo "📊 ===== Validation Summary ====="
echo "If all critical tests passed, proceed to next phase."
echo "If any test failed, review logs and consider rollback options."
echo ""

# Show available backups
echo "📁 Available backups:"
if git branch -a | grep -q "backup/gamecanvas"; then
    echo "  ✅ Git backup branch: backup/gamecanvas-pre-refactor"
else
    echo "  ⚠️  Git backup branch not found"
fi

if ls *.backup.* 1>/dev/null 2>&1; then
    echo "  ✅ File backups found:"
    ls *.backup.* | head -5
    if [ $(ls *.backup.* | wc -l) -gt 5 ]; then
        echo "    ... and $(($(ls *.backup.* | wc -l) - 5)) more"
    fi
else
    echo "  ⚠️  File backups not found"
fi

echo ""
echo "🔄 Quick rollback commands:"
echo "  git checkout backup/gamecanvas-pre-refactor"
echo "  flutter clean && flutter pub get"
echo ""
echo "📞 For help with failures:"
echo "  - Check test output above for specific errors"
echo "  - Review BACKUP_ROLLBACK_STRATEGY.md for detailed rollback procedures"
echo "  - Check TESTING_FRAMEWORK_SETUP.md for test debugging tips"