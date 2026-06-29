# BiteBeat — Total Design Refactor Plan

> Implementation-ready plan for a full visual + structural + functional design refactor of the BiteBeat iOS app, aligned to Apple Human Interface Guidelines (verified via sosumi MCP).

## Project Facts

| | |
|---|---|
| App | BiteBeat (music → food recommendation) |
| Bundle ID | `com.pucakgunung.BiteBeat` |
| Deployment target | **iOS 26.0 / 26.5** (NOT iOS 17 — stale AGENTS.md) |
| Swift | 5.0 |
| Build | `xcodebuild -workspace challange-2.xcworkspace -scheme BiteBeat -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug` |
| Working dir | `/Users/hisyam/Documents/ADA/XcodeProject/c2-xcode/BiteBeatApp` |
| Local SPM package | `Packages/BiteBeatMusic` (left untouched) |

## Locked Decisions

1. **Scope:** visual + structural **+ functional** (add TabView navigation, English-only copy). No new features beyond nav restructure; preserve existing app behavior (mood analysis, maps flow, ending celebration).
2. **File structure:** full restructure to `Core/` + `Features/` + `DesignSystem/` + `Models/` + `Services/` + `Data/` + `Resources/`.
3. **Liquid Glass:** KEEP current `glassEffect` usage in content layer (warningBanner, locationBanner, statusBanner). This is an **intentional, user-approved deviation** from HIG Materials guidance ("don't use Liquid Glass in the content layer"). Document inline with a brief comment so reviewers know it is deliberate.
4. **Navigation:** add `TabView` (Home + Profile) as root after onboarding; `NavigationStack` per tab. Verified API: `TabView { Tab("Home", systemImage: "house.fill") { … } }` (iOS 18+, available on iOS 26 target) — see sosumi `TabView` doc.
5. **Language:** English only. Remove mixed Indonesian strings ("Saran menu powered by AI", "Saran menu by AI", "Saran menu by AI") → English equivalents.
6. **Typography:** refine `BiteBeatFont` wrapper (keep — it is DRY/centralized). **Remove** the `.custom(CGFloat)` escape hatch. Add semantic display cases (`.displayLarge`, `.displayMedium`, `.displaySmall`) that still resolve to Dynamic Type `Font.TextStyle` (largeTitle/title) with `.weight()` + `.fontDesign()`. All current `.custom(80/96/104/42/38/30/29/28/22/21/16/15/12/11/9)` mapped to semantic styles.
7. **Spacing/radius:** 4pt-grid token system; standardize horizontal screen padding to ONE token across all screens.

## Current State (design debt found)

- Magic numbers everywhere: spacing `24/36/20/18/16/12/34/28/38/118/8/6/5/4/2`, inconsistent horizontal padding per screen (Home=24, Recommendation=36, Profile=20).
- `.biteBeatFont(.custom(CGFloat))` hardcoded point sizes bypass Dynamic Type hierarchy (HIG Typography: use built-in text styles).
- DRY violations: ProfileView card background+shadow pattern repeated 3×; "Yay!/Nay!" button block repeated 3× (maps/legacy/alternatives); `mealHeroImage` circle+shadow repeated; `openSystemSettings()` duplicated 4× (ContentView, HomeView, ProfileViewModel, AuthorizationViewModel).
- `.frame(width: 320)` fixed-width dialogs (Authorization, AppleIntelPermission) — not adaptive.
- `.foregroundStyle(.white)` / `.black.opacity(...)` literals (skill forbids bare `.white`/`.black`).
- `.bold()` and `.fontWeight(.bold)` applied redundantly on top of `biteBeatFont(weight:)`.
- Corner radii off 4pt grid: `34, 28` (round to `32, 28→24` or keep documented).
- Mixed Indonesian/English copy.
- `LargeSongCard`, `HomeRoute`, `RecommendationData` defined inside `HomeView.swift`; domain models scattered across Views and Services.

Already HIG-aligned (preserve): `NavigationStack` + `NavigationPath`; `@Observable` models via `@Environment`; semantic grouped backgrounds; SF Symbols; `.glassProminent` primary buttons.

