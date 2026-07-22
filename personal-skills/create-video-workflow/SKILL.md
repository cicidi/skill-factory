---
name: create-video-workflow
description: |
  Use when converting research documents into audience-tailored content —
  presentations, social-media videos, websites, or multi-format packages.
  Use when asked to "make a video", "create a presentation from these docs",
  "turn research into a talk", or "build content from this material".
  A 7-phase, human-in-the-loop pipeline with audience-agent validation
  and CI/CD deploy to distribution channels.
---

# create-video-workflow

Converts research documents into audience-tailored content through a 7-phase,
human-in-the-loop pipeline. Every output is validated by a simulated audience
agent before going live. Existing Python tools under `tools/` handle
video/image generation; new phases add channel-aware planning, flexible
transcript generation, multi-format output, and CI/CD deploy.

## When to Use

- The user has research docs, notes, papers, or reference materials
- The user wants a presentation, video, website, or multi-format content from those materials
- The output channel matters: YouTube, social media, internal company docs, or GitHub demos each need a distinct style
- The user wants audience validation before publishing
- The user wants content deployed to a distribution channel

## When NOT to Use

- The user already has a finished script and just needs a 30-60s short-form video assembled — use the old 5-step flow in the git history of this file, or invoke the individual tools directly
- The user wants a one-shot text summary — summarization skills handle that
- The materials are a single PDF with no presentation intent — use a simpler extraction pipeline

## Example Spectrum

These show the range of what this skill handles — a lite single-format request, a standard video request, and a full multi-format request — so the AI can interpolate between them.

- **Lite (simple):** "Turn these meeting notes into a team slide deck" → Phase 0 channel=internal, audience=team. Phase 1-2 plan a few slides. Phase 3 transcript is professional. Phase 4 generates slides. Phase 6 minimal (skim validation). Phase 7 push to internal docs.
- **Standard (video):** "Make a YouTube video from this research paper" → Phase 0 channel=YouTube, audience=general public, goal=explain the finding. Full 7-phase pipeline with video toolchain, audience agent watches the video, Phase 7 uploads.
- **Full (multi-format):** "Build everything from this product spec — a launch video, a landing page, and internal docs" → Phase 0 maps three channels. Phase 2 plans video + website + docs as parallel units. Phase 4 parallel generation with different engines per type. Phase 5 assembles a package. Phase 6 validates each channel separately. Phase 7 deploys to all three.

## Skill Dependencies

- `doc-organize`: used in Phase 4 when generating document assets (determines path + naming, maintains INDEX.md)

---

## Phase 0: Channel & Audience (Requirements Document)

Goal: produce a requirements document that answers: what are we saying, to whom, and where?

**MUST:**
1. Ask the user: where will this content be distributed? Options: YouTube, social media (抖音/TikTok/公众号), internal company docs, conference talk, GitHub demo, website, or multi-channel.
2. For each channel, determine: audience expertise level, expected detail depth, tone constraints, platform-specific format requirements.
3. Co-draft a **Goal statement** — one paragraph that captures the core message. This becomes the validation target in Phase 6.
4. Write the requirements document to `projects/<name>/requirements.md` with:
   - Channels and audience profiles
   - Goal statement
   - Success criteria (what does the audience walk away knowing or feeling?)
   - Scope: what's in, what's out

**Output:** `projects/<name>/requirements.md`

**Fallback:** if the user can't articulate the goal, walk through examples: "Is this a tutorial? A pitch? A technical deep-dive? An announcement?" Narrow to one primary channel before proceeding.

---

## Phase 1: Source Ingestion

Goal: gather and normalize all input materials.

**MUST:**
1. Identify all input sources: markdown notes, PDF files, URLs (papers, articles, YouTube links, GitHub repos, internal company docs).
2. For each source type, extract readable text:
   - markdown / text: read directly
   - PDF: extract text (use an available PDF tool)
   - YouTube: fetch transcript if available
   - Web URLs: fetch and convert to text
   - GitHub: read README, relevant docs
   - Internal company docs: treat as markdown or PDF
3. Consolidate into `projects/<name>/source_material.md` — a single normalized document with content summaries, links to originals, and flagged gaps.

**Output:** `projects/<name>/source_material.md`

**Fallback:** for sources that can't be ingested (paywalled, audio-only, dead links), flag in a `gaps` section and ask the user whether to proceed without or find alternatives.

---

### Checkpoint 1 — Source Review

**STOP. Human-in-the-loop. No generation until user says "continue".**

Present:
- Source inventory (what was ingested, what was skipped)
- Coverage assessment: does the material support the Phase 0 Goal? Any obvious gaps?
- Ask: "Is this enough material, or do we need to add anything?"

User can add more sources, remove irrelevant ones, or confirm and proceed.

---

## Phase 2: Content Plan (Design)

Goal: produce a flexible content outline — not a rigid template.

**MUST:**
1. Based on the Goal (Phase 0) and source material (Phase 1), draft a content plan:
   - Output types: video segments, slide deck, markdown document, website, animated clips, or any mix the channel demands
   - Scene/structure list: a numbered sequence of content units (not forced to 6 scenes — can be 2 slides, 1 video, 3 markdown sections, etc.)
   - For each unit: type, topic, key point, approximate length or word count
