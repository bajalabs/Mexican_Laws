# Mexican Laws Download Project

## Overview
This project downloads and organizes all 334 active Mexican federal laws from the official Chamber of Deputies website (https://www.diputados.gob.mx/LeyesBiblio/).

## Project Structure

### Files Available
Each law is available in **3 formats**:
1. **PDF (Static)** - `{code}_static.pdf` - Official static PDF version
2. **DOC (Word)** - `{code}_document.doc` - Word document format
3. **PDF (Mobile)** - `{name}_mobile.pdf` - Mobile-optimized PDF version

### Folder Organization
- Each law gets its own numbered folder: `001_Law Name`, `002_Law Name`, etc.
- Folders are named with descriptive titles (e.g., "001_Constitucion Politica")
- Each folder contains up to 3 files + an info file

### Scripts Included

#### `download_mexican_laws.sh` (Main Script)
- Downloads all 334 laws automatically
- Creates organized folder structure
- Handles errors gracefully
- Provides progress updates
- Generates summary reports

#### `test_download.sh` (Test Script)
- Downloads first 3 laws only
- Used for testing before full execution
- Verifies download mechanism works

## Usage

### Quick Test (Recommended First)
```bash
./test_download.sh
```

### Full Download (All 334 Laws)
```bash
./download_mexican_laws.sh
```

**⚠️ Warning:** Full download will:
- Create 334 folders
- Download ~1,000+ files
- Take significant time (estimated 30-60 minutes)
- Use substantial bandwidth and disk space

## Sample Laws Included

The test successfully downloaded:
1. **001_Constitucion Politica** (Mexican Constitution)
   - CPEUM_static.pdf (3.0 MB)
   - CPEUM_document.doc (1.8 MB)
   - Constitucion_Politica_mobile.pdf (1.6 MB)

2. **002_Codigo Civil Federal** (Federal Civil Code)
   - CCF_static.pdf (3.4 MB)
   - CCF_document.doc (1.6 MB)
   - Codigo_Civil_Federal_mobile.pdf (3.2 MB)

3. **003_Codigo de Comercio** (Commerce Code)
   - CCom_static.pdf (2.6 MB)
   - CCom_document.doc (1.4 MB)
   - Codigo_de_Comercio_mobile.pdf (2.2 MB)

## Technical Details

### Source Website Analysis
- **Base URL:** https://www.diputados.gob.mx/LeyesBiblio/
- **PDF Path:** `/pdf/{code}.pdf`
- **DOC Path:** `/doc/{code}.doc`
- **Mobile PDF Path:** `/pdf_mov/{name}.pdf`

### Download Statistics
- **Total Laws Found:** 334 (updated count)
- **Expected Files:** ~1,002 files (334 × 3 formats)
- **Test Success Rate:** 100% (9/9 files downloaded successfully)

### Error Handling
- Graceful handling of missing files
- Continues download even if some files fail
- Detailed logging and reporting
- Individual file validation

## Next Steps

1. **✅ Completed:** Website analysis
2. **✅ Completed:** Folder structure creation
3. **✅ Completed:** Download script development
4. **✅ Completed:** Test execution (3 laws successfully downloaded)
5. **🔄 Ready:** Full execution (awaiting user approval)

## Execution Command

To download all 334 Mexican laws:
```bash
cd Mexican_Laws
./download_mexican_laws.sh
```

This will create a comprehensive library of all active Mexican federal laws in multiple formats, properly organized and documented.
