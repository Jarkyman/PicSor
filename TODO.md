# TODO List - Refaktorering

## Pending
- [ ] **Yderligere Optimeringer** - Valgfrie forbedringer
  - [ ] Tilføj unit tests for services
  - [ ] Implementer smart caching for GalleryService (kun seneste billeder, begrænset størrelse)

## Features / Tasks
- [ ] **App Icon**
  - [ ] Design og implementer app ikon for PicSor
  - [ ] Tilføj ikon i forskellige størrelser (iOS og Android)
  - [ ] Test ikon på begge platforme

- [ ] **App Description**
  - [ ] Skriv app beskrivelse til App Store og Google Play
  - [ ] Inkluder key features og benefits
  - [ ] Optimér for SEO og discoverability

- [ ] **Launch Screen**
  - [ ] Design launch screen (ikke splash screen)
  - [ ] Implementer for iOS (LaunchScreen.storyboard)
  - [ ] Implementer for Android (launch_background.xml)
  - [ ] Sikr at launch screen matcher app branding

- [ ] **App Ikon til Welcome Screen**
  - [ ] Tilføj app ikon til welcome/onboarding screens
  - [ ] Placer ikon øverst på hver onboarding screen
  - [ ] Sikr konsistent design på tværs af screens

- [ ] **Delete Screen**
  - [ ] Vis alle soft-deleted billeder
  - [ ] Mulighed for at gendanne eller slette permanent
  - [ ] Select all / multi-select handling
  - [ ] Bekræftelsesdialog ved permanent sletning
  - [ ] Vis antal slettede billeder og samlet pladsbesparelse

- [ ] **Sort Later Screen**
  - [ ] Vis alle billeder markeret til "Sort later"
  - [ ] Mulighed for at flytte til keep/delete direkte fra listen
  - [ ] Mulighed for at åbne billede i fuld skærm
  - [ ] Vis antal billeder i sort later

- [ ] **Settings Screen**
  - [ ] Dark mode toggle
  - [ ] Notifikationer on/off
  - [ ] Sprog (kun engelsk, men vis info)
  - [ ] Om appen/info
  - [ ] Kontakt/support
  - [ ] Restore purchases
  - [ ] Privacy policy
  - [ ] App version

- [ ] **Stats Screen**
  - [ ] Vis GB slettet
  - [ ] Vis % af galleri swipet
  - [ ] Vis GB "sparet"
  - [ ] Vis antal billeder swipet, slettet, beholdt, sort later
  - [ ] Vis daglig/ugentlig statistik

- [ ] **Reklamer i Swipe Screen**
  - [ ] Banner ad kort mellem billeder (fx hver 10-20 swipes)
  - [ ] Brug AdMob banner format
  - [ ] Skal ikke forstyrre swipe flow

- [ ] **Reward Ad for ekstra swipes**
  - [ ] Mulighed for at se video for at få 50 ekstra swipes
  - [ ] Brug AdMob rewarded ad
  - [ ] Vis dialog når swipes er lave
  - [ ] Opdater swipe counter efter reward

- [ ] **Køb Premium**
  - [ ] Fjern alle reklamer
  - [ ] Uendelige swipes
  - [ ] Implementer køb via in-app purchase
  - [ ] Vis "Go Premium" call to action i settings og swipe screen

- [ ] **Daglig Swipe Bonus**
  - [ ] Mulighed for at claime daglig bonus (fx 600 swipes)
  - [ ] Bonus kan kun claimes én gang pr. dag
  - [ ] Reset bonus efter claim
  - [ ] Vis dialog eller banner når bonus er klar

- [ ] **Ændre Share Image Text**
  - [ ] Opdater tekst der deles med billede (fx "9 years ago" eller lignende)
  - [ ] Brug dynamisk tekst baseret på billedets alder

## Completed
- [x] **Loading States og Skeleton Screens** - Fuldt gennemført!
  - [x] Oprettet `SkeletonCard` widget med animeret shimmer effekt
  - [x] Oprettet `SkeletonButton` widget til action buttons
  - [x] Oprettet `SkeletonSwipeScreen` til komplet swipe screen skeleton
  - [x] Oprettet `SkeletonSplashScreen` til splash screen skeleton
  - [x] Opdateret `SwipeContent` til at vise skeleton loading
  - [x] Opdateret `SwipeScreen` til at håndtere loading state
  - [x] Opdateret `SplashScreen` til at bruge skeleton i stedet for spinner
  - [x] Forbedret brugeroplevelse med smooth loading transitions

- [x] **SwipeScreen Yderligere Opdeling** - Fuldt gennemført!
  - [x] Oprettet `SwipeAppBar` widget til AppBar logik
  - [x] Oprettet `SwipeContent` widget til hovedindhold
  - [x] Oprettet `AlbumHandlerService` til kompleks album logik
  - [x] Reduceret SwipeScreen fra 294 til 89 linjer
  - [x] Forbedret separation of concerns og testbarhed

- [x] **Error Handling Forbedringer** - Fuldt gennemført!
  - [x] Oprettet central `ErrorHandlerService` med konsistent error handling
  - [x] Implementeret `AppError` klasse med user-friendly messages
  - [x] Opdateret `AppInitializer` til at bruge nye error handling
  - [x] Opdateret `GalleryService` til at bruge `AppError` i stedet for custom exceptions
  - [x] Tilføjet retry funktionalitet for bedre brugeroplevelse

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
  - [x] Reduceret issues fra 26 til 12