2. Write `projects/<name>/content_plan.md` with the structure.
3. Present to user: "This is the outline. Does this flow cover what we need?"

**Output:** `projects/<name>/content_plan.md`

**Fallback:** if the user rejects the plan, iterate. If stuck, fall back to a simple linear structure (intro → body → conclusion) and let Phase 3 refine it.

---

## Phase 3: Transcript → Spec

Goal: produce a channel-aware, spoken/conversational transcript and a structured spec that Phase 4 generators can consume.

The spec document is the equivalent of a software spec — Phase 4's code reads it as input.

**MUST:**
1. Write `projects/<name>/transcript.md`: the spoken/conversational text, in the channel's tone.
   - YouTube: engaging, personal, creator-style
   - 抖音/社交媒体: short, punchy, hook-driven
   - 公司内部: professional, clear, team-appropriate
   - 会议演讲: slides-oriented, oral delivery
   - GitHub demo: technical, demo-flow
   - The transcript is NOT academic prose — it is written to be heard and seen, not read silently.
2. Write `projects/<name>/spec.json`: the structured specification consumed by Phase 4 generators. One entry per content unit from Phase 2. Each entry contains:
   - `unit_id`, `type` (video / slide / markdown / website / image / animation)
   - `source_text`: the transcript segment for this unit
   - `on_screen_text`: text that appears on screen / slide
   - `visual_description`: what the audience sees (for image/video/animation generators)
   - `voiceover`: spoken text (for video)
   - `engine`: preferred generation engine — `seedance` / `gemini` / `chatgpt` / `ffmpeg` — based on the unit type and format
   - `format`: output dimensions or format constraints
3. For each unit, confirm: does it advance the Goal from Phase 0?

**Output:** `projects/<name>/transcript.md` + `projects/<name>/spec.json`

**Fallback:** if the transcript feels too stiff for the channel, ask the user to read a segment aloud — what trips them up? Rewrite that segment.

---

### Checkpoint 2 — Transcript Review

**STOP. Human review of transcript and spec.**

- Present transcript in the channel's tone. User can edit any segment.
- Review the spec: are all units covered? Any missing visual descriptions?
- Discuss: "Does this sound right for the channel? Anything to add or cut?"
- User says "continue" to proceed.

---

## Phase 4: Asset Generation (Implementation)

Goal: parallel generation of all assets specified in `spec.json`. Existing Python tools handle video/image; new generators handle slides, markdown, websites.

**MUST:**
1. For each unit in `spec.json`, dispatch to the appropriate generator:
   - `type: video` → use existing toolchain: `tools/gen_narrative.py` + `tools/gen_scenes.py` + `tools/gen_images.py` + `tools/gen_videos.py` + `tools/poll_tasks.py`
   - `type: image` → `tools/gen_images.py` (standalone) or direct API call to chosen engine
   - `type: slide` → generate slide content (markdown with slide separators)
   - `type: markdown` → use `doc-organize` to determine path and naming, then write the document
   - `type: website` → generate HTML/CSS/JS files
   - `type: animation` → generate animation prompt for chosen engine
2. All asset generation runs in parallel where the engine supports it. The existing video toolchain has its own internal parallelism (images can generate in parallel; videos are sequential with last-frame chaining).
3. Write generated assets to `projects/<name>/output/<type>/`.
4. Track generation status in `projects/<name>/gen_status.json`.

**Output:** all generated assets in `projects/<name>/output/`

**Fallback per generator:**
- Video: if Seedance fails, retry / skip the scene / mark for manual redo
- Image: retry with adjusted prompt or fall back to a placeholder
- Slide/Markdown/Website: if generation produces garbled output, regenerate with a simplified prompt
- Document (doc-organize): if type/path can't be determined, place in `projects/<name>/output/` and ask user for preferred location

---

### Checkpoint 3 — Asset Review

**STOP. Human review of every generated asset.**

- Videos: watch each clip. User can say "redo scene N" with notes.
- Images: review each image. User can request adjustments.
- Slides: review content. User can edit in place.
- Markdown/Website: review for accuracy and style.
- User says "continue" to proceed to composition.

---

## Phase 5: Composition (Build)

Goal: assemble all reviewed assets into the final output package.

**MUST:**
1. For each output type, apply the appropriate composition:
   - Video: `tools/concat.sh` normalizes and concatenates all scene clips
   - Slide deck: compile slides into a single presentation file
   - Markdown document: insert generated images/videos as links or placeholders
   - Website: assemble pages, link assets, ensure navigation
   - Mixed multi-format: produce a package directory with all formats and an index
2. Write the final output to `projects/<name>/output/final/`.
3. Generate a `projects/<name>/output/final/README.md` listing all outputs.

**Output:** final assembled content in `projects/<name>/output/final/`

**Fallback:** if composition fails on a specific type, produce what assembled and flag the rest for manual assembly.

---

## Phase 6: Validation (Audience Agent)

Goal: simulate the target audience and verify the Goal from Phase 0 was achieved.

