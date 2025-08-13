# CI/CD Setup Documentation

This document describes the CI/CD pipeline setup for the CiCdSampleProject React Native application.

## Overview

The CI/CD pipeline is implemented using GitHub Actions and includes:
- Automated testing and code quality checks
- Android APK/AAB building and deployment to Google Play
- iOS building and deployment to TestFlight/App Store
- Environment-specific deployments (staging/production)

## Workflows

### 1. CI Workflow (`ci.yml`)
**Triggers:** Push to `main`/`develop` branches, Pull Requests
**Purpose:** Run tests, linting, type checking, and security scans

**Jobs:**
- **test**: Runs ESLint, TypeScript checks, Jest tests with coverage
- **prettier-check**: Validates code formatting
- **security-scan**: Runs npm audit and CodeQL analysis

### 2. Android Build Workflow (`android-build.yml`)
**Triggers:** Push to `main`, tags, manual dispatch
**Purpose:** Build Android APK/AAB and deploy to Google Play

**Jobs:**
- **build-android**: Creates debug APK, release APK, and AAB
- **deploy-android**: Deploys AAB to Google Play Console (internal track)

### 3. iOS Build Workflow (`ios-build.yml`)
**Triggers:** Push to `main`, tags, manual dispatch
**Purpose:** Build iOS app and deploy to TestFlight

**Jobs:**
- **build-ios**: Creates iOS build using Fastlane
- **deploy-ios**: Deploys to TestFlight

### 4. Deploy Workflow (`deploy.yml`)
**Triggers:** Manual dispatch only
**Purpose:** Deploy to specific environments (staging/production)

**Features:**
- Choose platform (Android, iOS, or both)
- Choose environment (staging or production)
- Environment-specific deployment tracks

## Required Secrets

### GitHub Repository Secrets

#### Android Secrets
```
ANDROID_KEYSTORE_FILE          # Base64 encoded keystore file
ANDROID_KEYSTORE_PASSWORD      # Keystore password
ANDROID_KEY_ALIAS             # Key alias name
ANDROID_KEY_PASSWORD          # Key password
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON # Google Play Console service account JSON
```

#### iOS Secrets
```
MATCH_PASSWORD                 # Fastlane Match password
FASTLANE_USER                 # Apple Developer account email
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD # App-specific password
FASTLANE_SESSION              # Fastlane session (optional)
```

## Setup Instructions

### 1. Android Setup

#### Generate Keystore
```bash
keytool -genkey -v -keystore my-upload-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

#### Configure Android Signing
1. Add keystore to `android/app/` directory
2. Update `android/gradle.properties`:
```properties
MYAPP_UPLOAD_STORE_FILE=my-upload-key.keystore
MYAPP_UPLOAD_KEY_ALIAS=my-key-alias
MYAPP_UPLOAD_STORE_PASSWORD=*****
MYAPP_UPLOAD_KEY_PASSWORD=*****
```

3. Update `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            if (project.hasProperty('MYAPP_UPLOAD_STORE_FILE')) {
                storeFile file(MYAPP_UPLOAD_STORE_FILE)
                storePassword MYAPP_UPLOAD_STORE_PASSWORD
                keyAlias MYAPP_UPLOAD_KEY_ALIAS
                keyPassword MYAPP_UPLOAD_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Google Play Console Setup
1. Create a service account in Google Cloud Console
2. Grant necessary permissions in Google Play Console
3. Download service account JSON file
4. Add JSON content to `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret

### 2. iOS Setup

#### Fastlane Match Setup
```bash
cd ios
bundle exec fastlane match init
```

#### Apple Developer Account
1. Create App-Specific Password in Apple ID settings
2. Set up Fastlane Match for code signing
3. Configure bundle identifier in Xcode

### 3. Environment Configuration

#### GitHub Environments
Create environments in GitHub repository settings:
- `staging`: For internal testing
- `production`: For production releases

#### Environment Variables
Configure environment-specific variables in GitHub environments.

## Usage

### Running CI/CD Locally

#### Run Tests
```bash
npm test
npm run lint
npm run type-check
```

#### Build Android
```bash
npm run build:android
npm run build:android:bundle
```

#### Build iOS
```bash
cd ios
bundle exec fastlane build_release
```

### Manual Deployment

#### Deploy via GitHub Actions
1. Go to Actions tab in GitHub repository
2. Select "Deploy" workflow
3. Click "Run workflow"
4. Choose environment and platform
5. Click "Run workflow"

#### Deploy Android via Fastlane
```bash
cd android
./gradlew bundleRelease
# Upload to Google Play Console manually
```

#### Deploy iOS via Fastlane
```bash
cd ios
bundle exec fastlane deploy_testflight  # For TestFlight
bundle exec fastlane deploy_app_store   # For App Store
```

## Troubleshooting

### Common Issues

1. **Android Build Fails**
   - Check keystore configuration
   - Verify Gradle wrapper permissions
   - Clean build: `npm run clean:android`

2. **iOS Build Fails**
   - Update CocoaPods: `cd ios && pod install`
   - Check code signing certificates
   - Clean build: `npm run clean:ios`

3. **Fastlane Issues**
   - Update Fastlane: `bundle update fastlane`
   - Check Apple Developer account status
   - Verify Match password

### Logs and Debugging
- Check GitHub Actions logs for detailed error messages
- Use `fastlane --verbose` for detailed iOS build logs
- Use `./gradlew --info` for detailed Android build logs

## Security Best Practices

1. **Secrets Management**
   - Never commit secrets to repository
   - Use GitHub Secrets for sensitive data
   - Rotate secrets regularly

2. **Code Signing**
   - Use separate certificates for development and production
   - Store certificates securely using Fastlane Match
   - Enable two-factor authentication on Apple Developer account

3. **Dependencies**
   - Regularly update dependencies
   - Run security audits: `npm audit`
   - Use Dependabot for automated updates

## Monitoring and Notifications

### GitHub Actions
- Enable email notifications for failed builds
- Use GitHub mobile app for real-time notifications
- Set up Slack/Discord webhooks for team notifications

### App Store Connect / Google Play Console
- Monitor app review status
- Set up crash reporting (Crashlytics, Sentry)
- Track app performance metrics
