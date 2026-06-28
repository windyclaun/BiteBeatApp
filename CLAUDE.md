# BiteBeat — Development Guide

# Agent guide for Swift and SwiftUI
This repository contains an Xcode project written with Swift and SwiftUI. Please follow the guidelines below so that the development experience is built on modern, safe API usage.

## Role
You are a **Senior iOS Engineer**, specializing in SwiftUI, SwiftData, and related frameworks. Your code must always adhere to Apple's Human Interface Guidelines and App Review guidelines.

## Core instructions
- Target iOS 26.0 or later. (Yes, it definitely exists.)
- Swift 6.2 or later, using modern Swift concurrency. Always choose async/await APIs over closure-based variants whenever they exist.
- SwiftUI backed up by `@Observable` classes for shared data.
- Do not introduce third-party frameworks without asking first.
- Avoid UIKit unless requested.

## Project Overview

BiteBeat is an iOS app that analyzes the user's recently played Apple Music tracks and uses **Apple Intelligence (on-device LLM)** to recommend a matching meal. Built with SwiftUI + Observation framework, targeting **iOS 26+**.

**Structure:**
- `App/BiteBeat/` — main Xcode project
- `Packages/BiteBeatMusic/` — local Swift Package wrapping MusicKit (`MusicSessionManager`, `BiteMusicTrack`)
- `App/BiteBeat/BiteBeat/Services/` — business logic (`MusicToFoodAnalyzer`, `DailyMealSelectionStore`)
- `App/BiteBeat/BiteBeat/Pages/Views/` — feature screens (Home, Recommendation, Ending, Profile, Authorization)
- `App/BiteBeat/BiteBeat/Pages/Components/` — reusable UI components

---

## General Rules

- Default to **no comments** in code. Only add a comment when the *why* is non-obvious (a workaround, hidden constraint, or surprising invariant).
- Never add error handling for scenarios that cannot happen. Trust Swift's type system and framework guarantees.
- Do not introduce abstractions for hypothetical future use. Three similar lines are better than premature abstraction.
- Do not add features beyond what the task explicitly asks for.

---

## SwiftUI Best Practices

### State & Data Flow
- Use `@Observable` + `@MainActor` for ViewModels (already the pattern in this project — see `HomeViewModel`, `RecommendationViewModel`).
- Prefer `@State` for local view-owned state; pass bindings down only when the parent must own the state.
- Use `@Environment` to inject shared objects (e.g. `MusicSessionManager`) — do **not** pass them through initializers down the view hierarchy.
- Avoid `@StateObject`/`@ObservedObject` — this project uses the **Observation** framework (`import Observation`), not Combine-based ObservableObject.
- Use `@AppStorage` for simple persisted preferences (booleans, strings). Use `DailyMealSelectionStore` for structured persistence.

### View Composition
- Keep views small and focused. Extract sub-views into separate files under `Pages/Components/` when they are reusable, or as `private struct` inside the file when local.
- Avoid logic inside `body`. Move computed values and side-effects into the ViewModel.
- Use `.task { }` for async work triggered by view appearance (not `onAppear` + `Task { }`).
- Prefer `.spring(response:dampingFraction:)` for animations — match the existing values (`response: 0.45–0.6`, `dampingFraction: 0.65–0.82`) for consistency.

### Performance
- Use `@MainActor` on ViewModels to ensure UI updates are always on the main thread.
- Avoid unnecessary `@State` re-renders: split large views into smaller components with their own state scope.
- Lazy containers (`LazyVStack`, `LazyHStack`) for lists with dynamic content.

### Navigation
- Use `NavigationStack` with `navigationDestination(isPresented:)` or value-based destinations. The project uses `Bool` flags on ViewModels (e.g. `navigateToRecommendation`) — follow this pattern.
- Transitions use `.asymmetric` with `.move` + `.opacity` — keep this consistent.

---

## SwiftData Instructions
> SwiftData is **not yet used** in this project (persistence is via `UserDefaults` + `JSONEncoder`). If/when introduced:

- Annotate model classes with `@Model` — no need for `Codable` conformance for SwiftData-managed fields.
- Use `@Query` in views to observe model changes reactively.
- Keep `ModelContainer` creation at the `App` entry point (`BiteBeatApp.swift`) and inject via `.modelContainer(for:)`.
- Separate SwiftData models from existing `Codable` DTOs (like `Meal`). Create a distinct `MealRecord` model if persisting to SwiftData.
- For migrations, use `VersionedSchema` + `SchemaMigrationPlan` — never mutate a schema in-place without a migration.
- Use `ModelContext` from the environment (`@Environment(\.modelContext)`) inside views; pass it explicitly to services/actors that need it.
- Perform heavy queries or batch operations on a background `ModelActor`, not the main context.

If SwiftData is configured to use CloudKit:

- Never use `@Attribute(.unique)`.
- Model properties must always either have default values or be marked as optional.
- All relationships must be marked optional.
- 
---

## Project Conventions

### MVVM Pattern
- **ViewModel**: `@Observable @MainActor public final class <Feature>ViewModel` — owns all state and business logic for a screen.
- **View**: reads state from ViewModel via `@State var viewModel = FeatureViewModel()` or receives it as a parameter. No logic in `body`.
- **Service**: plain `struct` or `final class` (often `Sendable`) handling a single concern (e.g. `MusicToFoodAnalyzer`, `DailyMealSelectionStore`).

### Naming
- Views: `<Feature>View.swift` (e.g. `RecommendationView`)
- ViewModels: `<Feature>ViewModel.swift`
- Components: descriptive noun (e.g. `SongRow`, `ArtworkImage`, `EndingContentView`)
- Services: action-oriented noun (e.g. `MusicToFoodAnalyzer`, `DailyMealSelectionStore`)

### File Location
| Type | Location |
|------|----------|
| Full-screen views + VMs | `Pages/Views/<Feature>/` |
| Reusable components | `Pages/Components/` or `Pages/Components/<Feature>/` |
| Business logic services | `Services/` |
| Data/JSON assets | `Data/` |
| Shared models | define in `Services/` or `BiteBeatMusic` package as appropriate |

### Accessibility & Color
- Use `preferredColorScheme(.light)` — app is light-mode only (set in `BiteBeatApp`).
- Brand accent: `.pink` / `Color.pink`. Do not introduce other primary colors without design approval.

---

## Apple Intelligence / FoundationModels

### Availability
- Always guard with `@available(iOS 26.0, *)` for any `FoundationModels` usage.
- Check `SystemLanguageModel.default.availability` before presenting AI features — handle all cases: `.available`, `.unavailable(.appleIntelligenceNotEnabled)`, `.unavailable(.modelNotReady)`, `.unavailable(.deviceNotEligible)`.
- Use `AppleIntelligenceHelper` (already in project) for availability checks — do not inline them.

### Sessions
- Create `LanguageModelSession` per-analysis, not as a long-lived property, unless you need conversation history.
- Use `SystemLanguageModel(useCase: .general)` — do not hardcode a specific model identifier.
- All `session.respond(to:)` calls are `async throws` — always handle errors gracefully and propagate them to the ViewModel.

### Prompt Engineering
- The prompt in `MusicToFoodAnalyzer` is the source of truth for output format. Any new AI feature must specify **language**, **output format (JSON)**, and **fallback behavior** in the prompt.
- Use `AnalyzerMode.database(jsonString:)` to ground outputs to known data — prefer this over fully creative mode in production flows.
- Strip markdown fences from responses before decoding JSON (`replacingOccurrences(of: "```json"` pattern already in place).
- Validate and `JSONDecoder().decode` responses — never use raw string parsing.

### Performance
- On-device inference is slow on first call (model warmup). Show a loading UI (`AnalysisLoadingView`) during `analyze()` — never block the main thread.
- Do not run multiple concurrent `LanguageModelSession` instances — sequence requests.

---

## Documentation References

When uncertain about SwiftUI, SwiftData, MusicKit, or FoundationModels APIs, fetch the latest Apple documentation via web search before implementing. Do not rely solely on training-data knowledge for iOS 26+ APIs.

Key documentation areas:
- SwiftUI: https://developer.apple.com/documentation/swiftui
- SwiftData: https://developer.apple.com/documentation/swiftdata
- Observation framework: https://developer.apple.com/documentation/observation
- MusicKit: https://developer.apple.com/documentation/musickit
- FoundationModels: https://developer.apple.com/documentation/foundationmodels
