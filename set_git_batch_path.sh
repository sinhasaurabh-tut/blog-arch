#!/bin/bash

# Variables - update these as needed
KEY_NAME="blog-arch"
PRIVATE_KEY_PATH="D:/Personal/certs/cert_tut_blog/arch-blog"
PUBLIC_KEY_PATH="${PRIVATE_KEY_PATH}.pub"
GIT_REMOTE_NAME="origin"

# Your GitHub user and repository
REPO_OWNER="sinhasaurabh-tut"
REPO_NAME="blog-arch"

echo
echo "Using SSH key files:"
echo "Private Key: $PRIVATE_KEY_PATH"
echo "Public Key : $PUBLIC_KEY_PATH"
echo

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "ERROR: Private key file '$PRIVATE_KEY_PATH' not found!"
  exit 1
fi

if [ ! -f "$PUBLIC_KEY_PATH" ]; then
  echo "WARNING: Public key file '$PUBLIC_KEY_PATH' not found!"
fi

# Start ssh-agent if not running
if ! pgrep ssh-agent > /dev/null; then
  echo "Starting ssh-agent..."
  eval "$(ssh-agent -s)"
else
  echo "ssh-agent is already running."
fi

# Add SSH private key to ssh-agent
echo "Adding SSH private key to ssh-agent..."
ssh-add "$PRIVATE_KEY_PATH"
if [ $? -ne 0 ]; then
  echo "ERROR adding SSH key. Make sure ssh-agent is running and key has proper permissions."
  exit 1
fi

echo
echo "Displaying public key:"
if [ -f "$PUBLIC_KEY_PATH" ]; then
  cat "$PUBLIC_KEY_PATH"
else
  echo "Public key not found."
fi
echo "====================================="

# Test SSH connection to GitHub
echo "Testing SSH connection to GitHub..."
ssh -T git@github.com
if [ $? -eq 1 ]; then
  echo "SSH connection to GitHub succeeded."
else
  echo "ERROR: SSH connection to GitHub failed."
  echo "Please check your SSH key and GitHub settings."
  exit 1
fi

# Check current git remote URL
CURRENT_REMOTE_URL=$(git remote get-url "$GIT_REMOTE_NAME")
echo "Current git remote ($GIT_REMOTE_NAME) URL: $CURRENT_REMOTE_URL"

# Update remote URL to use SSH alias blog-arch
NEW_REMOTE_URL="git@blog-arch:${REPO_OWNER}/${REPO_NAME}.git"
echo "Updating git remote '$GIT_REMOTE_NAME' to SSH alias URL: $NEW_REMOTE_URL"
git remote set-url "$GIT_REMOTE_NAME" "$NEW_REMOTE_URL"

if [ $? -eq 0 ]; then
  echo "Git remote URL updated successfully."
else
  echo "Failed to update git remote URL."
fi

echo
echo "You can now run 'git push' successfully with your SSH key."
