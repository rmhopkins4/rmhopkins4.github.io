#!/bin/sh

# Define directories
baseDir=$(pwd)
logFile="$baseDir/.git/hooks/pre-commit.log"

# Clear log file if it already exists
> "$logFile"

# Log the start of the script
echo "Starting pre-commit hook script..." >> "$logFile"

# Get the current date in ISO 8601 format
TZ='America/New_York' 
currentDate=$(date +"%Y-%m-%dT%H:%M:%S%z")


# Find all HTML and Markdown files
find "$baseDir" -type d -name "_includes" -prune -o -type f \( -name "*.html" -o -name "*.md" \) -print | while read -r filePath; do
    echo "Processing $filePath" >> "$logFile"

    # Read the file content
    fileContent=$(cat "$filePath")

    # Check if front matter exists
    if echo "$fileContent" | grep -q '^---'; then
        # Extract the front matter part
        frontMatter=$(echo "$fileContent" | sed -n '1,/^---$/p' | sed '1d; $d') # Extract the lines between the `---` delimiters
        bodyContent=$(echo "$fileContent" | sed '1,/^---$/d') # Extract body content

        # Check if 'last_modified' field exists in the front matter
        if echo "$frontMatter" | grep -q '^last_modified:'; then
            # Update existing 'last_modified' field
            updatedFrontMatter=$(echo "$frontMatter" | sed "s/^last_modified:.*/last_modified: $currentDate/")
        else
            # Add 'last_modified' field inside the front matter
            updatedFrontMatter=$(echo "$frontMatter" | sed -e "/^layout:/a last_modified: $currentDate")
        fi

        # Combine updated front matter and body content
        updatedContent="---\n$updatedFrontMatter\n---\n$bodyContent"
    else
        # If no front matter, add it to the top with 'last_modified'
        updatedContent="---\nlast_modified: $currentDate\n---\n$fileContent"
    fi

    # Write the updated content back to the file
    echo -e "$updatedContent" > "$filePath"

    # Stage the file for commit (if not already staged)
    git add "$filePath"

    # Log success
    echo "Updated and staged $filePath" >> "$logFile"
done

# Log completion
echo "Update process completed. Check $logFile for details." >> "$logFile"

# Exit with a status code of 0 to indicate success
exit 0
