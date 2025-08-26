#!/bin/bash

# Monitor conversion progress

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Mexican Laws Conversion Progress Monitor ===${NC}\n"

# Check if background process is running
if pgrep -f "convert_from_folder6.sh" > /dev/null; then
    echo -e "${GREEN}✓ Background conversion is running${NC}"
else
    echo -e "${YELLOW}⚠ Background conversion not detected (may have completed)${NC}"
fi

echo ""

# Count completed folders (those with both DOCX and MD files)
completed_folders=0
total_folders=334

for dir in */; do
    if [[ "$dir" =~ ^[0-9] ]]; then
        dir_name="${dir%/}"
        cd "$dir_name"
        
        # Check for both DOCX and MD files
        docx_count=$(find . -name "*.docx" -type f | wc -l | tr -d ' ')
        md_count=$(find . -name "*.md" -type f | wc -l | tr -d ' ')
        
        if [ "$docx_count" -gt 0 ] && [ "$md_count" -gt 0 ]; then
            ((completed_folders++))
        fi
        
        cd ..
    fi
done

echo -e "${BLUE}Folders with both DOCX and Markdown: $completed_folders / $total_folders${NC}"

# Calculate percentage
if [ "$completed_folders" -gt 0 ]; then
    percentage=$((completed_folders * 100 / total_folders))
    echo -e "${BLUE}Progress: $percentage%${NC}"
fi

echo ""

# Count total files
total_docx=$(find . -name "*.docx" -type f | wc -l | tr -d ' ')
total_md=$(find . -name "*.md" -type f | wc -l | tr -d ' ')
echo -e "${BLUE}Total DOCX files: $total_docx${NC}"
echo -e "${BLUE}Total Markdown files: $total_md${NC}"

echo ""

# Show disk usage
echo -e "${YELLOW}=== Disk Usage ===${NC}"
docx_size=$(find . -name "*.docx" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "N/A")
md_size=$(find . -name "*.md" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "N/A")
echo -e "${BLUE}DOCX Collection: $docx_size${NC}"
echo -e "${BLUE}Markdown Collection: $md_size${NC}"

echo ""

# Show recent log entries
echo -e "${YELLOW}=== Recent Activity ===${NC}"
if [ -f "conversion_log_from_6.txt" ]; then
    tail -8 conversion_log_from_6.txt | grep -E "(Processing:|Success|Failed)" || tail -8 conversion_log_from_6.txt
else
    echo "No log file found"
fi

echo ""

# Show latest completed folders
echo -e "${YELLOW}=== Latest Completed Folders ===${NC}"
latest_folders=()
for dir in */; do
    if [[ "$dir" =~ ^[0-9] ]]; then
        dir_name="${dir%/}"
        cd "$dir_name"
        
        # Check for both DOCX and MD files
        docx_count=$(find . -name "*.docx" -type f | wc -l | tr -d ' ')
        md_count=$(find . -name "*.md" -type f | wc -l | tr -d ' ')
        
        if [ "$docx_count" -gt 0 ] && [ "$md_count" -gt 0 ]; then
            latest_folders+=("$dir_name")
        fi
        
        cd ..
    fi
done

# Show last 5 completed folders
if [ ${#latest_folders[@]} -gt 0 ]; then
    start_index=$(( ${#latest_folders[@]} - 5 ))
    if [ $start_index -lt 0 ]; then
        start_index=0
    fi
    
    for (( i=start_index; i<${#latest_folders[@]}; i++ )); do
        echo "${latest_folders[i]}"
    done
else
    echo "No completed folders found yet"
fi
