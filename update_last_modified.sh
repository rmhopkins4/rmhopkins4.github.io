#!/bin/bash
# Loop through all HTML and Markdown files
for file in $(find . -name "*.html" -o -name "*.md")
do
  last_modified=$(git log -1 --format="%ci" $file)
  # Check if the file has front matter with last_modified
  if grep -q 'last_modified:' $file; then
    # Update existing last_modified field
    sed -i '' "s/last_modified:.*/last_modified: $last_modified/" $file
  else
    # Add last_modified field at the top if not present
    sed -i '' "1i\\
    last_modified: $last_modified
    " $file
  fi
done
