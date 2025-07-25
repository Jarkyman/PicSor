# TODO List - Refaktorering

## In Progress
- [ ] **Fremtidige Refaktoreringer** - Potentielle forbedringer
  - [ ] Opdel SwipeScreen yderligere hvis nødvendigt
  - [ ] Forbedre error handling i hele appen
  - [ ] Tilføj unit tests for services

## Pending
- [ ] **Yderligere Optimeringer** - Valgfrie forbedringer
  - [ ] Implementer persistent caching for GalleryService
  - [ ] Tilføj loading states og skeleton screens
  - [ ] Optimér memory usage for store billeder

## Completed
- [x] **GalleryService Forbedringer** - Fuldt gennemført!
  - [x] Tilføjet caching for assets (5 minutter validitet)
  - [x] Forbedret error handling med custom exceptions
  - [x] Tilføjet retry mekanisme med exponential backoff
  - [x] Graceful handling af individuelle asset fejl
  - [x] Cache management metoder

- [x] **App.dart Cleanup** - Fuldt gennemført!
  - [x] Oprettet `lib/screens/stats_screen.dart` (placeholder)
  - [x] Oprettet `lib/screens/settings_screen.dart` (placeholder)
  - [x] Fjernet placeholder screens fra app.dart
  - [x] Forbedret filstruktur og separation

- [x] **SplashScreen Refaktorering** - Fuldt gennemført!
  - [x] Oprettet `OnboardingManager` til onboarding flow
  - [x] Oprettet `AppInitializer` til app startup
  - [x] Opdateret SplashScreen til at bruge nye managers
  - [x] Reduceret kompleksitet og forbedret separation of concerns

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
*🎉 Alle planlagte refaktoreringer er nu gennemført! Appen har betydeligt forbedret kodekvalitet, separation of concerns, og maintainability.* 