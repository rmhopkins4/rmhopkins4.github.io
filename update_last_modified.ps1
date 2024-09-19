# Define directories
$baseDir = Get-Location
$logFile = Join-Path $baseDir "update_log.txt"

# Clear log file if it already exists
if (Test-Path $logFile) {
    Clear-Content -Path $logFile
}

# Get all HTML and Markdown files
$files = Get-ChildItem -Path $baseDir -Recurse -Include "*.html", "*.md"

foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Output "Processing $filePath" | Out-File -FilePath $logFile -Append

    # Get the last commit date for the file
    $lastModified = git log -1 --format="%ci" $filePath
    Write-Output "Last modified date: $lastModified" | Out-File -FilePath $logFile -Append

    # Read the file content using UTF-8 encoding
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

    # Check if front matter exists
    if ($content -match '^---\s*([\s\S]*?)\s*---\s*([\s\S]*)$') {
        $frontMatter = $matches[1]
        $body = $matches[2]

        # Check if 'last_modified:' is already in the front matter
        if ($frontMatter -match '^last_modified:') {
            # Update existing 'last_modified' field
            $updatedFrontMatter = $frontMatter -replace '^last_modified:.*', "last_modified: $lastModified"
        } else {
            # Add 'last_modified' field
            $updatedFrontMatter = "last_modified: $lastModified`n$frontMatter"
        }

        # Reconstruct the updated content
        $updatedContent = "---`n$updatedFrontMatter`n---`n$body"
    } else {
        # If no front matter is found, just append it to the top
        $updatedContent = "---`nlast_modified: $lastModified`n---`n$content"
    }

    # Write the updated content back to the file with UTF-8 encoding
    [System.IO.File]::WriteAllText($filePath, $updatedContent, [System.Text.Encoding]::UTF8)

    # Log success
    Write-Output "Updated $filePath" | Out-File -FilePath $logFile -Append
}

Write-Output "Update process completed. Check $logFile for details." | Out-File -FilePath $logFile -Append
