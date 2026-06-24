#!/usr/bin/env bash
set -uo pipefail

# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
pass=0; fail=0; warn=0

pass_msg() { ((pass++)); printf "  ${GREEN}PASS${NC} %s\n" "$1"; }
fail_msg() { ((fail++)); printf "  ${RED}FAIL${NC} %s\n" "$1"; }
warn_msg() { ((warn++)); printf "  ${YELLOW}WARN${NC} %s\n" "$1"; }

# ── 0. Detect source repo ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  Skill-Factory Skill Validator                                  ${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BOLD}[0] Source Repo Detection${NC}"

SOURCE_REPO=""
if [[ -n "${SKILL_FACTORY_SOURCE:-}" ]]; then
    SOURCE_REPO="${SKILL_FACTORY_SOURCE}"
    echo "  Using SKILL_FACTORY_SOURCE env var: $SOURCE_REPO"
elif [[ -d "$HOME/project/skill-factory" && -d "$HOME/project/skill-factory/.git" ]]; then
    SOURCE_REPO="$HOME/project/skill-factory"
    echo "  Found source repo at ~/project/skill-factory/"
else
    echo "  ERROR: Cannot find skill-factory source repo."
    echo "  Set SKILL_FACTORY_SOURCE or ensure ~/project/skill-factory/ exists with .git/"
    exit 1
fi

REPO_REALPATH=$(cd "$SOURCE_REPO" && pwd -P)

# ── S. Source repo only check (not deployed copy) ─────────────────────
echo -e "${BOLD}[S] Source Repo Only Verification${NC}"

DEPLOYED_PATHS=(
    "$HOME/.config/opencode/skills/skill-factory"
    "$HOME/.claude/commands"
    "$HOME/.opencode/instructions"
)

IS_DEPLOYED=false
for dp in "${DEPLOYED_PATHS[@]}"; do
    if [[ -e "$dp" ]]; then
        dp_real=$(cd "$dp" 2>/dev/null && pwd -P || echo "$dp")
        if [[ "$dp_real" == "$REPO_REALPATH" ]]; then
            IS_DEPLOYED=true
            fail_msg "Path matches deployed copy location: $dp"
        fi
    fi
done
if [[ "$IS_DEPLOYED" == "false" ]]; then
    pass_msg "Testing source repo, not deployed copy"
fi

if git -C "$SOURCE_REPO" remote get-url origin &>/dev/null; then
    pass_msg "Source repo is a valid git repo"
else
    fail_msg "Source repo is NOT a valid git repo (no origin remote)"
fi

# ── 1. Directory structure check ───────────────────────────────────────
echo ""
echo -e "${BOLD}[1] Directory Structure Check${NC}"

for subdir in ai-coworker-skills personal-skills import-skills; do
    if [[ -d "$SOURCE_REPO/$subdir" ]]; then
        pass_msg "Directory '$subdir/' exists"
    else
        fail_msg "Directory '$subdir/' MISSING"
    fi
done

