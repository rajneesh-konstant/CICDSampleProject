#!/bin/bash

# CI/CD Setup Script for React Native Project
# This script helps set up the CI/CD pipeline for the project

set -e

echo "🚀 Setting up CI/CD for React Native Project"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the project root."
    exit 1
fi

print_info "Checking project setup..."

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js 18+ is required. Current version: $(node --version)"
    exit 1
fi
print_status "Node.js version: $(node --version)"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    print_info "Installing npm dependencies..."
    npm install
    print_status "Dependencies installed"
else
    print_status "Dependencies already installed"
fi

# Install iOS dependencies
if [ -d "ios" ]; then
    print_info "Setting up iOS dependencies..."
    cd ios
    
    # Install bundler gems
    if [ -f "Gemfile" ]; then
        if ! command -v bundle &> /dev/null; then
            print_warning "Bundler not found. Installing..."
            gem install bundler
        fi
        bundle install
        print_status "Ruby gems installed"
    fi
    
    # Install CocoaPods
    if [ -f "Podfile" ]; then
        if ! command -v pod &> /dev/null; then
            print_warning "CocoaPods not found. Please install it manually:"
            print_info "sudo gem install cocoapods"
            exit 1
        fi
        pod install
        print_status "CocoaPods dependencies installed"
    fi
    
    cd ..
fi

# Check Android setup
if [ -d "android" ]; then
    print_info "Checking Android setup..."
    
    # Make gradlew executable
    if [ -f "android/gradlew" ]; then
        chmod +x android/gradlew
        print_status "Made gradlew executable"
    fi
    
    # Check if Android SDK is available
    if ! command -v adb &> /dev/null; then
        print_warning "Android SDK not found in PATH. Make sure Android Studio is installed."
    else
        print_status "Android SDK found"
    fi
fi

# Create necessary directories
mkdir -p docs
print_status "Created docs directory"

# Check if GitHub Actions workflows exist
if [ -d ".github/workflows" ]; then
    print_status "GitHub Actions workflows found"
    
    # List workflow files
    echo "Available workflows:"
    for workflow in .github/workflows/*.yml; do
        if [ -f "$workflow" ]; then
            echo "  - $(basename "$workflow")"
        fi
    done
else
    print_error "GitHub Actions workflows not found in .github/workflows/"
fi

# Check for required configuration files
echo ""
print_info "Checking configuration files..."

if [ -f ".prettierrc" ]; then
    print_status "Prettier configuration found"
else
    print_warning "Prettier configuration not found"
fi

if [ -f "android/gradle.properties.example" ]; then
    print_status "Android gradle.properties example found"
    if [ ! -f "android/gradle.properties" ]; then
        print_warning "Copy android/gradle.properties.example to android/gradle.properties and fill in your values"
    fi
else
    print_warning "Android gradle.properties example not found"
fi

# Check for Fastlane setup
if [ -f "ios/fastlane/Fastfile" ]; then
    print_status "Fastlane configuration found"
else
    print_warning "Fastlane configuration not found"
fi

echo ""
print_info "Next Steps:"
echo "1. Set up GitHub repository secrets (see docs/CI_CD_SETUP.md)"
echo "2. Configure Android signing (keystore and gradle.properties)"
echo "3. Set up iOS code signing with Fastlane Match"
echo "4. Push to GitHub to trigger CI/CD workflows"

echo ""
print_info "Useful commands:"
echo "  npm test                    # Run tests"
echo "  npm run lint               # Run linting"
echo "  npm run type-check         # TypeScript check"
echo "  npm run format             # Format code"
echo "  npm run build:android      # Build Android APK"

echo ""
print_status "CI/CD setup complete! 🎉"
print_info "See docs/CI_CD_SETUP.md for detailed configuration instructions."
