---
name: pic-to-txt
description: |
  Use when a folder of screenshot images needs to be converted into a
  clean text document. Runs OCR on each image (PaddleOCR for Chinese,
  EasyOCR for English), combines results in filename order, then refines
  with LLM to produce a polished document saved alongside the images.
license: MIT
compatibility: claude-code
metadata:
  triggers:
    - extract text from images
    - convert images to text
    - ocr these images
    - pic to txt
    - screenshot to text
    - 图片转文字
    - 提取图片文字
  when_to_use: |
    When a user has a folder of screenshots, photos, or scanned images
    that need to be converted to editable text. Each folder represents
    one document (e.g., scanned book pages, product screenshots, slides).
    Best for image sets that are visually clean with readable text
    (screenshots, scans, slides, forms).
  when_not_to_use: |
    For handwritten text (accuracy is poor). For single images — use
    OCR inline instead. For PDF files — use a dedicated PDF tool.
    For extracting structured data (tables, forms) — a specialized
    document parser is better. For images with heavy watermarks or
    artistic text overlays.
---

# pic-to-txt

Converts a folder of sorted image files into a clean text document
using OCR + LLM refinement. Each folder is treated as one document:
images are processed in filename order, their OCR text concatenated,
and the combined result is refined by an LLM for accuracy and
readability.

The pipeline auto-detects or accepts a language hint and routes
to the appropriate OCR engine: PaddleOCR (best Chinese accuracy)
or EasyOCR (good English + GPU support).

## When to Use

- You have a folder of screenshots from a product, app, or website
  and want to extract all visible text
- You scanned book pages or documents and need editable text
- You have presentation slides exported as images and need the text
- You captured a series of images from a video or demo and want
  the transcript
- Any batch of images where each folder = one document

## When NOT to Use

- Handwritten notes, cursive, or calligraphy (OCR accuracy below 60%)
- A single image — just inline an OCR command instead of invoking the skill
- PDF files — use a PDF parser (PyMuPDF, pdfplumber)
- Complex tables or forms where layout structure matters
- Images with heavy watermark overlays or artistic/distorted text

## Prerequisites

Install required OCR libraries (one-time setup):

### For Chinese documents (PaddleOCR):

PaddleOCR requires two packages. The CPU version is sufficient for
most use cases and avoids heavy CUDA dependencies:

```bash
pip install paddlepaddle paddleocr
```

### For English documents (EasyOCR):

```bash
pip install easyocr
```

### For both:

```bash
pip install paddlepaddle paddleocr easyocr
```

The companion script `ocr.py` is bundled with this skill and handles
both engines — no additional setup needed.

## Companion Script

The skill ships with `ocr.py` — a Python script that handles the
OCR heavy lifting. It takes a folder path and optional language
argument, runs the appropriate engine, outputs combined text.

```bash
python3 /path/to/ocr.py <folder> [--lang zh|en|auto]
```

When `--lang auto`, the script inspects file extension conventions:
`.chs`, `.zh/` subfolder, or common Chinese filename patterns →
PaddleOCR. Defaults to English → EasyOCR otherwise.

## Process

### Step 0: Verify dependencies

Check that the OCR libraries are installed:

```bash
python3 -c "import paddleocr; print('PaddleOCR ok')" 2>&1 || echo "Install: pip install paddlepaddle paddleocr"
python3 -c "import easyocr; print('EasyOCR ok')" 2>&1 || echo "Install: pip install easyocr"
```

At least one engine must be available. Install missing ones before
proceeding (see Prerequisites).

### Step 1: Scan the target folder

Given a folder path, list all image files sorted by filename:

```bash
ls -1v <folder>/*.{png,jpg,jpeg,gif,bmp,tiff} 2>/dev/null
```

`ls -1v` sorts naturally (01 comes before 02, 10 before 100).
If images use numbered filenames like `page_01.png`, `page_02.png`,
this produces the correct page order. Confirm the order with the user
before proceeding.

Expected image naming conventions:
- `01.png`, `02.png`, ... (simple numbered)
- `page_001.jpg`, `page_002.jpg`, ... (padded numbers)
- `screenshot-2026-07-18-14h30m00s.png` (timestamp — sort by time)
- Any alphanumeric sort produces the intended reading order

### Step 2: Run OCR

**English documents (EasyOCR):**

