---
name: video-production-pip-style
description: |
  Replicate the Andrei Jikh video production style: clean talking-head
  background + heavy Picture-in-Picture citations (74% of runtime) with
  external images, video clips, news articles, and data charts. Speaker
  shrinks to a small bottom-right PiP box when citing sources. Includes
  equipment, DaVinci Resolve workflow, and frame-by-frame production
  checklist.
license: MIT
compatibility: claude-code
metadata:
  triggers:
    - make a video like andrei jikh
    - pip video production
    - picture in picture youtube style
    - video production skills
    - youtube video production
    - 视频制作风格
    - andrei jikh style
  when_to_use: |
    When producing a research-driven YouTube video that requires heavy
    use of external citations (images, clips, articles, data) while
    keeping the presenter on screen. Best for opinion/analysis content
    where the presenter reacts to and comments on source material.
    The core format: talking head intros → PiP-cited content → conclusion.
  when_not_to_use: |
    For pure talking-head vlogs (no citations needed). For screen recording
    / tutorial content (different format). For videos with minimal editing
    (this style requires significant post-production).
---

# video-production-pip-style

Produce YouTube videos in the Andrei Jikh style — a clean, citation-heavy
format where the speaker talks to camera on a minimal background, then
**shrinks to a small bottom-right corner box** (Picture-in-Picture / PiP)
while the main screen shows external content:

- News articles and headlines
- Other YouTube video clips
- Charts and data visualizations
- Images and photographs
- Social media posts

> **Style DNA:** ~74% of runtime is PiP-mode. The speaker's face never
> disappears — it stays visible reacting to content, which creates a
> personal connection even during heavy citation segments.

## Analysis Source

This skill is based on frame-by-frame analysis (185 frames @ 1/10s) of:
- **Video:** "China Is About To Pop The AI Bubble"
- **Creator:** Andrei Jikh
- **Duration:** 30:47
- **Style Classification:**
  - Picture-in-Picture: **74%**
  - Talking Head (full-frame): **6%**
  - Fullscreen Content (no speaker): **2%**
  - Clean BG transitions: **4%**
  - Other: **14%**

## Equipment Required

### Minimal Setup (Starting)
| Item | Purpose |
|------|---------|
| Webcam (1080p minimum) | Face capture |
| Plain background (wall or backdrop) | Clean talking head shots |
| Good softbox/key light x2 | Even facial lighting |
| Lapel mic | Clean audio |
| Computer (for editing) | DaVinci Resolve or Premiere |

### Recommended Setup
| Item | Purpose |
|------|---------|
| DSLR/Mirrorless camera | Higher quality face capture |
| Green screen + 3-point lighting | Flexible background replacement |
| Teleprompter app/device | Script reading while looking at lens |
| High-quality condenser mic | Professional audio |
| 2+ monitors | One for script, one for production |

## Background Setup

**The source video does NOT use green screen.** The background is a
physical light gray backdrop (~rgb 192-240). This gives a clean, studio
look without chroma-key artifacts.

### Option A: Physical Backdrop (Recommended for Simplicity)
- Use a matte light gray or white backdrop
- Light it evenly with 2 softboxes (one on each side, 45° angle)
- Keep the speaker 3-6 feet from the backdrop to avoid shadows
- Result: clean, professional, no keying needed

### Option B: Green Screen (Recommended for Flexibility)
- Use a green screen with 3-point lighting
- Key out in post-production
- Replace with your chosen background:
  - **Light gray gradient** (most like Andrei Jikh)
  - **Custom branded background** with logo/colors
  - **Subtle animated background** (moving gradients, particle effects)
  - **Blurred office/bookshelf** (if you have a real background)
- Keying settings in DaVinci Resolve: 3D Keyer → Qualifier on green →
  Clean Black/White → Spill suppression

### Background Color Palette (from analysis)
The primary background color is:
- Light talking-head segments: `rgb(192-240, 192-240, 192-240)` — soft gray
- Content/PiP segments: dark `rgb(0-48, 0-48, 0-48)` — black/dark gray

Your custom background should:
- Be clean and uncluttered
- Have enough contrast with your skin/hair tone
- NOT be busy/distracting (the content IS the visual interest)
- Use colors that match your brand

## PiP Setup: How It Works

### PiP Position
**97% of PiP shots are in the BOTTOM-RIGHT corner** of the screen.

