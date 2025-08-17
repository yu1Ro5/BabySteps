# iOS Build & Code Signing Troubleshooting Guide

## Recent Fixes (December 2024)

### ✅ **Info.plist and Provisioning Profile Issues - RESOLVED**

#### Problem: Info.plist not found and provisioning profile errors
**Error**: 
1. `Error: Info.plist not found at Sources/Info.plist`
2. `No profiles for 'com.yu1Ro5.BabySteps' were found`

#### Root Cause:
- File path resolution issues in GitHub Actions environment
- Automatic code signing not properly configured for provisioning profiles
- Missing explicit signing environment setup

#### Solution Applied:
1. **Enhanced File Validation**: Added comprehensive file existence and readability checks
2. **Improved Code Signing Setup**: Added temporary keychain creation and signing environment configuration
3. **Explicit Signing Parameters**: Added `PROVISIONING_PROFILE_SPECIFIER=""` to force automatic provisioning
4. **Better Error Reporting**: Enhanced logging for debugging file path and signing issues

#### Files Modified:
- `.github/workflows/ios-build-testflight.yml`: Enhanced validation and signing setup
- `project.yml`: Added automatic signing optimization settings
- `ExportOptions.plist`: Optimized for automatic signing workflow

---

## Common Issues and Solutions

### 1. Code Signing Conflicts

#### Problem: Conflicting Code Signing Identity
**Error**: The target "BabySteps" has conflicting provisioning settings. It is automatically signed for development but also specifies a manual iPhone Distribution identity.

#### Solution:
- **Ensure Consistent Signing**: The project is now configured to use automatic signing consistently
- **Check project.yml**: Verify `CODE_SIGN_STYLE: "Automatic"` is set for all targets
- **Clear Manual Overrides**: Remove any manual `CODE_SIGN_IDENTITY` or `PROVISIONING_PROFILE_SPECIFIER` settings

#### Configuration in project.yml:
```yaml
settings:
  CODE_SIGN_STYLE: "Automatic"
  CODE_SIGN_IDENTITY: "iPhone Developer"
  PROVISIONING_PROFILE_SPECIFIER: ""
  CODE_SIGN_INCLUDE_ALL_CONTENT_FOR_APP: "YES"
  CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION: "YES"
```

### 2. Build Failure (Error 65)

#### Problem: Archive build fails with error code 65

#### Common Causes:
1. **Code Signing Issues**: Inconsistent signing configuration
2. **Missing Dependencies**: Required frameworks or libraries not found
3. **Build Settings**: Incorrect build configuration
4. **Xcode Version**: Incompatible Xcode version

#### Solutions:

##### A. Code Signing Fix
```bash
# Clean previous builds
xcodebuild clean -project BabySteps.xcodeproj -scheme BabySteps -configuration Release

# Build with explicit signing settings
xcodebuild -project BabySteps.xcodeproj \
           -scheme BabySteps \
           -configuration Release \
           -archivePath ./build/BabySteps.xcarchive \
           CODE_SIGN_STYLE=Automatic \
           CODE_SIGN_IDENTITY="iPhone Developer" \
           DEVELOPMENT_TEAM="58Y7Q3D4A7" \
           PROVISIONING_PROFILE_SPECIFIER="" \
           archive
```

##### B. Verify Project Configuration
```bash
# Check generated project settings
grep -i "CODE_SIGN_STYLE\|CODE_SIGN_IDENTITY\|PROVISIONING_PROFILE" BabySteps.xcodeproj/project.pbxproj

# Verify XcodeGen configuration
xcodegen generate --spec project.yml
```

##### C. Check Build Environment
```bash
# Verify Xcode version
xcodebuild -version

# Check available SDKs
xcodebuild -showsdks | grep iOS

# Verify project structure
ls -la *.xcodeproj
ls -la Sources/
```

### 3. Export IPA Issues

#### Problem: IPA export fails after successful archive

#### Solutions:

##### A. Verify ExportOptions.plist
```xml
<key>signingStyle</key>
<string>automatic</string>
<key>teamID</key>
<string>58Y7Q3D4A7</string>
```

