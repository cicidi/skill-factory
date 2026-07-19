---
name: youtube-research-pipeline
description: |
  Use when turning any topic into a complete YouTube video package:
  deep research via 3 parallel subagents, advocate debate, conversational
  transcript, and interactive HTML page. The HTML is the sole deliverable —
  a readable article embedding transcript, data visualizations (Chart.js),
  and research screenshots. Follows doc-organize conventions for output.
license: MIT
compatibility: claude-code
metadata:
  triggers:
    - make a youtube video research
    - research pipeline for video
    - turn this topic into a video
    - research → transcript → html
    - youtube content pipeline
    - 做个视频研究
    - 一条龙视频制作
  when_to_use: |
    When a topic (any topic) needs to go end-to-end from research to
    YouTube-ready HTML. Best for research-heavy content that benefits
    from data visualizations, screenshots, and a balanced perspective.
    The pipeline has 5 phases and outputs a single self-contained HTML page.
  when_not_to_use: |
    For quick one-off research without video output — use inline research
    instead. For pure OCR without video pipeline — use pic-to-txt. For
    editing an existing video script — edit the HTML directly. For
    topics that need zero data visualization.
---

# youtube-research-pipeline

End-to-end pipeline that turns any topic into a scrollable, video-ready
HTML article. Runs deep research via 3 parallel subagents, stress-tests
findings with advocate debate, then produces a single self-contained HTML
page that embeds the conversational transcript, Chart.js data animations,
and embedded research screenshots.

## When to Use

- You have a topic and want a complete YouTube video package from scratch
- You have existing research / images that need deep enrichment + video script
- You need data visualized as animated charts inside a readable article
- You want a balanced, debated perspective (not just one-sided reporting)
- You want all outputs organized per doc-organize conventions

## When NOT to Use

- Quick research without video output — just do inline search
- Only need OCR on images — use pic-to-txt skill instead
- Editing an existing script — edit the HTML file directly
- Topic with zero data to visualize — overkill, skip the pipeline

## Pipeline Overview

```
User Topic / Image Folder
        │
        ▼
Phase 0: Pic-to-Txt (conditional)
  If images provided → OCR to text
  If text already exists → skip
        │
        ▼
Phase 1: Deep Research (3 parallel subagents)
  ┌──────────────────────────────────────────┐
  │ Agent A: Academic & Research Papers      │
  │  • Scholar, SSRN, NBER, arXiv           │
  │  • Screenshot key tables/charts          │
  ├──────────────────────────────────────────┤
  │ Agent B: Industry & Market Data          │
  │  • Moody's, BLS, Fed, Zillow, FHFA      │
  │  • Screenshot data dashboards            │
  ├──────────────────────────────────────────┤
  │ Agent C: News, Policy & Trends           │
  │  • Latest news, layoffs, policies       │
  │  • Screenshot articles                   │
  └──────────────────────────────────────────┘
        │
        ▼
Phase 1b: Aggregate Research
  Merge → dedup → cross-validate sources
        │
        ▼
Phase 2: Advocate Debate
  Challenge conclusions, find counter-evidence
        │
        ▼
Phase 3+4: HTML Production
  Combine research + debate + screenshots → single HTML
  AI autonomously picks chart type from data shape
  Writes conversational transcript (10-20 min / ~2500-5000 words)
        │
        ▼
Phase 5: Organize Outputs
  doc-organize conventions
```

## Process

### Phase 0: Pic-to-Txt (Conditional)

If the user provides a folder of images (screenshots, scanned slides):

```bash
python3 ~/project/skill-factory/personal-skills/pic-to-txt/ocr.py <folder> --lang auto
```

If text already exists (research doc, notes), skip this phase entirely.

### Phase 1: Deep Research (3 Parallel Subagents)

Launch 3 agents concurrently. Each receives the same topic + existing research
context but has a different research lens:

**Agent A — Academic & Research Papers:**
- Search: Google Scholar, SSRN, NBER, arXiv, JSTOR
- Find: papers on the topic from 2024-2026
- Capture: key findings, data points, methodology
- Screenshot: important tables, figures, regression results (save to `screenshots/`)
- Output raw findings to `raw/agent-academic-output.md`

**Agent B — Industry & Market Data:**
- Search: Moody's, BLS, Federal Reserve, Zillow, FHFA, Freddie Mac, industry reports
- Find: current statistics, forecasts, market data
- Capture: specific numbers, rankings, trends
- Screenshot: data dashboards, report excerpts (save to `screenshots/`)
- Output raw findings to `raw/agent-industry-output.md`

**Agent C — News, Policy & Trends:**
- Search: Google News, Reuters, Bloomberg, government announcements
- Find: recent events, policy changes, company actions, real-world cases
- Capture: concrete examples, quotes, timelines
- Screenshot: news articles (save to `screenshots/`)
- Output raw findings to `raw/agent-news-output.md`

**All 3 agents MUST:**
- Cite every data point with a URL source
- Screenshot key visuals via Playwright MCP (`browser_navigate` → `browser_take_screenshot`)
- Return structured findings, not philosophical musings

