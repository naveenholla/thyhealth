#!/bin/bash

# Make sure we're in the project root directory
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found. Please run this script from the project root directory."
    exit 1
fi

# Create a temporary file
tmp_file=$(mktemp)

# Add new dependencies if they don't exist
add_dependency() {
    local package=$1
    local version=$2
    if ! grep -q "^  $package:" pubspec.yaml; then
        echo "Adding $package:$version to pubspec.yaml"
        # Find the dependencies section and add the new dependency
        awk -v pkg="$package" -v ver="$version" '
        /^dependencies:/ { 
            print
            print "  " pkg ": " ver
            next
        }
        { print }
        ' pubspec.yaml > "$tmp_file"
        mv "$tmp_file" pubspec.yaml
    else
        echo "$package already exists in pubspec.yaml"
    fi
}

# Add required dependencies
add_dependency "sqflite" "^2.3.2"
add_dependency "sqflite_common_ffi" "^2.3.2"
add_dependency "path_provider" "^2.1.2"
add_dependency "intl" "^0.19.0"
add_dependency "fl_chart" "^0.66.2"

# Run flutter pub get to install dependencies
echo "Installing dependencies..."
flutter pub get

echo "Dependencies update completed!" 