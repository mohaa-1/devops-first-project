<!--
Short, focused Copilot/AI instructions for this repository.
Keep the file concise — agents should read this before making changes.
-->

# Repository-specific guidance for AI coding agents

- **Repo:** `devops-first-project` (owner: `mohaa-1`, branch: `main`).
- **Workspace path:** contains `aws project` (this suggests infra work, confirm before assuming cloud provider).

**What to inspect first:**
- `README.md` — the repository currently only contains a minimal README.
- `infra/` — present but currently empty; treat as the canonical location for infrastructure code.

**Big picture / scope**
- This repository is small and currently does not contain application code, build manifests, or tests. Your primary responsibilities are small, explicit changes: add infra files under `infra/`, expand the README, or create CI/workflow files when instructed.

**Project-sensitive rules (do not assume):**
- Do not introduce a framework, language, or package manager without asking the repository owner. There are no discoverable package manifests (e.g. `package.json`, `requirements.txt`, `pyproject.toml`, `*.tf`) — confirm before adding dependencies.
- When adding infra code, create a single top-level subdirectory under `infra/` (for example `infra/terraform/` or `infra/cloudformation/`) and include a short `README.md` explaining how to run it.

**Merging / updating this file**
- If a `.github/copilot-instructions.md` already exists, preserve existing content. Append an "AI additions" section with a short header and date rather than overwriting. Show a clear diff in the PR description.

**Useful commands for exploratory checks (PowerShell)**
```powershell
# Search common manifests
Get-ChildItem -Path . -Recurse -Include package.json,requirements.txt,pyproject.toml,*.tf,*.yml,*.yaml -ErrorAction SilentlyContinue

# Show top-level tree
Get-ChildItem -Path . -Force
```

**Behavioral guidelines for changes**
- Keep changes minimal and atomic. Each PR should have a short purpose and a clear rollback path.
- When creating new infra or CI, include precise run instructions and required tools/versions in the new `README.md` under the added folder.
- If you need to run or propose commands (build/test/deploy), include the exact PowerShell commands and clarify any OS assumptions (this workspace uses Windows PowerShell v5.1).

**When stuck / missing info**
- Ask the repository owner for the preferred cloud provider, tooling, or CI before implementing infra or workflows.
- If asked to scaffold a project (app or infra), propose one concise option and ask for confirmation before implementing.

**Examples (use these patterns)**
- Add infra files in `infra/terraform/` and include `infra/terraform/README.md` with: how to init, plan, and apply (exact commands).
- Add CI in `.github/workflows/` only after owner confirmation; include a top-line comment explaining purpose and required secrets.

---

## AI additions — Docker + CI/CD Setup (Nov 15, 2025)

**Current project state:**
- **Application:** Python Flask app in `.vscode/app.py` with pytest tests
- **Containerization:** Docker-based (`.vscode/Dockerfile`), exposes port 5000
- **CI workflow:** `.github/workflows/ci.yml` — runs tests and builds Docker image on push to `main`
- **CD workflow:** `.github/workflows/cd-ec2.yml` — SSH-based deployment to EC2
- **Deployment:** `.infra/deploy/remote-deploy.sh` now builds and runs Docker containers on EC2

**Key patterns in this project:**

1. **Application code location:** Flask app lives in `.vscode/` (non-standard; consider moving to `src/` or root in future refactors)
2. **CI runs on:** Every push to `main` and PRs; tests first, then builds Docker image
3. **CD runs on:** Successful pushes to `main` (controlled via `needs: test`)
4. **Deployment strategy:** SSH archive upload + Docker build/run on target EC2 instance
5. **Container networking:** Port 5000 (Flask) exposed on EC2; update security groups if needed

**Required GitHub repository secrets (Settings → Secrets and variables → Actions):**
- `EC2_SSH_PRIVATE_KEY` — private key for `DEPLOY_PATH` user
- `EC2_HOST` — EC2 IP or hostname
- `EC2_USER` — SSH username (ubuntu, ec2-user, etc.)
- `DEPLOY_PATH` — remote directory (e.g., `/home/ubuntu/app`)
- `EC2_KNOWN_HOSTS` (optional) — pre-scanned SSH host key

**Pre-deployment EC2 setup:**
```bash
# On EC2 instance:
sudo apt-get update
sudo apt-get install -y docker.io openssh-server openssh-client tar
sudo usermod -aG docker <deploy-user>  # add user to docker group
```

**Local commands to test deployment:**
```powershell
# Trigger CD workflow manually
gh workflow run cd-ec2.yml --ref main

# Check workflow status
gh workflow view cd-ec2 --ref main
```

**Customization points:**
- To add Docker registry push (e.g., ECR, Docker Hub), modify `ci.yml` build step and add credentials as secrets
- To use CodeDeploy or Lambda instead of SSH, replace `.github/workflows/cd-ec2.yml` and `infra/deploy/remote-deploy.sh`
- Flask app health check: test endpoint at `/` returns "Hello DevOps!" (200 OK) — add `/health` route if needed for load balancer checks
