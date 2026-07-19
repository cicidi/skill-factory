---
name: youtube-summarize
description: |
  Use when a YouTube video URL needs to be downloaded, transcribed, and
  summarized. Uses a three-tier approach: (1) fetch captions via API
  (fastest), (2) download audio + Whisper transcription + screenshot OCR
  for videos without captions, (3) metadata-only fallback. Raw transcripts
  are refined using video metadata and comments for accuracy, then saved
  as a clean document.
license: MIT
compatibility: claude-code
metadata:
  triggers:
    - summarize this youtube video
    - what is this video about
    - youtube summary
    - tl;dr this video
    - transcribe this video
    - what does this video say
    - get transcript of this video
  when_to_use: |
    When the user provides a YouTube URL and wants to understand the
    content without watching the full video. When extracting key points,
    insights, or actionable takeaways from a video. When researching
    competitor YouTube channels and analyzing their content strategy.
    When needing a clean corrected transcript of a video.
  when_not_to_use: |
    For short-form content (Shorts) under 60 seconds where description
    is sufficient. For very long videos (>2 hours) that would hit
    transcription time/cost limits. For content behind age-gates or
    private videos that cannot be accessed.
---

# youtube-summarize

Downloads, transcribes, and summarizes YouTube video content. The
pipeline has three data tiers plus a transcript refinement step that
uses video metadata and comments to correct Whisper/OCR errors before
producing the final document and summary.

## When to Use

- User provides a YouTube URL and asks "what is this video about?"
- User wants a TL;DR of a video without watching it
- User is researching competitor YouTube channels
- User needs key takeaways from a long-form video
- User wants to extract quotable statements or data points from a video
- User needs a clean corrected transcript for content repurposing
- User needs to decide whether a video is worth watching

## When NOT to Use

- Video is a YouTube Short under 60 seconds (description is sufficient)
- Video is over 2 hours long (would exceed reasonable processing time)
- User asks for a download or offline copy of the video
- Only usable for publicly available content

## Prerequisites

The following tools are used and should be available:
- `youtube-transcript-api` (Python) — for fetching captions
- `yt-dlp` — for downloading audio/video when no captions exist
- `ffmpeg` — for audio conversion and frame extraction
- `openai-whisper` — for audio transcription
- `easyocr` — for screenshot OCR (burned-in subtitles)

## Process

### Step 1: Extract video ID

Parse the YouTube URL to get the video ID (the `v=` parameter or
the path in shortened URLs like `youtu.be/VIDEO_ID`).

### Step 2: Extract metadata and comments

Use the Playwright browser to open the video page and extract:
- Video title
- Channel name and subscriber count
- View count and upload date
- Full video description (including timestamps)
- Top comments (sorted by relevance, top 20-30)

This data is used in two ways:
- **Tier 3 fallback**: if all transcription fails, summarize from
  metadata + comments alone
- **Transcript refinement**: even when transcription succeeds, metadata
  and comments provide context to correct errors

### Step 3: Transcribe (3 tiers, try in order)

#### Tier 1 — Captions API (fastest)

```python
from youtube_transcript_api import YouTubeTranscriptApi
ytt_api = YouTubeTranscriptApi()
transcript = ytt_api.fetch(video_id)
```

Works for most videos with captions enabled (manual or auto-generated).
Combine all snippets into one transcript with timestamps.

If successful, this is the ground truth — skip Tier 2.

#### Tier 2a — Audio download + Whisper transcription

If no captions available, download audio and transcribe:

1. Download audio using yt-dlp:
   ```
   yt-dlp -x --audio-format mp3 -o "/tmp/yt_audio_%(id)s.%(ext)s" <URL>
   ```

2. Transcribe with Whisper (uses GPU if available):
   ```python
   import whisper
   model = whisper.load_model("base")
   result = model.transcribe("/tmp/yt_audio.mp3")
   ```

#### Tier 2b — Screenshots + OCR (burned-in subtitles)

Some videos have hardcoded subtitles or important on-screen text:

1. Download a video segment and extract frames at intervals:
   ```
   ffmpeg -i /tmp/yt_video.mp4 -vf "fps=1/10" -q:v 2 \
     /tmp/yt_frames/frame_%04d.jpg
   ```

