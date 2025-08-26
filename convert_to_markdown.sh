#!/bin/bash

# Mexican Laws to Markdown Conversion Script
# Converts all DOC files to Markdown using pandoc

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_LAWS=0
SUCCESSFUL_CONVERSIONS=0
FAILED_CONVERSIONS=0

echo -e "${BLUE}=== Mexican Laws to Markdown Conversion ===${NC}"
echo -e "${BLUE}Converting all DOC files to Markdown format...${NC}\n"

# Function to convert DOC to Markdown
convert_doc_to_markdown() {
    local doc_file="$1"
    local output_file="$2"
    local law_name="$3"
    
    if [ -f "$doc_file" ]; then
        echo -e "  ${YELLOW}Converting DOC to Markdown...${NC}"
        
        # Use pandoc to convert DOC to Markdown with enhanced options
        if pandoc "$doc_file" \
            --from docx \
            --to markdown \
            --wrap=preserve \
            --extract-media=images \
            --standalone \
            --metadata title="$law_name" \
            --output "$output_file" 2>/dev/null; then
            
            echo -e "  ${GREEN}✓${NC} Markdown conversion successful"
            return 0
        else
            echo -e "  ${RED}✗${NC} Markdown conversion failed"
            return 1
        fi
    else
        echo -e "  ${RED}✗${NC} DOC file not found: $doc_file"
        return 1
    fi
}

# Function to add metadata header to markdown
add_metadata_header() {
    local markdown_file="$1"
    local law_code="$2"
    local law_name="$3"
    local folder_name="$4"
    
    # Create temporary file with metadata header
    cat > "${markdown_file}.tmp" << EOF
---
title: "$law_name"
law_code: "$law_code"
source: "Cámara de Diputados de México"
url: "https://www.diputados.gob.mx/LeyesBiblio/"
converted_date: "$(date '+%Y-%m-%d')"
folder: "$folder_name"
formats_available:
  - PDF (Static)
  - DOC (Word Document)
  - PDF (Mobile)
  - Markdown (Converted)
---

# $law_name

**Código:** $law_code  
**Fuente:** Cámara de Diputados de México  
**Convertido a Markdown:** $(date '+%Y-%m-%d %H:%M:%S')

---

EOF
    
    # Append original content
    cat "$markdown_file" >> "${markdown_file}.tmp"
    mv "${markdown_file}.tmp" "$markdown_file"
}

# Get all law directories
law_dirs=($(find . -maxdepth 1 -type d -name "[0-9]*" | sort))
TOTAL_LAWS=${#law_dirs[@]}

echo -e "${BLUE}Found $TOTAL_LAWS law directories to process${NC}\n"

# Process each law directory
for i in "${!law_dirs[@]}"; do
    dir="${law_dirs[$i]}"
    dir_name=$(basename "$dir")
    
    echo -e "${YELLOW}[$((i + 1))/$TOTAL_LAWS] Processing: $dir_name${NC}"
    
    cd "$dir"
    
    # Find DOC file
    doc_file=$(find . -name "*.doc" -type f | head -1)
    
    if [ -n "$doc_file" ]; then
        # Extract law code and name from filename
        doc_basename=$(basename "$doc_file" .doc)
        law_code=$(echo "$doc_basename" | sed 's/_document$//')
        
        # Get law name from folder
        law_name=$(echo "$dir_name" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
        
        # Create markdown filename
        markdown_file="${law_code}.md"
        
        # Convert DOC to Markdown
        if convert_doc_to_markdown "$doc_file" "$markdown_file" "$law_name"; then
            # Add metadata header
            add_metadata_header "$markdown_file" "$law_code" "$law_name" "$dir_name"
            
            ((SUCCESSFUL_CONVERSIONS++))
            echo -e "  ${GREEN}✓ Law converted successfully${NC}"
            
            # Show file size
            if [ -f "$markdown_file" ]; then
                file_size=$(du -h "$markdown_file" | cut -f1)
                echo -e "  ${BLUE}📄 Markdown file: $file_size${NC}"
            fi
        else
            ((FAILED_CONVERSIONS++))
            echo -e "  ${RED}✗ Law conversion failed${NC}"
        fi
    else
        echo -e "  ${RED}✗ No DOC file found in directory${NC}"
        ((FAILED_CONVERSIONS++))
    fi
    
    cd ..
    echo ""
done

# Create master index of all markdown files
echo -e "${YELLOW}Creating master index...${NC}"
cat > "MARKDOWN_INDEX.md" << EOF
# Mexican Federal Laws - Markdown Collection

**Total Laws:** $TOTAL_LAWS  
**Successfully Converted:** $SUCCESSFUL_CONVERSIONS  
**Failed Conversions:** $FAILED_CONVERSIONS  
**Conversion Date:** $(date)

## Index of Laws

EOF

# Add each law to the index
for i in "${!law_dirs[@]}"; do
    dir="${law_dirs[$i]}"
    dir_name=$(basename "$dir")
    law_name=$(echo "$dir_name" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
    
    # Check if markdown file exists
    cd "$dir"
    markdown_file=$(find . -name "*.md" -type f | head -1)
    if [ -n "$markdown_file" ]; then
        echo "- [$((i + 1)). $law_name]($dir/$(basename "$markdown_file"))" >> "../MARKDOWN_INDEX.md"
    else
        echo "- $((i + 1)). $law_name *(conversion failed)*" >> "../MARKDOWN_INDEX.md"
    fi
    cd ..
done

# Final report
echo -e "${BLUE}=== Conversion Complete ===${NC}"
echo -e "${GREEN}Successfully converted: $SUCCESSFUL_CONVERSIONS laws${NC}"
echo -e "${RED}Failed conversions: $FAILED_CONVERSIONS laws${NC}"
echo -e "${BLUE}Total laws processed: $TOTAL_LAWS${NC}"
echo -e "\n${YELLOW}✓ Master index created: MARKDOWN_INDEX.md${NC}"
echo -e "${YELLOW}✓ All markdown files include metadata headers${NC}"
echo -e "${YELLOW}✓ Files organized in original folder structure${NC}"

# Show total markdown size
total_md_size=$(find . -name "*.md" -type f -exec du -ch {} + | tail -1 | cut -f1)
echo -e "${BLUE}📊 Total markdown collection size: $total_md_size${NC}"
