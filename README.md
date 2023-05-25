# Flttr

Flutter provides commands to run and build the app on simulators or devices. We've created a wrapper, which also configures our project for the right flavor and build settings.

1. [Getting started](#getting-started)
1. [Roadmap](#roadmap)
1. [Usage](#usage)
1. [Configuration](#configuration)
1. [Run](#run)
1. [Build](#build)
1. [Upgrade](#upgrade)
1. [Development](#development)
1. [Troubleshooting](#troubleshooting)

## Getting started

Go to the [latest release](https://github.com/UnlockAgency/flutter-cli/releases/latest) on Github and download the .gem file listed there. 

Once downloaded, install it:

```
# Go to the folder you've put the file in
cd ~/Downloads

gem install flttr-{version}.gem
```

The CLI is now installed globally on your system. You can remove the downloaded file again.

## Roadmap

`flttr init`

Initializing the directory for usage with flavored config files.

`flttr create {project_name}`

Creating a new Flutter project using the Boilerplate

`flttr import {arg}`

Importing for instance translations.

## Usage

Printing the menu:

```
flttr --help

NAME
    flttr - An Unlock wrapper arround the flutter CLI

SYNOPSIS
    flttr [global options] command [command options] [arguments...]

VERSION
    0.1.2

GLOBAL OPTIONS
    --help             - Show this message
    -v, --[no-]verbose - Verbose logging
    --version          - Display the program version

COMMANDS
    build   - Build the app
    config  - Configure the Flttr CLI
    help    - Shows a list of commands or help for one command
    init    - Init a Flutter project for flavored configuration
    run     - Run on a device or simulator
    upgrade - Upgrade Flttr
```

Shows the commands that you're able to run:

```
flttr help
flttr init [--help]
flttr config [--help]
flttr run [--help]
flttr build [--help]
flttr upgrade [--help]
```

## Init

When installing a new Flutter project, you need to add the config/ directory and it's subfiles to be able to use flavors. Flttr provides an `init` command to create this directory for you and create the necessary files.

```
flttr init
```

## Configuration

By default, flttr does a version check when executing any command. It then checks for any newer version at the Github releases overview. If an upgrade is available, you'll be notified. Upgrading is a manual step you need to do yourself: `flttr upgrade`. 

If you wish to disable the version check before running the commands, update your config: 

```
flttr config --version-check=false
```

## Run

```
<flavor> = test, accept, production, release
<platform> = ios, android

flttr [ --verbose] run --platform <platform> --flavor <flavor>
```

### Release

```
<flavor> = test, accept, production, release
<platform> = ios, android

flttr [ --verbose] run --platform <platform> --flavor <flavor> --release
```

## Build

### Local builds

For Android, you can specify the artifact type, `apk` or `appbundle`. You're also able to build a debug or release version. 

```
<artifact> = apk, appbundle

flttr build --platform android --artifact <artifact> --flavor <flavor> --release
flttr build --platform ios --flavor <flavor> --release
```

## Upgrade

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

## Troubleshooting
 
When building for an iPhone, Flutter stores the signing certificate into memory. If you then want to run a different app on a physical device, Flutter always uses the same certificate.

To clear it before running on a device, run `flutter config --clear-ios-signing-cert`. 

