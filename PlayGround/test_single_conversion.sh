#!/bin/bash

# Test script for single folder conversion (078)
# This tests the conversion process before running the full batch

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_FOLDER="078_Ley de los Institutos Nacionales de Salud"

echo -e "${BLUE}🧪 Testing conversion process with folder: $TEST_FOLDER${NC}\n"

# Change to Mexican Laws Active directory
cd /Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/Mexican_Laws/Mexican_Laws-Diputados/Mexican_Laws-Active

if [ ! -d "$TEST_FOLDER" ]; then
    echo -e "${RED}❌ Test folder not found: $TEST_FOLDER${NC}"
    exit 1
fi

echo -e "${YELLOW}📂 Entering folder: $TEST_FOLDER${NC}"
cd "$TEST_FOLDER"

# Find DOC file
doc_file=$(find . -name "*.doc" -type f | head -1)

if [ -z "$doc_file" ]; then
    echo -e "${RED}❌ No DOC file found${NC}"
    exit 1
fi

echo -e "${BLUE}📄 Found DOC file: $doc_file${NC}"

# Get file size
doc_size=$(stat -f%z "$doc_file" 2>/dev/null || echo "0")
doc_size_mb=$((doc_size / 1024 / 1024))
echo -e "${BLUE}📏 File size: ${doc_size_mb}MB${NC}"

# Extract law information
law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
law_name=$(echo "$TEST_FOLDER" | sed 's/^[0-9]*_//' | sed 's/_/ /g')

echo -e "${BLUE}🏷️  Law code: $law_code${NC}"
echo -e "${BLUE}📚 Law name: $law_name${NC}"

# Test LibreOffice conversion
echo -e "\n${YELLOW}🔄 Testing LibreOffice DOC → DOCX conversion...${NC}"

if timeout 180s soffice --headless --convert-to docx "$doc_file" 2>/dev/null; then
    sleep 1  # Give LibreOffice time to finish
    
    docx_file=$(find . -name "*.docx" -type f | head -1)
    if [ -n "$docx_file" ]; then
        docx_size=$(du -h "$docx_file" | cut -f1)
        echo -e "${GREEN}✅ DOCX conversion successful: $docx_size${NC}"
        
        # Test Pandoc conversion
        echo -e "${YELLOW}🔄 Testing Pandoc DOCX → Markdown conversion...${NC}"
        
        if pandoc "$docx_file" \
            --from docx \
            --to markdown \
            --wrap=preserve \
            --standalone \
            --metadata title="$law_name" \
            --output "${law_code}_test.md" 2>/dev/null; then
            
            md_size=$(du -h "${law_code}_test.md" | cut -f1)
            md_lines=$(wc -l < "${law_code}_test.md")
            echo -e "${GREEN}✅ Markdown conversion successful: $md_size ($md_lines lines)${NC}"
            
            # Show first few lines of Markdown
            echo -e "\n${BLUE}📖 First 10 lines of generated Markdown:${NC}"
            head -10 "${law_code}_test.md"
            
            echo -e "\n${GREEN}🎉 Test conversion successful!${NC}"
            echo -e "${BLUE}📊 Results:${NC}"
            echo -e "   DOC: ${doc_size_mb}MB"
            echo -e "   DOCX: $docx_size"
            echo -e "   Markdown: $md_size ($md_lines lines)"
            
            # Clean up test files
            echo -e "\n${YELLOW}🧹 Cleaning up test files...${NC}"
            rm -f "$docx_file" "${law_code}_test.md"
            echo -e "${GREEN}✅ Test completed successfully - system is ready for batch processing${NC}"
            
        else
            echo -e "${RED}❌ Pandoc conversion failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ DOCX file not found after conversion${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ LibreOffice conversion failed or timed out${NC}"
    exit 1
fi