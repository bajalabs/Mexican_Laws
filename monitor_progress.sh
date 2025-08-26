#!/bin/bash

# Progress monitoring script for Mexican Laws download

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Mexican Laws Download Progress Monitor ===${NC}\n"

# Check if download is still running
if pgrep -f "download_mexican_laws.sh" > /dev/null; then
    echo -e "${GREEN}✓ Download script is running${NC}"
else
    echo -e "${YELLOW}⚠ Download script not detected (may have completed)${NC}"
fi

# Count folders created (excluding . and ..)
folders_created=$(find . -maxdepth 1 -type d -name "[0-9]*" | wc -l | tr -d ' ')
echo -e "${BLUE}Folders created: $folders_created / 334${NC}"

# Calculate percentage
if [ "$folders_created" -gt 0 ]; then
    percentage=$((folders_created * 100 / 334))
    echo -e "${BLUE}Progress: $percentage%${NC}"
fi

# Count total files downloaded
total_files=$(find . -name "*.pdf" -o -name "*.doc" | wc -l | tr -d ' ')
expected_files=$((folders_created * 3))
echo -e "${BLUE}Files downloaded: $total_files (expected: $expected_files)${NC}"

# Show recent log entries
echo -e "\n${YELLOW}=== Recent Log Entries ===${NC}"
if [ -f "download_log.txt" ]; then
    tail -10 download_log.txt
else
    echo "No log file found yet"
fi

# Show disk usage
echo -e "\n${YELLOW}=== Disk Usage ===${NC}"
du -sh . 2>/dev/null || echo "Calculating..."

# Show latest folders
echo -e "\n${YELLOW}=== Latest Folders Created ===${NC}"
ls -1 | grep "^[0-9]" | tail -5
