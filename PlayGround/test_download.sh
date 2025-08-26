#!/bin/bash

# Test script to download first 3 laws only
# This is for testing the download mechanism before running the full script

set -e

BASE_URL="https://www.diputados.gob.mx/LeyesBiblio"
PDF_URL="${BASE_URL}/pdf"
DOC_URL="${BASE_URL}/doc"
PDF_MOV_URL="${BASE_URL}/pdf_mov"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Test Download (First 3 Laws) ===${NC}"

# Test with first 3 laws
test_codes=("CPEUM" "CCF" "CCom")
test_names=("Constitucion_Politica" "Codigo_Civil_Federal" "Codigo_de_Comercio")

for i in "${!test_codes[@]}"; do
    code="${test_codes[$i]}"
    name="${test_names[$i]}"
    
    folder_name=$(echo "$name" | sed 's/_/ /g')
    final_folder_name="$(printf "%03d" $((i + 1)))_${folder_name}"
    
    echo -e "${YELLOW}Testing: $folder_name${NC}"
    
    mkdir -p "$final_folder_name"
    cd "$final_folder_name"
    
    # Test each download
    echo "  Testing PDF download..."
    curl -f -s -L "${PDF_URL}/${code}.pdf" -o "${code}_static.pdf" && echo -e "  ${GREEN}✓ PDF downloaded${NC}" || echo "  ✗ PDF failed"
    
    echo "  Testing DOC download..."
    curl -f -s -L "${DOC_URL}/${code}.doc" -o "${code}_document.doc" && echo -e "  ${GREEN}✓ DOC downloaded${NC}" || echo "  ✗ DOC failed"
    
    echo "  Testing PDF_MOV download..."
    curl -f -s -L "${PDF_MOV_URL}/${name}.pdf" -o "${name}_mobile.pdf" && echo -e "  ${GREEN}✓ PDF_MOV downloaded${NC}" || echo "  ✗ PDF_MOV failed"
    
    ls -la
    cd ..
    echo ""
done

echo -e "${BLUE}Test complete! Check the folders to verify downloads.${NC}"
