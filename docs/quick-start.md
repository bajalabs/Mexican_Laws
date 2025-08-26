# 🚀 Quick Start Guide

Get up and running with the Mexican Laws Database in minutes!

## 📋 **Prerequisites**

### Required Tools
- **bash/zsh** shell (macOS/Linux)
- **curl** for downloading files
- **git** for version control

### Optional Tools (for conversion)
- **LibreOffice** for DOC to DOCX conversion
- **pandoc** for Markdown generation

### System Requirements
- **~2GB free disk space** for complete dataset
- **Internet connection** for downloading laws
- **macOS, Linux, or WSL** (Windows Subsystem for Linux)

## 🛠️ **Installation**

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/mexican-laws-db.git
cd mexican-laws-db
```

### 2. Make Scripts Executable
```bash
chmod +x *.sh
```

### 3. Install Dependencies (Optional)
```bash
# macOS with Homebrew
brew install libreoffice pandoc

# Ubuntu/Debian
sudo apt-get install libreoffice pandoc

# CentOS/RHEL
sudo yum install libreoffice pandoc
```

## 🎯 **Quick Test**

Test the system with just 3 laws:

```bash
./test_download.sh
```

This will:
- ✅ Download 3 sample laws (Constitution, Civil Code, Commerce Code)
- ✅ Create organized folder structure
- ✅ Verify download mechanism works
- ✅ Show you what to expect

**Expected output:**
```
=== Test Download (First 3 Laws) ===

Testing: Constitucion Politica
  Testing PDF download... ✓ PDF downloaded
  Testing DOC download... ✓ DOC downloaded
  Testing PDF_MOV download... ✓ PDF_MOV downloaded

Testing: Codigo Civil Federal
  Testing PDF download... ✓ PDF downloaded
  Testing DOC download... ✓ DOC downloaded
  Testing PDF_MOV download... ✓ PDF_MOV downloaded

Testing: Codigo de Comercio
  Testing PDF download... ✓ PDF downloaded
  Testing DOC download... ✓ DOC downloaded
  Testing PDF_MOV download... ✓ PDF_MOV downloaded

Test complete! Check the folders to verify downloads.
```

## 📥 **Full Download**

Download all 334 Mexican federal laws:

```bash
./download_mexican_laws.sh
```

**⚠️ Warning:** This will:
- Download ~1,000+ files (1.1GB total)
- Take 30-60 minutes depending on connection
- Create 334 organized folders

**Progress tracking:**
The script provides real-time progress updates:
```
[001/334] Downloading: Constitucion Politica
  ✓ PDF downloaded (3.0MB)
  ✓ DOC downloaded (1.8MB) 
  ✓ PDF_MOV downloaded (1.6MB)

[002/334] Downloading: Codigo Civil Federal
  ✓ PDF downloaded (3.4MB)
  ✓ DOC downloaded (1.6MB)
  ✓ PDF_MOV downloaded (3.2MB)
...
```

## 📖 **Convert to Markdown**

Convert DOC files to readable Markdown format:

```bash
# Convert a single law (for testing)
./convert_folder78_only.sh

# Convert all laws (requires LibreOffice)
./convert_simple.sh
```

**Conversion process:**
1. **DOC → DOCX**: LibreOffice converts old Word format
2. **DOCX → Markdown**: Pandoc creates clean Markdown
3. **Metadata**: Adds law information and structure

## 🔍 **Explore the Data**

### Browse Law Folders
```bash
# List all downloaded laws
ls -la [0-9]*

# Check a specific law
cd "001_Constitucion_Politica"
ls -la
```

### Check File Sizes
```bash
# Total dataset size
du -sh .

# Individual law sizes
du -sh [0-9]*/ | head -10
```

### Search Laws
```bash
# Find laws by name
ls | grep -i "civil"
ls | grep -i "penal"
ls | grep -i "federal"

# Find converted Markdown files
find . -name "*.md" | head -10
```

## 📊 **Verify Your Setup**

Check what you have downloaded:

```bash
# Count files by type
echo "PDF files: $(find . -name "*.pdf" | wc -l)"
echo "DOC files: $(find . -name "*.doc" | wc -l)" 
echo "DOCX files: $(find . -name "*.docx" | wc -l)"
echo "Markdown files: $(find . -name "*.md" | wc -l)"
echo "Total folders: $(find . -maxdepth 1 -type d -name '[0-9]*' | wc -l)"
```

**Expected results after full download:**
```
PDF files: 668
DOC files: 334
DOCX files: 76 (if conversion completed)
Markdown files: 74 (if conversion completed)  
Total folders: 334
```

## 🎯 **What's Next?**

### 📚 **Explore the Laws**
- Browse the `001_Constitucion_Politica` folder
- Open PDF files to see original formatting
- Check Markdown files for readable text format

### 🔧 **Contribute to the Project**
- Help complete Markdown conversion (76/334 done)
- Improve conversion scripts
- Add metadata extraction
- Report any issues found

### 🚀 **Build Something Cool**
- Create a search interface
- Build a legal chatbot
- Analyze legal patterns
- Develop mobile app

## ❓ **Troubleshooting**

### Common Issues

**🐛 Download fails**
```bash
# Check internet connection
curl -I https://www.diputados.gob.mx/LeyesBiblio/

# Retry specific law
cd "001_Constitucion_Politica"
curl -o test.pdf "https://www.diputados.gob.mx/LeyesBiblio/pdf/CPEUM.pdf"
```

**🐛 LibreOffice conversion hangs**
```bash
# Kill LibreOffice processes
killall soffice

# Restart LibreOffice
/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --version
```

**🐛 Permission denied**
```bash
# Make scripts executable
chmod +x *.sh

# Check permissions
ls -la *.sh
```

### Getting Help

- **📋 Check Issues**: [GitHub Issues](https://github.com/yourusername/mexican-laws-db/issues)
- **💬 Ask Questions**: [GitHub Discussions](https://github.com/yourusername/mexican-laws-db/discussions)
- **📧 Contact**: [your-email@example.com](mailto:your-email@example.com)

## 🎉 **Success!**

You now have:
- ✅ Complete Mexican legal database
- ✅ Organized folder structure
- ✅ Multiple file formats
- ✅ Conversion tools
- ✅ Ready for development

**Ready to build the future of legal technology!** 🚀

---

*Next: Check out the [Architecture Guide](architecture.md) to understand the system design*
