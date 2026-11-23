# Skill Spec: /rbx-ui-reference

Category: build · Source: `studio/skills/rbx-ui-reference/SKILL.md`

## Static assertions

- [ ] The description starts with Roblox and the frontmatter matches the command name.
- [ ] Cases without evidence have an explicit skip or fallback.
- [ ] Analysis cites observed time or frame order, labels inference, and gives phone and desktop verification states.
- [ ] The brief appears in chat by default. Requested game-repo reports stay in `.rbx-studio/reports/`.

## Case 1: Playable videos

**Fixture**: Supply both linked demos in `docs/roblox/ui-reference-videos.md` and ask for a Locker brief.

- [ ] Cite distinct observed frames from both clips.
- [ ] Explain which elements establish card hierarchy and which establish reward hierarchy.
- [ ] Translate those patterns into original Locker assets, selection and equip states, and phone and desktop checks.

## Case 2: Inaccessible video, one screenshot

**Fixture**: An X clip fails to play. A still shows a dimmed shop and an enlarged item.

- [ ] Identify the source as a still and describe the visible focus and backdrop.
- [ ] Mark the trigger, duration, easing, and exit as unverified. Identify which further frames would resolve them.

## Case 3: Missing reference

**Fixture**: Run the command without a link, clip, or screenshots.

- [ ] Return the relevance skip without inventing observations or writing a report.
