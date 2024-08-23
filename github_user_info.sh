#!/bin/bash

# Ensure required commands are available
for cmd in curl jq zenity; do
    if ! command -v $cmd &> /dev/null; then
        zenity --error --text="Required command $cmd not found. Please install $cmd and try again." --window-icon="$ICON_PATH"
        exit 1
    fi
done

# Define the icon path (update this with the actual path to your icon)
ICON_PATH="icon.png"

# Display About dialog
zenity --info --title="About" --text="GitHub User Info (GUI)\n\nAuthor:\nMade with ☕ by Haitham Aouati\n\nGitHub:\nhttps://github.com/haithamaouati\n\nIcon:\nArtwork by artist Kaouter\n\nLicense:\nThis script is provided under the MIT License" --window-icon="$ICON_PATH"

# Get GitHub username from user
GITHUB_USER=$(zenity --entry --title="Enter GitHub Username" --text="Please enter the GitHub username:" --window-icon="$ICON_PATH")

# Check if user provided input
if [ -z "$GITHUB_USER" ]; then
    zenity --error --text="No GitHub username provided. Exiting script." --window-icon="$ICON_PATH"
    exit 1
fi

# Fetch user info from GitHub API
USER_INFO=$(curl -s "https://api.github.com/users/$GITHUB_USER")

# Check if the request was successful
if [ "$(echo "$USER_INFO" | jq -r '.message')" == "Not Found" ]; then
    zenity --error --text="GitHub user not found. Please check the username and try again." --window-icon="$ICON_PATH"
    exit 1
fi

# Parse user info
NAME=$(echo "$USER_INFO" | jq -r '.name')
EMAIL=$(echo "$USER_INFO" | jq -r '.email')
BIO=$(echo "$USER_INFO" | jq -r '.bio')
LOCATION=$(echo "$USER_INFO" | jq -r '.location')
AVATAR_URL=$(echo "$USER_INFO" | jq -r '.avatar_url')
COMPANY=$(echo "$USER_INFO" | jq -r '.company')
BLOG=$(echo "$USER_INFO" | jq -r '.blog')
TWITTER=$(echo "$USER_INFO" | jq -r '.twitter_username')
CREATED_AT=$(echo "$USER_INFO" | jq -r '.created_at')
UPDATED_AT=$(echo "$USER_INFO" | jq -r '.updated_at')
PUBLIC_REPOS=$(echo "$USER_INFO" | jq -r '.public_repos')
FOLLOWERS=$(echo "$USER_INFO" | jq -r '.followers')
FOLLOWING=$(echo "$USER_INFO" | jq -r '.following')

# Show user info in list dialog
zenity --list --title="GitHub User Info" --window-icon="$ICON_PATH" \
    --column="Item" --column="Value" \
    Name "$NAME" \
    Email "$EMAIL" \
    Bio "$BIO" \
    Location "$LOCATION" \
    Avatar "$AVATAR_URL" \
    Company "$COMPANY" \
    Blog "$BLOG" \
    Twitter "$TWITTER" \
    Created_at "$CREATED_AT" \
    Updated_at "$UPDATED_AT" \
    Public_Repositories "$PUBLIC_REPOS" \
    Followers "$FOLLOWERS" \
    Following "$FOLLOWING"

# Ask where to save JSON file
SAVE_PATH=$(zenity --file-selection --title="Save JSON File" --save --confirm-overwrite --file-filter="JSON files (/*.json) | *.json" --window-icon="$ICON_PATH")

# Check if user selected a path
if [ -z "$SAVE_PATH" ]; then
    zenity --error --text="No file path selected. Exiting script." --window-icon="$ICON_PATH"
    exit 1
fi

# Save user info to JSON file
echo "$USER_INFO" > "$SAVE_PATH"

# Notify user of success
zenity --info --text="User info saved successfully to $SAVE_PATH" --window-icon="$ICON_PATH"