**MUST:**
1. Launch an **audience agent** — an independent AI instance configured with the audience profile from Phase 0's requirements document.
2. The audience agent must be able to:
   - Read text content (slides, markdown, transcripts)
   - Watch video content (describe what is seen and heard)
   - Listen to audio (if voiceover is generated separately)
3. The audience agent produces:
   - A **review/观后感**: what impression did the content leave? Was it engaging? Clear? Did anything confuse?
   - A **summary**: what was the main takeaway? Does it match the Phase 0 Goal statement?
4. Present the audience agent's review and summary to the user.
5. Compare the agent's summary against the Phase 0 Goal statement. If there's a gap — the agent took away something different from the intended message — identify which phase needs revision and loop back.

**Output:** `projects/<name>/output/final/audience_review.md`

**Fallback:** if the audience agent's review shows a misalignment, go back to the phase that introduced the gap:
- Goal not clear → Phase 0 (refine goal statement)
- Missing examples or evidence → Phase 1 (add source material)
- Structure issue → Phase 2 (revise content plan)
- Tone or clarity issue → Phase 3 (rewrite transcript)
- Visual mismatch → Phase 4 (regenerate specific assets)

---

### Checkpoint 4 — Validation Review

**STOP. Human reviews audience agent feedback.**

- Present audience agent review + summary side-by-side with the Phase 0 Goal statement.
- User decides: "pass" (proceed to deploy), or "revise" (go back to the identified phase).
- User says "continue" to proceed to deploy.

---

## Phase 7: Deploy (CI/CD Pipeline)

Goal: publish the validated content to the distribution channels specified in Phase 0.

**MUST:**
1. For each channel, execute the release:
   - YouTube: upload video via YouTube Data API (or manual upload with instructions, if API unavailable)
   - 抖音/TikTok: upload via platform API (or export with platform-optimized format)
   - Internal company docs: push to the company documentation system (Confluence, Notion, etc.)
   - GitHub: commit and push to the target repository, create a release
   - Website: deploy to the target hosting platform
2. Generate `projects/<name>/output/final/release_notes.md` listing: what was published, where, when, and links to live content.
3. Verify each deployment: confirm the content is accessible at the target URL.

**Output:** published content at target channels + `projects/<name>/output/final/release_notes.md`

**Fallback:** for channels without API access, produce export-ready files and instructions for manual upload. For channels with API failures, retry once then flag for manual handling.

---

## Error Handling

On any phase failure:
- Stop at the current phase. Do not proceed to the next.
- Flag the error in `projects/<name>/errors.md`.
- Offer options: retry, skip this unit, revise requirements, or abort.

## Quality Gates

Before proceeding past each checkpoint, confirm:
- Phase 0: Goal statement is explicit and measurable
- Phase 1: All sources ingested or gaps acknowledged
- Phase 2: Content plan covers the Goal
- Phase 3: Transcript matches the channel tone; spec covers every unit
- Phase 4: All assets generated or failures documented
- Phase 5: Composition complete and verified
- Phase 6: Audience agent summary aligns with Phase 0 Goal
- Phase 7: All target channels confirmed live or export-ready

## Test Scenarios

### Scenario 1: Research paper → YouTube video
**Input:** "Turn this research paper PDF into a YouTube explainer video"
**Expected:** Phase 0 sets channel=YouTube, audience=general public, goal=explain the key finding accessibly. Phase 1 ingests the PDF. Phase 2 plans video segments with hook, body, takeaway. Phase 3 writes a conversational YouTube script. Phase 4 generates video via existing toolchain. Phase 5 concats to final MP4. Phase 6 audience agent confirms the explanation was clear. Phase 7 uploads to YouTube.

### Scenario 2: Internal docs → team presentation
**Input:** "Create a team presentation from these internal docs and meeting notes"
**Expected:** Phase 0 sets channel=internal company, audience=engineering team. Phase 1 ingests docs and notes. Phase 3 transcript is professional but not academic. Phase 4 generates slides + markdown handout. No video needed. Phase 7 deploys to internal docs system.

### Scenario 3: GitHub repo → demo website
**Input:** "Build a demo landing page from this GitHub repo"
**Expected:** Phase 0 sets channel=website, audience=developers evaluating the project. Phase 1 reads README and key files. Phase 4 generates HTML/CSS. Phase 7 deploys to hosting.

## Sources

- Phase 0-2 (Requirements + Design): confidence high — modeled on software development lifecycle, adapted for content creation
- Phase 3 (Transcript → Spec): confidence high — channel-aware tone profiles derived from platform conventions
- Phase 4 (Asset Generation): confidence high — existing toolchain at `tools/` (gen_narrative.py, gen_scenes.py, gen_images.py, gen_videos.py, poll_tasks.py, concat.sh, extract_frame.py) for video/image; new generators for slides/markdown/website/animation
- Phase 5 (Composition): confidence high — ffmpeg for video; template-based assembly for other formats
- Phase 6 (Validation): confidence medium — audience agent concept depends on quality of simulated audience prompt
- Phase 7 (Deploy): confidence medium — platform API availability varies; manual-upload fallback included
