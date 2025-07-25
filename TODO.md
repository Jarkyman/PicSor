# TODO List - Refaktorering

## In Progress
- [ ] **SplashScreen Refaktorering** - Del op i mindre komponenter
  - [ ] Opret `OnboardingManager` til onboarding flow
  - [ ] Opret `AppInitializer` til app startup
  - [ ] Opdater SplashScreen til at bruge nye managers

## Pending
- [ ] **App.dart Cleanup** - Flyt placeholder screens
  - [ ] Opret `lib/screens/stats_screen.dart` (placeholder)
  - [ ] Opret `lib/screens/settings_screen.dart` (placeholder)
  - [ ] Fjern placeholder screens fra app.dart

- [ ] **GalleryService Forbedringer** - Tilføj caching og error handling
  - [ ] Tilføj caching for assets
  - [ ] Forbedret error handling
  - [ ] Tilføj retry mekanisme

## Completed
- [x] **SwipeLogicService Refaktorering** - Fuldt gennemført!
  - [x] Oprettet `DeckManager` service til deck logik
  - [x] Oprettet `SwipeCounter` service til swipe limits og refill
  - [x] Oprettet `ActionHistory` service til undo/redo stack
  - [x] Opdateret SwipeLogicService til at bruge nye services
  - [x] Bevarede backward compatibility med getters

- [x] **Onboarding Refaktorering** - Fuldt gennemført!
  - [x] Oprettet fælles onboarding widgets i `lib/widgets/onboarding/`
  - [x] Opdateret alle 6 onboarding screens til at bruge fælles widgets
  - [x] Ensartet design og mindre kodeduplikering

- [x] **Warning Cleanup** - Fuldt gennemført!
  - [x] Fjernet unused imports, fields, variables
  - [x] Fixet deprecated withOpacity
  - [x] Fixet unnecessary underscores
  - [x] Reduceret issues fra 26 til 17

---
*Refaktorering plan: SwipeLogicService ✅, nu SplashScreen, derefter App.dart cleanup, og til sidst GalleryService forbedringer.* 