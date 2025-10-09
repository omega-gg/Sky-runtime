#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

name="IC-Light"

repository="https://github.com/lllyasviel/IC-Light.git"

code="$PWD/code"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

read -p "Build IC-Light ? (yes/no) " REPLY

if [ "$REPLY" != "yes" ]; then exit 1; fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

rm -rf   "$code"
mkdir -p "$code"
touch    "$code"/.gitignore

cd "$code"

#--------------------------------------------------------------------------------------------------
# Clone
#--------------------------------------------------------------------------------------------------

git clone "$repository"

cd "$name"

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

python -m venv .venv

if [ -f ".venv/Scripts/activate" ]; then

   # Windows / Git Bash
  . ".venv/Scripts/activate"
else
  . ".venv/bin/activate"
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

python -m pip install --upgrade pip

python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# NOTE: huggingface_hub is required.
python -m pip install "huggingface_hub==0.25.0"

python -m pip install -r requirements.txt

# NOTE: peft is causing an issue.
python -m pip uninstall -y gradio peft

# NOTE: The old gradio causes an error on the UI.
python -m pip install gradio==3.50.2
