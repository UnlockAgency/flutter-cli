# Flttr

Flutter provides commands to run and build the app on simulators or devices. We've created a wrapper, which also configures our project for the right flavor and build settings.

1. [Getting started](#getting-started)
1. [Usage](#usage)
1. [Create](#create)
1. [Init](#init)
1. [Import](#import)
1. [Configuration](#configuration)
1. [Run](#run)
1. [Build](#build)
1. [Upgrade](#upgrade)
1. [Development](#development)

## Getting started

Go to the [latest release](https://github.com/UnlockAgency/flutter-cli/releases/latest) on Github and download the .gem file listed there. 

Once downloaded, install it:

```
# Go to the folder you've put the file in
cd ~/Downloads

gem install flttr-{version}.gem
```

The CLI is now installed globally on your system. You can remove the downloaded file again.

## Usage

Printing the menu:

```
flttr --help

NAME
    flttr - An Unlock wrapper arround the flutter CLI

SYNOPSIS
    flttr [global options] command [command options] [arguments...]

VERSION
    1.4.2

GLOBAL OPTIONS
    --help             - Show this message
    -v, --[no-]verbose - Verbose logging
    --version          - Display the program version

COMMANDS
    build   - Build the app
    config  - Configure the Flttr CLI
    create  - Create a new Flutter project
    help    - Shows a list of commands or help for one command
    import  - Import data into the project, like translations
    init    - Init a Flutter project for flavored configuration
    run     - Run on a device or simulator
    upgrade - Upgrade Flttr
```

Shows the commands that you're able to run:

```
flttr help
flttr create [--help]
flttr init [--help]
flttr import [--help]
flttr config [--help]
flttr run [--help]
flttr build [--help]
flttr upgrade [--help]
```

## flttr create

You can create a new project using `flttr create`. It either creates an entire new Flutter project for you, or can update an existing one. 

As one of the final steps, it asks you if you want to copy files from a boilerplate repository. You can configure the repository during the step. It clones the repo and copies files to the newly created Flutter project. You can use these variables inside the boilerplate project, which will be replaced:

```
_BUNDLE_IDENTIFIER_IOS_
_PROJECT_NAME_LOWER_CASED_
_PROJECT_NAME_
```

Which can be used at locations like:

```main.dart
import 'package:_PROJECT_NAME_LOWER_CASED_/main/injection.dart';
```

## flttr init

When installing a new Flutter project, you need to add the config/ directory and it's subfiles to be able to use flavors. Flttr provides an `init` command to create this directory for you and create the necessary files.

```
flttr init
```

### `config/.config.yaml`

```yaml
# A list of flavors available for your app
flavors: 
    - test
    - accept
    - production
    - release

# A list of actions triggered when building or running the app
# The commands are executed from the root of the project 
actions:
    pre:
        - echo 'Run command for flavor: {flavor}'

# Configure files which are flavor-specific
# These are then copied during build to the location the key specifies
ios:
    files:
        "ios/Runner/GoogleService-Info.plist":
            release: "firebase/GoogleService-Info-release.plist"
            test,accept,production: "firebase/GoogleService-Info.plist"

android:
    files: {}

web: {}
```

### `config/*.json`

These files contain environment variables which are used for both platforms: API keys, flavor names, endpoints et cetera. These can be accessed in a Flutter project with:

```
String.fromEnvironment('API_HOST')
```

### `config/[android|ios|web]/*.json`

These files contain platform specific configuration variables. Like for Android: application ID and (optional) suffix. These are accessible in gradle files too.

The variables inside the iOS .json files are added as config variables to `Generated.xcconfig`. This way, they can be used to define signing configuration.

## flttr import

We've built an integration with the Prontalize API to easily import the translations from their API into the project. Before running the command, make sure you've added a `.env` file which contains the `PRONTALIZE_API_KEY` and `PRONTALIZE_PROJECT_ID`.

```
flttr import translations
```

## flttr config

### Version check
By default, flttr does a version check when executing any command. It then checks for any newer version at the Github releases overview. If an upgrade is available, you'll be notified. Upgrading is a manual step you need to do yourself: `flttr upgrade`. 

If you wish to disable the version check before running the commands, update your config: 

```
flttr config --version-check=false
```

### Xcode version
You're able to switch Xcode version via `xcode-select -s /Applications/Xcode.app`. But this is a system wide switch. The flttr cli can also be configured to always use a specific version of Xcode installed, like the beta version.

By default, flttr uses the default Xcode version installed. You can configure a different version to be used with:

```
flttr config --xcode-location=/Applications/Xcode-beta.app
```

This might occasionally ask for a sudo password, because the `xcode-select` command requires it. You can disable the password request by opening:

```
sudo visudo
``` 

And then adding this line:

```
## Do not ask for a password when running the xcode-select command
%admin ALL=(ALL) NOPASSWD: /usr/bin/xcode-select
```

Save the file py pressing `:wq` and you're done.

## flttr run|build

### Setup

The project should contain a `/config` folder, which can also be created for you by running `flttr init`. The contents of this folder and it's files is described at [`flttr init`](#flttr-init)

### Running the app
```
<platform> = ios, android, web

flttr [ --verbose] run --platform <platform> --flavor <flavor> [--release]
```

### Building the app

Global options:

```
--flavor            <value from .config.yaml>
--prepare           Run the command in "prepare" mode, to only copy config files and show the flutter command which would be executed
```

**Android:**
```
--artifact          Either apk (default) or appbundle
--[no-]obfuscation  Enable or disable code obfuscation, disabled by default
--release           Enable or disable release mode, disabled by default

flttr build android --flavor=accept --artifact=appbundle --obfuscation --release
```

**iOS:**
```
--archive           Whether to build and create an .xcarchive too
--[no-]codesign     Enable or disable code signing (in combination with --release & disabled by default)
--export-method     Either app-store (default), development, ad-hoc or enterprise
--[no-]obfuscation  Enable or disable code obfuscation, disabled by default
--release           Enable or disable release mode, disabled by default

flttr build ios --flavor=accept --export-method=ad-hoc --obfuscation --archive --release --codesign
```

**Web:**
```
flttr build web --flavor=accept
```

## flttr upgrade

You're able to upgrade the CLI using:

```
flttr upgrade
```

It'll install the latest version listed at Github.

## Development

Clone this repo and install dependencies:

```
bundle install
```

Then, do whatever you want to do.

### Building 
When you're done, upgrade the version of the package at `lib/flttr/version.rb` and commit your changes.

After, commiting, run `gem build` in the root of the repository. It'll create a file like `flttr-{version}.gem`. This file won't be committed into version control. 

### Create new version
The latest version won't be automatically available to everyone. You'll need to create a new release at Github and mark it as the "latest". **It's important** that you name the release like: "v1.1.0". 

Include the `*.gem` file you created during build in this release. It doesn't matter what the name of the file is.

### Upgrading
When running `flttr upgrade`, the latest version will be available for everyone. The command will automatically fetch the `*.gem` file you've uploaded with the release tag.
