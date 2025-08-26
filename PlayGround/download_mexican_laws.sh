#!/bin/bash

# Mexican Laws Download Script
# Downloads all 334 active Mexican federal laws in 3 formats:
# 1. PDF (static version)
# 2. DOC (Word document)
# 3. PDF_MOV (mobile/updated version)

set -e  # Exit on any error

# Base URLs
BASE_URL="https://www.diputados.gob.mx/LeyesBiblio"
PDF_URL="${BASE_URL}/pdf"
DOC_URL="${BASE_URL}/doc"
PDF_MOV_URL="${BASE_URL}/pdf_mov"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_LAWS=0
SUCCESSFUL_DOWNLOADS=0
FAILED_DOWNLOADS=0

echo -e "${BLUE}=== Mexican Laws Download Script ===${NC}"
echo -e "${BLUE}Downloading all active Mexican federal laws...${NC}\n"

# Function to create sanitized folder name
sanitize_folder_name() {
    local name="$1"
    # Replace underscores with spaces, remove special characters, limit length
    echo "$name" | sed 's/_/ /g' | sed 's/[^a-zA-Z0-9 -]//g' | cut -c1-80
}

# Function to download a file with error handling
download_file() {
    local url="$1"
    local output_path="$2"
    local file_type="$3"
    
    if curl -f -s -L "$url" -o "$output_path" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Downloaded $file_type"
        return 0
    else
        echo -e "  ${RED}✗${NC} Failed to download $file_type from $url"
        return 1
    fi
}

# Get law codes and names
echo -e "${YELLOW}Fetching law list from website...${NC}"
curl -s "${BASE_URL}/index.htm" | grep -E 'href="pdf/[^"]+\.pdf"' | sed 's/.*href="pdf\/\([^"]*\)\.pdf".*/\1/' > law_codes.txt
curl -s "${BASE_URL}/index.htm" | grep -E 'pdf_mov/[^"]+\.pdf' | sed 's/.*pdf_mov\/\([^"]*\)\.pdf.*/\1/' > law_names.txt

TOTAL_LAWS=$(wc -l < law_codes.txt)
echo -e "${BLUE}Found $TOTAL_LAWS laws to download${NC}\n"

# Create arrays from files (macOS compatible)
law_codes=()
law_names=()
while IFS= read -r line; do
    law_codes+=("$line")
done < law_codes.txt

while IFS= read -r line; do
    law_names+=("$line")
done < law_names.txt

# Download each law
for i in "${!law_codes[@]}"; do
    code="${law_codes[$i]}"
    name="${law_names[$i]}"
    
    # Create sanitized folder name
    folder_name=$(sanitize_folder_name "$name")
    law_number=$(printf "%03d" $((i + 1)))
    final_folder_name="${law_number}_${folder_name}"
    
    echo -e "${YELLOW}[$((i + 1))/$TOTAL_LAWS] Processing: $folder_name${NC}"
    
    # Create directory
    mkdir -p "$final_folder_name"
    cd "$final_folder_name"
    
    # Download counters for this law
    law_success=0
    
    # Download PDF (static version)
    if download_file "${PDF_URL}/${code}.pdf" "${code}_static.pdf" "PDF (Static)"; then
        ((law_success++))
    fi
    
    # Download DOC (Word document)
    if download_file "${DOC_URL}/${code}.doc" "${code}_document.doc" "DOC (Word)"; then
        ((law_success++))
    fi
    
    # Download PDF_MOV (mobile/updated version)
    if download_file "${PDF_MOV_URL}/${name}.pdf" "${name}_mobile.pdf" "PDF (Mobile)"; then
        ((law_success++))
    fi
    
    # Create info file
    cat > "law_info.txt" << EOF
Law Information
===============
Code: $code
Name: $name
Folder: $final_folder_name
Downloaded: $(date)

Files Downloaded: $law_success/3
- ${code}_static.pdf (Static PDF version)
- ${code}_document.doc (Word document)
- ${name}_mobile.pdf (Mobile PDF version)

Source: https://www.diputados.gob.mx/LeyesBiblio/
EOF
    
    if [ $law_success -gt 0 ]; then
        ((SUCCESSFUL_DOWNLOADS++))
        echo -e "  ${GREEN}✓ Law downloaded successfully ($law_success/3 files)${NC}"
    else
        ((FAILED_DOWNLOADS++))
        echo -e "  ${RED}✗ Law download failed${NC}"
    fi
    
    cd ..
    echo ""
done

# Clean up temporary files
rm -f law_codes.txt law_names.txt

# Final report
echo -e "${BLUE}=== Download Complete ===${NC}"
echo -e "${GREEN}Successfully processed: $SUCCESSFUL_DOWNLOADS laws${NC}"
echo -e "${RED}Failed downloads: $FAILED_DOWNLOADS laws${NC}"
echo -e "${BLUE}Total laws: $TOTAL_LAWS${NC}"
echo -e "\n${YELLOW}All files have been organized in numbered folders with descriptive names.${NC}"
echo -e "${YELLOW}Each folder contains up to 3 file formats and an info file.${NC}"