## Target File Structure

```
BiteBeat/
├── App/
│   ├── BiteBeatApp.swift            # @main only (unchanged behavior)
│   └── ContentView.swift            # root router: onboarding → MainTabView
├── DesignSystem/
│   ├── Spacing.swift                # 4pt grid spacing tokens
│   ├── CornerRadius.swift           # corner radius tokens
│   ├── Typography.swift             # refined BiteBeatFont (no .custom)
│   └── Color+Semantic.swift         # typed semantic color helpers
├── Core/
│   ├── Components/                  # PrimaryActionButton, SecondaryActionButton,
│   │                                # MealHeroImage, InfoItem, SectionHeader,
│   │                                # StatusBanner, LargeSongCard, SongRow,
│   │                                # ArtworkImage, FoodImageView, AnalysisLoadingView
│   ├── Modifiers/                   # CardStyle, ScreenPadding, ShadowStyle, etc.
│   ├── Extensions/                  # View+, Color+, etc.
│   └── Utilities/                   # SystemSettingsOpener (deduped), formatters
├── Features/
│   ├── Home/        Views/ HomeView, MainTabView ; Models/ HomeViewModel
│   ├── Recommendation/ Views/ RecommendationView ; Models/ RecommendationViewModel
│   ├── Ending/      Views/ EndingView ; Models/ EndingViewModel
│   ├── Profile/     Views/ ProfileView, AboutView, SecretMenuView, ProfileDetailsSheet ; Models/ ProfileViewModel
│   └── Authorization/ Views/ AuthorizationView, AppleIntelligencePermissionView ; Models/ AuthorizationViewModel
├── Ending/          (13 celebration subcomponents — keep grouped)
├── Models/          Meal, RestaurantDishes, NearbyRestaurant, RecommendationData, HomeRoute, DailyMealSelection
├── Services/        (6 services — unchanged, move location only)
├── Data/            default_playlist.json, foods.json, pixie.mp3
└── Resources/Assets.xcassets/  AccentColor, AppIcon, LogoApp
```

## Design Token Specification

### Spacing (4pt grid) — `DesignSystem/Spacing.swift`
```
xs=4  sm=8  md=12  lg=16  xl=20  xxl=24  xxxl=32  huge=48
```
- Standard screen horizontal padding token = `.screenPadding` (resolve to `xl`=20 or `xxl`=24 — pick ONE, apply everywhere).
- Expose as `View` modifier `.padding(.screen)` and as `CGFloat` constants.

### CornerRadius — `DesignSystem/CornerRadius.swift`
```
small=8  medium=12  large=16  xl=20  pill=Use .capsule / continuous capsule
```
- Round existing `34→32`, `28→24` (or keep as a documented `cardLarge` token). Use `RoundedRectangle(cornerRadius:style: .continuous)` consistently.

### Typography — refine `DesignSystem/Typography.swift`
- Keep `BiteBeatFont` enum + `biteBeatFont(_:weight:)` View extension (DRY).
- **Remove** `case custom(CGFloat)` and `textStyle(forApproximateSize:)`.
- Add: `displayLarge` → `.largeTitle` weight `.bold`; `displayMedium` → `.largeTitle` weight `.semibold`; `displaySmall` → `.title` weight `.bold`. For oversized brand/logo (80pt), use `displayLarge` + `.fontDesign()` — logo is non-reading content, fixed large size acceptable per HIG.
- Map all current `.custom(N)`:
  - `80, 96, 104` → `.displayLarge` (logo/avatar hero)
  - `38, 42, 30, 29, 28` → `.largeTitle` / `.title` with weight
  - `22, 21` → `.title2`
  - `16` → `.callout`/`.body`
  - `15` → `.subheadline`
  - `12, 11` → `.caption`/`.footnote`
  - `9` → `.caption2`
- Remove redundant `.bold()`/`.fontWeight(.bold)` stacked on `biteBeatFont(weight:)` — pass weight into the modifier.

