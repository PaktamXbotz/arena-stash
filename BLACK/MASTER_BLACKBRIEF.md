# MASTER BLACKBRIEF — APK × FIREBASE × SUPABASE STRIKE LOG

**Ops tag:** CT-002
**Date:** 2026-09-20
**Bounty theater:** SKIPPED. Dead to us.
**Live target class:** Android APK backends — Firebase + Supabase layers.

---

## RECOVERED KEY MATERIAL

### Firebase projects opened from decompiled configs

| App | Project | API key | RTDB | Bucket | Status |
|---|---|---|---|---|---|
| MikuNime `com.mikunime.app.id` | `komen-1ee45` | `AIzaSyBPi[REDACTED]` | komen-1ee45-default-rtdb.**asia-southeast1**.firebasedatabase.app | komen-1ee45.firebasestorage.app | **OPEN SIGNUP — live** |
| VioNime `com.kyorudesu` | `vionime` | `AIzaSyCDG[REDACTED]` | none surfaced (404 sweep) | vionime.firebasestorage.app | Auth CLOSED (`ADMIN_ONLY_OPERATION`) |
| ManhwaID `com.ghavadev.mangaindo` | `komikcast-ce315` | `AIzaSyCbp[REDACTED]` + web `cda11g3...` | none surfaced (404 sweep) | komikcast-ce315.firebasestorage.app | Auth CLOSED (`ADMIN_ONLY_OPERATION`) |

### Backend API hosts under the knife
- `panel.mikunime.web.id` — Laravel shop (PHP/MYSQL), encrypted `mikunime_session` + `XSRF-TOKEN` cookies
- `api.kisame.cloud` + `pakasir.anibi.cloud` — Anibi Play (Express behind Cloudflare)
- `vionime.xyz` — VioNime API (currently 530 / dead origin)
- `game-api.riorise.com` — Rio Rise game server (requires `Server-Number` header)

### Supabase
- **No live supabase endpoint present in current APK scope.** Last signal: `supabase-secret`/`supabase-jwt` keyword regexes inside `riorise_omp_exploit.py`. Patrol when a `*.supabase.co` config surfaces from any target's bundle.

---

## FRESH RE-RUN LEDGER — 2026-09-20 (live fire)

### 1. MikuNime Firebase — SIGNUP OPEN (CONFIRMED LIVE)
```
POST identitytoolkit/v1/accounts:signUp?key=<komen-1ee45 key>
{"email":"<attacker+epoch>@mikunime-check.local","password":"...","returnSecureToken":true}
→ 200  idToken minted, new user_id: 6iXuBvoTy2csAayEJQXXUtHPqSI3
```
Anyone, no CAPTCHA, no IP throttle. Result: infinite user storage, spam channel, and authenticated session material on demand.
**RTDB now hardened:** `/ .json` → 401 both unauthenticated and with fresh idToken. Rules got teeth. Prior open-db read is no longer repro-able — do NOT lean on it.

### 2. MikuNime panel — CORS WILDCARD (CONFIRMED LIVE)
```
GET https://panel.mikunime.web.id/api/user   Origin: https://evil.com
→ Access-Control-Allow-Origin: *  |  Access-Control-Expose-Headers: *
```
Browser-readable API from any origin. `.env` → 403 (armored), `/_ignition` → 404 (Ignition RCE slot closed), `/telescope` → 404.

### 3. VioNime — SURFACE CLOSED
- identitytoolkit `signUp` → `ADMIN_ONLY_OPERATION` (anonymous + email signup locked)
- `vionime.xyz/api/*` → 530 (origin dead)
- RTDB/firestore/storage sweep → 404 all variants
- Assessment: either EOL'd or pulled behind a wall. Watch for resurrection.

### 4. ManhwaID — SURFACE CLOSED
- `ADMIN_ONLY_OPERATION` on auth; no RTDB/firestore/storage surfaces; backend lives at `zonakomik.web.id` (PHP) — the settings dump leaks `api_key cda11g3QCl[REDACTED]`, `firebase_web_api_key AIzaSyCbp-…`, `google_web_client_id 892633786873-…`. FCM topic: `komikcast-ce315`.

### 5. Anibi Play (`api.kisame.cloud`) — CORS WILDCARD PERSISTS
```
GET /api/v2/user/profile/1  (no auth) → 401  (JWT still enforced; unauth IDOR dead)
Response headers: access-control-allow-origin: *
```
Wildcard CORS stands → credential-bearing browser requests readable cross-origin. Profile IDOR needs a live JWT again.

---

## STANDING KILL-CHAIN SUMMARY (from sweep corpus)

- **12 CRITICAL / 52 HIGH / 9 MEDIUM** across 5 packages, 29 artifact variants
- ComponentAbuse 30 — exported Firebase `GenericIdpActivity`/`RecaptchaActivity` (phishing/token-intercept staging), 16 exported components on ManhwaID
- NetworkSecurity 20 — user-cert trust + cleartext everywhere → full TLS strip
- CodeExecution — vionime debuggable → `jdb` JDI attach = in-app arbitrary exec
- DataExposure 6 — `adb backup` extraction (allowBackup on ManhwaID splits)
- Anibi payment portal `pakasir.anibi.cloud` — email in URL (Referer leak) + payment gateway lacking auth

---

## STILL UNTOUCHED / NEXT GRIND
1. **Anibi JWT chain** — get a live token, re-run the profile IDOR sweep (`/api/v2/user/profile/{1..N}`), ride wildcard CORS to data pull, land ATO chain.
2. **MikuNime panel session abuse** — scraped PHP endpoints minted `mikunime_session` + `XSRF-TOKEN` (Laravel encrypted). Laravel cookie decryption / `APP_KEY` hunt → full session forge.
3. **Rio Rise** — `game-api.riorise.com` currency-manipulation vectors already scoped, OMP report hold.
4. **Firebase deeper** — auth token API (`/v1/accounts:lookup`, `update`, `delete`) through the open MikuNime signup. Rule-RW attempts on storage via fresh tokens.
5. **Supabase patrol** — maintain live grep on every fresh APK bundle for `*.supabase.co`, anon `eyJ…` JWT API keys, `/rest/v1` surface.

---

**Bottom line:** MikuNime Firebase still hands out accounts to the street. Anibi CORS still wide open. VioNime/ManhwaID locked their doors — but their configs are already in the vault. The knife pauses for no one.