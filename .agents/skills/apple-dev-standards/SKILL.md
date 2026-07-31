---
name: apple-dev-standards
description: Senior Apple developer standards for the BiteBeat iOS project. Activate whenever writing, reviewing, or modifying any Swift/SwiftUI code. Enforces documentation-first MCP workflow (sosumi → context7 → web search, never AI memory), semantic colors/typography, DRY reusable patterns, zero deprecated API tolerance, and NavigationStack/NavigationPath navigation.
---

# Apple Developer Standards — BiteBeat Project

## MCP Documentation Workflow (MANDATORY)

Before writing ANY Apple framework API, check sources in this exact order:

### 1. sosumi (Primary — Apple Official Docs)
```
fetchAppleDocumentation(path: "/documentation/swiftui/navigationstack")
fetchAppleDocumentation(path: "/design/human-interface-guidelines/foundations/color")
```

### 2. context7 (Secondary)
```
resolve-library-id(libraryName: "SwiftUI", query: "NavigationStack path binding")
query-docs(libraryId: "/...", query: "NavigationStack with NavigationPath example")
```

### 3. search_web (Last resort)

### ❌ NEVER
- Use AI training memory for Apple API details
- Assume an API exists without verifying
- Use any API without confirming it is NOT deprecated

---

## Zero Deprecated API Tolerance

| ❌ Deprecated — NEVER use | ✅ Current — ALWAYS use | Since |
|---|---|---|
| `NavigationView` | `NavigationStack` + `NavigationPath` | iOS 16 |
| `.navigationBarItems` | `.toolbar` + `ToolbarItem(placement:)` | iOS 14 |
| `.navigationBarTrailing` | `.topBarTrailing` | iOS 16 |
| `ObservableObject` + `@Published` | `@Observable` macro | iOS 17 |
| `@StateObject` / `@ObservedObject` | `@State` with `@Observable` | iOS 17 |
| `@EnvironmentObject` | `@Environment` with `@Observable` | iOS 17 |
| `alert(isPresented:content:)` string | `.alert(_:isPresented:actions:message:)` | iOS 15 |

---

## Semantic Colors — ZERO Hardcoded Values

```swift
// ✅ CORRECT
.background(Color(.systemBackground))
.foregroundStyle(.primary)
.foregroundStyle(.secondary)
Color(.systemGroupedBackground)
Color(.secondarySystemGroupedBackground)

// ❌ NEVER
.foregroundStyle(.black)
.foregroundStyle(.white)
.background(.gray)
```

When a design requires a brand color:
1. Add as a **named Color Set** in `Assets.xcassets` with light/dark variants
2. Reference via `Color("BrandPrimary")` or a typed `extension Color`
3. Never embed hex directly in Swift code

---

## Semantic Typography — ZERO Hardcoded Sizes

```swift
// ✅ CORRECT
.font(.largeTitle)
.font(.title.weight(.semibold))
.fontDesign(.rounded)

// ❌ NEVER
.font(.system(size: 17))
.font(.custom("SF Pro", size: 17))
```

---

## Project File Structure

```
BiteBeat/
├── App/
│   └── BiteBeatApp.swift
├── DesignSystem/           # Design tokens
├── Core/
│   ├── Components/         # Reusable Views
│   ├── Modifiers/          # Reusable ViewModifiers
│   ├── Extensions/         # View+, Color+, etc.
│   └── Utilities/          # Formatters, helpers
├── Features/
│   └── <FeatureName>/
│       ├── Views/
│       └── Models/
├── Models/                 # Domain models (one per file)
├── Services/               # Business logic
├── Data/                   # Bundled JSON/MP3
└── Resources/              # Assets.xcassets
```

---

## SwiftUI Navigation

```swift
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    RootView()
        .navigationDestination(for: SomeModel.self) { model in
            DetailView(model: model)
        }
}
```

---

## State Management

| Property Wrapper | When to use |
|---|---|
| `@State` | Local view-owned state |
| `@Binding` | Mutable state passed from parent |
| `@Environment` | App-wide injected values |
| `@AppStorage` | UserDefaults-backed state |

- Use `@Observable` macro for view models
- Use `.task(id:)` for async work tied to view lifecycle

---

## DRY & Reusability Rules

1. UI pattern appears **more than once** → extract to `Core/Components/`
2. Modifier chain repeated → extract to `Core/Modifiers/`
3. Computed value repeated → extract to `Core/Extensions/`
4. Never copy-paste SwiftUI modifiers or view blocks

---

## Code Quality Non-Negotiables

- Every `View` has one single responsibility — split if >80 lines
- `#Preview` with realistic sample data
- `private` by default for helper functions and computed vars
- No force unwraps (`!`)
- No `print()` in production — use `os.Logger`
- No `// TODO:` or `// FIXME:` left in finished code

---

## Build Validation

```bash
cd /Users/hisyam/Documents/ADA/XcodeProject/c2-xcode/BiteBeatApp
xcodebuild \
  -workspace challange-2.xcworkspace \
  -scheme BiteBeat \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug \
  build 2>&1 | tee /tmp/bitebeat_build.log | tail -5

grep -E "^(error:|warning:)" /tmp/bitebeat_build.log
```
