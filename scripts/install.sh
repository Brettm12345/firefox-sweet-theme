#!/bin/sh

THEMEDIRECTORY=$(cd "$(dirname "$0")" && cd .. && pwd)
FIREFOXFOLDER=$HOME/.mozilla/firefox
PROFILENAME=""
GNOMISHEXTRAS=false

# Get options.
while getopts 'f:p:g' flag; do
    case "${flag}" in
    f) FIREFOXFOLDER="${OPTARG}" ;;
    p) PROFILENAME="${OPTARG}" ;;
    g) GNOMISHEXTRAS=true ;;
    *) exit 1 ;;
    esac
done

# Define profile folder path.
PROFILEFOLDER=$(test -z "$PROFILENAME" && echo "$FIREFOXFOLDER/$PROFILENAME" || fd ".*\.default" -t d "$FIREFOXFOLDER")

echo "Building theme in $THEMEDIRECTORY"
cd "$THEMEDIRECTORY" || exit
yarn build

# Enter Firefox profile folder.
cd "$PROFILEFOLDER" || exit
echo "Installing theme in $PWD"

# Create a chrome directory if it doesn't exist.
mkdir -p chrome
cd chrome || exit

# Copy theme repo inside
echo "Coping repo in $PWD"
cp -R "$THEMEDIRECTORY" "$PWD"

# Create single-line user CSS files if non-existent or empty.
test -s userChrome.css || echo >>userChrome.css

# Import this theme at the beginning of the CSS files.
sed -i '1s/^/@import "firefox-sweet-theme\/userChrome.css";\n/' userChrome.css

# If GNOMISH extras enabled, import it in customChrome.css.
test "$GNOMISHEXTRAS" = true && {
    echo "Enabling GNOMISH extra features"
    test -s customChrome.css || echo >>firefox-sweet-theme/customChrome.css
    sed -i '1s/^/@import "theme\/hide-single-tab";\n/' firefox-sweet-theme/customChrome.css
    sed -i '2s/^/@import "theme\/matching-autocomplete-width";\n/' firefox-sweet-theme/customChrome.css
}

# Symlink user.js to firefox-sweet-theme one.
echo "Set configuration user.js file"
ln -sf chrome/firefox-sweet-theme/configuration/user.js ../user.js

echo "Done."
