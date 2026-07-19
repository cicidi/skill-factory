---
name: youtube-summarize
description: |
  Use when a YouTube video URL needs to be summarized. Opens the video,
  extracts key information from the page, and produces a structured
  summary covering core thesis, key points, and actionable takeaways.
license: MIT
compatibility: claude-code
metadata:
  triggers:
    - summarize this youtube video
    - what is this video about
    - youtube summary
    - tl;dr this video
  when_to_use: |
    When the user provides a YouTube URL and wants to understand the
    content without watching the full video. When extracting key points,
    insights, or actionable takeaways from a video. When deciding whether
    to watch a video based on its content summary.
  when_not_to_use: |
    For summarizing short-form content (Shorts) under 60 seconds - the
    description alone is usually sufficient. For timecodes-only extraction
    without content summarization. For downloading or transcribing videos
    without user permission.
---

# youtube-summarize

Summarizes YouTube video content by opening the video page in a browser,
extracting the description, comments, and visual content, then producing
a structured summary.

## When to Use

- User provides a YouTube URL and asks "what is this video about?"
- User wants a TL;DR of a video without watching it
- User is researching competitors and wants to understand their content
- User needs key takeaways from a long-form video
- User wants to decide whether a video is worth watching

## When NOT to Use

- Video is a YouTube Short under 60 seconds (description is sufficient)
- User asks for a download or offline copy of the video
- User wants a verbatim transcript rather than a summary
- The tool should be used ethically - only summarize publicly available content

## Process

### Step 1: Navigate to the video

Open the YouTube video URL using the browser navigate tool.

### Step 2: Extract metadata

Read the video page snapshot to extract:
- Video title
- Channel name and subscriber count
- View count
- Upload date
- Video description
- Key timestamps from the description

### Step 3: Summarize

Produce a structured summary containing:

**Core Thesis**: One sentence on what the video is about.

**Key Points**: 3-7 bullet points covering the main arguments,
insights, or educational content.

**Target Audience**: Who would benefit from watching this.

**Actionable Takeaways**: Specific things viewers can do after
watching (if applicable).

**Notable Quotes or Statistics**: Striking data points or quotes
from the video description or content.

### Step 4: Present

Format the summary as clean markdown with the video title as the
heading. Include a link to the original video.

## Quality Gates

- MUST extract the video title, channel name, and view count
- MUST produce at least 3 key points
- MUST present in markdown format
- NICE: identify the video format (educational, vlog, interview,
  tutorial, review)

## Anti-Patterns

- Do NOT watch the full video end-to-end if the description already
  contains sufficient detail
- Do NOT fabricate information not present in the page content
- Do NOT summarize content behind age-gates or private videos