### Phase 1b: Aggregate Research

After all 3 agents complete, run a 4th agent to:

1. Read all 3 raw outputs
2. Merge findings (deduplicate overlapping data)
3. Cross-validate sources (if two agents found same stat, confidence is higher)
4. Flag contradictions between sources
5. Write:
   - `research/YYYY-MM-DD-<topic>-research.md` — clean, structured research doc
   - `research/YYYY-MM-DD-<topic>-research.evidence.md` — all source URLs with annotations

### Phase 2: Advocate Debate

Launch an agent with devil's advocate instructions:

1. Read the merged research doc
2. For each major claim/conclusion, attempt to refute:
   - Is the data cherry-picked? What does the full picture show?
   - Are the methodology assumptions questionable?
   - What would a skeptic say about this conclusion?
   - Are there alternative interpretations of the same data?
3. Find specific counter-evidence (web search for opposing views)
4. Write:
   - `raw/advocate-discussion/YYYY-MM-DD-advocate-debate.md`

### Phase 3+4: HTML Production (Transcript + Page)

This is the core creative phase. Launch an agent to produce the final HTML:

**Content Rules:**
- Conversational, spoken-word tone (like explaining to a friend)
- 10-20 minutes reading time (~2500-5000 words)
- Structure: hook → context → key findings (with data + visuals) → counterpoint →
  conclusion → sources
- No academic jargon unless explained casually
- Every data point has a visible source citation (small text/superscript)

**Chart Selection (AI autonomous decision):**
Examine the research data and pick the best visualization:

| Data shape | Chart type |
|------------|-----------|
| Time series (dates + values) | `line` — trend over time |
| Categorical rankings | `bar` — compare magnitudes |
| Percentages summing to 100% | `doughnut` or `polarArea` — composition |
| Multiple series comparison | `bar` grouped — side-by-side |
| Large single value comparison | `bar` horizontal — easy reading |
| Geographic data (MSAs, states) | Formatted table with color bars |

All charts use Chart.js with animation (duration: 1000ms, easing: easeOutQuart).

**Technical Requirements:**
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Topic — YouTube Research</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    /* Mobile-first responsive design */
    /* Large readable fonts (18px+ body text) */
    /* Smooth scroll behavior */
    /* Dark/light mode via prefers-color-scheme */
  </style>
</head>
```

**Output file:** `prd/presentation.html`

### Phase 5: Organize Outputs

Create INDEX.md entry and ensure all files follow the structure:

```
docs/initiatives/<topic>/
├── raw/
│   ├── agent-academic-output.md
│   ├── agent-industry-output.md
│   ├── agent-news-output.md
│   └── advocate-discussion/
│       └── YYYY-MM-DD-advocate-debate.md
├── research/
│   ├── YYYY-MM-DD-<topic>-research.md
│   └── YYYY-MM-DD-<topic>-research.evidence.md
├── prd/
│   └── presentation.html          ← ★ Single deliverable
├── screenshots/                   ← Research screenshots
├── slides/                        ← Original images (if OCR was used)
└── _raw_ocr_output.txt            ← OCR raw output (if applicable)
```

---

## Quality Gates

- Phase 0 MUST complete before Phase 1 (if images exist)
- Phase 1 MUST launch all 3 subagents concurrently (not serial)
- Phase 1 MUST wait for all 3 agents before running aggregation
- EVERY data point in research MUST have a source URL
- Screenshots MUST be taken for key data visuals (not just linked)
- Advocacy MUST produce at least one counter-argument per major claim
- HTML MUST be valid (no broken tags, no 404 images)
- HTML MUST use Chart.js for data animations
- Transcript MUST be conversational (read it aloud to verify)
- HTML MUST be readable on mobile (responsive CSS)
- All files MUST follow doc-organize path conventions
- NICE: include a dark mode CSS preference

## Anti-Patterns

- Do NOT run subagents serially — parallelism is critical for speed
- Do NOT use raw research as the HTML content — must rewrite in conversational tone
- Do NOT skip advocate debate — one-sided content reduces credibility
- Do NOT hardcode chart types — let the agent decide based on data shape
- Do NOT create separate HTML and transcript files — transcript lives IN the HTML
- Do NOT leave data uncited — every number needs a source

## Companion Scripts

- `pic-to-txt:ocr.py` — OCR image folder to text (used in Phase 0)

## Exit Criteria

The pipeline is complete when:
1. `prd/presentation.html` exists and is valid
2. All research docs are saved with sources
3. Advocate debate is documented
4. INDEX.md is updated with all outputs

## Sources

- Architecture design: confidence high — based on successful patterns from
  pic-to-txt, doc-organize, and contrarian-review skills
- Phase 1 parallelism: confidence high — 3 independent subagents + aggregator
  is a standard fan-out pattern
- HTML chart selection: confidence medium — agent judgment needed to match
  data shape to chart type; may need iteration
- doc-organize integration: confidence high — follows established conventions
