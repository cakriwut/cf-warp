# Setting Up Docker Hub Publishing

This document explains how to set up the GitHub Actions workflow to automatically publish your Docker image to Docker Hub.

## Prerequisites

1. A Docker Hub account
2. A GitHub repository with this project

## Setup Steps

### 1. Create Docker Hub Access Token

1. Log in to your [Docker Hub account](https://hub.docker.com/)
2. Go to Account Settings > Security
3. Click "New Access Token"
4. Give it a name (e.g., "GitHub Actions")
5. Select "Read & Write" permissions
6. Copy the generated token (you won't be able to see it again)

### 2. Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:
   - Name: `DOCKERHUB_USERNAME`
   - Value: Your Docker Hub username
   - Name: `DOCKERHUB_TOKEN`
   - Value: The access token you generated in step 1

### 3. Push to GitHub

The workflow will automatically run when you:
- Push to the `main` branch
- Create a new tag starting with `v` (e.g., `v1.0.0`)

### 4. Workflow Details

The GitHub Actions workflow will:
1. Build the Docker image
2. Tag it with:
   - The git tag (if pushing a tag)
   - The branch name (if pushing to a branch)
   - The commit SHA
   - `latest` (if pushing to the default branch)
3. Push the image to Docker Hub under your username/repository

## Using Custom Image Name

If you want to use a different image name than your GitHub repository name, modify the `IMAGE_NAME` environment variable in the `.github/workflows/docker-publish.yml` file.

## Troubleshooting

If the workflow fails, check:
1. That your Docker Hub credentials are correct
2. That you have the necessary permissions to push to the repository
3. That the Dockerfile builds successfully locally