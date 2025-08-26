#!/bin/bash

# Mexican Laws DOC → DOCX → Markdown Conversion Script
# FOCUSED: Convert ONLY folder 078 for testing

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
DOCX_CREATED=0
MARKDOWN_CREATED=0

echo -e "${BLUE}=== Mexican Laws Conversion (FOLDER 078 ONLY) ===${NC}"
echo -e "${BLUE}DOC → DOCX → Markdown (Keeping both DOCX and MD files)${NC}\n"

# Target directory
target_dir="078_Ley de los Institutos Nacionales de Salud"

if [ ! -d "$target_dir" ]; then
    echo -e "${RED}❌ Target directory not found: $target_dir${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/1] Processing: $target_dir${NC}"

cd "$target_dir"

# Find DOC file
doc_file=$(find . -name "*.doc" -type f | head -1)

if [ -n "$doc_file" ]; then
    # Extract law code
    law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
    law_name=$(echo "$target_dir" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
    
    echo -e "  ${BLUE}📄 Converting: $law_name${NC}"
    echo -e "  ${BLUE}📁 Code: $law_code${NC}"
    
    # Show file info
    doc_size=$(du -h "$doc_file" | cut -f1)
    echo -e "  ${BLUE}📊 DOC file size: $doc_size${NC}"
    
    # Step 1: DOC to DOCX
    echo -e "  ${YELLOW}Step 1: DOC → DOCX${NC}"
    echo -e "  ${BLUE}ℹ️  Running: soffice --headless --convert-to docx \"$doc_file\"${NC}"
    
    if timeout 300 soffice --headless --convert-to docx "$doc_file" 2>/dev/null; then
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
folder: "$target_dir"
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
        echo -e "  ${RED}✗ DOCX conversion failed or timed out (5 minutes)${NC}"
        ((FAILED++))
    fi
else
    echo -e "  ${RED}✗ No DOC file found${NC}"
    ((FAILED++))
fi

cd ..

# Final report
echo -e "\n${BLUE}=== Conversion Complete (Folder 078) ===${NC}"
echo -e "${GREEN}✅ Successful conversions: $SUCCESSFUL${NC}"
echo -e "${BLUE}📄 DOCX files created: $DOCX_CREATED${NC}"
echo -e "${BLUE}📝 Markdown files created: $MARKDOWN_CREATED${NC}"
echo -e "${RED}❌ Failed conversions: $FAILED${NC}"

if [ $SUCCESSFUL -gt 0 ]; then
    echo -e "\n${GREEN}🎉 Folder 078 conversion completed successfully!${NC}"
    echo -e "${YELLOW}📁 Folder contains: DOC + DOCX + Markdown files${NC}"
    
    # Show final folder contents
    echo -e "\n${BLUE}📂 Final folder contents:${NC}"
    ls -la "$target_dir/"
else
    echo -e "\n${RED}❌ Conversion failed for folder 078${NC}"
    echo -e "${YELLOW}💡 Check LibreOffice installation and try manual conversion${NC}"
fi
