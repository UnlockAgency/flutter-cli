# CHANGELOG

## v1.7.1

### Improvements
- Added `--export-options-plist` argument to `flutter build ipa` command, to specify manual signing configuration

## v1.7.0

### Breaking changes

Updated build commands, see README.md for new format and argument descriptions. 

**Previously:**
```
flttr build --platform ios [--flavor=] [--release] [--[no-]obfuscation]
flttr build --platform android [--flavor=] [--artifact=] [--release] [--[no-]obfuscation]
```

**New:**
```
flttr build ios [--flavor=] [--release] [--archive] [--export-method=] [--[no-]obfuscation] [--[no-]codesign] [--prepare]
flttr build android [--flavor=] [--release] [--artifact=] [--[no-]obfuscation] [--prepare]
```
