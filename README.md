# SSL Certificate Checker

A Bash script to **check the SSL certificate expiration status** of multiple domains. The script fetches certificate data using `openssl`, verifies validity based on the current date, and logs results to structured output files.

---

## Description

This repository contains a simple yet effective Bash utility for automating the validation of SSL certificates for websites. It can be used by system administrators, DevOps teams, or developers to:

- Detect **expired or invalid certificates**
- Log all results for future auditing
- Avoid security warnings due to outdated certificates

---

## Requirements

- `openssl` – available by default on most Unix/Linux systems.
- `gdate` (on macOS) – install via Homebrew:
  ```bash
  brew install coreutils
  ```
On Linux, date is sufficient; just replace **gdate** with **date** in the script if needed.

---

## How to Use:

  ```bash
  chmod +x check_ssl.sh
  ./check_ssl.sh 443 20 /home/user/ssl_logs
  ```
- 443 – port to check (default: 443)
- 20 – number of days before expiry to trigger a warning (default: 30)
- /home/user/ssl_logs – folder where log files will be saved (default: current directory)

Don't forget to check the newly created files for the output!


