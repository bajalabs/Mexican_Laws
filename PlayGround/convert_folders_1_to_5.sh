#!/bin/bash

# Convert folders 1-5 with DOCX preservation
# (These were processed earlier but DOCX files were deleted)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Converting Folders 1-5 (with DOCX preservation) ===${NC}\n"

# Process folders 1-5
for i in {1..5}; do
    # Find the directory
    dir=$(find . -maxdepth 1 -type d -name "$(printf "%03d*" $i)" | head -1)
    
    if [ -n "$dir" ]; then
        dir_name=$(basename "$dir")
        echo -e "${YELLOW}[$i/5] Processing: $dir_name${NC}"
        
        cd "$dir_name"
        
        # Find DOC file
        doc_file=$(find . -name "*.doc" -type f | head -1)
        
        if [ -n "$doc_file" ]; then
            law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
            law_name=$(echo "$dir_name" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
            
            echo -e "  ${BLUE}📄 Converting: $law_name${NC}"
            
            # Check if DOCX already exists
            existing_docx=$(find . -name "*.docx" -type f | head -1)
            
            if [ -z "$existing_docx" ]; then
                # Create DOCX
                echo -e "  ${YELLOW}Creating DOCX...${NC}"
                if soffice --headless --convert-to docx "$doc_file" 2>/dev/null; then
                    docx_file=$(find . -name "*.docx" -type f | head -1)
                    docx_size=$(du -h "$docx_file" | cut -f1)
                    echo -e "  ${GREEN}✓ DOCX created: $docx_size${NC}"
                else
                    echo -e "  ${RED}✗ DOCX creation failed${NC}"
                fi
            else
                docx_file="$existing_docx"
                docx_size=$(du -h "$docx_file" | cut -f1)
                echo -e "  ${BLUE}ℹ️  DOCX already exists: $docx_size${NC}"
            fi
            
            # Check if Markdown exists and update it
            if [ -f "${law_code}.md" ]; then
                echo -e "  ${BLUE}ℹ️  Updating existing Markdown with DOCX reference${NC}"
                
                # Update the metadata to include DOCX reference
                sed -i.bak 's/files_available:/files_available:\
  - original_doc: "'$(basename "$doc_file")'"\
  - intermediate_docx: "'$(basename "$docx_file")'"\
  - final_markdown: "'${law_code}.md'"/' "${law_code}.md" 2>/dev/null || true
                
                md_size=$(du -h "${law_code}.md" | cut -f1)
                echo -e "  ${GREEN}✓ Markdown updated: $md_size${NC}"
            fi
            
            echo -e "  ${GREEN}✅ Complete${NC}"
        else
            echo -e "  ${RED}✗ No DOC file found${NC}"
        fi
        
        cd ..
        echo ""
    fi
done

echo -e "${GREEN}🎉 Folders 1-5 processing complete!${NC}"