##### B. Check Archive Integrity
```bash
# Verify archive exists and is valid
ls -la ./build/BabySteps.xcarchive

# Check archive contents
xcodebuild -showBuildSettings -archivePath ./build/BabySteps.xcarchive
```

### 4. GitHub Actions Workflow Issues

#### Problem: Workflow fails during build or export

#### Debugging Steps:

1. **Check Workflow Logs**: Review detailed error messages in GitHub Actions
2. **Verify Secrets**: Ensure all required secrets are properly configured
3. **Check File Paths**: Verify Info.plist and project file locations
4. **Review Build Steps**: Check each step for specific failure points

#### Required GitHub Secrets:
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY`

### 5. XcodeGen Issues

#### Problem: Generated project has incorrect settings

#### Solutions:

##### A. Regenerate Project
```bash
# Remove existing project
rm -rf *.xcodeproj

# Regenerate with XcodeGen
xcodegen generate --spec project.yml
```

##### B. Verify Configuration
```bash
# Check project.yml syntax
xcodegen --spec project.yml --project . --quiet

# Validate project structure
xcodegen --spec project.yml --project . --lint
```

### 6. Provisioning Profile Issues

#### Problem: App Store distribution fails due to provisioning

#### Solutions:

1. **Automatic Signing**: Use automatic signing with proper team ID
2. **Clear Manual Profiles**: Remove any manual provisioning profile specifications
3. **Verify Team Access**: Ensure the team has proper App Store Connect access

### 7. Build Number Management

#### Problem: Build number conflicts or TestFlight upload failures

#### Solutions:

1. **Incremental Build Numbers**: Use sequential build numbers (1, 2, 3...)
2. **Persistent Storage**: Save build numbers in artifacts for continuity
3. **Version Management**: Separate version from build number

### 8. Environment-Specific Issues

#### macOS Runner Issues:
- **Xcode Version**: Ensure correct Xcode version is selected
- **Permissions**: Check file and directory permissions
- **Dependencies**: Verify Homebrew and XcodeGen installation

#### Network Issues:
- **API Rate Limits**: Check App Store Connect API limits
- **Authentication**: Verify API key permissions and validity
- **Proxy/Firewall**: Check network access to Apple services

## Debugging Commands

### Build Verification
```bash
# Check project configuration
xcodebuild -list -project BabySteps.xcodeproj

# Verify scheme configuration
xcodebuild -list -project BabySteps.xcodeproj -json

# Check build settings
xcodebuild -showBuildSettings -project BabySteps.xcodeproj -scheme BabySteps
```

### Code Signing Verification
```bash
# Check signing identity
security find-identity -v -p codesigning

# Verify provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Check team ID
grep -r "58Y7Q3D4A7" BabySteps.xcodeproj/
```

### Archive Verification
```bash
# List archive contents
xcodebuild -showBuildSettings -archivePath ./build/BabySteps.xcarchive

# Check archive info
plutil -p ./build/BabySteps.xcarchive/Info.plist
```

### File Path Verification
```bash
# Check Info.plist existence and readability
ls -la Sources/Info.plist
file Sources/Info.plist
head -5 Sources/Info.plist

# Verify absolute paths
realpath Sources/Info.plist
pwd
```

## Prevention Best Practices

1. **Consistent Configuration**: Use automatic signing consistently across all targets
2. **Version Control**: Keep project.yml and ExportOptions.plist in version control
3. **Regular Updates**: Update Xcode and dependencies regularly
4. **Testing**: Test builds locally before pushing to GitHub Actions
5. **Documentation**: Maintain clear documentation of build requirements and procedures
6. **File Validation**: Always verify file existence and readability in CI/CD pipelines

## Getting Help

If issues persist:

1. **Check GitHub Actions Logs**: Detailed error information is available in workflow runs
2. **Review Recent Changes**: Check what changed before the issue occurred
3. **Compare Configurations**: Verify settings match working configurations
4. **Community Resources**: Check Apple Developer Forums and GitHub Discussions
5. **Apple Developer Support**: Contact Apple Developer Support for code signing issues