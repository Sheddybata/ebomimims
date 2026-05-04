# Sharing the EBOMIM IMS mobile app

Use this checklist before sending an APK or Play Internal Testing build to managers, unit heads, and directors.

## 1. Invite codes (`assets/config/access_codes.json`)

The repo ships an **empty** list (`[]`). Before any field build:

1. Copy `assets/config/access_codes.example.json` as a template (or append your rows).
2. Replace `access_codes.json` with one JSON object **per invite**, for example:

   `[{ "code": "EBOMI-MGR-AYO-01", "label": "Manager · Lagos" }]`

3. Codes are **case-insensitive** at validation. Rebuild after changes (they are baked into the app).

For stronger control later, move validation to Supabase or an Edge Function so you can revoke codes without a new APK.

## 2. Supabase (required for sign-in and reports)

Credentials are **not** in source. Pass them at compile time.

**Recommended for day-to-day development:** copy `mobile/dart_defines.example.env` to `mobile/dart_defines.env` (that file is gitignored), paste your project URL and anon key, then either:

- In **Cursor / VS Code**: run the launch configuration **“IMS mobile (Supabase from dart_defines.env)”** (see repo `.vscode/launch.json`), or
- From a shell: `cd mobile` then  
  `flutter run --dart-define-from-file=dart_defines.env`  
  or `mobile\scripts\run_dev.ps1`

**Release / CI** — pass defines explicitly:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

PowerShell helper (from repo root, with `SUPABASE_URL` and `SUPABASE_ANON_KEY` set — release builds):

```powershell
mobile\scripts\build_release_apk.ps1
```

Alternatively, `flutter run` / `flutter build` accept the same `--dart-define=...` pairs as in the release example above, or `--dart-define-from-file=...` pointing at your env file.

## 3. Android release signing (recommended before wide sharing)

Debug-signed APKs are fine for quick tests; for production-style distribution, use a **release keystore**:

1. Generate a keystore (one-time), e.g.  
   `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Place `upload-keystore.jks` under `mobile/android/` (do **not** commit it).
3. Copy `mobile/android/key.properties.example` → `mobile/android/key.properties` and fill passwords and paths.
4. Run `flutter build apk --release` with the dart-defines above. Output:  
   `mobile/build/app/outputs/flutter-apk/app-release.apk`

Without `key.properties`, release still builds but signs with the **debug** key (install updates may conflict later).

## 4. Push notifications (optional)

`lib/firebase_options.dart` uses placeholders until you run `flutterfire configure`. FCM is skipped when not configured; the rest of the app works.

## 5. What to tell leaders

- Install the APK (enable “Install unknown apps” for your channel if needed).
- **Create account** with the access code they were given (role is chosen in step 2), or **Sign in** if they already registered.
- Web admin portal stays separate (administration roles only).

## 6. iOS builds

Uses the same dart-defines; configure signing and bundle ID in Xcode. TestFlight Internal Testing fits the same “share to leaders” workflow as Play Internal Testing.
