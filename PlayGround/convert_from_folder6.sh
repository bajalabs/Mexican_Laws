#!/bin/bash

# Mexican Laws DOC → DOCX → Markdown Conversion Script
# Starting from folder 6, keeping both DOCX and Markdown files

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
DOCX_CREATED=0
MARKDOWN_CREATED=0

echo -e "${BLUE}=== Mexican Laws Conversion (Starting from Folder 6) ===${NC}"
echo -e "${BLUE}DOC → DOCX → Markdown (Keeping both DOCX and MD files)${NC}\n"

# Count directories from 006 onwards
TOTAL=$(find . -maxdepth 1 -type d -name "[0-9]*" | grep -E "^./0(0[6-9]|[1-9][0-9]|[1-9][0-9][0-9])" | wc -l | tr -d ' ')
echo -e "${BLUE}Found $TOTAL law directories to process (starting from 006)${NC}\n"

# Process each directory starting from 006
counter=0
for dir in */; do
    # Skip if not a numbered directory
    if [[ ! "$dir" =~ ^[0-9] ]]; then
        continue
    fi
    
    # Skip directories 001-005 (already processed)
    dir_number=$(echo "$dir" | grep -o '^[0-9]*')
    if [ "$dir_number" -lt 6 ]; then
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
            # Find the created DOCX file
            docx_file=$(find . -name "*.docx" -type f | head -1)
            if [ -n "$docx_file" ]; then
                docx_size=$(du -h "$docx_file" | cut -f1)
                echo -e "  ${GREEN}✓ DOCX created: $docx_size${NC}"
                ((DOCX_CREATED++))
                
                # Step 2: DOCX to Markdown
                echo -e "  ${YELLOW}Step 2: DOCX → Markdown (keeping DOCX)${NC}"
                if pandoc "$docx_file" \
                    --from docx \
                    --to markdown \
                    --wrap=preserve \
                    --standalone \
                    --metadata title="$law_name" \
                    --output "${law_code}.md" 2>/dev/null; then
                    
                    echo -e "  ${GREEN}✓ Markdown created${NC}"
                    ((MARKDOWN_CREATED++))
                    
                    # Add metadata header
                    cat > "${law_code}.md.tmp" << EOF
---
title: "$law_name"
law_code: "$law_code"
source: "Cámara de Diputados de México"
source_url: "https://www.diputados.gob.mx/LeyesBiblio/"
conversion_method: "DOC → DOCX → Markdown"
converted_date: "$(date '+%Y-%m-%d')"
converted_time: "$(date '+%H:%M:%S')"
folder: "$dir_name"
files_available:
  - original_doc: "$(basename "$doc_file")"
  - intermediate_docx: "$(basename "$docx_file")"
  - final_markdown: "${law_code}.md"
structure_preserved: true
---

# $law_name

**Código de Ley:** $law_code  
**Fuente:** Cámara de Diputados de México  
**Convertido:** $(date '+%Y-%m-%d %H:%M:%S')  
**Archivos disponibles:** DOC, DOCX, Markdown

---

EOF
                    
                    # Append original content and replace
                    cat "${law_code}.md" >> "${law_code}.md.tmp"
                    mv "${law_code}.md.tmp" "${law_code}.md"
                    
                    # Show results for both files
                    md_size=$(du -h "${law_code}.md" | cut -f1)
                    md_lines=$(wc -l < "${law_code}.md")
                    echo -e "  ${BLUE}📊 DOCX: $docx_size${NC}"
                    echo -e "  ${BLUE}📊 Markdown: $md_size, $md_lines lines${NC}"
                    
                    ((SUCCESSFUL++))
                    echo -e "  ${GREEN}✅ Success (both DOCX and MD preserved)${NC}"
                else
                    echo -e "  ${RED}✗ Markdown conversion failed${NC}"
                    echo -e "  ${BLUE}ℹ️  DOCX file preserved: $(basename "$docx_file")${NC}"
                    ((FAILED++))
                fi
            else
                echo -e "  ${RED}✗ DOCX file not found after conversion${NC}"
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
echo -e "${BLUE}=== Conversion Complete (From Folder 6) ===${NC}"
echo -e "${GREEN}✅ Successful conversions: $SUCCESSFUL${NC}"
echo -e "${BLUE}📄 DOCX files created: $DOCX_CREATED${NC}"
echo -e "${BLUE}📝 Markdown files created: $MARKDOWN_CREATED${NC}"
echo -e "${RED}❌ Failed conversions: $FAILED${NC}"
echo -e "${BLUE}📊 Total processed: $TOTAL${NC}"

if [ $SUCCESSFUL -gt 0 ]; then
    success_rate=$(( SUCCESSFUL * 100 / TOTAL ))
    echo -e "${BLUE}🎯 Success Rate: $success_rate%${NC}"
    
    # Show collection sizes
    total_docx_size=$(find . -name "*.docx" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "N/A")
    total_md_size=$(find . -name "*.md" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "N/A")
    echo -e "${BLUE}📚 Total DOCX Collection: $total_docx_size${NC}"
    echo -e "${BLUE}📚 Total Markdown Collection: $total_md_size${NC}"
fi

echo -e "\n${GREEN}🎉 Conversion completed! Both DOCX and Markdown files preserved.${NC}"
echo -e "${YELLOW}📁 Each folder now contains: DOC + DOCX + Markdown files${NC}"
