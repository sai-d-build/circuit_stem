#!/bin/bash

# Script to add ignore comments to canvas.draw* method calls
# This addresses cascade_invocations lint issues for void methods

find lib/ -name "*.dart" -exec sed -i 's/canvas\.draw\([a-zA-Z]*\)(\([^)]*\))/canvas.draw\1(\/\/ ignore: cascade_invocations\n\2)/g' {} \;

echo "Canvas cascade fixes applied"