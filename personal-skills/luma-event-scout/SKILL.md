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

Scout Lu.ma for Bay Area events matching Cicidi's criteria. Output a dual-list (recommended + strongly not recommended) to `~/project/luma/events-{YYYY}-{MM}.md`. Every speaker is background-checked via maigret.

## Skill Dependencies

- `maigret`: used for speaker background checks — searches across social media, GitHub, and forums for username presence. Install: `pip install maigret`. Reference: https://github.com/soxoj/maigret

## Cicidi's Preferences (Persistent)

These are the default filters. Do not ask to reconfirm each time.

### Location
- **San Francisco** — primary
- **Peninsula + South Bay** — Palo Alto, Mountain View, Stanford, Menlo Park, Sunnyvale, Cupertino, San Jose, Santa Clara. Equal priority to SF. Many AI companies are HQ'd here.
- **East Bay** — Berkeley, Oakland — secondary, only if exceptional speaker

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

### Speaker Quality — Hard Gate (MUST)

For each speaker and host, run this checklist. Events that fail the hard gate are REJECTED.

**Hard gate (one must pass):**
- **牛校**: Stanford, Berkeley, MIT, CMU, Caltech, Harvard, 清华, 北大, Oxford, Cambridge, ETH Zurich, or equivalent top-tier CS/AI program
- **大厂**: FAANG (Meta/Google/Apple/Amazon/Netflix), Microsoft, OpenAI, Anthropic, DeepMind, Nvidia, top AI labs
- **知名独角兽/大公司**: senior role (VP+) at a company with real traction (Series B+, known product)

If the speaker has a 牛校 or 大厂 background, a niche/small product is fine — the speaker carries the event.

**Background check (MUST for every speaker/host):**
1. **maigret username search**: use maigret to search for the speaker's online presence
   ```bash
   maigret <username> --all-sites
   ```
   Maigret reference: https://github.com/soxoj/maigret
2. **LinkedIn**: role at notable company, career trajectory. "AI enthusiast" / "prompt engineer" / no verifiable experience → FAIL.
3. **GitHub**: active repos with original code, not just forks/tutorials. Check contributor graphs.
4. **Google Scholar / arXiv**: publications with citations.
5. **Company check**: is the company real? Revenue? Funding? User count? Or just a landing page?

**Automatic rejection signals:**
- Speaker has NO verifiable online presence beyond a Luma profile → FAIL
- Company website is a single landing page with no product → FAIL
- Product is a thin ChatGPT/Claude wrapper with no moat → FAIL
- Company has < 5 employees and no notable investors or revenue → FAIL
- Speaker's only credential is "AI founder" with no prior engineering/research role → FAIL

**Documentation**: for every speaker that passes, write evidence in the output card:
`牛校 Stanford CS PhD` or `大厂 Google Director` or `独角兽 VP at HeyGen (Series B, $100M+)`

### Product/Company Analysis (the "AI wrapper filter")

For events where a company/product is being presented or demoed, evaluate:

**Automatic downgrade signals:**
- Product is a thin wrapper around ChatGPT/Claude/Gemini API with no proprietary tech
- Product is easily replaced by a Claude custom instruction or open-source equivalent
- Company has negligible users/traction (check SimilarWeb, social media, app store ratings)
- Demo is a "vibe coded" prototype with no production deployment
- "AI-powered" buzzwords without a specific technical innovation

**Positive signals:**
- Proprietary models, data, or infrastructure that can't be replicated with an API call
- Real user base with retention (not just a waitlist or beta signup page)
- Published research, patents, or technical deep-dives
- Solving a genuinely hard problem (not "ChatGPT but for X industry")
- Open-source project with real community adoption

**Examples of rejects:**
- Notivta + Actionlayer — small user base, easily replaced by Claude Computer Use
- Magnific AI — narrow image upscaling, replaceable by open-source diffusion models
- Generic "AI meeting summarizer" — Claude/Gemini already does this natively

**Examples of genuine tech:**
- eBPF-based observability agents — kernel-level, not API-wrapper
- Custom speech/vision models trained on proprietary data
- MCP infrastructure with real security/auth layers
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
## 🟢 Recommended — Worth Your Time
| # | Event | Date | Speaker Credentials | Why |
|---|-------|------|-------------------|-----|