# ── Collect all skill directories ──────────────────────────────────────
ALL_SKILLS=()
for subdir in ai-coworker-skills personal-skills import-skills; do
    if [[ -d "$SOURCE_REPO/$subdir" ]]; then
        for d in "$SOURCE_REPO/$subdir"/*/; do
            [[ -d "$d" ]] || continue
            dirname=$(basename "$d")
            ALL_SKILLS+=("$subdir|$dirname")
        done
    fi
done

# Sort for consistent output
IFS=$'\n' ALL_SKILLS=($(sort <<<"${ALL_SKILLS[*]}")); unset IFS

TOTAL_SKILLS=${#ALL_SKILLS[@]}

# ── 2. SKILL.md existence check ────────────────────────────────────────
echo ""
echo -e "${BOLD}[2] SKILL.md Existence Check (${TOTAL_SKILLS} skill dirs)${NC}"

declare -A SKILL_MD_FILES
MISSING_COUNT=0

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md_path="$SOURCE_REPO/$category/$dirname/SKILL.md"
    if [[ -f "$md_path" ]]; then
        SKILL_MD_FILES["$category/$dirname"]="$md_path"
    else
        fail_msg "$category/$dirname/ — MISSING SKILL.md"
        ((MISSING_COUNT++))
    fi
done
if [[ $MISSING_COUNT -eq 0 ]]; then
    pass_msg "All ${TOTAL_SKILLS} skill directories contain SKILL.md"
fi

# ── Helpers ────────────────────────────────────────────────────────────

# Extract YAML frontmatter (lines between first pair of ---)
extract_frontmatter() {
    awk 'BEGIN{c=0} /^---$/{c++; if(c==2) exit; next} c==1' "$1"
}

# Extract a top-level YAML scalar value. Handles `key: val`, `key: |`, `key: "val"`
yaml_get() {
    local file="$1" field="$2"
    local fm
    fm=$(extract_frontmatter "$file")
    echo "$fm" | awk -v f="$field" '
        BEGIN { in_block = 0; found = 0 }
        found == 0 && $0 ~ "^" f ":" {
            $0 = substr($0, index($0, ":") + 1)
            sub(/^[[:space:]]*\|?[[:space:]]*/, "")
            print
            in_block = 1
            found = 1
            if ($0 !~ /^[[:space:]]*$/) next
        }
        in_block == 1 {
            if ($0 ~ /^[a-zA-Z_-]+:/) exit
            sub(/^[[:space:]]{2,}/, "")
            print
        }
    '
}

# Check if a top-level field exists in frontmatter
yaml_has_field() {
    local fm
    fm=$(extract_frontmatter "$1")
    echo "$fm" | grep -qE "^$2:" && return 0 || return 1
}

# Get body text (everything after second ---)
get_body() {
    awk 'BEGIN{c=0} /^---$/{c++; next} c>=2' "$1"
}

# Check if frontmatter exists (at least one --- line)
has_frontmatter() {
    head -1 "$1" | grep -q '^---$' && return 0 || return 1
}

# ── 3. Frontmatter validation ──────────────────────────────────────────
echo ""
echo -e "${BOLD}[3] Frontmatter Validation (5-field: name, description, license, compatibility, metadata)${NC}"

REQUIRED_FIELDS=(name description license compatibility metadata)

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue

    if ! has_frontmatter "$md"; then
        fail_msg "Frontmatter: '$category/$dirname' — no YAML frontmatter (missing ---)"
        continue
    fi

    fm_ok=true
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! yaml_has_field "$md" "$field"; then
            fm_ok=false
            fail_msg "Frontmatter: '$category/$dirname' — missing '$field' field"
        fi
    done
    if $fm_ok; then
        pass_msg "Frontmatter: '$category/$dirname' — all 5 fields present"
    fi
done

# ── 4. Required sections check ─────────────────────────────────────────
echo ""
echo -e "${BOLD}[4] Required Sections: ## When to Use + ## When NOT to Use + ## Process (or # Process)${NC}"

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue

    sections_ok=true
    body=$(get_body "$md")

    if ! echo "$body" | grep -qE '^## When to Use'; then
        sections_ok=false
        fail_msg "Sections: '$category/$dirname' — missing '## When to Use'"
    fi
    if ! echo "$body" | grep -qE '^## When NOT to Use'; then
        sections_ok=false
        fail_msg "Sections: '$category/$dirname' — missing '## When NOT to Use'"
    fi
    if ! echo "$body" | grep -qE '^#{1,2} Process'; then
        sections_ok=false
        fail_msg "Sections: '$category/$dirname' — missing '## Process' / '# Process'"
    fi
    if $sections_ok; then
        pass_msg "Sections: '$category/$dirname' — all required sections present"
    fi
done

# ── 5. Prohibited patterns check ───────────────────────────────────────
echo ""
echo -e "${BOLD}[5] Prohibited Patterns${NC}"

# Match actual section headers at line start (not inside code spans or checkboxes)
PROHIBITED_SECTIONS_PATTERN='^## (Changelog|Convention Notes)\s*$'
DECORATIVE_EMOJIS_PATTERN='\x{2705}|\x{274C}|\x{1F680}|\x{1F525}|\x{2714}|\x{274E}|\x{1F4A5}|\x{1F4AF}|\x{1F44D}|\x{1F44E}|\x{1F389}|\x{26A1}|\x{1F6A8}|\x{1F514}|\x{23F0}|\x{2B50}|\x{1F31F}|\x{1F4A1}|\x{1F4AC}|\x{25B6}|\x{270F}|\x{1F4DD}|\x{2139}'
# Match actual OCR artifacts, not references to them inside backtick code spans
OCR_ARTIFACT_PATTERN='[^`]\*\*>[^*]+\*\*<'