### Color — `DesignSystem/Color+Semantic.swift`
- Keep semantic grouped backgrounds: `Color(.systemGroupedBackground)`, `Color(.secondarySystemGroupedBackground)`, `Color(.tertiarySystemGroupedBackground)`.
- Foreground: `.primary`, `.secondary`, `.tertiary`, `Color(.label)`, `Color(.secondaryLabel)`, `Color(.systemGray)`, `Color(.systemGray5)`.
- Status colors: use `Color(.systemGreen)`, `Color(.systemOrange)`, `Color(.systemRed)` (adaptive) instead of bare `.green/.orange/.red` for explicitness.
- `.white`/`.black`: replace bare literals. Allow `Color(.white)` ONLY on guaranteed-opaque accent/gradient surfaces (logo screen, map pins, prominent button labels) — expose as a typed helper `Color.onAccent` to make intent explicit. Remove `.black.opacity(X)` for shadows → use a `ShadowStyle` modifier with system-appropriate shadow (HIG: avoid heavy custom shadows; prefer subtle).
- Accent: `Color.accentColor` for primary actions/emphasis only (HIG: apply color sparingly, reserve prominent for the single primary action).

## Phased Task List

### Phase 0 — Foundations & Project Hygiene
- [ ] Fix `AGENTS.md` + `.agents/skills/apple-dev-standards/SKILL.md`: replace all "Reparin"/`c3-xcode`/iOS 17 references with "BiteBeat"/`c2-xcode`/iOS 26; correct build command to workspace+scheme above.
- [ ] Create `DesignSystem/` files (Spacing, CornerRadius, Typography refined, Color+Semantic). Verify each API via sosumi before use (`.fontDesign`, `Color(uiColor:)`, `RoundedRectangle`).
- [ ] Create `Core/Modifiers/`: `CardStyle`, `ScreenPadding`, `ShadowStyle` ViewModifiers + `View` extensions.
- [ ] Create `Core/Components/`: `PrimaryActionButton`, `SecondaryActionButton` (replace repeated "Yay!/Nay!" blocks), `MealHeroImage`, `InfoItem`, `SectionHeader`, `StatusBanner` (unify warning/status banners).
- [ ] Create `Core/Utilities/SystemSettingsOpener` (dedupe 4× `openSystemSettings()`).
- [ ] Add `#Preview` with realistic mock data to every new component.

### Phase 1 — Domain Models & Services Consolidation
- [ ] Move `Meal`, `RestaurantDishes`, `NearbyRestaurant`, `RecommendationData`, `HomeRoute`, `DailyMealSelection` definitions into `Models/` (one file per model per skill). Locate current definitions (HomeView.swift, Services files) and relocate.
- [ ] Move 6 Services into `Services/` (location only, no logic change).
- [ ] Move `Data/` resources and `Assets.xcassets` into `Resources/` (update asset references if path changes — verify `Image("LogoApp")` still resolves).

