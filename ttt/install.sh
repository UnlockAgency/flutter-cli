#!/bin/bash

# Stop when encountering errors
set -o errexit

# SCRIPT
# --------------------

echo " "
echo "[FLUTTER] Boilerplate"
echo "---------------------"
echo "Installing the Flutter Boilerplate project in a new or existing project."
echo " "

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$SCRIPT_DIR

read -r -p "Do you want to create a new project in this directory? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -r -p "What's your project name? " PROJECT_NAME
    PROJECT_NAME_LOWER_CASED=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

    echo " "
    echo "[$PROJECT_NAME] Running installation script.."
    flutter create $PROJECT_NAME_LOWER_CASED
    cd $PROJECT_NAME_LOWER_CASED
    PROJECT_DIR=$SCRIPT_DIR/$PROJECT_NAME_LOWER_CASED
else
    read -r -p "Is this file located in the root of an existing Flutter project? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        PROJECT_NAME=${PWD##*/}
        PROJECT_NAME_LOWER_CASED=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
    
        echo " "
        echo "[$PROJECT_NAME] Running installation script.."
    else
        exit 0
    fi
fi

# For iOS replace _ with - and for Android the other way around.
BUNDLE_IDENTIFIER_IOS="nl.unlock.$(echo "$PROJECT_NAME_LOWER_CASED" | sed 's/\_/\-/g')"
BUNDLE_IDENTIFIER_ANDROID="nl.unlock.$(echo "$PROJECT_NAME_LOWER_CASED" | sed 's/\-/\_/g')"

echo " "
echo "[:] Updating pubspec.yaml"

sed -i '.bak' '/^dev_dependencies:.*/i \
\ \ flutter_localizations:\
\ \ \ \ sdk: flutter\
\
' $PROJECT_DIR/pubspec.yaml

sed -i '.bak' '/^flutter:.*/a \
\ \ generate: true\
' $PROJECT_DIR/pubspec.yaml

echo " "
echo "[:] Installing packages"
echo " - go_router"
flutter pub add go_router
echo " - logger"
flutter pub add logger
echo " - intl"
flutter pub add intl
echo " - shared_preferences"
flutter pub add shared_preferences
echo " - dio"
flutter pub add dio:'^4.0.6'
echo " - get_it"
flutter pub add get_it
echo " - flutter_secure_storage"
flutter pub add flutter_secure_storage
echo " - firebase_core"
flutter pub add firebase_core
echo " - firebase_analytics"
flutter pub add firebase_analytics
echo " - firebase_crashlytics"
flutter pub add firebase_crashlytics
echo " - firebase_messaging"
flutter pub add firebase_messaging
echo " - sentry_flutter"
flutter pub add sentry_flutter
echo " - uuid"
flutter pub add uuid
echo " - package_info_plus"
flutter pub add package_info_plus
echo " - flutter_launcher_icons --dev"
flutter pub add --dev flutter_launcher_icons

echo "" 
echo " - You should manually add Illuminate:"
echo "
  illuminate:
    # path: ../packages/illuminate/
    git:
      url: git@github.com:UnlockAgency/flutter_illuminate.git
      ref: v1.2.1 # Change this to your preference
" 

read -n 1 -r -s -p $"Press any key to continue.."

# Update the packages
flutter pub get

echo "Cloning boilerplate files.."
BOILERPLATE_DIR=$PROJECT_DIR/tmp
mkdir -p $BOILERPLATE_DIR
git archive --remote=git@gitlab.e-sites.nl:team-i/flutter/boilerplate.git HEAD | tar -x -C $BOILERPLATE_DIR

echo " "
echo "[:] Applying project name to files.."

FILE_REGEX='.*\.(dart|md|xcconfig|plist)$'
find -E $BOILERPLATE_DIR -type f -regex $FILE_REGEX -exec sed -i '' s/_BUNDLE_IDENTIFIER_IOS_/$BUNDLE_IDENTIFIER_IOS/g {} +
find -E $BOILERPLATE_DIR -type f -regex $FILE_REGEX -exec sed -i '' s/_PROJECT_NAME_LOWER_CASED_/$PROJECT_NAME_LOWER_CASED/g {} +
find -E $BOILERPLATE_DIR -type f -regex $FILE_REGEX -exec sed -i '' s/_PROJECT_NAME_/$PROJECT_NAME/g {} +

echo " "
echo "[:] Copying boilerplate code.."
cp -R $BOILERPLATE_DIR/* $PROJECT_DIR

echo " "
echo "[:] Removing default tests present"
rm -r -f -v $PROJECT_DIR/test
rm -r -f -v $PROJECT_DIR/templates
mkdir $PROJECT_DIR/test

echo " "
echo "[:] Running flutter gen-l10n"
flutter gen-l10n

# We're doing a minor change ourselves, renaming the bundle identifier
FILE_REGEX='.*\.(xml|gradle|kt)$'
find -E $PROJECT_DIR/android -type f -regex $FILE_REGEX -exec sed -i '' s/com.example.$PROJECT_NAME_LOWER_CASED/$BUNDLE_IDENTIFIER_ANDROID/g {} +

echo " "
echo " "
echo "We could configure your project to use the right Firebase project(s)."
echo "If you want to skip this step, you can always do it later. The commands are described in the README."
read -r -p "Do you want to configure the Firebase project(s) now? [y/N] " response
echo " "

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Ignore errors thrown here
    set +e

    echo "[:] Setting up Firebase"
    echo " - ACCEPT"
    echo " "
    read -r -p "What's your project identifier for ACCEPT? " FIREBASE_PROJECT_IDENTIFIER

    flutterfire config \
        --project=$FIREBASE_PROJECT_IDENTIFIER \
        --out=lib/firebase_options_accept.dart \
        --ios-bundle-id=$BUNDLE_IDENTIFIER_IOS.accept \
        --android-package-name=$BUNDLE_IDENTIFIER_ANDROID.accept

    echo " "
    echo " - PRODUCTION"
    echo " "
    read -r -p "What's your project identifier for PRODUCTION? " FIREBASE_PROJECT_IDENTIFIER

    flutterfire config \
        --project=$FIREBASE_PROJECT_IDENTIFIER \
        --out=lib/firebase_options_production.dart \
        --ios-bundle-id=$BUNDLE_IDENTIFIER_IOS.production \
        --android-package-name=$BUNDLE_IDENTIFIER_ANDROID.production

    echo " "
    echo " - RELEASE"
    echo " "
    read -r -p "What's your project identifier for RELEASE? " FIREBASE_PROJECT_IDENTIFIER

    flutterfire config \
        --project=$FIREBASE_PROJECT_IDENTIFIER \
        --out=lib/firebase_options.dart \
        --ios-bundle-id=$BUNDLE_IDENTIFIER_IOS \
        --android-package-name=$BUNDLE_IDENTIFIER_ANDROID

    set -o errexit
else
    echo "Instructions on how to setup Firebase are in the README."
fi

echo " "
echo "Your Flutter project is complete!"

rm -rf $BOILERPLATE_DIR