PiP metrics:
- PiP box size: ~25-30% of screen width, ~20-25% of screen height
- PiP shape: Rounded rectangle (soft corners)
- PiP border: Thin white or no border (the content behind provides separation)
- Content fills the full screen behind PiP

### When to Use PiP vs Full Talking Head

| Scene Type | Format | When |
|------------|--------|------|
| Intro / Hook | Full talking head | First 30-60 seconds |
| Transition / Setup | Full talking head | New section starts |
| Citing a source | PiP + fullscreen content | Showing article, clip, chart |
| Reacting to content | PiP + fullscreen content | Video clip, tweet, quote |
| Emotional moment | Full talking head | Serious conclusion, opinion |
| Data deep-dive | PiP + fullscreen chart | Showing stats and graphs |
| Conclusion | Full talking head | Wrap-up, CTA |

## Production Workflow

### Phase 1: Script with Citation Markers

Write your script with embedded `[PIP]` markers at every point where
you'll show external content:

```
[FULL] The AI industry is spending $300B this year.
      But here's what nobody is talking about...
[PIP] According to this Bloomberg report, Chinese companies
      are building data centers at 3x the speed.
      <show Bloomberg article screenshot>
[FULL] This changes everything for American tech.
[PIP] Look at this chart from McKinsey...
      <show chart>
```

**Citation density target:** Every 10-30 seconds, a new visual.
The content should feel fast-paced and visually rich.

### Phase 2: Record Talking Head

1. Set up your background and lighting
2. Record the FULL script as a talking head (no content yet)
3. Use a teleprompter for smooth delivery
4. Record in highest quality possible (4K if available)
5. Keep eye contact with the lens
6. Gesture naturally — your hands won't be visible in PiP but
   your upper body language matters

### Phase 3: Gather Citation Materials

Collect all the content you'll show:
- Screenshots of articles (full pages, not cropped)
- News headlines
- Data charts (create in Canva/Flourish if needed)
- Video clips from other sources
- Social media posts/screenshots
- Your own graphics and callouts

Organize them in folders matching your script sections.

### Phase 4: PiP Edit in DaVinci Resolve

#### Step-by-Step:

1. **Import** your talking head video and all citation materials

2. **Timeline setup** (for each section):
   ```
   Track 1: Citation content (full screen images/clips)
   Track 2: Talking head (scaled down)
   ```

3. **Create PiP effect:**
   - Place your talking head clip on Track 2
   - Go to Inspector → Transform
   - Set Zoom to **50-55%** (shrink to ~1/4 size)
   - Set Position: X = **+700 to +800**, Y = **+400 to +500**
     (bottom-right corner — exact values depend on your resolution)
   - Add Rounded Corners: **10-15px** radius
   - Add Border: **2px white border** (optional, looks cleaner)

4. **Place citation content** on Track 1 (full screen below PiP)
   - Images: Zoom to fill screen
   - Video clips: Mute original audio, use your voiceover
   - Charts: Add as stills or short video zooms

