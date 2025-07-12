# Packer Pipeline for Concourse

This directory contains a Concourse CI/CD pipeline for automating Packer template builds.

## Pipeline Features

### 🚀 **Jobs**
- **build-ubuntu-template**: Builds Ubuntu 22.04 template (triggers on git commits + daily)
- **build-centos-template**: Builds CentOS template (manual trigger + weekly)  
- **cleanup-old-templates**: Removes old templates to free space (manual trigger)

### 🔄 **Triggers**
- **Git commits**: Auto-builds when packer/ directory changes
- **Manual**: Trigger builds via Concourse UI
- **Scheduled**: Daily Ubuntu builds, weekly CentOS builds

### ✅ **Validation & Testing**
- **Config validation**: `packer validate` before building
- **Template verification**: Checks if template was created successfully
- **API testing**: Verifies Proxmox API connectivity

## Setup Instructions

### 1. Update Git Repository
Edit `pipeline.yml` line 13 to point to your git repository:
```yaml
uri: https://github.com/your-username/proxmox-ai.git
```

### 2. Configure Credentials
```bash
# Copy and edit credentials
cp credentials.yml credentials-local.yml
# Edit credentials-local.yml with your actual Proxmox API secret
```

### 3. Deploy Pipeline
```bash
# Install fly CLI (Concourse command line tool)
curl -L https://github.com/concourse/concourse/releases/latest/download/fly-linux-amd64.tgz | tar -xz
sudo mv fly /usr/local/bin/

# Login to Concourse
fly -t main login -c http://concourse-server:8080 -u admin -p admin

# Deploy the pipeline
fly -t main set-pipeline -p packer-builds -c pipeline.yml -l credentials-local.yml

# Unpause the pipeline
fly -t main unpause-pipeline -p packer-builds
```

### 4. Trigger Builds
```bash
# Manual trigger Ubuntu build
fly -t main trigger-job -j packer-builds/build-ubuntu-template

# Manual trigger CentOS build  
fly -t main trigger-job -j packer-builds/build-centos-template

# Manual cleanup
fly -t main trigger-job -j packer-builds/cleanup-old-templates
```

## Future Enhancements

### 🔮 **Suggested Improvements**
- **Multi-OS support**: Add more OS templates (Debian, Rocky Linux, etc.)
- **Testing enhancements**: 
  - SSH connectivity tests
  - Package installation verification
  - Performance benchmarks
- **Notification system**: Slack/email alerts for build status
- **Template versioning**: Tag templates with build numbers/dates
- **Parallel builds**: Build multiple OS templates simultaneously
- **Security scanning**: Vulnerability scans on built templates
- **Template promotion**: Deploy to dev/staging/prod environments
- **Rollback capability**: Revert to previous template versions

### 📊 **Monitoring Ideas**
- Build duration tracking
- Success/failure rates
- Template size monitoring
- Storage usage alerts

### 🔧 **Advanced Features**
- **Dynamic configuration**: Build different variants (minimal, full, GPU-enabled)
- **Integration testing**: Spin up VMs from templates and run tests
- **Artifact management**: Export/import templates for disaster recovery
- **Custom variables**: Environment-specific configurations

## Troubleshooting

### Common Issues
- **Authentication errors**: Check credentials-local.yml
- **Network timeouts**: Verify Proxmox API accessibility
- **Build failures**: Check packer logs in Concourse UI
- **Template conflicts**: Ensure template IDs don't conflict

### Debug Commands
```bash
# Check pipeline status
fly -t main pipelines

# View job logs
fly -t main watch -j packer-builds/build-ubuntu-template

# Check builds history
fly -t main builds -j packer-builds/build-ubuntu-template
```