```bash
python3 -c "
import easyocr, sys
reader = easyocr.Reader(['en'], gpu=True)
for img in sorted(sys.argv[1:]):
    result = reader.readtext(img)
    text = ' '.join([item[1] for item in result])
    print(f'--- {img} ---')
    print(text)
" <folder>/*.png
```

**Chinese documents (PaddleOCR):**

```bash
python3 -c "
from paddleocr import PaddleOCR
import sys
ocr = PaddleOCR(use_angle_cls=True, lang='ch')
for img in sorted(sys.argv[1:]):
    result = ocr.ocr(img, cls=True)
    text = ' '.join([line[1][0] for line in result[0]])
    print(f'--- {img} ---')
    print(text)
" <folder>/*.png
```

PaddleOCR first run downloads model files (~15 MB) — subsequent runs
are instant.

**Mixed Chinese/English:** Use PaddleOCR with `lang='ch'` — it handles
both well. Or run both engines and merge results (PaddleOCR keeps
Chinese, EasyOCR fills English gaps).

Save raw OCR output to `<folder>/_raw_ocr_output.txt` for reference.

### Step 3: LLM refinement

OCR output contains errors — wrong characters, missing punctuation,
merged words, split characters. The raw output CANNOT be used as the
final document. Refinement is mandatory.

Use an LLM call with this prompt structure:

```
You are a document editor. Below is raw OCR text extracted from a
series of images of a document. The images were processed in order
so the text flows sequentially.

## Raw OCR text
<raw OCR output>
```

```
Task: Review and correct the raw OCR text.

Rules:
- Fix OCR errors (wrong characters, missing spaces, split words)
- Restore proper punctuation and paragraph breaks
- Keep the original content and meaning — do NOT add or summarize
- If a word/phrase is uncertain, flag with [sic?] or [unclear]
- Preserve document structure: headings, lists, sections
- Output as clean, readable text with proper paragraphs
- If the document has a clear title or heading, preserve it

Output the corrected document as a clean text block.
```

### Step 4: Save the document

Save the refined text to `<folder>/<folder_name>.md` (markdown for
readability) or `<folder>/<folder_name>.txt` — alongside the images.

The output file name is the folder name. For example, a folder called
`the-impact-of-ai-on-home-prices/` produces
`the-impact-of-ai-on-home-prices/the-impact-of-ai-on-home-prices.md`.

### Step 5: Report to user

Report back:
1. **Output file** — path to the saved document
2. **Image count** — how many images were processed
3. **OCR engine** — which engine was used (PaddleOCR / EasyOCR)
4. **Raw word count** vs **Refined word count**
5. **Notable corrections** — any major fixes the LLM applied
   (e.g., fixed domain-specific terms, restored formatting)

## Language Selection

| User says | OCR engine | Best for |
|-----------|-----------|----------|
| "中文" / Chinese content | PaddleOCR (ch) | Chinese documents, mixed CJK |
| "英文" / English content | EasyOCR (en) | Clean English text, GPU accelerated |
| "auto" / mixed | Check filename conventions or ask user | When unsure, prefer PaddleOCR for mixed C/E |

When the language is ambiguous (folder name could be either), ask the
user before proceeding.

## Quality Gates

- MUST confirm image count and order with user before running OCR
- MUST save raw OCR output as `_raw_ocr_output.txt` for reference
- MUST run LLM refinement — raw OCR output is never the final result
- MUST save output alongside the source images (same folder)
- MUST report which OCR engine was used
- MUST handle missing/invalid image paths gracefully
- MUST clean up any temp files if created
- NICE: show a preview of the first image's OCR output before full run
- NICE: flag low-confidence OCR regions for manual review
- NICE: preserve paragraph breaks from original document layout

## Anti-Patterns

- Do NOT use raw OCR text as the deliverable — it contains errors
  that the LLM refinement step must fix
- Do NOT summarize or rephrase the content during refinement —
  fix errors, keep the original meaning
- Do NOT assume all images in a folder belong to the same document —
  verify with the user first
- Do NOT process images out of sort order — file order IS page order
- Do NOT skip language detection — wrong engine = poor accuracy
- Do NOT resize or downsample images before OCR — higher resolution
  yields better results

## Sources

- OCR engine selection: confidence medium — based on published accuracy
  benchmarks (PaddleOCR: 95%+ Chinese, EasyOCR: 88-93% Chinese / 92-95%
  English) and user preference
- Process design: confidence high — based on established OCR pipeline
  patterns (extract → combine → refine)
- Image sorting: confidence high — `ls -1v` natural sort matches common
  file naming conventions
