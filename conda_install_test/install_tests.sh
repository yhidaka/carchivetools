#!/bin/bash

# Exit immediately if a command exits
set -e

# Ensure the current directory is where this installation script is located.
INSTALL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$INSTALL_SCRIPT_DIR"

# Check if conda is properly initialized. If not, initialize it.
if ! declare -F conda >/dev/null; then
    echo "Initializing conda..."
    # Without sourcing this shell, the following `conda` | `mamba` command may fail.
    source _conda_setup.sh
    echo "Finished initializing conda."
fi

# Check if mamba is available, fallback to conda
if command -v mamba >/dev/null; then
    CONDA_CMD="mamba"
else
    CONDA_CMD="conda"
fi

PYTHON_VERSIONS=("3.10" "3.11" "3.12")
NUMPY_VERSIONS=("1" "2")

TEMP_GIT_DIR="${TMPDIR:-/tmp}/$(whoami)/git"

for PYVER in "${PYTHON_VERSIONS[@]}"; do
    for NPVER in "${NUMPY_VERSIONS[@]}"; do
        ENV_NAME="carch_${PYVER//./}_np${NPVER}"

        echo "Creating conda environment '$ENV_NAME' with Python $PYVER and NumPy $NPVER..."

        # "--yes" to answer "yes" to all prompts.
        $CONDA_CMD env create --yes -n "$ENV_NAME" python="$PYVER" numpy="$NPVER" twisted libprotobuf abseil-cpp -c conda-forge

        conda activate "$ENV_NAME"

        pip install protobuf

        rm -rf "$TEMP_GIT_DIR/carchivetools" # Remove the directory if it exists to avoid any existing "build" folder
        mkdir -p "$TEMP_GIT_DIR"
        cd "$TEMP_GIT_DIR"
        git clone -b py3 https://github.com/yhidaka/carchivetools.git
        cd carchivetools
        pip install .

        echo "Running tests for Python $PYVER and NumPy $NPVER..."

        cd "$INSTALL_SCRIPT_DIR"
        python test_carchivetools.py

        echo "Installation and tests completed successfully."

        echo "Cleaning up..."
        conda deactivate
        conda env remove -n "$ENV_NAME" -y
        echo "Conda environment '$ENV_NAME' successfully removed."

        echo "Test completed for Python $PYVER and NumPy $NPVER."
        echo "---------------------------------------------------"
    done
done

echo "All combinations tested successfully."