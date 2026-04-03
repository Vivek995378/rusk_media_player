# Rusk Media — Micro-Drama Interactive Player

A high-fidelity vertical video feed built in Flutter, demonstrating best-in-class UI/UX polish for a micro-drama platform.

---

## Architecture

Clean Architecture with BLoC state management:

```
lib/
├── core/
│   ├── design_system/       # Colors, typography tokens
│   ├── di/                  # GetIt dependency injection
│   ├── init/                # App entry, router, app widget
│   └── utils/               # Extensions, helpers
└── features/
    ├── splash/              # Animated splash screen
    ├── tutorial/            # First-launch gesture guide overlay
    └── video_feed/
        ├── data/
        │   ├── datasources/ # Static video data source
        │   └── repository_impl/
        ├── domain/
        │   ├── entities/    # VideoEntity
        │   ├── repositories/
        │   └── usecases/    # FetchVideos, FetchMoreVideos
        └── presentation/
            ├── bloc/        # VideoFeedCubit + VideoFeedState
            └── view/
                └── widgets/ # All player UI components
```

**UI ↔ Business Logic separation:** All video state (liked IDs, current index, preloaded URLs, tutorial active flag) lives in `VideoFeedCubit`. Widgets are purely reactive — they read state via `BlocSelector` and emit events via cubit methods. No business logic in widget files.

---

## Core Features Implemented

### 1. Vertical Video Feed
- Infinite circular scroll using a virtual 100,000-page `PreloadPageView` with modulo indexing
- Custom `PageScrollPhysics` extending `PageScrollPhysics` with a soft spring (`mass: 0.4, stiffness: 100, damping: 16`) for buttery-smooth snapping
- LRU controller cache (max 3) — adjacent videos pre-warmed in background
- 5-second timeout per video: auto-skips to next if a video fails to load
- **Custom loading state:** `VideoFeedPremiumLoader` — animated shimmer background with diagonal sweep bands, floating particles, cycling frame images with crossfade transitions, and a running-boy GIF synced to the progress bar

### 2. Emotional Micro-Interactions

**Double-Tap to Like**
- Heart burst appears at the exact tap `localPosition`
- Primary heart: `0.3 → 1.3` scale with `easeOutBack`, then `1.3 → 1.0` with `elasticOut` (spring physics)
- 4 satellite hearts scatter with randomised size, color, direction, and stagger delay
- Floating `+N` count text drifts upward with `SlideTransition` + `FadeTransition`
- Haptic feedback on trigger

**Progress Scrubbing**
- Custom-painted progress bar (`CustomPainter`) with pink→orange gradient fill
- Bar expands vertically `3px → 8px` with a scrub handle dot on drag
- Time preview tooltip (`00:05 / 00:15`) follows finger position, clamped to screen bounds
- Seeks video on drag end and resumes playback

**Additional Gestures**
- Single tap → mute/unmute with animated indicator
- Long press → hold-to-pause (Instagram-style) with subtle dim overlay
- Long press + drag up/down → volume control with glassmorphism volume bar (backdrop blur, breathing glow, animated thumb)

### 3. Retention Paywall
- Triggers automatically at the **10-second mark** of any video
- Background blurs in real-time via `BackdropFilter` (`sigmaX/Y: 0 → 12`, animated)
- Paywall card slides up from bottom with a custom 3-phase curve: overshoot to `-0.06`, bounce to `0.03`, settle to `0`
- **"Unlock Episode" CTA:** `CustomPainter` shimmer band sweeps left-to-right every 3 seconds using a `LinearGradient` clipped to a rounded rect

---

## Additional Polish

| Feature | Detail |
|---|---|
| Splash screen | Animated logo with bounce scale, brand gradient text, particle field |
| First-launch tutorial | 5-step gesture guide with `ic_guide_boy.png` + animated `guide_hand.png` demonstrating each gesture. Auto-advances every 3s with countdown timer. Persisted via `SharedPreferences` — shows only once. |
| Brand loading overlay | `VideoFeedPremiumLoader` shown randomly every 2–3 scrolls as a branded interstitial |
| Mute indicator | Animated scale+fade icon on single tap |
| Buffering indicator | Thin gradient bar at top during mid-playback stalls only (not during initial load) |
| App lifecycle | Pauses on background, resumes on foreground |
| Font | Google Fonts Onest via `GoogleFonts.onestTextTheme()` |

---

## Running the Project

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and a physical device or emulator with network access (videos stream from Cloudinary).

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `preload_page_view` | Adjacent page pre-loading |
| `video_player` | Video playback |
| `flutter_cache_manager` | Video file caching |
| `go_router` | Navigation |
| `google_fonts` | Onest typeface |
| `shared_preferences` | Tutorial seen flag persistence |
| `equatable` | Value equality for BLoC states |
| `fpdart` | Functional Either type for repository results |