2. Run OCR on each frame:
   ```python
   import easyocr
   reader = easyocr.Reader(['ch_sim', 'en'], gpu=True)
   for img in sorted(frames):
       result = reader.readtext(img)
       text = " ".join([item[1] for item in result])
   ```

3. Merge with Whisper output when both available.

#### Tier 3 — Metadata-only fallback

If all transcription tiers fail, use only the metadata and comments
extracted in Step 2. This produces a summary but no transcript document.

### Step 4: Transcript refinement (LLM review & correct)

Whisper and OCR both produce errors, especially with:
- Mixed Chinese/English content (房贷专业术语)
- Accented speech or background noise
- Low-quality OCR from burned-in subs

The raw transcript CANNOT be used directly. Instead:

1. **Assemble context package:**
   - Raw transcript text (from Tier 1, 2a, or 2b)
   - Video title
   - Full video description
   - Top 20-30 viewer comments
   - Channel name and topic

2. **Prompt the LLM to review and correct:**
   ```
   You are a transcript editor. Below is:
   (A) A raw auto-generated transcript (may contain errors)
   (B) The video's description and title
   (C) Viewer comments discussing the content

   Task: Review the raw transcript, correct errors using context from
   (B) and (C), fix misheard terms (especially domain-specific jargon
   like mortgage terms, legal phrases, technical terms), and produce
   a clean, corrected transcript.

   Rules:
   - Do NOT change the speaker's voice or opinion
   - Do NOT add content not supported by the raw text
   - Flag uncertain corrections with [brackets]
   - Preserve timestamps if available
   - Output as clean plain text
   ```

3. **Output:** A corrected transcript document saved to a file.

### Step 5: Generate structured summary

From the corrected transcript (or from metadata + comments in Tier 3),
produce a structured analysis:

**Core Thesis**: One sentence on what the video is about.

**Key Points**: 3-7 bullet points covering the main arguments,
insights, or educational content.

**Target Audience**: Who would benefit from watching this.

**Actionable Takeaways**: Specific things viewers can do after
watching (if applicable).

**Notable Quotes / Data**: Striking statements or statistics from
the transcript.

### Step 6: Deliver output

Return to the user:
1. **Corrected transcript** — saved as a text file
2. **Structured summary** — inline markdown
3. **Processing report** — which tiers were used, duration, any notes on confidence

## Tier Selection Heuristic

| Condition | Tier | Speed (with GPU) |
|-----------|------|-----------------|
| Captions available | Tier 1 (API) | Fast (~2s) |
| No captions, has audio | Tier 2a (Whisper base) | Fast (~10-60s) |
| Burned-in subs only | Tier 2b (screenshot+OCR) | Medium (~30-120s) |
| Audio + burned-in subs | Tier 2a + 2b combined | Medium (~60-180s) |
| Everything fails | Tier 3 (metadata only) | Fast (~2s) |

Recommendation: For most videos, run Tier 2a (Whisper). Only add
Tier 2b (OCR) when you know the video has important on-screen text
or burned-in subtitles. The refinement step (Step 4) always runs
after Tier 2a/2b to clean up errors.

## Quality Gates

- MUST attempt Tier 1 (captions API) before any download approach
- MUST extract metadata + comments before refinement step
- MUST run transcript refinement after any Tier 2 transcription
- MUST report which tier(s) were used in the output
- MUST handle Chinese and English content
- MUST clean up temp files (audio, frames) after processing
- MUST warn user before processing videos over 1 hour
- NICE: save corrected transcript to a file for user to reuse
- NICE: note low-confidence corrections with [brackets]

## Anti-Patterns

- Do NOT use raw Whisper/OCR output as the final transcript (always
  refine with LLM using metadata + comments as context)
- Do NOT run OCR on every frame — sample at reasonable intervals
- Do NOT process videos over 2 hours without user confirmation
- Do NOT fabricate information in the transcript during refinement
- Do NOT keep downloaded audio or frame files after processing
- Do NOT attempt Tier 2b unless Tier 2a produced sparse results
  or user confirms burned-in subs exist
