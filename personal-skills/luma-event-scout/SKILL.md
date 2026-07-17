---
name: luma-event-scout
description: |
  Use when the user wants to scout AI/tech events on Luma in the Bay Area that match specific criteria (weekend/weekday-evening timing, advanced topics, notable speakers, free admission). Use when user asks "find me events", "what's happening in SF", "scout Luma", or "search for AI meetups". Handles scraping, filtering by speaker quality (GitHub/LinkedIn check), topic level, cost, and generates a ranked event list in ~/project/luma/ with feedback-based preference learning.
license: MIT
compatibility: opencode
metadata:
  triggers:
    - "find events on luma"
    - "scout luma"
    - "search luma events"
    - "ai events sf"
    - "bay area meetups"
    - "what's happening in sf"
  when_to_use: |
    User asks for event recommendations in Bay Area/SF. User wants AI/tech lectures, talks, or demos (not pure networking). User has constraints on timing, cost, speaker quality, and topic depth.
  when_not_to_use: |
    User asks about non-tech events (concerts, parties). User wants events outside Bay Area. User is looking for purely social/networking events with no substantive content.
---

# Luma Event Scout

Scout Lu.ma for Bay Area events matching Cicidi's criteria. Output a ranked list to `~/project/luma/events-{YYYY}-{MM}.md`. Learn from feedback to optimize future searches.

## Cicidi's Preferences (Persistent)

These are the default filters. Do not ask to reconfirm each time.

### Location
- San Francisco, Peninsula, South Bay (Palo Alto, Mountain View, Stanford, San Jose)
- East Bay (Berkeley, Oakland) — secondary, only if exceptional

### Time Range
- Only search events within **1 month** from the current date. Ignore events beyond this window.

### Timing
- Weekends (Sat/Sun) — highest priority
- Weekdays (Mon-Fri) after 4:00 PM
- Weekdays before 4:00 PM — skip unless extraordinary speaker

