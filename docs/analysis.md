# 🔬 Analysis Scripts

[← Back to Main README](../README.md)

---

## Table of Contents

- [Deep Inspector](#deep-inspector)
- [Magic Decoder](#magic-decoder)
- [Log Grepper](#log-grepper)
- [Hashcat Helper](#hashcat-helper)

---

## Deep Inspector

**Script:** `inspect.bat`  
**Purpose:** Comprehensive file analysis using multiple forensics tools

### Overview

Deep Inspector runs a battery of analysis tools on suspicious files: file type detection, strings extraction, binwalk for embedded files, metadata extraction, steganography detection, and hash calculation.

### Prerequisites

**Required:**
- `certutil` (included in Windows)

**Optional (for full functionality):**
- `file` - File type detection
- `strings` - String extraction
- `binwalk` - Embedded file analysis
- `exiftool` - Metadata extraction
- `zsteg` - Steganography detection (images)

**Installation:**
```batch
# Binwalk
pip install binwalk

# ExifTool
# Download: https://exiftool.org/

# Zsteg (requires Ruby)
gem install zsteg

# Strings (Sysinternals Suite)
# Download: https://docs.microsoft.com/sysinternals/
```

### Usage

```batch
inspect.bat [filename]
```

### Examples

**Analyze image:**
```batch
inspect.bat suspicious.jpg
```

**Analyze binary:**
```batch
inspect.bat malware.exe
```

**Analyze firmware:**
```batch
inspect.bat router_firmware.bin
```

### What It Does (6 Stages)

**1. File Type Detection**
```batch
file suspicious.jpg
# Output: PNG image data, 1920 x 1080, 8-bit/color RGB
```

**2. Strings Extraction**
```batch
strings suspicious.jpg | grep -i "flag\|password\|key"
# Finds: flag{hidden_in_plain_sight}
```

**3. Binwalk Analysis**
```bash
binwalk suspicious.jpg
# Output:
# DECIMAL       HEXADECIMAL     DESCRIPTION
# 0             0x0             PNG image
# 54321         0xD431          Zlib compressed data
```

**4. Metadata Extraction**
```bash
exiftool suspicious.jpg
# GPS Coordinates: 40.7128, -74.0060
# Author: John Doe
# Software: Adobe Photoshop
```

**5. Steganography Detection** (images only)
```bash
zsteg suspicious.png
# b1,rgb,lsb,xy: "SECRET MESSAGE HERE"
```

**6. Hash Calculation**
```bash
certutil -hashfile suspicious.jpg SHA256
# a1b2c3d4e5f6...
# VirusTotal: https://www.virustotal.com/gui/file/a1b2c3d4...
```

### Generated Output

```
inspect_suspicious.jpg_20251130_1430/
├── summary.txt              # Complete analysis report
├── file_output.txt          # File type detection
├── strings_output.txt       # All extracted strings
├── binwalk_output.txt       # Embedded file analysis
├── exiftool_output.txt      # Metadata
├── zsteg_output.txt         # Steganography results
├── hash_md5.txt            # MD5 hash
├── hash_sha1.txt           # SHA1 hash
├── hash_sha256.txt         # SHA256 hash
└── _suspicious.jpg.extracted/  # Extracted embedded files
```

### CTF Examples

**Hidden flag in image:**
```batch
inspect.bat challenge.png

[5/6] Checking for steganography...
⚠ Possible steganography detected
b1,rgb,lsb,xy: "flag{st3g0_1s_c00l}"
```

**Firmware with embedded filesystem:**
```batch
inspect.bat firmware.bin

[3/6] Analyzing embedded files...
✓ Embedded files extracted to: _firmware.bin.extracted/
  - Squashfs filesystem
  - Linux kernel
  - Configuration files
```

**Malware analysis:**
```batch
inspect.bat suspicious.exe

[2/6] Extracting readable strings...
Found: "http://malicious-c2.com"
Found: "ransomware.dat"
Found: "bitcoin_address"

[6/6] Calculating file hashes...
SHA256: abc123def456...
VirusTotal: https://www.virustotal.com/gui/file/abc123...
```

**Document forensics:**
```batch
inspect.bat document.pdf

[4/6] Extracting metadata...
Author: Confidential Source
Creation Date: 2025:01:15 14:30:00
Producer: Microsoft Word
```

### Tips & Tricks

**Quick triage:**
```batch
# Run inspect first on any downloaded file
inspect.bat mystery_file

# Check summary for interesting findings
type inspect_mystery_file_20251130_1430\summary.txt
```

**Extract hidden data:**
```batch
# If binwalk finds embedded files
cd inspect_file_20251130_1430\_file.extracted
# Analyze extracted files
```

**Compare hashes:**
```batch
# Check if file is known malware
# Copy SHA256 from output
# Paste into VirusTotal search
```

**String analysis:**
```batch
# Review strings file for interesting data
type inspect_file_20251130_1430\strings_output.txt | findstr /i "flag password key admin"
```

### What Each Tool Reveals

| Tool | What It Finds | Example |
|------|--------------|---------|
| `file` | True file type | "PNG renamed as JPG" |
| `strings` | Readable text | URLs, passwords, debug messages |
| `binwalk` | Embedded files | Hidden archives, filesystems |
| `exiftool` | Metadata | GPS location, author, timestamps |
| `zsteg` | LSB steganography | Hidden messages in images |
| `hashes` | File fingerprint | Malware identification |

### Common Findings

**Steganography indicators:**
- Unusual file size for image resolution
- Suspicious metadata
- LSB patterns detected by zsteg

**Embedded files:**
- Archive inside image
- Encrypted data blocks
- Firmware filesystem

**Metadata leaks:**
- Author names and email
- GPS coordinates from photos
- Software versions
- Edit history

---

## Magic Decoder

**Script:** `decode.bat`  
**Purpose:** Attempt multiple decoding methods simultaneously

### Overview

Magic Decoder tries 10 different encoding schemes on a string to find readable text. Perfect for CTF challenges with unknown encoding.

### Prerequisites

**Required:**
- PowerShell (included in Windows)
- `certutil` (included in Windows)

**Optional:**
- Python 3.x (for Base32)

### Usage

```batch
decode.bat [encoded_string]
```

### Examples

**Base64:**
```batch
decode.bat SGVsbG8gV29ybGQh
# Output: Hello World!
```

**Hex:**
```batch
decode.bat "48656c6c6f20576f726c6421"
# Output: Hello World!
```

**URL encoded:**
```batch
decode.bat "Hello%20World%21"
# Output: Hello World!
```

**Interactive mode:**
```batch
decode.bat
Enter string to decode: [paste encoded string]
```

### Decoding Methods (10 Total)

1. **Base64** - Standard encoding
2. **Hexadecimal** - 0-9, A-F encoding
3. **URL Encoding** - %20, %3A, etc.
4. **ROT13** - Letter substitution
5. **Binary** - 01010101 strings
6. **ASCII Decimal** - Space-separated numbers
7. **Base32** - A-Z, 2-7 encoding
8. **Morse Code** - Dots and dashes
9. **Reverse String** - Backwards text
10. **Caesar Cipher** - All 25 shifts

### Example Output

```
Input: SGVsbG8gV29ybGQh
Length: 16 characters

[1/10] Attempting Base64 decode...
✓ Base64 decoded successfully!
Hello World!

[2/10] Attempting Hex decode...
[FAIL] Not valid Hex

[3/10] Attempting URL decode...
[INFO] No URL encoding detected

[4/10] Attempting ROT13 decode...
✓ ROT13 applied:
FtryyB JBeyq!

...

Successful decodings: 2
Results saved to: decoded_results.txt
```

### CTF Examples

**Hidden flag (Base64):**
```batch
decode.bat "ZmxhZ3t0aGlzX2lzX2FfZmxhZ30="
# ✓ Base64: flag{this_is_a_flag}
```

**Hex-encoded message:**
```batch
decode.bat "666c61677b68657861646563696d616c7d"
# ✓ Hex: flag{hexadecimal}
```

**Multi-layer encoding:**
```batch
# Layer 1: Base64
decode.bat "NDg2NTZjNmM2ZjIwNTc2ZjcyNmM2NDIx"
# Output: 48656c6c6f20576f726c6421

# Layer 2: Hex
decode.bat "48656c6c6f20576f726c6421"
# Output: Hello World!
```

**Caesar cipher:**
```batch
decode.bat "Uryyb Jbeyq"
# ✓ ROT13: Hello World
# Also check all 25 Caesar shifts in output file
```

### Tips & Tricks

**Check all results:**
```batch
# Script saves all attempts to file
type decoded_results.txt

# Review Caesar cipher shifts for readable text
findstr /C:"Shift" decoded_results.txt
```

**Nested encoding:**
```batch
# Decode multiple times
decode.bat [layer1] → [layer2] → [layer3]
```

**Binary with spaces:**
```batch
decode.bat "01001000 01100101 01101100 01101100 01101111"
# Handles space-separated binary automatically
```

**Identify by pattern:**
- Ends with `=` → Base64
- Only 0-9, A-F → Hex
- Contains `%20` → URL encoding
- Only 0-1 → Binary
- Only A-Z, 2-7 → Base32

---

## Log Grepper

**Script:** `loggrep.bat`  
**Purpose:** Filter access logs to show only errors and suspicious activity

### Overview

Log Grepper analyzes web server logs, removing normal 200 OK traffic and highlighting errors (4xx/5xx) and suspicious keywords (admin, login, SQL injection attempts).

### Prerequisites

**Required:**
- PowerShell (included in Windows)

**No Installation Needed!**

### Usage

```batch
loggrep.bat [logfile] [mode]
```

**Modes:**
- `errors` - Show only 4xx/5xx errors (default)
- `suspicious` - Show suspicious keywords
- `all` - Show errors + suspicious
- `custom` - Custom keyword search

### Examples

**Filter errors:**
```batch
loggrep.bat access.log
# or
loggrep.bat access.log errors
```

**Find suspicious activity:**
```batch
loggrep.bat access.log suspicious
```

**Complete analysis:**
```batch
loggrep.bat access.log all
```

**Custom search:**
```batch
loggrep.bat access.log custom
Enter keywords: exploit shellcode backdoor
```

### What It Finds

**HTTP Errors:**
- **4xx Client Errors**: 400, 401, 403, 404, 429
- **5xx Server Errors**: 500, 502, 503, 504

**Suspicious Keywords:**
- `admin`, `administrator`, `root`
- `login`, `password`, `authentication`
- `sql`, `inject`, `script`, `xss`, `csrf`
- `phpmyadmin`, `wp-admin`
- `config`, `env`, `backup`, `database`

### Generated Output

```
loggrep_access.log_20251130_1430/
├── summary.txt          # Complete analysis
├── errors.txt           # All 4xx/5xx errors
├── suspicious.txt       # Suspicious keyword matches
└── statistics.txt       # Status code breakdown
```

### Example Output

```
Log File: access.log
File Size: 2,451,892 bytes
Mode: all

[1/3] Filtering HTTP errors (4xx, 5xx)...
✓ Found 342 HTTP errors
  - 4xx Client Errors: 298
  - 5xx Server Errors: 44

[2/3] Filtering suspicious keywords...
  Found 15 entries with "admin"
  Found 8 entries with "login"
  Found 3 entries with "sql"
✓ Found 26 suspicious entries

========================================
SUMMARY
========================================
Total Entries: 10,234
2xx Success: 9,542 (93%)
3xx Redirects: 350 (3%)
4xx Client Errors: 298 (3%)
5xx Server Errors: 44 (<1%)
Error Rate: 3%
```

### CTF Examples

**Find attack attempts:**
```batch
loggrep.bat ctf_access.log suspicious

# Output:
192.168.1.100 - "GET /admin.php" 200
192.168.1.100 - "POST /login?user=admin&pass=admin" 401
192.168.1.100 - "GET /backup.sql" 200
```

**Identify brute force:**
```batch
loggrep.bat access.log all

# Multiple 401s from same IP = brute force
192.168.1.50 - "POST /login" 401
192.168.1.50 - "POST /login" 401
192.168.1.50 - "POST /login" 401
```

**Find SQL injection:**
```batch
loggrep.bat access.log custom
Enter keywords: UNION SELECT DROP TABLE

# Shows all SQL injection attempts
```

---

## Hashcat Helper

**Script:** `hashcat-helper.bat`  
**Purpose:** Identify hash type and generate hashcat commands

### Overview

Hashcat Helper automatically identifies hash types and generates ready-to-run hashcat commands with correct modes and parameters. No more looking up hash modes manually.

### Prerequisites

**Required:**
- `hashcat` - Password cracking tool
- Python 3.x

**Optional:**
- `hashid` - Enhanced hash identification

**Installation:**
```batch
# Hashcat
# Download: https://hashcat.net/hashcat/

# Hashid
pip install hashid

# Wordlist (rockyou.txt)
# Download: https://github.com/brannondorsey/naive-hashcat/releases
```

### Usage

```batch
hashcat-helper.bat [hash] [optional:wordlist]
```

### Examples

**MD5 hash:**
```batch
hashcat-helper.bat 5f4dcc3b5aa765d61d8327deb882cf99

# Identified: MD5 (Mode: 0)
# Command: hashcat -m 0 -a 0 temp_hash.txt rockyou.txt
```

**NTLM hash:**
```batch
hashcat-helper.bat 8846F7EAEE8FB117AD06BDD830B7586C

# Identified: NTLM (Mode: 1000)
# Command: hashcat -m 1000 -a 0 temp_hash.txt rockyou.txt
```

**bcrypt hash:**
```batch
hashcat-helper.bat "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"

# Identified: bcrypt (Mode: 3200)
# Command: hashcat -m 3200 -a 0 temp_hash.txt rockyou.txt
```

**From file:**
```batch
hashcat-helper.bat hashes.txt

# Processes first hash
# Generates commands for entire file
```

### Detected Hash Types

| Hash Type | Length | Mode | Example |
|-----------|--------|------|---------|
| MD5 | 32 | 0 | 5f4dcc3b5aa765d61d8327deb882cf99 |
| SHA1 | 40 | 100 | a94a8fe5ccb19ba61c4c0873d391e987982fbbd3 |
| NTLM | 32 | 1000 | 8846F7EAEE8FB117AD06BDD830B7586C |
| SHA-256 | 64 | 1400 | 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824 |
| SHA-512 | 128 | 1700 | cf83e1357eefb8bdf1542850d66d8007... |
| bcrypt | varies | 3200 | $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgc... |

### Generated Files

**hashcat_command.bat:**
```batch
@echo off
REM Hash Type: MD5
REM Hashcat Mode: 0

echo Starting hashcat...
hashcat -m 0 -a 0 "temp_hash.txt" "C:\Tools\wordlists\rockyou.txt"

pause
```

**hashcat_advanced.txt:**
```
[1] DICTIONARY ATTACK
hashcat -m 0 -a 0 hash.txt wordlist.txt

[2] DICTIONARY + RULES
hashcat -m 0 -a 0 hash.txt wordlist.txt -r rules/best64.rule

[3] MASK ATTACK (Brute Force)
hashcat -m 0 -a 3 hash.txt ?a?a?a?a?a?a?a?a

[4] HYBRID ATTACK
hashcat -m 0 -a 6 hash.txt wordlist.txt ?d?d?d?d

... (complete reference)
```

### CTF Examples

**Crack simple MD5:**
```batch
# Found hash in source code
hashcat-helper.bat 5f4dcc3b5aa765d61d8327deb882cf99

# Run generated command
hashcat_command.bat

# Result: password
```

**Windows NTLM hashes:**
```batch
# Dumped from SAM database
hashcat-helper.bat ntlm_hashes.txt

# Crack with rules
hashcat -m 1000 -a 0 ntlm_hashes.txt rockyou.txt -r best64.rule
```

**bcrypt (slow):**
```batch
hashcat-helper.bat "$2a$10$..."

# bcrypt is intentionally slow
# Try small wordlist first
hashcat -m 3200 -a 0 hash.txt top10000.txt
```

### Attack Modes

**Dictionary (-a 0):**
```batch
# Try each word in wordlist
hashcat -m 0 -a 0 hash.txt rockyou.txt
```

**Rules (-r):**
```batch
# Apply rules to wordlist
# password → P@ssw0rd, PASSWORD, password123
hashcat -m 0 -a 0 hash.txt rockyou.txt -r best64.rule
```

**Mask Attack (-a 3):**
```batch
# Brute force with pattern
hashcat -m 0 -a 3 hash.txt ?l?l?l?l?l?l?l?l  # 8 lowercase
hashcat -m 0 -a 3 hash.txt ?u?l?l?l?d?d?d?d  # Password1234
```

**Hybrid (-a 6, -a 7):**
```batch
# Dictionary + digits
hashcat -m 0 -a 6 hash.txt rockyou.txt ?d?d?d?d
# Tries: password0000, password0001, ..., password9999
```

### Tips & Tricks

**Start simple:**
```batch
# 1. Try common passwords first
hashcat -m 0 hash.txt top10000.txt

# 2. Add rules
hashcat -m 0 hash.txt top10000.txt -r best64.rule

# 3. Full wordlist
hashcat -m 0 hash.txt rockyou.txt -r rockyou-30000.rule
```

**GPU acceleration:**
```batch
# Hashcat automatically uses GPU
# Check devices: hashcat -I
# Force GPU: hashcat --force
```

**Session management:**
```batch
# Name session
hashcat --session mysession -m 0 hash.txt wordlist.txt

# Resume later
hashcat --restore --session mysession
```

**Check cracked:**
```batch
# Show results
hashcat -m 0 hash.txt --show
```

---

[← Back to Main README](../README.md) | [← Previous: Exploitation](EXPLOITATION.md) | [Next: Development Scripts →](DEVELOPMENT.md)