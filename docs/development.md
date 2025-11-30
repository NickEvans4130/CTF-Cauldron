# ⚙️ Development & Workflow Scripts

[← Back to Main README](../README.md)

---

## Table of Contents

- [Workspace Nuke & Pave](#workspace-nuke--pave)
- [War Room Launcher](#war-room-launcher)
- [WIP Saver](#wip-saver)
- [The Seeder](#the-seeder)
- [Am I Up? Pinger](#am-i-up-pinger)
- [Instant Tunnel](#instant-tunnel)

---

## Workspace Nuke & Pave

**Script:** `nuke-pave.bat`  
**Purpose:** Clean Docker environment and rebuild project from scratch

### Overview

Instantly clean your entire Docker environment - stops containers, removes images, prunes system, and rebuilds with `docker-compose up --build`. Perfect for clearing cache issues and starting fresh.

### Prerequisites

**Required:**
- Docker Desktop
- Docker Compose

### Usage

```batch
nuke-pave.bat
```

Run from your project directory (where docker-compose.yml is located).

### What It Does

**Step-by-step process:**

1. **Stops all containers** - `docker stop $(docker ps -aq)`
2. **Removes all containers** - `docker rm $(docker ps -aq)`
3. **Prunes Docker system** - Removes unused images, networks, volumes
4. **Prunes builder cache** - Clears Docker build cache
5. **Rebuilds project** - `docker-compose up --build -d`

### Example Output

```
========================================
Docker Workspace Nuke & Pave
========================================

[1/5] Stopping all running containers...
Containers stopped successfully.

[2/5] Removing all containers...
Containers removed successfully.

[3/5] Pruning Docker system...
Deleted Images: 15
Deleted Containers: 8
Deleted Volumes: 3
Total reclaimed space: 4.2GB

[4/5] Pruning Docker builder cache...
Builder cache pruned successfully.

[5/5] Rebuilding project with docker-compose...

========================================
Nuke & Pave completed successfully!
========================================
```

### Use Cases

**Cache issues:**
```batch
# Old image cached, changes not reflecting
nuke-pave.bat
# Forces complete rebuild
```

**Disk space:**
```batch
# Docker eating disk space
nuke-pave.bat
# Removes all unused images/containers/volumes
```

**Fresh start:**
```batch
# Testing from clean state
nuke-pave.bat
# Ensures no leftover data
```

**Before CTF:**
```batch
# Clean environment before competition
nuke-pave.bat
# Start with fresh containers
```

### Tips & Tricks

**Quick alias:**
```batch
# Add to PATH
# Then just type: nuke-pave
```

**Preserve data volumes:**
```batch
# If you want to keep database data:
# Remove --volumes flag from script
docker system prune -af  # Without --volumes
```

**Schedule regular cleanups:**
```batch
# Create scheduled task
# Run weekly to free disk space
```

---

## War Room Launcher

**Script:** `war-room.bat`  
**Purpose:** Launch complete penetration testing workspace

### Overview

Opens your full penetration testing toolkit: Burp Suite, browser pointing to localhost, and 4 split terminal panes for different tasks. Everything launches in one command.

### Prerequisites

**Required:**
- Windows Terminal (recommended) or CMD

**Optional:**
- Burp Suite
- Chrome/Edge browser

### Usage

```batch
war-room.bat
```

### What It Launches

**1. Burp Suite** - Web proxy and scanner  
**2. Browser** - Opens target URL (default: localhost:3000)  
**3. Four Terminal Panes:**
   - **Recon** - For reconnaissance commands
   - **Exploit Dev** - For crafting payloads
   - **Logs** - For monitoring application logs
   - **NetCat Listener** - For catching reverse shells

### Configuration

Edit paths at top of script:

```batch
REM Configuration
set BURP_PATH="C:\Program Files\BurpSuiteCommunity\BurpSuiteCommunity.exe"
set BROWSER_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"
set TARGET_URL=http://localhost:3000
```

### Example Output

```
========================================
War Room Launcher
========================================

[1/4] Launching Burp Suite...
Burp Suite launched.

[2/4] Opening browser with target URL...
Browser launched.

[3/4] Launching Windows Terminal with split panes...
Windows Terminal launched with split panes.

[4/4] Setting up tool environment...
Environment ready.

========================================
War Room is LIVE!
========================================

Active Components:
  - Burp Suite (Proxy/Scanner)
  - Browser (http://localhost:3000)
  - 4 Terminal Panes (Recon/Exploit/Logs/Listener)

Happy Hunting!
```

### Terminal Layout

```
┌─────────────────┬─────────────────┐
│                 │                 │
│  Recon          │  Exploit Dev    │
│                 │                 │
├─────────────────┼─────────────────┤
│                 │                 │
│  Logs           │  NetCat         │
│                 │  Listener       │
└─────────────────┴─────────────────┘
```

### CTF Workflow

**Terminal assignments:**

**Pane 1 (Recon):**
```batch
recon.bat 10.10.10.100
hunt.bat http://10.10.10.100
```

**Pane 2 (Exploit Dev):**
```batch
revshell.bat
cradle.bat exploit.py
```

**Pane 3 (Logs):**
```batch
loggrep.bat access.log all
tail -f application.log
```

**Pane 4 (Listener):**
```batch
listn.bat 4444
# Wait for reverse shell connection
```

### Tips & Tricks

**Customize layout:**
```batch
# Edit script to add more panes
# Or launch different tools
start "" "C:\Tools\Wireshark\Wireshark.exe"
```

**Auto-start services:**
```batch
# Add to script
docker-compose up -d
python -m http.server 8000
```

**Save terminal layout:**
```batch
# Windows Terminal supports saved layouts
# Configure once, launch every time
```

---

## WIP Saver

**Script:** `wip.bat`  
**Purpose:** Quick git commit and push for "panic saving"

### Overview

Instantly commits all changes with a timestamp and pushes to remote. Perfect for quickly saving work during CTFs when you need to move fast.

### Prerequisites

**Required:**
- Git

### Usage

```batch
wip.bat [optional: custom message]
```

### Examples

**Basic save:**
```batch
wip.bat
# Creates: "WIP: 2025-11-30 14:30"
```

**With custom message:**
```batch
wip.bat "found admin panel"
# Creates: "WIP: found admin panel - 2025-11-30 14:30"
```

**During CTF:**
```batch
wip.bat "flag 1 complete"
wip.bat "trying sql injection"
wip.bat "got shell on target"
```

### What It Does

**Step-by-step:**

1. **Checks git repo** - Verifies you're in a git repository
2. **Gets current branch** - Detects which branch you're on
3. **Generates timestamp** - Creates unique commit message
4. **Stages all changes** - `git add -A`
5. **Commits** - `git commit -m "WIP: ..."`
6. **Pushes** - `git push origin [branch]`

### Example Output

```
========================================
WIP Saver - Git Panic Save
========================================

Current Branch: main
Commit Message: WIP: found admin panel - 2025-11-30 14:30

[1/4] Checking for changes...
 M exploit.py
 M notes.txt
?? flag.txt

[2/4] Adding all changes...
✓ All changes staged

[3/4] Creating commit...
✓ Commit created

[4/4] Pushing to remote...
✓ Changes pushed to remote

========================================
✓ WIP SAVED SUCCESSFULLY!
========================================

Branch: main
Commit: WIP: found admin panel - 2025-11-30 14:30
Status: Pushed to remote

Your work is safe! 🎉
```

### CTF Workflow

**Save frequently:**
```batch
# Found vulnerability
wip.bat "found sqli in login"

# Developed exploit
wip.bat "working exploit code"

# Got flag
wip.bat "flag{...} captured"

# End of session
wip.bat "end of day save"
```

### Tips & Tricks

**Alias for speed:**
```batch
# Create ultra-short alias
# Copy wip.bat to w.bat
# Then just: w
```

**Commit often:**
```batch
# Every 15-30 minutes during CTF
# Before trying risky changes
# After completing objectives
```

**Review history:**
```bash
# See your WIP commits
git log --oneline | grep WIP

# Squash WIPs later
git rebase -i HEAD~10
```

**Branch protection:**
```batch
# Works on any branch
git checkout feature-branch
wip.bat "testing new approach"
# Pushes to feature-branch
```

### Common Issues

**Push fails (no remote):**
```bash
# Set upstream first
git push --set-upstream origin main
```

**No changes to commit:**
```batch
# Script will warn you
# Nothing to save
```

---

## The Seeder

**Script:** `seed.bat`  
**Purpose:** Populate database with dummy data for testing

### Overview

Hits your API endpoints to create dummy users, posts, and comments. Perfect for quickly setting up test data for demos or development.

### Prerequisites

**Required:**
- `curl` (included in Windows 10+)
- Running API server

### Usage

```batch
seed.bat
```

### Configuration

Edit at top of script:

```batch
REM Configuration
set API_BASE_URL=http://localhost:3000/api
set NUM_USERS=10
set NUM_POSTS=25
set NUM_COMMENTS=50
set AUTH_TOKEN=
```

### What It Creates

**Users:**
```json
{
  "username": "user1",
  "email": "user1@example.com",
  "firstName": "User",
  "lastName": "Number1",
  "password": "Demo123!"
}
```

**Posts:**
```json
{
  "title": "Demo Post 1: Sample Title",
  "content": "This is demo content for post 1...",
  "userId": 1
}
```

**Comments:**
```json
{
  "text": "This is a sample comment 1...",
  "postId": 5,
  "userId": 3
}
```

### Example Output

```
========================================
The Seeder - Database Population
========================================

API Base URL: http://localhost:3000/api
Target: 10 users, 25 posts, 50 comments

[1/4] Creating users...
  ✓ Created user: user1
  ✓ Created user: user2
  ...
  Users created: 10/10

[2/4] Creating posts...
  ✓ Created post 1
  ✓ Created post 2
  ...
  Posts created: 25/25

[3/4] Creating comments...
  ✓ Created comment 1
  ✓ Created comment 2
  ...
  Comments created: 50/50

========================================
Seeding Complete!
========================================

Summary:
  Users: 10/10
  Posts: 25/25
  Comments: 50/50

Your database is ready for demos! 🎉
```

### Use Cases

**Fresh database:**
```batch
# After database reset
nuke-pave.bat
seed.bat
```

**Demo preparation:**
```batch
# Before client demo
seed.bat
# Shows populated application
```

**Testing:**
```batch
# Test with realistic data
seed.bat
# Run integration tests
```

### Customization

**Adjust JSON payload:**
```batch
REM Edit payload to match your API
set JSON={"username":"!USERNAME!","email":"!EMAIL!"}
```

**Add more entity types:**
```batch
REM Add products, orders, etc.
REM Copy user creation section
REM Modify for new entity
```

**Authentication:**
```batch
REM If API requires auth
set AUTH_TOKEN=your_bearer_token_here
```

---

## Am I Up? Pinger

**Script:** `am-i-up.bat`  
**Purpose:** Monitor endpoint until it returns 200 OK

### Overview

Continuously polls an endpoint and alerts you (with sound!) when it comes back online. Perfect for monitoring server restarts or deployments.

### Prerequisites

**Required:**
- `curl` (included in Windows 10+)
- PowerShell (for sound)

### Usage

```batch
am-i-up.bat [url]
```

### Examples

**Monitor localhost:**
```batch
am-i-up.bat http://localhost:3000
```

**Monitor deployment:**
```batch
am-i-up.bat https://staging.example.com
```

### Configuration

```batch
REM Edit settings
set ENDPOINT=http://localhost:3000
set CHECK_INTERVAL=5
set PLAY_SOUND=true
set MAX_ATTEMPTS=0  # 0 = unlimited
```

### Example Output

```
========================================
Am I Up? Pinger
========================================

Target Endpoint: http://localhost:3000
Check Interval: 5 seconds

[Attempt 1] Checking http://localhost:3000...
  Status: Connection failed - Server not reachable
  Retrying in 5 seconds...

[Attempt 2] Checking http://localhost:3000...
  Status: 503 - Server responding but not ready
  Retrying in 5 seconds...

[Attempt 3] Checking http://localhost:3000...
  Status: 200 OK

========================================
✓ SERVER IS UP AND RUNNING!
========================================

Endpoint: http://localhost:3000
Response: 200 OK
Total attempts: 3

Playing alert sound...
```

### Use Cases

**After deployment:**
```batch
# Deploy to server
kubectl apply -f deployment.yml

# Start monitoring
am-i-up.bat https://myapp.com/health

# Get notified when live
```

**Docker rebuild:**
```batch
# Terminal 1: Rebuild
nuke-pave.bat

# Terminal 2: Monitor
am-i-up.bat http://localhost:3000

# Audio alert when ready
```

**CTF machine restart:**
```batch
# Target rebooting
am-i-up.bat http://10.10.10.100

# Alerts when back online
```

---

## Instant Tunnel

**Script:** `instant-tunnel.bat`  
**Purpose:** Start ngrok tunnel and share URL automatically

### Overview

Launches ngrok tunnel, queries the API for the public URL, copies it to clipboard, and optionally posts to Slack/Discord. Perfect for quickly sharing local development.

### Prerequisites

**Required:**
- Ngrok (install from https://ngrok.com)

**Optional:**
- Slack/Discord webhook for notifications

### Usage

```batch
instant-tunnel.bat
```

### Configuration

```batch
REM Configuration
set LOCAL_PORT=3000
set NGROK_PATH=ngrok
set WEBHOOK_URL=
set WEBHOOK_TYPE=slack  # or discord
```

### What It Does

1. **Starts ngrok tunnel** - `ngrok http 3000`
2. **Queries ngrok API** - Gets public URL from localhost:4040
3. **Copies to clipboard** - URL ready to paste
4. **Posts to webhook** - Notifies team (optional)

### Example Output

```
========================================
Instant Tunnel Launcher
========================================

[1/4] Starting Ngrok tunnel on port 3000...
Waiting for tunnel to initialize...

[2/4] Querying Ngrok API for public URL...
Tunnel URL retrieved: https://abc123.ngrok.io

[3/4] Copying URL to clipboard...
URL copied to clipboard!

[4/4] Posting to webhook...
Notification sent to Slack.

========================================
Tunnel is LIVE!
========================================

Public URL: https://abc123.ngrok.io
Local Port: 3000

The URL has been copied to your clipboard.
Press any key to stop the tunnel...
```

### Webhook Setup

**Slack:**
```batch
# Create Incoming Webhook in Slack settings
# https://api.slack.com/messaging/webhooks
set WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
set WEBHOOK_TYPE=slack
```

**Discord:**
```batch
# Server Settings → Integrations → Webhooks
set WEBHOOK_URL=https://discord.com/api/webhooks/YOUR/WEBHOOK
set WEBHOOK_TYPE=discord
```

### Use Cases

**Share local dev:**
```batch
# Running local server
instant-tunnel.bat

# Share URL with team
# https://abc123.ngrok.io
```

**Demo to client:**
```batch
# Show work in progress
instant-tunnel.bat

# Client can access immediately
```

**Webhook testing:**
```batch
# Test webhook receivers
instant-tunnel.bat

# Provides public URL for callbacks
```

**Mobile testing:**
```batch
# Test on phone
instant-tunnel.bat

# Access local app on mobile device
```

### Tips & Tricks

**Custom subdomain:**
```batch
# Ngrok paid plans
ngrok http 3000 --subdomain=myapp
# URL: https://myapp.ngrok.io
```

**Basic auth:**
```batch
# Protect tunnel
ngrok http 3000 --auth="user:password"
```

**Multiple tunnels:**
```batch
# Terminal 1
instant-tunnel.bat  # Port 3000

# Terminal 2
# Edit script to use port 8080
instant-tunnel.bat
```

---

[← Back to Main README](../README.md) | [← Previous: Analysis Scripts](ANALYSIS.md)

---

## 🎯 Quick Reference Summary

### Script Startup Times

| Script | Duration | When to Run |
|--------|----------|-------------|
| `war-room.bat` | 10 sec | Before starting CTF |
| `recon.bat` | 10-30 min | First thing (let it run) |
| `hunt.bat` | 1-2 min | Immediately after recon starts |
| `listn.bat` | Instant | Before attempting exploitation |
| `revshell.bat` | Instant | When you find RCE |
| `wip.bat` | 5-10 sec | Every 15-30 minutes |
| `nuke-pave.bat` | 2-5 min | When Docker acts weird |
| `seed.bat` | 1-2 min | After database reset |
| `am-i-up.bat` | Variable | During server restarts |
| `instant-tunnel.bat` | 5 sec | When sharing local work |

### Memory Aids

**RHLES** - Recon, Hunt, Listen, Exploit, Save
- **R**econ.bat - Scan the target
- **H**unt.bat - Find exposed files  
- **L**istn.bat - Start listener
- **E**xploit - Use revshell.bat + cradle.bat
- **S**ave - wip.bat frequently

---

**End of Documentation**