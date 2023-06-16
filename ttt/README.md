# ttt

## Getting Started 🚀

Make sure you've installed Flutter on your machine: https://docs.flutter.dev/get-started/install.

Clone the repository and run in the root of the project:

```
$ bundle install
$ flutter pub get
```

### Config

The project contains a config folder. The folder contains a json file for each "flavor". Put all global environment variables inside that file, like for instance: 

```
# config/accept.json

{
    "FLAVOR": "accept",
    "API_HOST": "<api_host>",
    "APP_NAME": "ttt",
    "SENTRY_DSN": "<sentry_dsn>"
}
```

#### Signing configuration

The folder also has subdirectories for `android` and `ios`. Per each flavor, this folder also contains configuration files. Inside these files, it's possible to add extra configuration which is platform specific.

The keys are available for Android during gradle build process and will be added to the `Generated.xcconfig` file for iOS.

## Run the app

Flutter has a helpfull command to run the app on a device or simulator: 
```
flutter run ios
flutter run android
```

To be able to load the configuration files inside the `config/*` folder, we have to use a custom script to run or build the app: `flutter.rb`. It's inside the root of your project. Check the available configuration of the command using:

```
./flutter.rb --help

Usage: /flutter.rb [options]
    -p, --platform PLATFORM          Select platform
                                      (android, ios)
    -f, --flavor FLAVOR              Select flavor
                                      (test, accept, production, release)
    -a, --artifact ARTIFACT          Select artifact type
                                      (apk, appbundle)
    -r, --release                    Run release mode (debug by default)
    -v, --verbose                    Verbose mode
    -b, --build                      Build mode
    -h, --help                       Show this message
```

### Debug

```
<flavor> = test, accept, production, release
<platform> = ios, android

./flutter.rb --platform <platform> --flavor <flavor> --verbose
```

### Release

```
<flavor> = test, accept, production, release
<platform> = ios, android

./flutter.rb --platform <platform> --flavor <flavor> --verbose --release
```

## Creating builds

### Local builds

Just add the `--build` and `--release` flags. For Android, you can also specify the artifact type, `apk` or `appbundle`.

```
<artifact> = apk, appbundle

./flutter.rb --platform android --artifact <artifact> --flavor <flavor> --release --build
./flutter.rb --platform ios --flavor <flavor> --release --build
```

### Release

#### iOS
```
cd ios && make build
```

Then choose the correct environment to create the build for. It'll automatically upload the version to Firebase.

#### Android

From the branch you'd like to create the build for, create a tag. The type of tag determines what build version you're making:

|TAG|Creates|
|---|---|
|v0.0.1|Release build|
|v0.0.1-beta|Accept build|
|v0.0.1-alpha|Production build|

## Translations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

### Import translations

Create a project and API key at [Prontalize](https://prontalize.nl). Add the project ID and API key to your `.env` file.

Run this script from the root of your project, to import the translations from Prontalize:

```
scripts/import_localization
```

## Firebase

Before running this command, at the apps to your Firebase project. When running this command, the package created a `lib/firebase_options_<flavor>.dart` file which is a proxy for the Android and iOS configuration files.

### Test
```
flutterfire config \
  --platforms=android,ios \
  --project=<firebase_project_id> \
  --out=lib/firebase_options_test.dart \
  --ios-bundle-id=<bundle_identifier>.test \
  --android-package-name=<package_name>.test
```

### Accept
```
flutterfire config \
  --platforms=android,ios \
  --project=<firebase_project_id> \
  --out=lib/firebase_options_accept.dart \
  --ios-bundle-id=<bundle_identifier>.accept \
  --android-package-name=<package_name>.accept
```

### Production
```
flutterfire config \
  --platforms=android,ios \
  --project=<firebase_project_id> \
  --out=lib/firebase_options_production.dart \
  --ios-bundle-id=<bundle_identifier>.production \
  --android-package-name=<package_name>.production
```

### Release
```
flutterfire config \
  --platforms=android,ios \
  --project=<firebase_project_id> \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=<bundle_identifier> \
  --android-package-name=<package_name>
```

## Creating app icons

https://pub.dev/packages/flutter_launcher_icons

> If you name your configuration file something other than flutter_launcher_icons.yaml or pubspec.yaml you will need to specify the name of the file when running the package.

We've already put the configuration file at `config/flutter_launcher_icons.yaml`.

```
flutter pub get
flutter pub run flutter_launcher_icons:main -f config/flutter_launcher_icons.yaml
```

## Testing

### iOS

**List all devices**
```
xcrun simctl list
```

**Boot the device**
```
xcrun simctl boot <device_id>
```

#### Dynamic links

```
/usr/bin/xcrun simctl openurl booted "<url>"
```

#### Push notifications

Create an apns file for each type of push notification:

```
{
    "aps":
    {
        "alert": "Registreer je inname van je Paracetamol."
    },
    "custom":
    {
        "type": "type_medication_intake_reminder",
        "payload": "{\"user_id\":\"xx\", \"medication_ids\": [\"x\", \"y\"]}"
    }
}
```

```
xcrun simctl push <device_id> <bundle_identifier> ./ios/<apns_file>
```