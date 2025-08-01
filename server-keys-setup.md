# 🚀 CI/CD SSH Key Setup & GitHub Actions Deployment Guide

## 1. **Generate SSH Key Pair on Local Machine**

Open your terminal and run:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
- When prompted for a file, you can specify a name (e.g., `~/.ssh/cicd_deploy_key`) or press Enter to use the default (`~/.ssh/id_rsa`).
- When prompted for a passphrase, press Enter for no passphrase (recommended for CI/CD).

**Result:**  
- Private key: `~/.ssh/cicd_deploy_key`
- Public key:  `~/.ssh/cicd_deploy_key.pub`

---

## 2. **Set Correct Permissions on Keys**

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/cicd_deploy_key
chmod 644 ~/.ssh/cicd_deploy_key.pub
```
> **Note:** Proper permissions are required for SSH to accept your keys.

---

## 3. **Add Public Key to Server’s `authorized_keys`**

Copy your public key to the server’s `authorized_keys` file:

```bash
ssh youruser@your.server.ip 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
cat ~/.ssh/cicd_deploy_key.pub | ssh youruser@your.server.ip 'cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```
Or, if you have direct access to the server:

```bash
cat ~/.ssh/cicd_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
> **Tip:** The public key can be safely shared and added to any server you want to access,.

---

## 4. **Copy Private Key for GitHub Actions**

Display your private key:

```bash
cat ~/.ssh/cicd_deploy_key
```
- **Copy the entire output**, including the lines:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  ...key data...
  -----END RSA PRIVATE KEY-----
  ```
- **Never share your private key publicly!** Only paste it into secure places like GitHub Secrets.

---

## 5. **Configure GitHub Actions Secrets**

In your GitHub repository, go to **Settings → Secrets and variables → Actions** and add the following secrets:

| Secret Name         | Description                                         |
|---------------------|-----------------------------------------------------|
| `SSH_PRIVATE_KEY`   | Paste the contents of your private key here         |
| `SSH_USER`          | The username for SSH login (e.g., `ubuntu`)         |
| `SSH_HOST`          | The server’s IP address or hostname                 |
| `WORK_DIR`          | Path to your main project directory on the server   |
| `MAIN_BRANCH`       | Name of your main branch (e.g., `main`)             |
| `TG_BOT_FOLDER`     | Path to your Telegram bot folder on the server      |
| `SCHEDULER_FOLDER`  | Path to your scheduler folder on the server         |

> **Tip:** You can add more secrets as needed for your project structure.

---

## 6. **Basic GitHub Actions Workflow Example**

Create `.github/workflows/deploy.yml` in your repo:

```yaml
name: Deploy to Server

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo (optional, for context)
        uses: actions/checkout@v4

      - name: Set up SSH key
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Test SSH Connection and Print Server Info
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
            echo "Hello, server!"
            uname -a
            whoami
            uptime
          EOF
```

---

## 7. **Quick Reference: Common Issues**

- **Permission denied (publickey):**
  - Public key not in `authorized_keys` on server
  - Wrong private key in GitHub secret
  - Wrong username or server IP
  - Key permissions too open or too restrictive

- **Always keep your private key secure!**
- **Never commit private keys to your repository.**

---

## 8. **Summary Table**

| Step                        | Command/Action                                      |
|-----------------------------|----------------------------------------------------|
| Generate key pair           | `ssh-keygen -t rsa -b 4096 -C "email"`             |
| Set permissions             | `chmod 700 ~/.ssh; chmod 600 ~/.ssh/cicd_deploy_key`|
| Add pub key to server       | `cat ~/.ssh/cicd_deploy_key.pub >> ~/.ssh/authorized_keys`|
| Copy private key for secret | `cat ~/.ssh/cicd_deploy_key`                       |
| Add secrets in GitHub       | See table above                                    |
| Test workflow               | Use sample `deploy.yml` above                      |

---

**Bookmark this doc for all your future CI/CD SSH deployments!**  
If you need a more advanced workflow (e.g., with Docker Compose commands), just update the SSH script section.