PROHIBITED_FAILS=0

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue
    label="'$category/$dirname'"

    body=$(get_body "$md")

    # Check prohibited sections
    if echo "$body" | grep -qE "$PROHIBITED_SECTIONS_PATTERN"; then
        ((PROHIBITED_FAILS++))
        fail_msg "Prohibited section (## Changelog / ## Convention Notes) in $label"
        echo "$body" | grep -nE "$PROHIBITED_SECTIONS_PATTERN" \
            | while IFS=: read -r lno line; do
                printf "    line %s: %s\n" "$lno" "$line"
              done || true
    fi

    # Check TBD/TODO (uppercase placeholders only, exclude quality gate references)
    if echo "$body" | grep -qE '\b(TBD|TODO)\b'; then
        tbd_todo_lines=$(echo "$body" | grep -nE '\b(TBD|TODO)\b' \
            | grep -vE '^[0-9]+:\s*- \[.*No .*(TBD|TODO|to be determined|placeholder)' \
            | grep -vE '^[0-9]+:\s+-\s.*(scan|check|flag|detect).*(TBD|TODO|placeholder)')
        if [[ -n "$tbd_todo_lines" ]]; then
            ((PROHIBITED_FAILS++))
            fail_msg "TBD/TODO placeholder found in $label"
            echo "$tbd_todo_lines" \
                | while IFS=: read -r lno line; do
                    printf "    line %s: %s\n" "$lno" "$line"
                  done || true
        fi
    fi

    # Check decorative emojis (body only, -P for unicode, exclude quality gate checkboxes)
    if echo "$body" | grep -qP "$DECORATIVE_EMOJIS_PATTERN" 2>/dev/null; then
        emoji_lines=$(echo "$body" | grep -nP "$DECORATIVE_EMOJIS_PATTERN" 2>/dev/null \
            | grep -vE '^[0-9]+:\s*- \[.*(decorative|emoji)' \
            | grep -vE '^[0-9]+:\s*- \[.*[❌✅🚀🔥]' \
            | grep -vE '^[0-9]+:\s+-\s.*[❌✅🚀🔥]')
        if [[ -n "$emoji_lines" ]]; then
            ((PROHIBITED_FAILS++))
            fail_msg "Decorative emoji found in $label"
            echo "$emoji_lines" \
                | while IFS=: read -r lno line; do
                    printf "    line %s: %s\n" "$lno" "$line"
                  done || true
        fi
    fi

    # Check OCR artifacts (not inside backtick code spans referencing the rule)
    if echo "$body" | grep -qE "$OCR_ARTIFACT_PATTERN"; then
        ocr_lines=$(echo "$body" | grep -nE "$OCR_ARTIFACT_PATTERN" \
            | grep -vE '`\*\*>.*<\*\*`')
        if [[ -n "$ocr_lines" ]]; then
            ((PROHIBITED_FAILS++))
            fail_msg "OCR artifact (**>text<**) found in $label"
            echo "$ocr_lines" \
                | while IFS=: read -r lno line; do
                    printf "    line %s: %s\n" "$lno" "$line"
                  done || true
        fi
    fi
done

if [[ $PROHIBITED_FAILS -eq 0 ]]; then
    pass_msg "No prohibited patterns found in any skill"
fi

# ── 6. Description rules ───────────────────────────────────────────────
echo ""
echo -e "${BOLD}[6] Description Rules (≤1024 chars, no first person)${NC}"