5. **Transitions:**
   - Talking head → PiP: Add **0.5s cross dissolve** on the shrink
   - Between citations: **Hard cuts** (Andrei's style is minimal transitions)
   - New section starts: **0.5s cross dissolve** back to full talking head

#### PiP Keyframes (for smooth shrink animation):

When transitioning from full head to PiP:

```
Frame 0: (full screen) Scale=100%, X=960, Y=540
Frame 5: (shrinking)   Scale=55%,  X=800, Y=450
Frame 10: (in place)   Scale=55%,  X=780, Y=420
```

Use ease-in/ease-out for smooth motion.

### Phase 5: Audio & Polish

1. **Voiceover levels:** -6dB to -3dB average
2. **Background music:** Low drone/ambient, -25dB, duck during speech
3. **Citation text overlays:** Small source labels at bottom (e.g.,
   "Source: Bloomberg, July 2026" in 12pt white text)
4. **Highlight callouts:** When pointing to something in a citation,
   add a subtle yellow circle/arrow animation (0.5s duration)
5. **Color grade:** Slightly warm tone (+200K temp) for talking head
6. **Export:** 1080p or 4K, 24fps or 30fps

## DaVinci Resolve PiP Macro

To make PiP faster, create a macro:

1. Right-click your PiP clip → Create Compound Clip
2. Add to Effects → Macros → Save as "PiP Bottom-Right"
3. Now you can drag-and-drop the PiP macro onto any clip

Macro settings to include:
- Transform: Scale 55%, Position X+780, Y+420
- Rounded corners: 15px
- Border: 2px white

## Citation Source Labeling

Add small source labels to every citation. Andrei Jikh style:
- Position: Bottom of screen, slightly left of PiP
- Font: Sans-serif, 12-14pt
- Color: White with semi-transparent black background
- Format: "Source: [Publication Name] — [Date]"
- Duration: Match the citation on screen
- Animation: Fade in with the citation

## Background Tips (Your Specific Questions)

> "Background做的很清晰。是不是我们可以用绿色背景，然后用别的替换？"

Yes! You have two paths:

**Path A — Physical Backdrop (no green screen):**
Easier, less post-production. Get a matte gray/white backdrop cloth
($30-50 on Amazon) and light it evenly. This is what Andrei does.

**Path B — Green Screen (more flexible):**
Use a green screen, then replace with:
- Your branded background (gradient in your brand colors — green could work!)
- A subtle animated background
- A blurred office/library
- Clean gray gradient (matching Andrei's look)

> "是不是我们可以用绿色背景"

If you want a **green backdrop** as your signature brand color:
1. Use green screen only for keying
2. Replace with a **solid green gradient** (your brand green, not
   chroma-key green) at ~30% saturation so it doesn't distract
3. Add subtle vignette or lighting effect to make it look intentional

## Frame-by-Frame YouTube Playbook

### Opening (0:00-1:00)
```
[00-10s] Full talking head: Hook / big claim
[10-20s] PiP: Shocking statistic or headline
[20-30s] PiP: Continue showing evidence
[30-40s] Full talking head: Context setup
[40-50s] PiP: Another data point
[50-60s] PiP: Visual evidence
```

### Body Section Pattern (Repeating)
```
[Full head, 10-20s] → Thesis statement
[PiP, 20-40s] → Show 2-3 citations supporting the point
[Full head, 10s] → Your analysis/opinion on what was shown
[PiP, 20-40s] → Show counter-argument or alternative data
[Full head, 10s] → Synthesis / takeaway
```

### Ending (Last 60s)
```
[Full head] Emotional/strong conclusion
[Full head] Call to action (subscribe, comment)
[Full head] What to watch next
```

## Checklist

### Pre-Production
- [ ] Write script with [FULL] and [PIP] markers
- [ ] Gather all citation materials (articles, clips, charts)
- [ ] Create custom background (if using green screen)
- [ ] Test lighting and audio levels

### Production
- [ ] Record all talking head segments (one continuous take)
- [ ] Record any additional voiceovers
- [ ] Capture screen recordings if needed
- [ ] Export citation clips/images

### Post-Production
- [ ] Import all footage into timeline
- [ ] Apply PiP effect to sections marked [PIP]
- [ ] Key out green screen (if using)
- [ ] Apply background replacement
- [ ] Add citation source labels
- [ ] Add callouts/highlights on key data
- [ ] Add background music
- [ ] Mix audio levels
- [ ] Color grade talking head
- [ ] Add intro/outro screens
- [ ] Export final video

## Common Anti-Patterns

- **PiP too large:** Speaker box should be ≤25% of screen. Bigger = amateur.
- **PiP too small:** Should still be recognizable. Test at mobile size.
- **No source labels:** Viewers need to know where citations come from.
- **Static PiP:** Animate the shrink (ease in/out) or it looks jarring.
- **Busy background:** If there's content AND PiP, the background behind
  PiP should not have competing text/faces in that corner.
- **One citation per minute:** The style demands HIGH citation density.
- **No speaker reaction:** In PiP, nod, react, gesture — you're still
  the presenter, not a passive face in the corner.

## Exit Criteria

The video is complete when:
1. Every script section with `[PIP]` has corresponding PiP edit
2. Every citation has a visible source label
3. PiP animations are smooth (not jarring)
4. Audio is clean (no background noise, consistent levels)
5. The final export plays correctly at 1080p
6. Total runtime matches the planned script length

## Companion Resources

- `youtube-research-pipeline` — For research and script writing
- `pic-to-txt` — OCR images to text for research
- `doc-organize` — Organize research docs and citations
