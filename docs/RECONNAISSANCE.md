# 📡 Reconnaissance Scripts

[← Back to Main README](../README.md)

---

## Table of Contents

- [Recon-in-a-Box](#recon-in-a-box)
- [Robots & Git Hunter](#robots--git-hunter)

---

## Recon-in-a-Box

**Script:** `recon.bat`  
**Purpose:** Automated comprehensive reconnaissance using nmap and gobuster

### Overview

Recon-in-a-Box automates the tedious process of network reconnaissance by running multiple nmap scans and directory enumeration simultaneously. It creates an organized directory structure with all scan results, making it easy to review findings.

### Prerequisites

**Required:**
- `nmap` - Network scanning
- `gobuster` - Directory/file enumeration
- `curl` - HTTP requests

**Installation:**
```batch
# Using Chocolatey
choco install nmap

# Gobuster - Download from GitHub
# https://github.com/OJ/gobuster/releases

# Wordlists - Download SecLists
# https://github.com/danielmiessler/SecLists
```

### Usage

```batch
recon.bat [target_ip_or_domain] [optional:port]
```

### Examples

**Basic scan:**
```batch
recon.bat 10.10.10.100
```

**Scan with custom web port:**
```batch
recon.bat 10.10.10.100 8080
```

**Scan a domain:**
```batch
recon.bat example.com
```

### What It Does

1. **Creates organized directory:**
   ```
   recon_10.10.10.100_20251130_1430/
   ├── info.txt              # Scan metadata
   ├── nmap_quick.txt        # Quick scan results
   ├── nmap_full.txt         # Full port scan
   ├── nmap_vuln.txt         # Vulnerability scan
   ├── gobuster.txt          # Directory enumeration
   └── summary.txt           # Consolidated report
   ```

2. **Runs three nmap scans:**
   - **Quick scan** (-sV -sC -T4): Fast service/version detection
   - **Full scan** (-p-): All 65535 ports
   - **Vuln scan** (--script vuln): Known vulnerability detection

3. **Directory enumeration:**
   - Runs gobuster against web services
   - Uses common wordlist for speed
   - Saves all discovered directories

4. **Generates summary:**
   - Lists open ports
   - Shows discovered directories
   - Highlights vulnerabilities

### Expected Output

```
Target: 10.10.10.100
Port: 80

[1/6] Creating output directory...
✓ Directory created: recon_10.10.10.100_20251130_1430

[2/6] Running quick Nmap scan...
✓ Quick scan complete

[3/6] Running comprehensive Nmap scan...
This may take several minutes...
✓ Full scan complete

[4/6] Running Nmap vulnerability scan...
✓ Vulnerability scan complete

[5/6] Running Gobuster directory enumeration...
✓ Directory enumeration complete

[6/6] Generating summary report...

========================================
Recon Complete!
========================================
```

### Configuration

Edit the script to customize:

```batch
REM Nmap options
set NMAP_QUICK=-sV -sC -T4
set NMAP_FULL=-sV -sC -p- -T4
set NMAP_VULN=--script vuln

REM Gobuster settings
set WORDLIST=C:\Tools\wordlists\common.txt
```

### Tips & Tricks

**Speed vs Coverage:**
- Quick scan: ~2-5 minutes
- Full scan: 10-30 minutes depending on network
- Vuln scan: 5-15 minutes

**Run in parallel:**
```batch
REM Terminal 1
recon.bat 10.10.10.100

REM Terminal 2 (while recon runs)
hunt.bat http://10.10.10.100
```

**Best practices:**
- Run quick scan first to identify services
- Review quick results before full scan completes
- Check gobuster results for interesting directories
- Always verify vulnerabilities manually

### Common Issues

**Nmap not found:**
```batch
# Add nmap to PATH or specify full path
set NMAP_PATH="C:\Program Files\Nmap\nmap.exe"
```

**Gobuster not found:**
```batch
# Download and add to PATH
# Or specify full path in script
set GOBUSTER_PATH="C:\Tools\gobuster.exe"
```

**Wordlist missing:**
```batch
# Download SecLists
git clone https://github.com/danielmiessler/SecLists.git C:\Tools\SecLists

# Update script with correct path
set WORDLIST=C:\Tools\SecLists\Discovery\Web-Content\common.txt
```

---

## Robots & Git Hunter

**Script:** `hunt.bat`  
**Purpose:** Find exposed sensitive files and directories (robots.txt, .git, .env, backups)

### Overview

Robots & Git Hunter checks for "low-hanging fruit" - commonly exposed files that reveal sensitive information. It's the first thing you should run against any web application.

### Prerequisites

**Required:**
- `curl` - HTTP requests (included in Windows 10+)

**No Installation Needed!** (Windows 10+)

### Usage

```batch
hunt.bat [url]
```

### Examples

**Basic scan:**
```batch
hunt.bat https://example.com
```

**With custom port:**
```batch
hunt.bat http://192.168.1.100:8080
```

**Without protocol (adds https:// automatically):**
```batch
hunt.bat example.com
```

### What It Checks (29 Targets)

**Configuration Files:**
- `.env`, `.env.local`, `.env.production`, `.env.backup`
- `config.php`, `wp-config.php`, `web.config`
- `composer.json`, `package.json`

**Version Control:**
- `.git/HEAD`, `.git/config`, `.gitignore`
- `.svn/entries`

**Information Disclosure:**
- `robots.txt`, `sitemap.xml`
- `README.md`, `CHANGELOG.md`
- `phpinfo.php`

**Backups & Databases:**
- `backup.zip`, `backup.sql`, `database.sql`
- `db_backup.sql`

**Administrative:**
- `admin/`, `administrator/`, `backup/`
- `server-status`, `server-info`
- `.htaccess`, `.DS_Store`

### Expected Output

```
Target: https://example.com

Starting scan...

[✓] FOUND: robots.txt (200)
  > robots.txt found - checking for interesting entries...
  Disallow: /admin/
  Disallow: /backup/

[✓] FOUND: .git/HEAD (200)
  > .git directory exposed! Potential for git dumping.

[✓] FOUND: .env (200)
  > .env file exposed! Check for credentials.

[~] FORBIDDEN: admin (403)
[ ] Not found: backup.zip

========================================
Scan Complete!
========================================

Checked: 29 targets
Found: 3 accessible files

⚠ WARNING: High-risk files found!
  Check .git, .env, or config files for sensitive data.
```

### Generated Files

```
hunt_example.com_20251130_1430/
├── summary.txt              # Complete findings report
├── robots_txt.txt           # Downloaded robots.txt
├── _git_HEAD.txt           # Downloaded .git/HEAD
├── _env.txt                # Downloaded .env file
└── sitemap_xml.txt         # Downloaded sitemap
```

### Status Codes Explained

- **200 OK** - File is accessible and downloaded
- **403 Forbidden** - File exists but access denied
- **401 Unauthorized** - Authentication required
- **404 Not Found** - File doesn't exist

### What to Do With Findings

**Found `.git/HEAD`:**
```batch
# Use git-dumper to extract repository
git-dumper http://example.com/.git/ output/

# Or use GitTools
./gitdumper.sh http://example.com/.git/ dump/
```

**Found `.env` file:**
```batch
# Review for credentials
type hunt_example.com_20251130_1430\_env.txt

# Look for:
# - DATABASE_PASSWORD=
# - API_KEY=
# - SECRET_KEY=
# - AWS_ACCESS_KEY_ID=
```

**Found `robots.txt`:**
```batch
# Check disallowed directories
type hunt_example.com_20251130_1430\robots_txt.txt

# Visit disallowed paths manually
# Often contains admin panels or backups
```

**Found backup files:**
```batch
# Download and extract
curl -O http://example.com/backup.zip
unzip backup.zip

# Review source code for vulnerabilities
```

### Tips & Tricks

**Run first in CTF:**
```batch
# Hunt should be one of your first commands
hunt.bat [target]

# While it runs, start other recon
recon.bat [target_ip]
```

**Combine with directory brute-forcing:**
```batch
# Hunt finds obvious files
hunt.bat https://example.com

# Then use gobuster for deeper enumeration
gobuster dir -u https://example.com -w wordlist.txt
```

**Check multiple sites quickly:**
```batch
# Create a list
echo http://site1.com > sites.txt
echo http://site2.com >> sites.txt

# Run in loop
for /F %i in (sites.txt) do hunt.bat %i
```

### Common Findings & Impact

| Finding | Impact | Next Steps |
|---------|--------|-----------|
| `.git/` exposed | Full source code access | Extract repo, review code |
| `.env` file | Database credentials, API keys | Test credentials on services |
| `robots.txt` | Hidden directories revealed | Enumerate disallowed paths |
| `backup.zip` | Source code, database dumps | Download and analyze |
| `phpinfo.php` | System information disclosure | Note PHP version, modules |
| `config.php` | Database credentials | Test on database port |
| `.DS_Store` | Directory listing | Parse for file names |
| `admin/` (403) | Admin panel exists | Try default credentials |

### Configuration

Customize targets by editing the script:

```batch
REM Add custom targets
set "TARGETS[29]=custom-file.txt"
set "TARGETS[30]=secret-backup.sql"
```

### Common Issues

**False positives:**
- Some sites return 200 for all URLs (check content)
- Use `-I` flag in curl to check headers only

**Slow scanning:**
- Script checks sequentially
- For large target lists, consider parallel scanning

**SSL errors:**
```batch
# Add -k flag to curl for self-signed certificates
curl -k -s -o nul -w "%{http_code}" "https://example.com/file"
```

---

[← Back to Main README](../README.md) | [Next: Exploitation Scripts →](EXPLOITATION.md)