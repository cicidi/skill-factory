---
name: transcribe-audio
description: |
  Use when converting audio files (m4a, mp3, wav, webm) to text
  transcripts using local Whisper on GPU. Use when the user says
  "transcribe this", "convert audio to text", "make a transcript",
  or when Phase 1 of create-video-workflow encounters audio material.
  No API key needed — runs entirely on local hardware.
---

# transcribe-audio

Converts audio files to text transcripts using the local Whisper CLI on GPU.
Handles m4a, mp3, wav, and other common audio formats. No API key, no cloud
cost — all processing happens on local hardware. Outputs plain text, SRT
subtitles, or TSV with timestamps.

## When to Use

- User drops an m4a/mp3/wav file and wants a transcript
- Phase 1 of create-video-workflow encounters audio-only source material
- A video file needs its audio track extracted and transcribed
- Batch transcription of multiple audio files in a directory

## When NOT to Use

- The content is already text — just read it
- YouTube video with existing captions — fetch captions directly via yt-dlp instead
- Need speaker diarization (who said what) — Whisper CLI doesn't label speakers; use a diarization tool or the OpenAI API for that
- Need perfect accuracy on heavy accents or noisy audio — local Whisper may struggle; consider API-based alternatives
- GPU not available — Whisper on CPU is very slow; use a smaller model (`tiny` or `base`)

## Example Spectrum

- **Lite:** `whisper recording.m4a --model tiny --output_format txt --output_dir .` → quick rough transcript, under 1 minute on GPU
- **Standard:** `whisper podcast.m4a --model medium --language en --output_format txt --output_dir ./transcripts/` → accurate transcript for clear English audio
- **Full:** extract audio from `interview.mp4` via ffmpeg → `whisper audio.mp3 --model large --language zh --output_format srt --output_dir ./output/` → Chinese subtitles with timestamps

---

## Process

### Step 0: GPU check

Confirm GPU is available before running. Whisper on CPU is 5-10× slower.

```bash
nvidia-smi 2>/dev/null | head -3 || echo "No GPU detected — will be slow, use --model tiny or base"
```

### Step 1: Handle input

**Must:**
1. If input is a video file (mp4, webm, mkv), extract audio first:
   ```bash
   ffmpeg -i input.mp4 -vn -acodec libmp3lame -q:a 2 /tmp/audio_for_transcribe.mp3
   ```
   Then transcribe the extracted audio.
2. If input is m4a/mp3/wav, pass directly to Whisper.
3. For batch (multiple files), loop with a simple bash script.

**Output:** confirmed audio file ready for transcription.

**Fallback:** if ffmpeg not available, tell user to extract audio manually.

### Step 2: Transcribe

Run local Whisper CLI:

```bash
whisper <audio-file> \
  --model <model> \
  --output_format txt \
  --output_dir <output-dir> \
  --language <lang>          # optional, auto-detect if omitted
```

**Model selection:**

| Model | VRAM | Speed | Accuracy | When |
|-------|------|-------|----------|------|
| `tiny` | ~1GB | Fastest | Low | Quick preview, checking if audio is usable |
| `base` | ~1GB | Fast | Basic | Clear audio, simple content |
| `small` | ~2GB | Medium | Decent | Podcasts, meetings |
| `medium` | ~5GB | Slower | Good | Default for most transcripts |
| `large` | ~10GB | Slowest | Best | Heavy accents, mixed languages, noisy audio |
| `turbo` | ~6GB | Fast | Near-large | Best speed/accuracy balance (if installed) |

Default: `medium` for English, `large` for Chinese or mixed-language audio. User can override.

**Output formats:**

| Flag | Output | Use case |
|------|--------|----------|
| `--output_format txt` | Plain text | Reading, searching |
| `--output_format srt` | Subtitles with timestamps | Video captions |
| `--output_format tsv` | Tab-separated with timestamps | Programmatic processing |
| `--output_format all` | All formats | Full coverage |

### Step 3: Clean up transcript

Whisper's raw output may have artifacts:
1. Strip the trailing silence markers and repeated phrases (Whisper sometimes loops on silence).
2. If the transcript reads as one long block, break into paragraphs at natural pauses (look for timestamp gaps or sentence endings in the TSV).
3. Remove Whisper's hallucinated captions (e.g., "Subtitles by...", "Thanks for watching") if they appear.

### Step 4: Present

Write transcript to output. Present:
- Word count, estimated reading time
- Language detected
- First 10 lines as preview
- Option to re-run with a different model or language flag

**Fallback:** if transcript looks wrong (wrong language, garbled text), re-run with `--language` explicitly set.

---

## Quality Gates

- [ ] GPU available or user warned about CPU speed
- [ ] Audio file exists and is readable
- [ ] Output file is non-empty and contains coherent text
- [ ] Language matches expectations (spot check first few lines)

## Sources

- Whisper CLI: https://github.com/openai/whisper — confidence high, open-source, installed locally
- Original openai-whisper skill: `/home/cicidi/project/openclaw/skills/openai-whisper/SKILL.md` — adapted pattern
