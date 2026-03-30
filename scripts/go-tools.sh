#!/bin/bash

# This script installs a list of recommended Go development tools.
# It iterates through a predefined list of tools and uses 'go install'
# to download and install each one.

# Exit immediately if a command exits with a non-zero status.
set -e

# Array of Go tools to be installed.
# The format is the package path followed by the desired version (@latest, @master, etc.).
tools=(
    "github.com/klauspost/asmfmt/cmd/asmfmt@latest"
    "github.com/go-delve/delve/cmd/dlv@latest"
    "github.com/kisielk/errcheck@latest"
    "github.com/davidrjenni/reftools/cmd/fillstruct@master"
    "github.com/rogpeppe/godef@latest"
    "golang.org/x/tools/cmd/goimports@master"
    "github.com/mgechev/revive@latest"
    "golang.org/x/tools/gopls@latest"
    "honnef.co/go/tools/cmd/staticcheck@latest"
    "github.com/fatih/gomodifytags@latest"
    "github.com/jstemmer/gotags@master"
    "github.com/josharian/impl@main"
    "github.com/fatih/motion@latest"
    "github.com/koron/iferr@master"
)

echo "Starting installation of Go development tools..."
echo "This may take a few minutes."
echo "-------------------------------------------------"

# Loop through the array of tools and install or update each one.
for tool in "${tools[@]}"; do
    # Extract the package path without the version information.
    package_path=${tool%@*}
    # Get the binary name from the end of the package path.
    binary_name=$(basename "$package_path")

    # Check if the tool is already in the system's PATH to provide better user feedback.
    if command -v "$binary_name" &> /dev/null; then
        echo "Updating ${binary_name} (${tool})..."
    else
        echo "Installing ${binary_name} (${tool})..."
    fi

    # The GO111MODULE=on ensures that Go modules are used.
    # The 'go install' command downloads, compiles, and installs the package.
    # It will overwrite an existing binary, effectively updating the tool.
    GO111MODULE=on go install "${tool}"
done

echo "-------------------------------------------------"
echo "All Go tools have been installed or updated successfully!"
echo "Please ensure that your \$GOPATH/bin or \$HOME/go/bin directory is in your shell's PATH."
