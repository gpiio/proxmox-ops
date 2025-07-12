#!/bin/bash

# Deploy Packer Pipeline to Concourse
# This script sets up the pipeline for automated Packer builds

set -e

echo "🚀 Deploying Packer Pipeline to Concourse"

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo "Installing fly CLI..."
    curl -L https://github.com/concourse/concourse/releases/latest/download/fly-linux-amd64.tgz | tar -xz
    sudo mv fly /usr/local/bin/
    echo "✅ fly CLI installed"
fi

# Check if credentials file exists
if [ ! -f "credentials-local.yml" ]; then
    echo "⚠️  Creating credentials-local.yml from template"
    cp credentials.yml credentials-local.yml
    echo "📝 Please edit credentials-local.yml with your actual Proxmox API secret"
    echo "   The file is at: $(pwd)/credentials-local.yml"
    read -p "Press Enter after updating the credentials file..."
fi

# Login to Concourse
echo "🔐 Logging into Concourse..."
CONCOURSE_URL="http://concourse-server:8080"
if ! fly -t main status &> /dev/null; then
    fly -t main login -c "$CONCOURSE_URL" -u admin -p admin
fi

# Set the pipeline
echo "📋 Setting pipeline..."
fly -t main set-pipeline \
    -p packer-builds \
    -c pipeline.yml \
    -l credentials-local.yml

# Unpause the pipeline
echo "▶️  Unpausing pipeline..."
fly -t main unpause-pipeline -p packer-builds

echo ""
echo "✅ Pipeline deployed successfully!"
echo ""
echo "🌐 Access Concourse UI: $CONCOURSE_URL"
echo "📊 View pipeline: $CONCOURSE_URL/teams/main/pipelines/packer-builds"
echo ""
echo "🔧 Manual trigger commands:"
echo "   fly -t main trigger-job -j packer-builds/build-ubuntu-template"
echo "   fly -t main trigger-job -j packer-builds/build-centos-template"
echo "   fly -t main trigger-job -j packer-builds/cleanup-old-templates"
echo ""
echo "📝 To update pipeline: re-run this script"
echo "🗑️  To delete pipeline: fly -t main destroy-pipeline -p packer-builds"