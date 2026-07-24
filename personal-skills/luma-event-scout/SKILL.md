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
- Hackathons — acceptable, same bar as talks. Topic must be advanced and relevant. Speaker/judge gate still applies. Additional hackathon-specific gates:
  - **Prize pool**: must include cash or gift cards (Amazon, Visa, etc.). Reject events that only offer "platform credits" or "API credits" as prizes — these are product-testing exercises, not real hackathons.
  - **Host quality**: must be hosted by a 大厂 (FAANG, OpenAI, Nvidia, etc.) or a 知名 startup (Series B+, known product). Reject hackathons from tiny companies using participants as free product testers. Check: would this company exist in 2 years? If not, skip.
  - **Bounty hunter signal**: cash prize pool $1K+ is a positive signal — attracts serious competitors, good networking.

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

Read personal info from `~/.person_info.md`. This file contains Name, Email, Company, Title, GitHub, LinkedIn, Phone, and Project description. Use these values when filling registration forms — do NOT hardcode them.

### Registration Script

Write and run a Playwright Python script at `~/project/luma/register_event.py`:

```python
from playwright.sync_api import sync_playwright

EVENT_URL = "https://lu.ma/{event-id}"
# Load from ~/.person_info.md — do NOT hardcode personal info

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

### Registration Form Filling Rules

1. **Personal info**: read from `~/.person_info.md`. Resume link = LinkedIn URL. Twitter/X = N/A unless user has one.
2. **Unknown fields**: guess reasonably based on context. If unsure, fill `N/A`. Never leave a field blank — blank fields block submission.
3. **Select dropdowns**: try keyword match first, then pick first non-placeholder option, then N/A.
4. **Checkboxes**: always check terms/consent boxes.
5. **Verification (MUST)**: after submitting, verify the page shows "You're going", "Pending approval", or "Request submitted". Then go to `https://luma.com/events` (user's my-events page) and confirm the event appears with Approved or Pending status. If not visible, redo the registration.

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

## How to Scrape Luma — Method Evolution

Four approaches were tried. Only #4 works comprehensively.

| # | Method | Result |
|---|--------|--------|
| 1 | WebFetch calendar pages | ❌ No dates — Luma is a client-rendered SPA |
| 2 | `__NEXT_DATA__` JSON extraction | ⚠️ Only first ~20 events (server-rendered). Misses events deeper in the scroll |
| 3 | Playwright infinite scroll + DOM extraction | ❌ Calendar date headers and event cards live in separate DOM trees — can't reliably associate. Script returned 0 |
| 4 | **`api.luma.com/calendar/get-items`** | ✅ The endpoint Luma's own frontend calls on scroll. Public (no auth), paginated JSON, all fields included. Combined with calendar chaining (seed → extract sub-calendar IDs → fetch all), finds 150+ events from 39+ calendars |

**Lesson**: don't fight the SPA. Find the API the SPA itself calls. Add `User-Agent` + `Referer` headers to avoid 403.

```
GET https://api.luma.com/calendar/get-items?calendar_api_id={id}&pagination_limit=50
Headers: User-Agent: Mozilla/5.0, Referer: https://luma.com/
Paginates via next_cursor in response.
```

Each event has: `name`, `start_at`, `end_at`, `geo_address_json.city`, `url`, `calendar_api_id`, `guest_count` (on the entry, not the event).

### Strategy 0: Calendar API — comprehensive (MUST)

This is the primary method. It finds ALL events, not just 20.

```python
import urllib.request, json

def fetch_calendar(calendar_id):
    events = []
    cursor = None
    for _ in range(20):
        url = f"https://api.luma.com/calendar/get-items?calendar_api_id={calendar_id}&pagination_limit=50"
        if cursor: url += f"&pagination_cursor={cursor}"
        req = urllib.request.Request(url)
        req.add_header("User-Agent", "Mozilla/5.0")
        req.add_header("Referer", "https://luma.com/")
        data = json.loads(urllib.request.urlopen(req, timeout=15).read())
        entries = data.get("entries", [])
        if not entries: break
        for entry in entries:
            ev = entry.get("event", {})
            events.append({
                "name": ev.get("name","?"),
                "start": ev.get("start_at","?"),
                "city": (ev.get("geo_address_json",{}) or {}).get("city",""),
                "cal_id": ev.get("calendar_api_id",""),
                "url": f"https://lu.ma/{ev.get('url','')}",
                "going": entry.get("guest_count", 0)
            })
        cursor = data.get("next_cursor")
        if not cursor: break
    return events
```

### Strategy 0a: Calendar discovery (chain from aggregators)

Start with these aggregator calendars, then chain-discover sub-calendars:

