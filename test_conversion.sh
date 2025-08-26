#!/bin/bash

# Test conversion script - converts first 3 laws only

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Test Markdown Conversion (First 3 Laws) ===${NC}"

test_dirs=("001_Constitucion Politica" "002_Codigo Civil Federal" "003_Codigo de Comercio")

for dir in "${test_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Testing: $dir${NC}"
        cd "$dir"
        
        # Find DOC file
        doc_file=$(find . -name "*.doc" -type f | head -1)
        
        if [ -n "$doc_file" ]; then
            echo "  Found DOC file: $doc_file"
            
            # Extract law code
            law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
            markdown_file="${law_code}.md"
            
            # Test pandoc conversion
            echo "  Testing pandoc conversion..."
            if pandoc "$doc_file" \
                --from docx \
                --to markdown \
                --wrap=preserve \
                --standalone \
                --output "$markdown_file" 2>/dev/null; then
                
                echo -e "  ${GREEN}✓ Conversion successful${NC}"
                
                # Check file size
                if [ -f "$markdown_file" ]; then
                    file_size=$(du -h "$markdown_file" | cut -f1)
                    line_count=$(wc -l < "$markdown_file")
                    echo -e "  ${BLUE}📄 Size: $file_size, Lines: $line_count${NC}"
                    
                    # Show first few lines
                    echo "  First 5 lines:"
                    head -5 "$markdown_file" | sed 's/^/    /'
                fi
            else
                echo -e "  ${RED}✗ Conversion failed${NC}"
            fi
        else
            echo -e "  ${RED}✗ No DOC file found${NC}"
        fi
        
        cd ..
        echo ""
    else
        echo -e "${RED}Directory not found: $dir${NC}"
    fi
done

echo -e "${BLUE}Test conversion complete!${NC}"
