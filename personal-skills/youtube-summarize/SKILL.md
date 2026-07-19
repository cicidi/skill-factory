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

### Step 3: Tier 2 — Download audio + Whisper (slow)

If no captions are available, use the fallback pipeline:

1. Download audio using yt-dlp with the browser's YouTube cookies:
   ```
   yt-dlp --cookies /tmp/yt_cookies.txt -x --audio-format mp3 \
     -o "/tmp/yt_audio_%(id)s.%(ext)s" <URL>
   ```

2. Transcribe using Whisper:
   ```python
   import whisper
   model = whisper.load_model("tiny")  # tiny for speed
   result = model.transcribe("/tmp/yt_audio.mp3", language="zh")
   ```

3. Use the transcribed text as the transcript.

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

| Condition | Tier | Speed |
|-----------|------|-------|
| Captions available | Tier 1 (API) | Fast (~2s) |
| No captions, <30 min | Tier 2 (Whisper) | Medium (~30-120s) |
| No captions, 30min+ | Tier 2 with tiny model | Slow (~2-5min) |
| Both fail | Tier 3 (metadata fallback) | Fast (~2s) |

## Quality Gates

- MUST attempt captions API before downloading audio
- MUST report which tier was used in the output
- MUST handle Chinese and English content
- MUST clean up temp files after processing
- NICE: detect video language automatically for Whisper
- NICE: show processing progress to user

## Anti-Patterns

- Do NOT download audio when captions are readily available
- Do NOT process videos over 2 hours without warning the user
- Do NOT fabricate information not present in the transcript
- Do NOT keep downloaded audio files after processing
