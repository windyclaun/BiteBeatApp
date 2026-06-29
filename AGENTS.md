# BiteBeat — Agent Instructions

## Project Overview

| | |
|---|---|
| **App Name** | BiteBeat |
| **Platform** | iOS |
| **Minimum Target** | iOS 26.0+ |
| **Language** | Swift 5.0 |
| **UI Framework** | SwiftUI |
| **Project Path** | `c2-xcode/BiteBeatApp/App/BiteBeat/BiteBeat/` |

---

## Mandatory Skill

**Before writing any Swift/SwiftUI code**, activate the project skill:

```
Skill: apple-dev-standards
Location: c2-xcode/.agents/skills/apple-dev-standards/SKILL.md
```

---

## MCP Servers Available

| MCP Server | Tool(s) | Purpose |
|---|---|---|
| **sosumi** | `fetchAppleDocumentation`, `searchAppleDocumentation`, `fetchAppleVideoTranscript` | Apple official docs — PRIMARY source |
| **context7** | `resolve-library-id`, `query-docs` | Framework docs — SECONDARY source |
| **web** | `search_web` | LAST resort only |

Documentation lookup order: **sosumi → context7 → search_web** — never AI memory.

---

## Project File Structure

```
c2-xcode/
├── AGENTS.md
├── .agents/
│   └── skills/
│       └── apple-dev-standards/
│           └── SKILL.md
└── BiteBeatApp/
    └── App/BiteBeat/BiteBeat/
        ├── App/
        │   ├── BiteBeatApp.swift
        │   └── ContentView.swift
        ├── DesignSystem/
        │   ├── Spacing.swift
        │   ├── CornerRadius.swift
        │   ├── Typography.swift
        │   └── Color+Semantic.swift
        ├── Core/
        │   ├── Components/
        │   ├── Modifiers/
        │   ├── Extensions/
        │   └── Utilities/
        ├── Features/
        │   └── <FeatureName>/
        │       ├── Views/
        │       └── Models/
        ├── Models/
        ├── Services/
        ├── Data/
        └── Resources/
```

---

## Hard Rules

1. **No hardcoded colors or sizes** — semantic colors and `Font` styles only
2. **No deprecated APIs** — verify via sosumi before every API usage
3. **NavigationStack + NavigationPath** — never `NavigationView`
4. **@Observable** — never `ObservableObject`/`@Published`
5. **DRY** — extract repeated patterns
6. **No assumptions** — check documentation first
7. **No force unwraps** — use `guard`, `if let`, or `??`

---

## Build Validation

```bash
cd /Users/hisyam/Documents/ADA/XcodeProject/c2-xcode/BiteBeatApp
xcodebuild -workspace challange-2.xcworkspace -scheme BiteBeat \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build 2>&1 | tee /tmp/bitebeat_build.log | tail -5

grep -E "^(error:|warning:)" /tmp/bitebeat_build.log
```