## 🔴 Strongly NOT Recommended — Waste of Time
| Event | Reason |
|-------|--------|
```

Each recommendation must include the speaker credential tag (e.g. "牛校 Stanford CS PhD", "大厂 Google Director").

Each rejected event must include a specific reason (e.g. "AI wrapper, no moat", "speaker背景不够 — no verifiable experience", "被 Claude 可直接替代").

## How to Scrape Luma

**CRITICAL**: Luma is a Next.js SPA. Dates and event names are NOT in the HTML source — they are client-rendered. WebFetch alone returns event cards without dates. The correct approach:

### Strategy 0: __NEXT_DATA__ JSON Extraction (MUST — primary method)

Every Luma page embeds a `<script id="__NEXT_DATA__" type="application/json">` tag with all event data including dates. Parse this JSON to get confirmed dates for ALL events in one call.

```bash
curl -s "https://luma.com/{page}" | python3 -c "
import sys, json, re
html = sys.stdin.read()
match = re.search(r'<script id=\"__NEXT_DATA__\" type=\"application/json\">(.*?)</script>', html)
data = json.loads(match.group(1))
fi = data['props']['pageProps']['initialData']['data']['featured_items']
for item in fi:
    ev = item.get('event', {})
    name = ev.get('name', '?')
    start = item.get('start_at', '?')
    geo = ev.get('geo_address_json', {}) or {}
    city = (geo.get('city', '') or '')
    going = item.get('guest_count', '?')
    url = ev.get('url', '')
    cal = (item.get('calendar', {}) or {}).get('name', '')
    print(f'{start[:10]} | {name} | {city} | {going} going | {cal}')
    print(f'  https://lu.ma/{url}')
"
```

**JSON field reference:**
- `featured_items[].start_at` — ISO 8601 date (e.g., `2026-07-28T23:00:00.000Z`)
- `featured_items[].event.name` — event title
- `featured_items[].event.geo_address_json.city` — city
- `featured_items[].event.geo_address_json.region` — state
- `featured_items[].guest_count` — attendee count
- `featured_items[].event.url` — URL slug
- `featured_items[].event.description_short` — short description
- `featured_items[].calendar.name` — host calendar/org

### Strategy 0a: Broad AI Category Search (MUST)

Search the full AI category and filter for Bay Area:

```
https://luma.com/ai        — ALL AI events globally; filter by city
https://luma.com/sf/ai     — SF AI events
```

**Bay Area city filter**: Parse the JSON, keep only events where `geo_address_json.city` matches:
`San Francisco`, `Palo Alto`, `Mountain View`, `Menlo Park`, `Sunnyvale`, `Santa Clara`, `San Jose`, `Cupertino`, `Berkeley`, `Oakland`, `Redwood City`, `South San Francisco`, `Foster City`, `Los Altos`, `Campbell`, `Milpitas`, `Fremont`, `San Mateo`, `Burlingame`

Also check the calendar's location field if geo_address_json.city is empty.

### Strategy 0b: Specific calendar pages (fallback)

Use the same `__NEXT_DATA__` JSON extraction on calendar pages:
```
https://luma.com/genai-sf              — Bond AI (largest, 130k+)
https://luma.com/sf-builders-collective — HackerSquad
https://luma.com/ls                    — Latent Space
https://luma.com/claudecommunity       — Claude/Anthropic events
```

### Strategy 1: WebFetch individual event pages (for speaker detail)
Use WebFetch on `https://lu.ma/{event-id}` to get the full description, speaker names, and venue address.
The description text contains the agenda and speaker info. Format: markdown.

### Strategy 2: Browser automation (for exhaustive search)
```bash
python3 ~/project/luma/scrape_luma.py
```

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

1. Fetch broad AI category pages first (`luma.com/sf/ai`, `luma.com/sf`) — do NOT limit to specific calendars
2. For each candidate event matching topic keywords, fetch the event detail page to confirm the date
3. Extract date, time, location, description, speakers from the detail page
4. **For every speaker and host**: run maigret username search, then check LinkedIn/GitHub/Google Scholar
5. **Apply hard speaker gate**: 牛校 or 大厂 or 知名独角兽VP+ → PASS. Neither → REJECT immediately
6. **Product analysis**: is this company real tech or an AI wrapper? Check for moat
7. Apply all remaining filters (timing, cost, topic, culture)
8. **Classify every event**: Recommended (with speaker credential tag) or Strongly NOT Recommended (with specific rejection reason)
9. Write dual-list output to `~/project/luma/events-{YYYY}-{MM}.md`
10. Load `~/project/luma/preferences.json` and apply learning
11. Present summary to user, ask for feedback
12. Record feedback and update preferences

## Anti-Patterns

- Do not include paid events without clearly calling them out
- Do not recommend events where speakers have no verifiable background
- Do not skip speaker background checks — this is the core value prop
- Do not skip maigret search for any speaker or host — every name must be checked
- Do not include pure-social events (parties, brunches, bar crawls)
- Do not recommend beginner-level content
- Do not recommend "AI wrapper" products (thin API layer, no moat, easily replaced by Claude/open-source)
- Do not recommend events from tiny companies with no traction unless the speaker has 牛校/大厂 credentials
- Do not rely only on specific calendars — always start with broad AI category search
- Do not recommend an event without a speaker credential tag on the output card
- Do not list an event in "Excluded" without a specific rejection reason

### Concrete Examples of Past Rejects

| Event/Company | Why Rejected |
|---------------|-------------|
| Notivta + ActionLayer | Product too small, low user count, easily replaced by Claude Computer Use |
| Magnific AI | Narrow image upscaling, replaceable by open-source diffusion models, small company |

## Test Scenarios

1. User says "find me AI events this month" — run full scout, output list
2. User says "+1, +3, -5" — record feedback, update preferences
3. User says "what's new this week" — re-scout, only show events since last run
4. User says "I like Deedy Das" — boost events with similar speakers
