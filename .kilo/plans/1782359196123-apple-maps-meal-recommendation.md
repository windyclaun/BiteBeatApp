# Plan: Apple Maps-based Meal Recommendation (Hybrid Maps + AI)

## Goal
Rework the meal-determination part of BiteBeat so recommendations are driven by **real nearby restaurants from Apple Maps**, with Apple Intelligence synthesizing plausible dishes per restaurant (matched to the user's music vibe). Location is primary; music vibe filters dish selection. Interactive Map + per-restaurant drill-in. Keep existing MVVM `@Observable` architecture, folder structure, Ending celebration, and Liquid Glass conventions from the prior refactor.

## Locked decisions (from planning interview)
1. **Menu source**: Hybrid — real places from Apple Maps + AI-suggested dishes (NOT literal scraped menus; Apple Maps exposes no menu API).
2. **Vibe vs proximity**: Location primary (nearest restaurants), music vibe filters which dish to pick at each restaurant.
3. **Structure**: Top-3 nearest restaurants; main meal = best-vibe dish at restaurant #1; alternatives = dishes at #2 and #3; tap a restaurant marker → drill-in detail listing several AI dishes for that one real restaurant.
4. **Location permission**: Just-in-time at "Analyze My Mood" tap; if denied/unavailable → fallback to current pure-AI flow (foods.json + dummy place) + a banner prompting to enable location.
5. **Map visualization**: Embedded interactive MapKit SwiftUI map with 3 markers + drill-in; chosen meal carries an "Open in Maps" navigation button.
6. **Food ban rule**: Remove the bakso/aci ban in the AI prompt; follow whatever the real nearby place serves.

## Affected boundaries (files)
New:
- `Services/LocationManager.swift` — `@Observable`, CoreLocation `CLLocationManager`, one-shot current location + authorization status, injected via `.environment` (mirror `MusicSessionManager` pattern).
- `Services/NearbyRestaurantFinder.swift` — MapKit `MKLocalSearch`/`MKLocalPointsOfInterestRequest`, category `.restaurant`, region around user, returns `[NearbyRestaurant]` sorted by distance.
- New drill-in subview under `Pages/Views/Recommendation/` (or `Pages/Components/`) — per-restaurant dish list.

Changed:
- `Services/MusicToFoodAnalyzer.swift` — rework prompt: feed real restaurant names (cuisine inferred from name), music vibe, foods.json; **remove bakso/aci ban**; batch one AI call returning dishes for all 3 restaurants; decode per-restaurant.
- `Services/MusicToFoodAnalyzer.swift` `Meal` model — add optional real-place fields (see Data model below).
- `Pages/Views/Recommendation/RecommendationView.swift` — rework to Maps-driven: interactive Map (3 markers, region around user), main meal card, drill-in on marker tap, "Open in Maps".
- `Pages/Views/Ending/` + `EndingMealDetailSheet` — show real address + distance + "Open in Maps" (`MKMapItem.openInMaps`).
- `Pages/Views/Home/HomeView.swift` + `HomeViewModel.swift` — orchestrate: request location just-in-time, call NearbyRestaurantFinder, branch to Maps flow vs fallback AI flow.
- `Pages/Components/AnalysisLoadingView.swift` + its VM — extend workflow to also fetch location + nearby restaurants + batch AI dish synthesis (with fallback).
- `BiteBeat.xcodeproj/project.pbxproj` — add `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription` (Debug+Release) and add new Swift files to target.

Unchanged: `BiteBeatMusic` package, folder structure, MVVM pattern, Ending celebration animation, Liquid Glass conventions, `BiteBeatTypography`, `DailyMealSelectionStore` (cascades via Codable Meal).

## Data model
Extend `Meal` (Codable) with optional real-place fields (all optional so fallback dummy meals still decode):
- `restaurantName: String?` (real MKMapItem name)
- `restaurantAddress: String?` (formatted address)
- `latitude: Double?`, `longitude: Double?`
- `distanceInMeters: Double?`
- `mapItemIdentifier: String?` (MKMapItem.Identifier.rawValue, for re-fetch / openInMaps)
- `phoneNumber: String?`, `websiteURL: String?`
Keep existing: title, price, calories, description, systemImage, gradientColors, imageUrl (Wikipedia dish image), crazyFunDescription. `restaurantName` computed var updated to prefer the real field when present.

`NearbyRestaurant` (intermediate, Sendable): name, address, coordinate, distance, mapItemIdentifier, phoneNumber, url, poiCategory.

## Data flow
1. User taps "Analyze My Mood" (HomeView).
2. Just-in-time: `LocationManager` requests WhenInUse auth → current coordinate.
   - Denied/unavailable/timeout → fallback path (skip to step 5b).
3. `NearbyRestaurantFinder.search(near: coordinate, radius: ~2km, category: .restaurant)` → sort by distance → top 3. If <1 found → widen radius once (~5km); still none → fallback.
4. `MusicToFoodAnalyzer.analyze(songs:nearbyRestaurants:)` — ONE batch AI call: pass restaurant names (+ vibe + foods.json), returns dishes per restaurant. Pick main = best-vibe dish @ restaurant #1; alts = dishes @ #2, #3; each restaurant also gets a fuller dish list for drill-in.
5a. Navigate to reworked RecommendationView (Maps flow): Map with 3 markers, main meal card, tap marker → drill-in dish list for that restaurant, pick → EndingView.
5b. Fallback path: existing pure-AI analyze(songs:) → current RecommendationView behavior (dummy place) + banner "Enable location for real nearby restaurants."
6. EndingView/MealDetailSheet: real address + distance + "Open in Maps" (`MKMapItem` reconstructed from identifier/coordinate → `openInMaps`).
7. `DailyMealSelectionStore.save(meal)` persists real-place fields (Codable cascade); Profile history shows real places.

## Implementation tasks (ordered)
1. Add `NSLocationWhenInUseUsageDescription` to pbxproj (Debug+Release); add new file refs to target membership.
2. `LocationManager` (@Observable): auth status, `requestWhenInUseAuthorization()`, `currentLocation() async -> CLLocation?` with timeout.
3. `NearbyRestaurantFinder`: `search(near:radius:) async throws -> [NearbyRestaurant]` via `MKLocalSearch` natural-language "restaurant" or `MKLocalPointsOfInterestRequest` category `.restaurant`, region `MKCoordinateRegion` centered on user; map `MKMapItem` → `NearbyRestaurant`; sort by distance.
4. Extend `Meal` model with optional real-place fields; update `restaurantName` computed var.
5. Rework `MusicToFoodAnalyzer`: new `analyze(songs:nearbyRestaurants:)` batch method (keep old `analyze(songs:)` for fallback); remove bakso/aci ban; new JSON schema `{restaurants:[{name, dishes:[...]}]}`.
6. Rework `RecommendationView` to Maps-driven: `Map` + 3 `Marker`s/annotations, region around user, main meal card (nearest restaurant's best-vibe dish), marker tap → drill-in sheet with that restaurant's dish list, pick → `onSelectMeal`.
7. Add drill-in subview: per-restaurant dish list (AI-suggested, labeled "Saran menu" not literal menu), each → onSelectMeal.
8. EndingView/EndingMealDetailSheet: show real address + distance + "Open in Maps" button (`MKMapItem.openInMaps`).
9. HomeView/HomeViewModel + AnalysisLoadingView/VM: orchestrate location → Maps → batch AI, with fallback branch + banner.
10. Verify `DailyMealSelectionStore`/Profile history render real-place fields.

## Liquid Glass & skill compliance
- New Map screen = content layer (no glass on map). Controls/drill-in sheet/buttons use `.glass`/`.glassProminent` per prior refactor conventions.
- No hardcoded colors/sizes; semantic colors & `biteBeatFont` (already semantic).
- `os.Logger` (no `print`) for new services.
- `NavigationPath` type-safe routing for new screens (extend `HomeRoute`/add `RecommendationRoute` as needed).
- Documentation-first: verify `MKLocalSearch`, `MKLocalPointsOfInterestRequest`, `MKMapItem.openInMaps`, `Map` (MapKit SwiftUI), `CLLocationManager` via sosumi before use.

## Failure modes & fallbacks
- Location denied/unavailable/timeout → pure-AI fallback + banner.
- No restaurants within radius → widen radius once → still none → pure-AI fallback.
- AI unavailable (Apple Intelligence off) → existing `fallbackRecommendation` path (dummy meal) but now clearly without real places.
- Sparse Indonesia POI coverage in Apple Maps → adaptive radius; document as known limitation.
- AI batch latency → single batched call (not per-restaurant round-trips); keep AnalysisLoadingView progress animation.

## Risks / open notes
- **Menu truth gap**: dishes are AI-suggested, NOT real menus (Apple Maps gives no menu API). UI must label suggestions as "Saran menu" / "AI-suggested dishes", not literal menus. This is the core honesty constraint.
- POI coverage in Indonesia may be thin for some areas — fallback covers it.
- `MKMapItem` reconstructed from stored identifier may fail re-fetch → fall back to coordinate-based `MKMapItem.init(location:address:)` for openInMaps.

## Validation
- `xcodebuild -project BiteBeat.xcodeproj -scheme BiteBeat -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Debug build` → `** BUILD SUCCEEDED **`, 0 error / 0 new warning.
- Simulator: set a simulated location (Features → Location) to test Maps flow.
- Test fallback path: deny location → confirm pure-AI flow + banner still works.
- `#Preview` for each new/changed screen with realistic sample data.
- Run diagnostics on every modified file.
