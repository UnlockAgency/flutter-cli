# CHANGELOG


## v1.10.6
- Translations now turns nl-NL to nl_NL for Flutter

## v1.10.5
- Removed web-renderer from web build and run

## v1.10.4
- Added language code support

## v1.10.3
- Added new translations for Budiyu support

## v1.10.1
- Now uses sub command to check if build is for iOS

## v1.10.0
- Added a check to avoid using xcode-select if platform is android

## v1.9.0
- Use Environment.xcconfig instead of Generated.xcconfig

## v1.8.3
- Added da_DK as supported languages (Danish)

## v1.8.2

### New features
- Add web-renderer flag: auto, canvaskit or html


### Breaking changes 
The `run` command has been updated. Previously:

```shell
flttr run --platform ios --flavor accept
flttr run --platform android --flavor accept
flttr run --platform web --flavor accept
```

Currently:

```shell
flttr run ios --flavor accept
flttr run android --flavor accept
flttr run web --flavor accept
```

## v1.8.1

### New features
- Add port flag when running on web

## v1.8.0

### New features
- Web platform support

## v1.7.2

### Bugfixes
- Fixed the `flttr create` command
- Updated templates for a new project

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
flttr build ios [--flavor=] [--release] [--archive] [--export-method=] [--[no-]obfuscation] [--[no-]codesign] [--dry-run]
flttr build android [--flavor=] [--release] [--artifact=] [--[no-]obfuscation] [--dry-run]
```
