#!/bin/bash

# Simple Mexican Laws DOC → DOCX → Markdown Conversion Script

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
SUCCESSFUL=0
FAILED=0
TOTAL=0

echo -e "${BLUE}=== Mexican Laws Conversion (DOC → DOCX → Markdown) ===${NC}\n"

# Count total directories
TOTAL=$(find . -maxdepth 1 -type d -name "[0-9]*" | wc -l | tr -d ' ')
echo -e "${BLUE}Found $TOTAL law directories to process${NC}\n"

# Process each directory
counter=0
for dir in */; do
    # Skip if not a numbered directory
    if [[ ! "$dir" =~ ^[0-9] ]]; then
        continue
    fi
    
    ((counter++))
    dir_name="${dir%/}"  # Remove trailing slash
    
    echo -e "${YELLOW}[$counter/$TOTAL] Processing: $dir_name${NC}"
    
    cd "$dir_name"
    
    # Find DOC file
    doc_file=$(find . -name "*.doc" -type f | head -1)
    
    if [ -n "$doc_file" ]; then
        # Extract law code
        law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
        law_name=$(echo "$dir_name" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
        
        echo -e "  ${BLUE}📄 Converting: $law_name${NC}"
        echo -e "  ${BLUE}📁 Code: $law_code${NC}"
        
        # Step 1: DOC to DOCX
        echo -e "  ${YELLOW}Step 1: DOC → DOCX${NC}"
        if soffice --headless --convert-to docx "$doc_file" 2>/dev/null; then
            echo -e "  ${GREEN}✓ DOCX created${NC}"
            
            # Find the created DOCX file (LibreOffice keeps original name)
            docx_file=$(find . -name "*.docx" -type f | head -1)
            
            # Step 2: DOCX to Markdown
            echo -e "  ${YELLOW}Step 2: DOCX → Markdown${NC}"
            if pandoc "$docx_file" \
                --from docx \
                --to markdown \
                --wrap=preserve \
                --standalone \
                --metadata title="$law_name" \
                --output "${law_code}.md" 2>/dev/null; then
                
                echo -e "  ${GREEN}✓ Markdown created${NC}"
                
                # Add metadata header
                cat > "${law_code}.md.tmp" << EOF
---
title: "$law_name"
law_code: "$law_code"
source: "Cámara de Diputados de México"
converted: "$(date '+%Y-%m-%d %H:%M:%S')"
method: "DOC → DOCX → Markdown"
---

# $law_name

**Código:** $law_code  
**Convertido:** $(date '+%Y-%m-%d %H:%M:%S')

---

EOF
                
                # Append original content and replace
                cat "${law_code}.md" >> "${law_code}.md.tmp"
                mv "${law_code}.md.tmp" "${law_code}.md"
                
                # Clean up DOCX
                rm -f "$docx_file"
                
                # Show result
                file_size=$(du -h "${law_code}.md" | cut -f1)
                lines=$(wc -l < "${law_code}.md")
                echo -e "  ${BLUE}📊 Result: $file_size, $lines lines${NC}"
                
                ((SUCCESSFUL++))
                echo -e "  ${GREEN}✅ Success${NC}"
            else
                echo -e "  ${RED}✗ Markdown conversion failed${NC}"
                rm -f "$docx_file"
                ((FAILED++))
            fi
        else
            echo -e "  ${RED}✗ DOCX conversion failed${NC}"
            ((FAILED++))
        fi
    else
        echo -e "  ${RED}✗ No DOC file found${NC}"
        ((FAILED++))
    fi
    
    cd ..
    echo ""
done

# Final report
echo -e "${BLUE}=== Conversion Complete ===${NC}"
echo -e "${GREEN}✅ Successful: $SUCCESSFUL${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo -e "${BLUE}📊 Total: $TOTAL${NC}"

if [ $SUCCESSFUL -gt 0 ]; then
    success_rate=$(( SUCCESSFUL * 100 / TOTAL ))
    echo -e "${BLUE}🎯 Success Rate: $success_rate%${NC}"
    
    # Show total size
    total_size=$(find . -name "*.md" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "N/A")
    echo -e "${BLUE}📚 Total Collection: $total_size${NC}"
fi

echo -e "\n${GREEN}🎉 Markdown conversion completed!${NC}"
