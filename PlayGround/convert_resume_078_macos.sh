#!/bin/bash

# macOS-Compatible Mexican Laws Conversion Script - Resume from Folder 078
# Simplified version without timeout command for macOS compatibility

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration  
MAX_FILE_SIZE_MB=15
BATCH_SIZE=10

# Counters
SUCCESSFUL=0
FAILED=0
SKIPPED_SIZE=0
SKIPPED_EXISTS=0
TOTAL=0
DOCX_CREATED=0
MARKDOWN_CREATED=0
CURRENT_BATCH=1

# Log file
LOG_FILE="conversion_log_macos_$(date '+%Y%m%d_%H%M%S').txt"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        macOS-Compatible Mexican Laws Conversion Script       ║${NC}"
echo -e "${BLUE}║              Resume from Folder 078 - v1.0                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}📋 DOC → DOCX → Markdown (macOS Compatible)${NC}\n"

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to convert single folder
convert_folder() {
    local dir_name="$1"
    local counter="$2"
    
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│ [$counter/$TOTAL] Processing: $dir_name${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
    
    cd "$dir_name"
    
    # Find DOC file
    doc_file=$(find . -name "*.doc" -type f | head -1)
    
    if [ -z "$doc_file" ]; then
        echo -e "  ${RED}✗ No DOC file found${NC}"
        ((FAILED++))
        cd ..
        return 1
    fi
    
    # Extract law information
    law_code=$(basename "$doc_file" .doc | sed 's/_document$//')
    law_name=$(echo "$dir_name" | sed 's/^[0-9]*_//' | sed 's/_/ /g')
    
    # Check if already converted
    if [ -f "${law_code}.md" ]; then
        echo -e "  ${PURPLE}ℹ️  Already converted - Markdown exists${NC}"
        ((SKIPPED_EXISTS++))
        cd ..
        return 0
    fi
    
    # Check file size
    doc_size=$(stat -f%z "$doc_file" 2>/dev/null || echo "0")
    doc_size_mb=$((doc_size / 1024 / 1024))
    
    if [ "$doc_size_mb" -gt "$MAX_FILE_SIZE_MB" ]; then
        echo -e "  ${YELLOW}⚠️  File too large: ${doc_size_mb}MB (max: ${MAX_FILE_SIZE_MB}MB)${NC}"
        echo -e "  ${YELLOW}⚠️  Skipping to prevent system hang${NC}"
        log_message "SKIPPED: $dir_name - File size ${doc_size_mb}MB exceeds limit"
        ((SKIPPED_SIZE++))
        cd ..
        return 0
    fi
    
    echo -e "  ${BLUE}📄 Law: $law_name${NC}"
    echo -e "  ${BLUE}📁 Code: $law_code${NC}"
    echo -e "  ${BLUE}📏 Size: ${doc_size_mb}MB${NC}"
    
    # Step 1: DOC to DOCX
    echo -e "  ${YELLOW}🔄 Step 1: DOC → DOCX${NC}"
    
    if soffice --headless --convert-to docx "$doc_file" 2>/dev/null; then
        # Give LibreOffice a moment to finish writing
        sleep 2
        
        # Find the created DOCX file
        docx_file=$(find . -name "*.docx" -type f | head -1)
        if [ -n "$docx_file" ]; then
            docx_size=$(du -h "$docx_file" | cut -f1)
            echo -e "  ${GREEN}✓ DOCX created: $docx_size${NC}"
            ((DOCX_CREATED++))
            
            # Step 2: DOCX to Markdown
            echo -e "  ${YELLOW}🔄 Step 2: DOCX → Markdown${NC}"
            if pandoc "$docx_file" \
                --from docx \
                --to markdown \
                --wrap=preserve \
                --standalone \
                --metadata title="$law_name" \
                --output "${law_code}.md" 2>/dev/null; then
                
                echo -e "  ${GREEN}✓ Markdown conversion successful${NC}"
                ((MARKDOWN_CREATED++))
                
                # Add metadata header
                cat > "${law_code}.md.tmp" << EOF
---
title: "$law_name"
law_code: "$law_code"
folder: "$dir_name"
source: "Cámara de Diputados de México"
source_url: "https://www.diputados.gob.mx/LeyesBiblio/"
conversion_method: "macOS DOC → DOCX → Markdown"
converted_date: "$(date '+%Y-%m-%d')"
converted_time: "$(date '+%H:%M:%S')"
original_size_mb: $doc_size_mb
files_available:
  - original_doc: "$(basename "$doc_file")"
  - intermediate_docx: "$(basename "$docx_file")"  
  - final_markdown: "${law_code}.md"
conversion_status: "success"
processing_batch: $CURRENT_BATCH
---

# $law_name

**Código de Ley:** $law_code  
**Fuente:** Cámara de Diputados de México  
**Convertido:** $(date '+%Y-%m-%d %H:%M:%S')  
**Tamaño original:** ${doc_size_mb}MB  
**Archivos disponibles:** DOC, DOCX, Markdown

---

EOF
                
                # Append original content and replace
                cat "${law_code}.md" >> "${law_code}.md.tmp"
                mv "${law_code}.md.tmp" "${law_code}.md"
                
                # Show final results
                md_size=$(du -h "${law_code}.md" | cut -f1)
                md_lines=$(wc -l < "${law_code}.md")
                echo -e "  ${BLUE}📊 Results:${NC}"
                echo -e "    ${BLUE}DOCX: $docx_size${NC}"
                echo -e "    ${BLUE}Markdown: $md_size ($md_lines lines)${NC}"
                
                ((SUCCESSFUL++))
                log_message "SUCCESS: $dir_name - $law_name converted successfully"
                echo -e "  ${GREEN}✅ Complete success (DOC + DOCX + MD)${NC}"
                
                cd ..
                return 0
            else
                echo -e "  ${RED}✗ Markdown conversion failed${NC}"
                echo -e "  ${BLUE}ℹ️  DOCX preserved: $(basename "$docx_file")${NC}"
                ((FAILED++))
                cd ..
                return 1
            fi
        else
            echo -e "  ${RED}✗ DOCX file not found after conversion${NC}"
            ((FAILED++))
            cd ..
            return 1
        fi
    else
        echo -e "  ${RED}✗ DOCX conversion failed${NC}"
        ((FAILED++))
        cd ..
        return 1
    fi
}

# Main execution
echo -e "${BLUE}🚀 Starting macOS conversion process...${NC}\n"

# Change to the correct directory
cd "/Users/ivi/VIBE/RATIOS/iulex-Dash/iulex-v1/Mexican_Laws/Mexican_Laws-Diputados/Mexican_Laws-Active"

# Count directories from 078 onwards
echo -e "${YELLOW}📊 Scanning directories...${NC}"
TOTAL=0
for dir in */; do
    if [[ "$dir" =~ ^[0-9] ]]; then
        dir_number=$(echo "$dir" | grep -o '^[0-9]*')
        if [ "$dir_number" -ge 78 ]; then
            ((TOTAL++))
        fi
    fi
done

echo -e "${BLUE}📈 Found $TOTAL law directories to process (078 onwards)${NC}"
echo -e "${YELLOW}⚠️  Skipping folder 077 (24MB file known to cause issues)${NC}"
echo -e "${PURPLE}⚙️  Configuration: Max file size: ${MAX_FILE_SIZE_MB}MB${NC}\n"

# Process directories
counter=0
batch_counter=0

for dir in */; do
    # Skip if not a numbered directory
    if [[ ! "$dir" =~ ^[0-9] ]]; then
        continue
    fi
    
    # Skip directories before 078
    dir_number=$(echo "$dir" | grep -o '^[0-9]*')
    if [ "$dir_number" -lt 78 ]; then
        continue
    fi
    
    ((counter++))
    ((batch_counter++))
    dir_name="${dir%/}"
    
    # Convert the folder
    convert_folder "$dir_name" "$counter"
    
    # Batch checkpoint
    if [ $((batch_counter % BATCH_SIZE)) -eq 0 ] || [ $counter -eq $TOTAL ]; then
        echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║                    BATCH $CURRENT_BATCH CHECKPOINT                        ║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo -e "${GREEN}✅ Completed: $SUCCESSFUL${NC}"
        echo -e "${RED}❌ Failed: $FAILED${NC}"
        echo -e "${YELLOW}⚠️  Skipped (size): $SKIPPED_SIZE${NC}"
        echo -e "${PURPLE}ℹ️  Skipped (exists): $SKIPPED_EXISTS${NC}"
        echo -e "${BLUE}📊 Progress: $(( (SUCCESSFUL + FAILED + SKIPPED_SIZE + SKIPPED_EXISTS) * 100 / TOTAL ))%${NC}"
        
        if [ $SUCCESSFUL -gt 0 ]; then
            success_rate=$(( SUCCESSFUL * 100 / (SUCCESSFUL + FAILED) ))
            echo -e "${CYAN}🎯 Success rate: ${success_rate}%${NC}"
        fi
        
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}\n"
        
        ((CURRENT_BATCH++))
        batch_counter=0
        
        # Brief pause between batches
        sleep 1
    fi
