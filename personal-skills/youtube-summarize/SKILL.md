---
name: youtube-summarize
description: |
  Use when a YouTube video URL needs to be downloaded, transcribed, and
  summarized. Uses a three-tier approach: (1) fetch captions via API
  (fastest), (2) download audio + Whisper transcription (for videos
  without captions), (3) fall back to page metadata only. Produces a
  structured summary of the video's content.
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
  when_to_use: |
    When the user provides a YouTube URL and wants to understand the
    content without watching the full video. When extracting key points,
    insights, or actionable takeaways from a video. When researching
    competitor YouTube channels and analyzing their content strategy.
  when_not_to_use: |
    For short-form content (Shorts) under 60 seconds where description
    is sufficient. For very long videos (>2 hours) that would hit
    transcription time/cost limits. For content behind age-gates or
    private videos that cannot be accessed.
---

# youtube-summarize

Downloads, transcribes, and summarizes YouTube video content using a
three-tier approach: caption API (fastest), audio download + Whisper
transcription (for videos without captions), or page metadata fallback.

## When to Use

- User provides a YouTube URL and asks "what is this video about?"
- User wants a TL;DR of a video without watching it
- User is researching competitor YouTube channels
- User needs key takeaways from a long-form video
- User wants to extract quotable statements or data points from a video
- User needs to decide whether a video is worth watching

## When NOT to Use

- Video is a YouTube Short under 60 seconds (description is sufficient)
- Video is over 2 hours long (would exceed reasonable processing time)
- User asks for a download or offline copy of the video
- Only usable for publicly available content

## Prerequisites

The following tools are used and should be available:
- `youtube-transcript-api` (Python) — for fetching captions
- `yt-dlp` — for downloading audio when no captions exist
- `ffmpeg` — for audio conversion
- `openai-whisper` — for audio transcription

## Process

### Step 1: Extract video ID

Parse the YouTube URL to get the video ID (the `v=` parameter or
the path in shortened URLs like `youtu.be/VIDEO_ID`).

### Step 2: Tier 1 — Fetch captions via API (fast)

```python
from youtube_transcript_api import YouTubeTranscriptApi
ytt_api = YouTubeTranscriptApi()
transcript = ytt_api.fetch(video_id)
```

This works for the majority of videos that have captions enabled
(manual or auto-generated). Combine all snippet texts into one
transcript string with timestamps.

If successful, skip to Step 4.

### Step 3: Tier 2a — Download audio + Whisper transcription

If no captions are available, download the audio and transcribe it:

1. Download audio using yt-dlp with browser cookies:
   ```
   yt-dlp --cookies /tmp/yt_cookies.txt -x --audio-format mp3 \
     -o "/tmp/yt_audio_%(id)s.%(ext)s" <URL>
   ```

2. Transcribe using Whisper (uses GPU if available — much faster):
   ```python
   import whisper
   model = whisper.load_model("base")  # "tiny|base|small|medium|large"
   result = model.transcribe("/tmp/yt_audio.mp3")
   ```

3. Use the transcribed text. For multilingual videos, let Whisper
   auto-detect the language or specify with `language="zh"`.

### Step 3b: Tier 2b — Screenshots + OCR (for burned-in subtitles)

Some videos have hardcoded subtitles burned into the video frames.
In that case, extract frames and run OCR:

1. Download a short segment of the video and extract frames at
   regular intervals using ffmpeg:
   ```
   ffmpeg -i /tmp/yt_audio.mp3 -vf "fps=1/10" -q:v 2 \
     /tmp/yt_frames/frame_%04d.jpg
   ```
   (1 frame every 10 seconds — adjust based on subtitle cadence)

2. Run OCR on each frame using EasyOCR (supports Chinese + English):
   ```python
   import easyocr
   reader = easyocr.Reader(['ch_sim', 'en'], gpu=True)
   for img in sorted(frames):
       result = reader.readtext(img)
       text = " ".join([item[1] for item in result])
   ```

3. Combine OCR results chronologically, deduplicate overlapping
   text, and merge into a subtitle-like transcript.

4. Merge with Whisper output (Tier 2a) for the most complete
   result — Whisper captures spoken audio, OCR captures burned-in
   text that Whisper might miss (diagrams, on-screen captions).

### Step 4: Summarize

Feed the full transcript (or a size-limited excerpt for very long
videos) to the LLM for structured analysis. Produce:

**Core Thesis**: One sentence on what the video is about.

**Key Points**: 3-7 bullet points covering the main arguments,
insights, or educational content.

**Target Audience**: Who would benefit from watching this.

**Actionable Takeaways**: Specific things viewers can do after
watching (if applicable).

**Notable Quotes / Data**: Striking statements or statistics from
the transcript.

### Step 5: Present

Format as clean markdown. Include:
- Video title and channel name
- Video link
- Tier used (caption API / audio transcription / metadata only)
- Duration of transcript processing
- Structured summary

## Tier Selection Heuristic

| Condition | Tier | Speed (with GPU) |
|-----------|------|-----------------|
| Captions available | Tier 1 (API) | Fast (~2s) |
| No captions, has audio | Tier 2a (Whisper base) | Fast (~10-60s with GPU) |
| Burned-in subs only | Tier 2b (Screenshot+OCR) | Medium (~30-120s) |
| Both audio + burned-in subs | Tier 2a + 2b combined | Medium (~60-180s) |
| Everything fails | Tier 3 (metadata) | Fast (~2s) |

Recommendation: For most videos, run Tier 2a (Whisper). Only add Tier 2b
(OCR) when you know the video has important on-screen text or
burned-in subtitles that Whisper won't capture.

## Quality Gates

- MUST attempt Tier 1 (captions API) before any download-based approach
- MUST report which tier(s) were used in the output
- MUST handle Chinese and English content for both Whisper and OCR
- MUST clean up temp files (audio, frames) after processing
- MUST warn user before processing videos over 1 hour
- NICE: try combined Whisper + OCR for best results
- NICE: detect video language automatically

## Anti-Patterns

- Do NOT run OCR on every frame — sample at reasonable intervals (1/10s)
- Do NOT process videos over 2 hours without user confirmation
- Do NOT fabricate information not present in the transcript
- Do NOT keep downloaded audio or frame files after processing
- Do NOT attempt Tier 2b (OCR) unless user confirms burned-in subs exist
  or Tier 2a produced sparse results
