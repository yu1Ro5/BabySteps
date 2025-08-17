# Changelog

## [Unreleased] - 2024-12-19

### 🔧 Fixed
- **Code Signing Conflicts**: Resolved conflicting provisioning settings between automatic and manual signing
- **Build Failures**: Fixed error code 65 during archive step in GitHub Actions
- **Signing Configuration**: Unified code signing settings across all targets to use automatic signing consistently

### 📝 Changed
- **project.yml**: Updated code signing configuration to prevent conflicts
  - Added explicit `CODE_SIGN_IDENTITY` settings for all SDKs
  - Cleared `PROVISIONING_PROFILE_SPECIFIER` to use automatic provisioning
  - Applied consistent signing settings to both main and test targets
- **GitHub Actions Workflow**: Enhanced build process with better error handling
  - Added code signing verification step
  - Implemented explicit signing parameters in build commands
  - Added detailed error logging for build and export failures
  - Added build cleaning step to prevent conflicts
- **ExportOptions.plist**: Optimized export configuration
  - Added explicit provisioning profile mappings
  - Specified signing certificate type
  - Added distribution bundle identifier

### 📚 Added
- **TROUBLESHOOTING.md**: Comprehensive guide for resolving iOS build and code signing issues
- **Enhanced Documentation**: Updated README with information about recent fixes
- **Error Handling**: Improved error reporting and debugging information in CI/CD pipeline

### 🚀 Technical Improvements
- **Consistent Signing**: All targets now use automatic signing with team ID `58Y7Q3D4A7`
- **Build Reliability**: Enhanced build process with explicit parameter passing
- **Debugging**: Added verification steps and detailed error output
- **Maintenance**: Clear documentation for future troubleshooting

## [Previous Versions]

*Note: This is the first documented changelog entry. Previous versions were not tracked.*

---

## How to Use This Changelog

### Format
- **Added**: New features or capabilities
- **Changed**: Updates to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Features that have been removed
- **Fixed**: Bug fixes and issue resolutions
- **Security**: Security-related updates

### Versioning
This project follows [Semantic Versioning](https://semver.org/) for version numbers:
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backward-compatible manner
- **PATCH**: Backward-compatible bug fixes

### Release Process
1. **Development**: Changes are made in development branches
2. **Testing**: Changes are tested in CI/CD pipeline
3. **Release**: Changes are merged to main branch and tagged
4. **Documentation**: Changelog is updated with release information