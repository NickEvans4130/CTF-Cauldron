# 🦇 CTF-Cauldron

> **A Cauldron of Bats**: Your Essential Batch Script Arsenal for CTF Challenges, Penetration Testing, and Security Research

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Shell: Batch](https://img.shields.io/badge/Shell-Batch-green.svg)](https://en.wikipedia.org/wiki/Batch_file)

---

## 📚 Table of Contents

- [Overview](#overview)
- [Quick Start Guide](#quick-start-guide)
- [Optimal CTF Workflow](#optimal-ctf-workflow)
- [Script Categories](#script-categories)
- [Installation](#installation)
- [Legal Notice](#legal-notice)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## 🎯 Overview

CTF-Cauldron is a collection of 15 powerful batch scripts designed to automate repetitive tasks in CTF challenges, penetration testing, and security research. Each script is a "bat" in your cauldron of tools, ready to swoop in and handle specific tasks with minimal typing.

**Why "Cauldron"?** A group of bats is called a cauldron or colony. These scripts work together like a coordinated swarm, each handling a specific task in your security workflow.

---

## 🚀 Quick Start Guide

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/CTF-Cauldron.git
cd CTF-Cauldron
```

2. **Add to PATH (Optional but Recommended):**
```batch
# Add the CTF-Cauldron directory to your system PATH
# This allows you to run scripts from anywhere
setx PATH "%PATH%;C:\path\to\CTF-Cauldron"
```

3. **Install Prerequisites:**
```batch
# Run the setup script to check dependencies
setup.bat
```

### First Run

```batch
# Test a simple script
listn.bat 4444

# Try the Magic Decoder
decode.bat SGVsbG8gV29ybGQh

# Generate a reverse shell
revshell.bat
```

---

## 🎮 Optimal CTF Workflow

### 📋 Recommended Script Order for CTF Challenges

When starting a CTF challenge, follow this optimized workflow to maximize efficiency and coverage:

#### **Phase 1: Initial Reconnaissance (First 5 minutes)**

```
1. recon.bat [target_ip]           → Full port scan + service detection
2. hunt.bat [target_url]            → Find exposed files (.git, .env, robots.txt)
3. listn.bat [port]                 → Start listener (if expecting reverse shell)
```

**Why this order?**
- **Recon** runs first because it takes the longest (10-20 minutes for full scan)
- **Hunt** runs simultaneously in another terminal to find low-hanging fruit
- **Listener** starts early so you're ready when you find an exploit

#### **Phase 2: File Analysis (5-15 minutes)**

```
4. inspect.bat [suspicious_file]    → Analyze downloaded files for hidden data
5. decode.bat [encoded_string]      → Decode any suspicious strings found
6. pattern.bat                      → If exploiting buffer overflow
```

**Why this order?**
- Analyze files immediately after downloading
- Decode any Base64/Hex strings found in files or source code
- Pattern calculator only if you identify a binary exploitation challenge

#### **Phase 3: Exploitation (15-30 minutes)**

```
7. revshell.bat                     → Generate reverse shell payload
8. cradle.bat [exploit.py]          → Transfer exploit to target
9. wip.bat "exploit working"        → Save progress frequently
```

**Why this order?**
- Generate payload after identifying vulnerability
- Use cradle to serve exploit files
- WIP commits save your work in case something breaks

#### **Phase 4: Post-Exploitation (30+ minutes)**

```
10. loggrep.bat [access.log]        → Analyze logs for credentials
11. hashcat-helper.bat [hash]       → Crack discovered password hashes
12. seed.bat                        → Populate test data if needed
```

**Why this order?**
- Analyze logs for additional information
- Crack hashes found during exploitation
- Seed data only if you need to test application functionality

---

### 🔄 Alternative Workflows

#### **Web Application CTF:**
```
1. hunt.bat [url]           # Find exposed files
2. loggrep.bat [logs]       # Analyze web logs
3. decode.bat [jwt_token]   # Decode JWT/cookies
4. seed.bat                 # Test with dummy data
5. wip.bat                  # Save progress
```

#### **Binary Exploitation CTF:**
```
1. inspect.bat [binary]     # Analyze binary file
2. pattern.bat              # Generate cyclic pattern
3. revshell.bat             # Generate shellcode
4. listn.bat 4444          # Start listener
5. wip.bat                 # Save exploit
```

#### **Network Penetration Test:**
```
1. recon.bat [ip]          # Full reconnaissance
2. hunt.bat [url]          # Web enumeration
3. hashcat-helper.bat      # Crack hashes
4. loggrep.bat [logs]      # Analyze activity
5. wip.bat                 # Document findings
```

---

## 📦 Script Categories

### 🌐 Network & Reconnaissance
- **[recon.bat](docs/RECONNAISSANCE.md#recon-in-a-box)** - Automated nmap + gobuster scanning
- **[hunt.bat](docs/RECONNAISSANCE.md#robots--git-hunter)** - Find exposed files and directories
- **[am-i-up.bat](docs/DEVELOPMENT.md#am-i-up-pinger)** - Monitor server availability
- **[instant-tunnel.bat](docs/DEVELOPMENT.md#instant-tunnel)** - Quick ngrok tunnel setup

### 🔓 Exploitation & Shells
- **[revshell.bat](docs/EXPLOITATION.md#reverse-shell-generator)** - Generate reverse shell payloads
- **[cradle.bat](docs/EXPLOITATION.md#cradle-generator)** - File transfer command generator
- **[listn.bat](docs/EXPLOITATION.md#listener-alias)** - Quick netcat listener
- **[pattern.bat](docs/EXPLOITATION.md#pattern-calculator)** - Buffer overflow pattern analysis

### 🔍 Analysis & Forensics
- **[inspect.bat](docs/ANALYSIS.md#deep-inspector)** - Comprehensive file analysis
- **[decode.bat](docs/ANALYSIS.md#magic-decoder)** - Multi-format string decoder
- **[loggrep.bat](docs/ANALYSIS.md#log-grepper)** - Log file analysis and filtering
- **[hashcat-helper.bat](docs/ANALYSIS.md#hashcat-helper)** - Hash identification and cracking

### 💻 Development & Workflow
- **[nuke-pave.bat](docs/DEVELOPMENT.md#workspace-nuke--pave)** - Clean Docker environment
- **[war-room.bat](docs/DEVELOPMENT.md#war-room-launcher)** - Launch complete workspace
- **[wip.bat](docs/DEVELOPMENT.md#wip-saver)** - Quick git commit and push
- **[seed.bat](docs/DEVELOPMENT.md#seeder)** - Populate database with test data

---

## 📖 Documentation

### Detailed Guides

- **[📡 Reconnaissance Scripts](docs/RECONNAISSANCE.md)** - Network scanning and enumeration tools
- **[💥 Exploitation Scripts](docs/EXPLOITATION.md)** - Payload generation and delivery
- **[🔬 Analysis Scripts](docs/ANALYSIS.md)** - File and data analysis tools
- **[⚙️ Development Scripts](docs/DEVELOPMENT.md)** - Workflow and automation tools

### Quick Reference

| Script | One-Liner Purpose | Example |
|--------|------------------|---------|
| `recon.bat` | Full port scan + enumeration | `recon.bat 10.10.10.100` |
| `hunt.bat` | Find exposed files | `hunt.bat https://example.com` |
| `revshell.bat` | Generate reverse shells | `revshell.bat` → Select language |
| `cradle.bat` | Transfer files to target | `cradle.bat exploit.py` |
| `listn.bat` | Start netcat listener | `listn.bat 4444` |
| `pattern.bat` | Buffer overflow analysis | `pattern.bat` → Generate pattern |
| `inspect.bat` | Analyze suspicious files | `inspect.bat malware.exe` |
| `decode.bat` | Decode encoded strings | `decode.bat SGVsbG8gV29ybGQh` |
| `loggrep.bat` | Filter access logs | `loggrep.bat access.log errors` |
| `hashcat-helper.bat` | Crack password hashes | `hashcat-helper.bat [hash]` |
| `wip.bat` | Quick git save | `wip.bat "found flag"` |
| `seed.bat` | Populate test database | `seed.bat` |
| `nuke-pave.bat` | Clean Docker environment | `nuke-pave.bat` |
| `war-room.bat` | Launch full workspace | `war-room.bat` |
| `am-i-up.bat` | Monitor server status | `am-i-up.bat http://localhost:3000` |

---

## 🛠️ Installation

### Prerequisites

**Required:**
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or higher
- Command Prompt (cmd.exe)

**Recommended Tools:**

Install these tools for full functionality:

```batch
# Using Chocolatey (https://chocolatey.org/)
choco install nmap
choco install netcat
choco install python
choco install git

# Using pip (Python)
pip install pwntools
pip install hashid
pip install binwalk

# Manual Downloads
# - Gobuster: https://github.com/OJ/gobuster/releases
# - ExifTool: https://exiftool.org/
# - Ngrok: https://ngrok.com/download
# - Hashcat: https://hashcat.net/hashcat/
```

### Script-Specific Requirements

| Script | Required Tools | Optional Tools |
|--------|---------------|----------------|
| `recon.bat` | nmap, gobuster | - |
| `hunt.bat` | curl | - |
| `revshell.bat` | - | - |
| `cradle.bat` | python | - |
| `listn.bat` | netcat | - |
| `pattern.bat` | python, pwntools | - |
| `inspect.bat` | certutil | file, strings, binwalk, exiftool, zsteg |
| `decode.bat` | certutil, powershell | python |
| `loggrep.bat` | - | - |
| `hashcat-helper.bat` | hashcat | hashid |
| `wip.bat` | git | - |
| `seed.bat` | curl | - |
| `nuke-pave.bat` | docker, docker-compose | - |
| `war-room.bat` | - | burpsuite, browser |
| `am-i-up.bat` | curl | - |

---

## ⚖️ Legal Notice

### ⚠️ IMPORTANT: Authorized Use Only

These scripts are designed for **LEGAL AND AUTHORIZED USE ONLY**:

✅ **Permitted Uses:**
- CTF competitions and practice platforms
- Authorized penetration testing engagements
- Security research in controlled lab environments
- Educational purposes with proper permissions
- Testing your own systems and applications
- Bug bounty programs within scope

❌ **Prohibited Uses:**
- Unauthorized access to computer systems
- Testing systems without explicit permission
- Any illegal or unethical hacking activities
- Causing harm or damage to systems
- Violating computer fraud laws

### Legal Responsibility

**YOU are responsible for:**
- Obtaining proper authorization before testing any system
- Complying with all applicable laws and regulations
- Understanding the Computer Fraud and Abuse Act (CFAA) and equivalent laws
- Respecting terms of service and acceptable use policies
- Using these tools ethically and professionally

**Unauthorized access to computer systems is illegal in most jurisdictions and may result in criminal prosecution.**

The authors and contributors of CTF-Cauldron assume no liability for misuse of these tools.

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding New Scripts

1. Fork the repository
2. Create a new branch: `git checkout -b feature/new-script`
3. Add your script following the naming convention: `script-name.bat`
4. Document your script in the appropriate docs file
5. Submit a pull request

### Script Guidelines

- Use clear, descriptive names
- Include error handling
- Provide helpful output messages
- Document prerequisites
- Add usage examples
- Follow existing code style

### Documentation

- Update README.md with new script
- Add detailed documentation to appropriate docs file
- Include example usage and output
- Document any dependencies

---

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- Inspired by common CTF and pentesting workflows
- Built for the security research community
- Tested in various CTF competitions and lab environments

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/CTF-Cauldron/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/CTF-Cauldron/discussions)
- **Updates**: Watch this repository for new scripts and features

---

## 🗺️ Roadmap

**Coming Soon:**
- [ ] Linux/macOS compatibility layer
- [ ] PowerShell versions of scripts
- [ ] Integration with common CTF platforms
- [ ] Automated report generation
- [ ] Docker container with all tools pre-installed
- [ ] GUI launcher for quick script access

---

**Made with 🦇 by the security community, for the security community.**

*Remember: With great power comes great responsibility. Always hack ethically and legally.*