```python
# Step 1: Start with Bond AI (largest Bay Area aggregator)
SEED_CALENDARS = [
    "cal-JTdFQadEz0AOxyV",  # Bond AI - San Francisco and Bay Area (130k+ members)
]

# Step 2: Fetch all sub-calendars referenced in Bond AI events
bond_events = fetch_calendar("cal-JTdFQadEz0AOxyV")
sub_calendars = set()
for e in bond_events:
    if e['cal_id']: sub_calendars.add(e['cal_id'])

# Step 3: Also check these additional known calendars
EXTRA_CALENDARS = [
    "cal-8lGTG3I2eA8rS2p",  # HackerSquad (SF Builders Collective)
    "cal-EVJ0XV6EJegxAT7",  # tokens& (SwarmHack)
    "cal-T3QXfRpK0pBwYqX",  # Founders Bay (You.com hackathons)
]
sub_calendars.update(EXTRA_CALENDARS)

# Step 4: Fetch ALL calendars, deduplicate by URL
all_events = {}
for cid in sub_calendars:
    for e in fetch_calendar(cid):
        if e['url'] not in all_events:
            all_events[e['url']] = e
```

**Calendar discovery is iterative**: each new calendar you fetch may reference new `calendar_api_id` values. Chain-discover until no new IDs appear.

### Strategy 0b: Bay Area + date filtering

```python
WINDOW_DAYS = 10  # from current date
BAY_AREA_CITIES = ['san francisco','palo alto','mountain view','menlo park',
    'sunnyvale','santa clara','san jose','cupertino','berkeley','oakland',
    'redwood city','south san francisco','foster city','los altos','campbell',
    'milpitas','fremont','san mateo','burlingame']

window_start = datetime.now().strftime('%Y-%m-%d')
window_end = (datetime.now() + timedelta(days=WINDOW_DAYS)).strftime('%Y-%m-%d')

bay_events = []
for e in all_events.values():
    city = e['city'].lower()
    in_window = window_start <= e['start'][:10] <= window_end
    in_bay = any(c in city for c in BAY_AREA_CITIES) or city == ''  # include unknown city
    if in_window and in_bay:
        bay_events.append(e)
```

### Strategy 1: Individual event pages (for speaker detail)

The API gives event metadata but NOT speaker/host names. For each event that passes the date + Bay Area filter, use WebFetch on the event URL to get full description, speaker names, bios, and venue.

For full coverage beyond the ~20-event `__NEXT_DATA__` limit. Navigate to a calendar page, scroll until no new events load, then extract.

```python
# playwright_scroll.py — save to ~/project/luma/
import asyncio
from playwright.async_api import async_playwright

async def scroll_and_extract(calendar_url, output_file):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto(calendar_url, wait_until="networkidle", timeout=30000)
        await page.wait_for_timeout(3000)
        
        prev = 0
        for i in range(40):
            await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            await page.wait_for_timeout(1500)
            links = await page.evaluate(
                "document.querySelectorAll('a[href^=\"/\"]').length")
            if links == prev and i > 5: break
            prev = links
        
        # Extract all unique event URLs with visible text
        data = await page.evaluate('''() => {
            const seen = new Set();
            return Array.from(document.querySelectorAll('a[href^="/"]'))
                .map(a => ({url: a.href, text: a.closest("div")?.innerText?.slice(0,200)||""}))
                .filter(x => x.url.includes("lu.ma/") && !seen.has(x.url) && seen.add(x.url));
        }''')
        
        import json
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Saved {len(data)} events to {output_file}")
        await browser.close()

asyncio.run(scroll_and_extract("https://luma.com/genai-sf", "events.json"))
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
- Do not recommend hackathons that only offer "platform credits" or "API credits" as prizes — these are product-testing exercises
- Do not recommend hackathons hosted by small/unknown companies — they're using participants as free labor
- Do not rely only on specific calendars — always start with broad AI category search
- Do not recommend an event without a speaker credential tag on the output card
- Do not list an event in "Excluded" without a specific rejection reason

### Concrete Examples of Past Rejects

| Event/Company | Why Rejected |
|---------------|-------------|
| Notivta + ActionLayer | Product too small, low user count, easily replaced by Claude Computer Use |
| Magnific AI | Narrow image upscaling, replaceable by open-source diffusion models, small company |
| Scalekit Build Day | "Build day" for a tiny company — participants as free product testers, no notable prizes |
| Mind Games AI Hackathon | 0 going, hosted by unknown startup XTrace, prizes unclear |

## Test Scenarios

1. User says "find me AI events this month" — run full scout, output list
2. User says "+1, +3, -5" — record feedback, update preferences
3. User says "what's new this week" — re-scout, only show events since last run
4. User says "I like Deedy Das" — boost events with similar speakers