done

# Final report
echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    FINAL CONVERSION REPORT                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}✅ Successful conversions: $SUCCESSFUL${NC}"
echo -e "${BLUE}📄 DOCX files created: $DOCX_CREATED${NC}"
echo -e "${BLUE}📝 Markdown files created: $MARKDOWN_CREATED${NC}"
echo -e "${YELLOW}⚠️  Files skipped (too large): $SKIPPED_SIZE${NC}"
echo -e "${PURPLE}ℹ️  Files skipped (already exist): $SKIPPED_EXISTS${NC}"
echo -e "${RED}❌ Failed conversions: $FAILED${NC}"
echo -e "${BLUE}📊 Total processed: $TOTAL${NC}"

if [ $TOTAL -gt 0 ]; then
    completion_rate=$(( (SUCCESSFUL + FAILED + SKIPPED_SIZE + SKIPPED_EXISTS) * 100 / TOTAL ))
    echo -e "${CYAN}📈 Completion rate: ${completion_rate}%${NC}"
    
    if [ $((SUCCESSFUL + FAILED)) -gt 0 ]; then
        success_rate=$(( SUCCESSFUL * 100 / (SUCCESSFUL + FAILED) ))
        echo -e "${CYAN}🎯 Success rate: ${success_rate}%${NC}"
    fi
fi

echo -e "\n${PURPLE}📁 Log file: $LOG_FILE${NC}"

if [ $SUCCESSFUL -gt 0 ]; then
    echo -e "\n${GREEN}🎉 Conversion completed with $SUCCESSFUL successes!${NC}"
    echo -e "${CYAN}📁 Each successful folder contains: DOC + DOCX + Markdown${NC}"
else
    echo -e "\n${RED}⚠️  No successful conversions completed${NC}"
fi

echo -e "${YELLOW}⚠️  Note: Folder 077 intentionally skipped (large file issue)${NC}"

exit 0