### Event Type
- Lectures, talks, fireside chats, demos, paper discussions
- NOT: pure networking mixers, parties, happy hours (unless there's a substantive talk)
- NOT: beginner workshops ("Intro to...", "Learn Python/AI from scratch")
- Hackathons — acceptable if topic is advanced and relevant

### Speaker Quality (the "bullshit filter")
For each speaker, do at least 2 of these checks:
1. **GitHub** — active repos, meaningful projects, not just forks/tutorials
2. **LinkedIn** — role at notable company or founder with traction, not "AI enthusiast"
3. **Education** — strong CS/AI program (Stanford, Berkeley, MIT, CMU) is a plus
4. **Publications** — papers, patents, or well-known blog posts
5. **Company affiliation** — FAANG, top AI lab, well-funded startup (Series A+)

Passing criteria: At least one of the above is strongly positive. Small company leads are fine if they have GitHub/paper credentials.

### Topic Requirements
Must be advanced or intermediate-advanced. Reject these signals of beginner content:
- Phrase "no experience required" or "beginners welcome"
- Title starts with "Introduction to..." or "Learn the basics of..."
- Agenda covers installing tools, hello-world examples

Preferred topics (in priority order):
1. AI agents, autonomous workflows, deterministic agent systems **(highest — Cicidi builds ai-coworker)**
2. LLM architecture, model routing, token economics, inference optimization
3. Agent memory, tool use, MCP, agent-computer interfaces
4. Software engineering + AI (code generation, SWE-bench, deterministic code)
5. AI safety, alignment, philosophy of AI
6. Animation, VFX, computer graphics + AI
7. Healthcare, biotech, drug discovery + AI
8. AI infrastructure, databases, systems

### Cost
- Free only. Reject any event with a ticket price.

### Cultural Filter
- Reject events that are exclusively in Chinese (title/description in Chinese → skip)

## Auto-Registration (Playwright)

When the user approves an event (reply `+N register`), use Playwright to auto-register.

### User Profile for Form Filling

| Field | Value |
|-------|-------|
| Name | Walter Chen |
| Title/Company | Staff Engineer, Intuit |
| Email | walterchen.ca@gmail.com |
| GitHub | https://github.com/cicidi/ |
| Project | https://github.com/cicidi/ai-coworker |
| Phone | 352-281-8555 |

### Registration Script

Write and run a Playwright Python script at `~/project/luma/register_event.py`:

```python
from playwright.sync_api import sync_playwright

EVENT_URL = "https://lu.ma/{event-id}"
PROFILE = {
    "name": "Walter Chen",
    "title": "Staff Engineer, Intuit",
    "email": "walterchen.ca@gmail.com",
    "github": "https://github.com/cicidi/",
    "project": "https://github.com/cicidi/ai-coworker",
    "phone": "352-281-8555"
}

def register():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        page = browser.new_page()
        page.goto(EVENT_URL)
        # Luma typically shows a "Register" / "Request to Join" button
        # After clicking, a modal form appears
        # Fill name, email, answer questions (use GitHub + project as "why attend")
        ...
```

### Registration Strategy
1. Navigate to event URL
2. Click the register/RSVP button ("Register", "Request to Join", "Save a spot")
3. Fill the registration form:
   - Name: "Walter Chen"
   - Email: walterchen.ca@gmail.com
   - If asked "What do you do?" or "Company": "Staff Engineer at Intuit"
   - If asked "Why do you want to attend?" or "About you": "Building ai-coworker (https://github.com/cicidi/ai-coworker) — a deterministic workflow system for AI agents. Interested in {relevant event topic}."
   - If asked "GitHub": "https://github.com/cicidi/"
   - If asked "LinkedIn": "https://linkedin.com/in/walterchen"
   - Phone (if asked): "352-281-8555"
4. Submit and confirm registration was successful
5. Report result to user

### Pre-check before registering
- Verify event is still within 1 month
- Verify event is free
- Confirm user approval was given for this specific event
- Do NOT register without explicit user approval (NEVER auto-register autonomously)

## Output Format

Save to `~/project/luma/events-{YYYY}-{MM}.md`. Each event is a **card** using a nested two-column table for wide terminal display:

```markdown
### N. [Event Name](https://lu.ma/{event-id})

| | |
|---|---|
| **时间** | Date, day of week, time (e.g. "Jul 14 Mon 6:30pm") |
| **地点** | Venue, neighborhood (e.g. "Notion HQ, SoMa SF") |
| **内容** | 2-3 line summary of what the event covers |
| **类型** | talk / hackathon / meetup / demo / fireside-chat / paper-reading |
| **演讲人/主办方背景** | Speaker credentials: company, role, GitHub stars, publications. Evidence-backed. |
| **What to do** | Concrete action: "Request approval", "Join waitlist (已满)", "直接到场" |
| **报名人数** | Count from Luma page (e.g. "643 Going") |
```

Each card uses a nested `| \| \|` table so cell content can span the full terminal width. Each event gets a horizontal rule separator.

After all cards, add:
```markdown
## Excluded
| Event | Reason |
|-------|--------|

## Reply
+N = interested, +N register = auto-register, -N = pass
```

## How to Scrape Luma

Luma is a Next.js SPA — dates are client-rendered. Use these strategies:

### Strategy 1: WebFetch individual event pages
Use the WebFetch tool on `https://lu.ma/{event-id}`. The description text contains the agenda which often includes times. Format: markdown.

### Strategy 2: Browse calendar pages
Fetch `https://lu.ma/{calendar-url}` for these high-signal calendars:
| Calendar | URL | Focus |
|----------|-----|-------|
| Bond AI SF | genai-sf | Largest AI community, 130k+ |
| SF Builders Collective | sf-builders-collective | Tech builders |
| Latent Space | ls | AI paper club, meetups |
| Big Brain Lectures | Big-Brain-SF | Paid lectures ($25-27), skip if free only |
| Claude Community | claudecommunity | Claude/Anthropic events |
| Frontier Tower | frontiertower | Frontier tech in SF |
| South Park Commons | southparkcommons-events | -1 to 0 community |
| H Company | hcompany.ai | AI agent research |

Also check: `sf`, `sf-ai`, `ai`

### Strategy 3: For exhaustive search, use browser automation
When the user explicitly asks for exhaustive search, recommend running:
```bash
python3 ~/project/luma/scrape_luma.py
```
(Provide a Playwright script that logs into Luma and scrapes event cards with dates.)

### Strategy 4: Check known high-signal event pages directly
When the user asks for "what's good right now", check specific event pages from the Bond AI calendar that appear on the `/genai-sf` page.

## Preference Learning

The skill maintains a preference file at `~/project/luma/preferences.json`:

```json
{
  "last_updated": "2026-07-10",
  "liked_topics": [],
  "disliked_topics": [],
  "liked_speakers": [],
  "disliked_speakers": [],
  "liked_formats": [],
  "disliked_formats": [],
  "min_relevance": 3,
  "feedback": []
}
```

After each list is generated:
1. Ask user: "Reply with `+N` (interested in event N) or `-N` (pass on event N)."
2. Record feedback in preferences.json
3. For future searches, boost events similar to liked ones, penalize disliked patterns

## Process

1. Fetch Luma AI category page and Bond AI calendar to discover event IDs
2. For each candidate event matching topic keywords, fetch the event detail page
3. Extract date, time, location, description, speakers from the detail page
4. For top candidates: search speaker background (LinkedIn, GitHub, Google Scholar)
5. Apply all filters (timing, cost, speaker quality, topic, culture)
6. Score and rank remaining events
7. Write output to `~/project/luma/events-{YYYY}-{MM}.md`
8. Load `~/project/luma/preferences.json` and apply learning
9. Present summary to user, ask for feedback
10. Record feedback and update preferences

## Anti-Patterns

- Do not include paid events without clearly calling them out
- Do not recommend events where speakers have no verifiable background
- Do not skip speaker background checks — this is the core value prop
- Do not include pure-social events (parties, brunches, bar crawls)
- Do not recommend beginner-level content

## Test Scenarios

1. User says "find me AI events this month" — run full scout, output list
2. User says "+1, +3, -5" — record feedback, update preferences
3. User says "what's new this week" — re-scout, only show events since last run
4. User says "I like Deedy Das" — boost events with similar speakers
