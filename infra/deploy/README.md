# Deploy to EC2 — setup and secrets

This folder contains helper scripts and instructions for deploying the repository to an EC2 instance using the GitHub Actions workflow at `.github/workflows/cd-ec2.yml`.

Required GitHub repository secrets (add in `Settings → Secrets`):

- `EC2_SSH_PRIVATE_KEY` — the private SSH key for the deploy user (the corresponding public key must be in the EC2 user's `~/.ssh/authorized_keys`).
- `EC2_HOST` — IP address or hostname of the target EC2 instance.
- `EC2_USER` — SSH username to connect as (for example, `ec2-user` or `ubuntu`).
- `DEPLOY_PATH` — remote directory where the repo will be extracted (e.g., `/home/ubuntu/app`).

Optional:

- `EC2_KNOWN_HOSTS` — pre-populated `ssh-keyscan` output for the host; if not provided the workflow will run `ssh-keyscan` during execution.

Preparing the EC2 instance

1. Create a user (or use the default) and add the public key to `~/.ssh/authorized_keys`.

   Example (on your local machine):

   ```powershell
   ssh-keygen -t ed25519 -C "deploy-key" -f deploy_key
   # Upload the public key content to EC2's ~/.ssh/authorized_keys for the deploy user
   # Use your cloud console or `ssh-copy-id` equivalent
   ```

2. Ensure basic packages are installed on the EC2 instance:

   ```bash
   sudo apt-get update
   sudo apt-get install -y tar unzip rsync
   # or, for Amazon Linux:
   sudo yum install -y tar unzip rsync
   ```

3. Decide how your application will be run on the EC2 host (systemd service, `pm2`, `docker-compose`, etc.).
   - The included `infra/deploy/remote-deploy.sh` is intentionally minimal — modify it to install dependencies and restart your service.

How deployment works (workflow summary)

- On push to `main` (or manual dispatch) the workflow archives the repository, uploads the archive to the EC2 host via `scp`, extracts it to `DEPLOY_PATH`, and runs `infra/deploy/remote-deploy.sh` on the host.

Security notes

- Keep `EC2_SSH_PRIVATE_KEY` secret and restrict access in GitHub.
- Consider using a dedicated deploy user on EC2 with limited privileges.
- For production setups, consider using AWS CodeDeploy, SSM Run Command, or more advanced artifact storage (S3) and signature verification.

Customization

- Replace the placeholder steps in `infra/deploy/remote-deploy.sh` with the exact build/install/service restart commands for your application.
- If you prefer using a deployment agent (CodeDeploy) or container-based deployment (ECS/EKS), ask and I can scaffold that instead.
