#!/bin/bash

INPUT_DIR1="./cookbooks"
INPUT_DIR2="./guides"
OUTPUT_DIR="./documentation"
ERROR_FLAG=0

mkdir -p "$OUTPUT_DIR"

process_directory() {
  local dir=$1
  echo "Processing notebooks from $dir..."
  
  for notebook in "$dir"/*.ipynb; do
    [ -e "$notebook" ] || continue
    
    filename=$(basename "$notebook")
    echo "Processing $filename..."
    
    if jupyter nbconvert --execute --to markdown --output-dir "$OUTPUT_DIR" "$notebook"; then
      echo "Converted $filename to markdown successfully"
    else
      echo "Error executing $filename"
      ERROR_FLAG=1
    fi
  done
}

process_directory "$INPUT_DIR1"
process_directory "$INPUT_DIR2"

if [ $ERROR_FLAG -eq 1 ]; then
  echo "One or more notebooks had execution errors."
  exit 1
else
  echo "All notebooks executed successfully."
  exit 0
fi