### Phase 2 — Navigation Restructure (functional)
- [ ] Create `Features/Home/Views/MainTabView`: `TabView` with `Tab("Home", systemImage: "house.fill")` (own `NavigationStack`) + `Tab("Profile", systemImage: "person.crop.circle.fill")` (own `NavigationStack`).
- [ ] Update `ContentView`: after onboarding + AI acknowledgement, present `MainTabView()` instead of `HomeView()`.
- [ ] Decouple Profile: remove `HomeRoute.profile` push; Profile becomes its own tab root. Profile's internal `ProfileRoute.about` stays as its own `NavigationStack` destination.
- [ ] Home `NavigationPath` keeps `.recommendation` → `.ending` routes only.
- [ ] Verify `Notification.Name.resetHome` reset path still works with new tab structure (it clears `path = NavigationPath()` — ensure it targets the Home tab's path).

### Phase 3 — View Token Migration Sweep
For EACH view, migrate to tokens/semantic typography/colors, standardize padding, English-only copy, extract repeated patterns to Core components:
- [ ] **HomeView** (+ `LargeSongCard` → move to Core/Components): tokens, `biteBeatFont` semantic, `.screenPadding`, card stack animations preserved, `analyzeMoodButton` → component, `connectionWarning`/`warningBanner` → `StatusBanner` (keep glassEffect per decision #3).
- [ ] **RecommendationView**: maps flow + legacy flow + alternatives flow; replace 3× "Yay!/Nay!" with `PrimaryActionButton`/`SecondaryActionButton`; `mealHeroImage`/`infoItem`/`mealSummary`/`dishRowCard`/`alternativeCard` → Core components or modifiers; `.padding(.top, 118)` → safe-area-aware spacing; `.frame(width: 320)` N/A here.
- [ ] **EndingView** + 13 Ending subcomponents: tokens, semantic typography, keep celebration animations; group in `Ending/` folder.
- [ ] **ProfileView** + `ProfileDetailsSheet`: 3× card pattern → `CardStyle` modifier; hero avatar `.custom(96/104)` → `.displayLarge`; `detailRow` divider stays; English copy.
- [ ] **AuthorizationView**: `.frame(width: 320)` → adaptive (`.frame(maxWidth: .smDialog)` or read available width); `.white` on accent → `Color.onAccent`; English copy.
- [ ] **AppleIntelligencePermissionView** (in ContentView.swift): same adaptive dialog treatment; availability color/status banner → `StatusBanner`; English copy.
- [ ] **AnalysisLoadingView**: tokens, semantic typography, English copy.

### Phase 4 — Validation
- [ ] Build: `xcodebuild -workspace challange-2.xcworkspace -scheme BiteBeat -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build 2>&1 | tee /tmp/bitebeat_build.log | tail -5`
- [ ] Check: `grep -E "^(error:|warning:)" /tmp/bitebeat_build.log` → **zero errors, zero new warnings**.
- [ ] Run diagnostics on every modified file.
- [ ] Visual QA (simulator): light + dark mode; Dynamic Type at largest **accessibility** text size; Increase Contrast ON. Confirm no truncation/overlap, tabs render, onboarding → tabs flow works, Recommendation→Ending push works, Profile tab independent.
- [ ] grep sweep: confirm no remaining `.custom(`, no bare `.foregroundStyle(.white)`/`.black`, no Indonesian strings, no raw magic spacing numbers outside DesignSystem.

## Risks & Mitigations

- **`project.pbxproj` breakage from full restructure:** use Xcode file-system-synchronized groups (folder references) where possible; add files via Xcode, not hand-edits to pbxproj; build after each phase.
- **TabView moves Profile state:** Profile previously pushed from Home with shared `MusicSessionManager`/`LocationManager` `@Environment` — these are injected at app root (`BiteBeatApp`), so both tabs inherit them. Verify `@Environment(MusicSessionManager.self)` resolves in Profile tab.
- **`resetHome` notification:** verify it still resets the correct (Home tab) NavigationPath after restructure.
- **Asset path change:** if `Assets.xcassets` moves to `Resources/`, confirm `Image("LogoApp")` and `AccentColor` still resolve (asset catalogs are target-bound, not path-bound — should be safe, but verify).
- **`BiteBeatMusic` SPM package:** untouched; ensure `import BiteBeatMusic` and `MusicSessionManager`/`BiteMusicTrack` types still resolve after main target restructure.

## Out of Scope

- No changes to `Packages/BiteBeatMusic` package internals.
- No new features beyond TabView navigation restructure.
- No full localization (en+id) — English only per decision #5.
- No Liquid Glass content-layer change per decision #3.
- No data/SwiftData persistence changes (app uses JSON resources + UserDefaults, not SwiftData — the stale AGENTS.md SwiftData refs are irrelevant to this project).

## Open Items for Implementer

- Confirm final standard screen padding value (`xl`=20 vs `xxl`=24) — pick one and apply universally. Recommendation: `xxl`=24 (matches current Home, the most-used screen).
- Confirm `cardLarge` corner radius token value (round `34→32`, `28→24`) — ensure visual parity acceptable.
- Verify via sosumi: `.fontDesign(_:)`, `Color(uiColor:)`, `RoundedRectangle(cornerRadius:style:)`, `Tab`/`TabView` APIs before first use in each phase (documentation-first rule).
