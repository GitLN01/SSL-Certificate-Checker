#!/bin/bash

# Enter domains that you would like to test:

URLS=(
google.com
github.com
cloudflare.com
stackoverflow.com
microsoft.com
mozilla.org
reddit.com
apple.com
openai.com
amazon.com
)

PORT="${1:-443}"
DAYS_BEFORE_EXPIRE_WARNING="${2:-30}"
OUT_DIR="${3:-$(pwd)}"

FAILED_DOMAINS="$OUT_DIR/failed_domains.txt"
VALID_CERTS="$OUT_DIR/valid_certificates.txt"
EXPIRING_CERTS="$OUT_DIR/expiring_soon.txt"

# Date command: use gdate if available (Mac), else fallback to date (Linux)
DATE_CMD=$(command -v date || command -v date)

# Timestamp for today
TODAY_TS=$($DATE_CMD +%s)

# Threshold for "expiring soon"
THRESHOLD_TS=$($DATE_CMD -d "+$DAYS_BEFORE_EXPIRE_WARNING days" +%s)

> "$FAILED_DOMAINS"
> "$VALID_CERTS"
> "$EXPIRING_CERTS"

echo -e "\n\033[1;34m Checking SSL certificates...\033[0m\n"

for domain in "${URLS[@]}"; do
  echo -e "\033[1;36m🔗 $domain\033[0m"

  cert_data=$(echo | openssl s_client -connect "$domain:$PORT" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates)

  if [[ -z "$cert_data" ]]; then
    echo -e "\033[0;31m❌ Cannot fetch certificate!\033[0m"
    echo "$domain" >> "$FAILED_DOMAINS"
    echo
    continue
  fi

  not_before=$(echo "$cert_data" | grep 'notBefore=' | cut -d= -f2)
  not_after=$(echo "$cert_data" | grep 'notAfter=' | cut -d= -f2)

  echo "    Issued On : $not_before"
  echo "    Expires On: $not_after"

  not_before_ts=$($DATE_CMD -d "$not_before" +%s 2>/dev/null)
  not_after_ts=$($DATE_CMD -d "$not_after" +%s 2>/dev/null)

  if [[ "$TODAY_TS" -ge "$not_before_ts" && "$TODAY_TS" -le "$not_after_ts" ]]; then
    if [[ "$not_after_ts" -le "$THRESHOLD_TS" ]]; then
      echo "$domain is expiring soon!" >> "$EXPIRING_CERTS"
    fi
    {
      echo "$domain"
      echo "  Issued On : $not_before"
      echo "  Expires On: $not_after"
      echo
    } >> "$VALID_CERTS"
  else
    echo "$domain -> Expired On: $not_after" >> "$FAILED_DOMAINS"
  fi

  echo
done

echo -e "\033[1;32mDone!\033[0m"
echo -e "Domains with expired or invalid certs saved to: \033[1m$FAILED_DOMAINS\033[0m"
echo -e "Valid certificates saved to: \033[1m$VALID_CERTS\033[0m"
echo -e "Certificates expiring in next $DAYS_BEFORE_EXPIRE_WARNING days: \033[1m$EXPIRING_CERTS\033[0m"
