#!/bin/sh

set -e

mkdir -p BuildTools
wget -O BuildTools/swiftlint.sh https://raw.githubusercontent.com/lordcodes/swiftlint-cli/main/swiftlint.sh
chmod a+x BuildTools/swiftlint.sh