FIRST_PERSON_RE='\b(I can|I will|I help|I have|I am|I would|I could|I should|I need|I want|I think|I know|I see|I found|I believe|I made|I wrote|I created|I modified|I updated|I changed|I fixed|I built|I designed)\b'

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue
    label="'$category/$dirname'"

    desc=$(yaml_get "$md" "description")
    desc_len=${#desc}
    ok=true

    if [[ $desc_len -gt 1024 ]]; then
        ok=false
        fail_msg "Description: $label — ${desc_len} chars (max 1024)"
    fi

    if [[ -n "$desc" ]] && echo "$desc" | grep -qiP "$FIRST_PERSON_RE" 2>/dev/null; then
        ok=false
        match=$(echo "$desc" | grep -oiP "$FIRST_PERSON_RE" 2>/dev/null | head -3 | tr '\n' ', ' || true)
        fail_msg "Description: $label — first person detected: $match"
    fi

    if $ok; then
        if [[ $desc_len -eq 0 ]]; then
            fail_msg "Description: $label — EMPTY description field"
        else
            pass_msg "Description: $label — ${desc_len} chars, valid"
        fi
    fi
done

# ── 7. Duplicate name check ────────────────────────────────────────────
echo ""
echo -e "${BOLD}[7] Duplicate Frontmatter Name Check${NC}"

declare -A NAME_MAP
DUPES_FOUND=false

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue

    fname=$(yaml_get "$md" "name" | head -1 | xargs)
    if [[ -z "$fname" ]]; then
        fail_msg "Duplicate name: '$category/$dirname' — could not extract 'name' field"
        continue
    fi

    if [[ -n "${NAME_MAP[$fname]:-}" ]]; then
        DUPES_FOUND=true
        fail_msg "Duplicate name: '$fname' found in both '${NAME_MAP[$fname]}' and '$category/$dirname'"
    else
        NAME_MAP[$fname]="$category/$dirname"
    fi
done

if [[ "$DUPES_FOUND" == "false" ]]; then
    pass_msg "All frontmatter 'name' values are unique"
fi

# ── 8. Directory-name consistency check ────────────────────────────────
echo ""
echo -e "${BOLD}[8] Directory-Name Consistency (dir matches skill name after stripping ai-coworker- prefix)${NC}"

for entry in "${ALL_SKILLS[@]}"; do
    category="${entry%%|*}"
    dirname="${entry##*|}"
    md="${SKILL_MD_FILES["$category/$dirname"]:-}"
    [[ -z "$md" ]] && continue

    fname=$(yaml_get "$md" "name" | head -1 | xargs)
    if [[ -z "$fname" ]]; then
        fail_msg "Name consistency: '$category/$dirname' — could not extract 'name' field"
        continue
    fi

    # Strip "ai-coworker-" prefix if present to get canonical dir name
    canonical="${fname#ai-coworker-}"

    if [[ "$canonical" == "$dirname" ]]; then
        pass_msg "Name consistency: '$category/$dirname' matches name '$fname'"
    else
        fail_msg "Name consistency: '$category/$dirname' — dir='$dirname' does not match canonical name '$canonical' (from frontmatter name='$fname')"
    fi
done

# ── 9. Empty directory check ───────────────────────────────────────────
echo ""
echo -e "${BOLD}[9] Empty Directory Check${NC}"

EMPTY_FOUND=false
for subdir in ai-coworker-skills personal-skills import-skills; do
    if [[ -d "$SOURCE_REPO/$subdir" ]]; then
        for d in "$SOURCE_REPO/$subdir"/*/; do
            [[ -d "$d" ]] || continue
            if [[ ! -f "$d/SKILL.md" ]]; then
                EMPTY_FOUND=true
                fail_msg "Empty dir: ${d#$SOURCE_REPO/} — no SKILL.md"
            fi
        done
    fi
done
if [[ "$EMPTY_FOUND" == "false" ]]; then
    pass_msg "No empty skill directories found"
fi

# ── Final Summary ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  SUMMARY${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
printf "  Skills tested:     %d\n" "$TOTAL_SKILLS"
printf "  ${GREEN}PASS${NC}:              %d\n" "$pass"
printf "  ${RED}FAIL${NC}:              %d\n" "$fail"
printf "  ${YELLOW}WARN${NC}:             %d\n" "$warn"
echo ""

if [[ $fail -gt 0 ]]; then
    echo -e "  ${RED}Result: SOME CHECKS FAILED${NC}"
    exit 1
else
    echo -e "  ${GREEN}Result: ALL CHECKS PASSED${NC}"
    exit 0
fi
