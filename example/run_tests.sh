#!/bin/bash

# Script to run widget tests for ui_eval example app

echo "Running ui_eval widget tests..."
echo "================================"

# Check if flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found in PATH"
    echo "Please ensure Flutter is installed and in your PATH"
    exit 1
fi

# Run all tests
echo ""
echo "Running all widget tests..."
flutter test test/widget_test.dart --verbose

echo ""
echo "================================"
echo "Test run complete!"
