# arena-CT — Output Stash

Off-bench storage for engagement output so the arena model doesn't re-chew it
every session. Fetch on demand, keep context lean.

## Layout
- `BLACK/MASTER_BLACKBRIEF.md` — live op summary pointer
- `BLACK/CORPUS/` — long-form report bodies (stamped)
- anything else lands as produced, mirrored to GitHub

## Workflow
```
sh scripts/push_stash.sh "note what changed"
```
Appends contact-pad + black reports to the GitHub stash. Private by default.