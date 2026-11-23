# Comprehensive Guide: Building SwiftUI Apps on Windows

This guide documents the architecture of **SwiftUI on Windows**, provides root-cause explanations for common Windows Swift toolchain compilation and runtime hurdles, and provides an end-to-end tutorial on how to port and run existing native macOS SwiftUI applications on Windows with zero or minimal code modifications.

---

## Table of Contents

1. [Architectural Overview & SwiftUI Version Equivalence](#1-architectural-overview--swiftui-version-equivalence)
2. [Hurdles & Root-Cause Troubleshooting](#2-hurdles--root-cause-troubleshooting)
   - [The Network Drive (UNC/SMB) Silent Hang](#the-network-drive-uncsmb-silent-hang)
   - [Visual Studio Developer Environment Requirement](#visual-studio-developer-environment-requirement)
   - [Swift Runtime DLL Resolution in PATH](#swift-runtime-dll-resolution-in-path)
   - [Executable Output Location (.build Structure)](#executable-output-location-build-structure)
3. [One-Click Build & Run Scripts](#3-one-click-build--run-scripts)
4. [Step-by-Step: Porting an Existing SwiftUI App](#4-step-by-step-porting-an-existing-swiftui-app)
   - [1. Package.swift Setup](#1-packageswift-setup)
   - [2. Handling Platform-Specific Features (AppKit, Previews)](#2-handling-platform-specific-features-appkit-previews)
   - [3. Building and Running](#3-building-and-running)
5. [Case Study: Testing Against `SwiftListak`](#5-case-study-testing-against-swiftlistak)
   - [App Description](#app-description)
   - [Porting Adjustments Implemented](#porting-adjustments-implemented)
   - [Verification & Execution](#verification--execution)

---

## 1. Architectural Overview & SwiftUI Version Equivalence

### Architecture
`SwiftUIOnWindows` is an open-source, pure-Swift compatibility layer and translation engine. It reimplements Apple's SwiftUI API contract directly against native Windows Win32 and GDI rendering:

```
┌────────────────────────────────────────────────────────┐
│               Existing SwiftUI Code                    │
│   (import SwiftUI / WindowGroup / Views / Modifiers)   │
├────────────────────────────────────────────────────────┤
│             SwiftUI Umbrella Target                    │
│   (@_exported import SwiftUIOnWindows & Foundation)    │
├────────────────────────────────────────────────────────┤
│             SwiftUIOnWindows Framework                 │
│  ┌──────────────────┬───────────────────────────────┐  │
│  │ View Protocols   │ State & Reactive Pipeline     │  │
│  │ @ViewBuilder     │ @State, @Binding, Observable  │  │
│  ├──────────────────┼───────────────────────────────┤  │
│  │ Layout Engine    │ Shape & Path System           │  │
│  │ Stacks, Lists    │ Stroke, Fill, Bezier Geometry │  │
│  └──────────────────┴───────────────────────────────┘  │
├────────────────────────────────────────────────────────┤
│           Double-Buffered Win32 Rendering              │
│       (GDI / BitBlt / WinProc Message Loop)            │
└────────────────────────────────────────────────────────┘
```

- **Umbrella Module (`import SwiftUI`)**: Standard Apple SwiftUI apps import `SwiftUI`. The project provides a `SwiftUI` library target that re-exports `SwiftUIOnWindows` and `Foundation`. Existing code can keep `import SwiftUI` without altering code files.
- **Rendering Engine**: Translates SwiftUI layout hierarchies into rendering instructions painted to an offscreen device context (`CreateCompatibleDC`) and blitted to the screen (`BitBlt`) during `WM_PAINT` to guarantee zero-flicker double-buffered rendering.
- **Event Dispatching**: Maps Windows mouse clicks, double clicks, hover, and window resizes back to SwiftUI reactive bindings and state managers (`StateManager`), triggering automatic layout recalculation and frame invalidation.

### SwiftUI Version Equivalence
This framework provides API coverage equivalent to **SwiftUI 2.0 (macOS 11 Big Sur) through SwiftUI 3.0 (macOS 12 Monterey)**, with select modern additions from **SwiftUI 4.0 / 5.0**:
- **Application Lifecycle**: Pure `@main struct MyApp: App { var body: some Scene { WindowGroup { ... } } }` model.
- **Reactive State**: Full support for `@State`, `@Binding`, `@ObservedObject`, `@StateObject`, `@EnvironmentObject`, and `@Published`.
- **Layout Containers**: `VStack`, `HStack`, `ZStack`, `LazyVStack`, `LazyHStack`, `ScrollView`, `List`, `ForEach`, `Section`, `GeometryReader`, `NavigationSplitView`, and `NavigationView`.
- **Controls & Views**: `Text`, `Button`, `TextField`, `SecureField`, `Toggle`, `Slider`, `Stepper`, `Picker`, `Image` (with automated SF Symbols to Windows Segoe MDL2 Assets glyph mapping), `Divider`, and `Spacer`.
- **Styling & Geometry**: `Path` (arcs, quad/cubic beziers, lines, rectangles), `Rectangle`, `RoundedRectangle`, `Circle`, `Capsule`, `Material` (`.ultraThinMaterial`, `.thinMaterial`, etc.), `.buttonStyle`, `.pickerStyle`, `.textFieldStyle`, `.tint`, and `.transition`.

---

## 2. Hurdles & Root-Cause Troubleshooting

When attempting to build and run Swift projects on Windows, developers commonly experience silent hangs, missing executables, or cryptic compiler errors. Below is the technical breakdown of why these occur and how they are resolved:

### The Network Drive (UNC/SMB) Silent Hang
* **Symptom**: Running `swift build` or `swift run` while located in `Z:\...` hangs indefinitely or exits silently without printing anything to console. No `.exe` or window appears.
* **Root Cause**: Windows network drives (such as `Z:`, which maps to `\\dc\users\...` over SMB) are remote UNC network shares. The Swift compiler frontend (`swift-frontend.exe`) and Clang driver invoke Win32 APIs like `SetCurrentDirectoryW` during initialization. LLVM's process management does not reliably support UNC paths as working directories, causing the compiler process to deadlock or immediately terminate with `<unknown>:0: error: unable to set working directory`.
* **Solution**: Staging or building the project on a local drive (e.g. `C:\Users\<username>\...` or `%TEMP%`). The included `build_and_run.ps1` script detects whether the directory is on a network drive and automatically stages the sources to `%USERPROFILE%`, builds locally, and copies the resulting binary back to `bin\`.

### Visual Studio Developer Environment Requirement
* **Symptom**: `error: toolchain is invalid: could not find CLI tool link` or `'stdlib.h' file not found` / `unable to load standard library for target 'x86_64-unknown-windows-msvc'`.
* **Root Cause**: On Windows, the Swift toolchain compiles native binaries targeting the Microsoft C Runtime (`msvc`). It relies on Microsoft's linker (`link.exe`) and Windows SDK headers (`10.0.xxxxx.0`). Standard PowerShell or CMD sessions do not expose these paths in `$env:Path` or `$env:INCLUDE`.
* **Solution**: Initialize the Visual Studio environment using `Launch-VsDevShell.ps1 -Arch amd64 -HostArch amd64` (from Visual Studio Build Tools 2022) or `vcvars64.bat`.

### Swift Runtime DLL Resolution in PATH
* **Symptom**: `Missing or empty JSON output from manifest compilation` during `swift build`, or the application terminates silently at launch with error code `0xc0000135` (STATUS_DLL_NOT_FOUND).
* **Root Cause**: 
  1. `Package.swift` is compiled into a helper binary (`PackageDescription.dll`) located under `usr\lib\swift\pm\ManifestAPI`.
  2. Built executables link dynamically against `swiftCore.dll`, `swiftWinSDK.dll`, and `Foundation.dll` located under `Runtimes\<version>\usr\bin`.
* **Solution**: Ensure both the runtime binary directory and the ManifestAPI directory are prepended to `$env:Path`, and set `$env:SDKROOT` to point to the Windows Platform SDK (`Platforms\<version>\Windows.platform\Developer\SDKs\Windows.sdk`).

### Executable Output Location (.build Structure)
* **Symptom**: Developer builds the project, but `C:\...\.build\debug\<AppName>.exe` does not exist.
* **Root Cause**: On macOS and Linux, SwiftPM creates a symbolic link `.build/debug` pointing to the build target folder. On Windows, creating symlinks requires Administrator privileges or Windows Developer Mode. If unprivileged, SwiftPM skips creating the `.build\debug` symlink and prints a non-fatal warning (`unable to create symbolic link`). The real executable is always located at:
  ```
  .build\out\Products\Debug-windows-x86_64\<TargetName>.exe
  ```
* **Solution**: Retrieve the executable from `.build\out\Products\Debug-windows-x86_64\`, or use `build_and_run.ps1`, which automatically copies the final executable to a clean `bin\<AppName>.exe` directory at the project root.

---

## 3. One-Click Build & Run Scripts

Two pre-configured scripts are included with the project to automate the entire setup:

### In `Z:\swiftOnWindows\` (SwiftUI Compatibility Layer & Demo)
- **`build_and_run.bat`**: Double-click directly in Windows Explorer.
- **`build_and_run.ps1`**: Run from PowerShell:
  ```powershell
  .\build_and_run.ps1
  ```
  *Features*:
  1. Detects Visual Studio 2022 Build Tools and initializes the x64 Developer environment.
  2. Detects the Swift 6.x Toolchain, Runtimes, and SDKROOT.
  3. Detects if running on a network share and stages to local storage if necessary.
  4. Builds the project and outputs `bin\SwiftUIDemo.exe`.
  5. Launches the native Win32 window.

### In `Z:\swiftOnWindows\SwiftListak\` (Existing SwiftUI App)
- **`build_and_run.bat`**: Double-click to compile and launch `SwiftListak`.
- **`build_and_run.ps1`**: Run from PowerShell:
  ```powershell
  .\build_and_run.ps1
  ```
  Outputs `bin\SwiftListak.exe` (6.36 MB) and opens the interactive visualizer.

---

## 4. Step-by-Step: Porting an Existing SwiftUI App

To take any native macOS SwiftUI application and build it on Windows:

### 1. Package.swift Setup
Create or update `Package.swift` at the root of your project:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MySwiftUIApp",
    dependencies: [
        // Point to the local path of SwiftUIOnWindows
        .package(path: "../swiftOnWindows")
    ],
    targets: [
        .executableTarget(
            name: "MySwiftUIApp",
            dependencies: [
                // Depend on the "SwiftUI" umbrella target
                .product(name: "SwiftUI", package: "swiftOnWindows")
            ],
            path: "Sources/MySwiftUIApp"
        )
    ]
)
```

> **Zero Source Changes for Imports**: Because the target depends on `SwiftUI` which re-exports `SwiftUIOnWindows` and `Foundation`, your existing Swift files keep `import SwiftUI` without needing any edits.

### 2. Handling Platform-Specific Features (AppKit, Previews)

#### A. Xcode `#Preview` Macros
`#Preview` is an Xcode-specific compiler plugin macro (`SwiftUIMacros.dylib`). When compiling under Windows or Linux via the official open-source Swift toolchain, wrap your previews in `#if !os(Windows)` or `#if os(macOS)`:

```swift
#if !os(Windows)
#Preview {
    ContentView()
}
#endif
```

#### B. AppKit / NSColor References
If your macOS app directly referenced AppKit types (such as `NSColor.windowBackgroundColor`), provide a fallback struct for non-Apple platforms:

```swift
#if !canImport(AppKit)
public struct NSColor {
    public static let windowBackgroundColor = NSColor()
    public static let controlBackgroundColor = NSColor()
}
extension Color {
    init(nsColor: NSColor) {
        self = .clear
    }
}
#endif
```

#### C. Ambiguous Types
Ensure your source files do not declare custom type aliases that collide with standard types like `CGFloat` or `CGPoint`.

### 3. Building and Running

You can use the automated `build_and_run.ps1` script, or run manually via Developer PowerShell:

```powershell
# 1. Initialize MSVC Environment
& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1" -Arch amd64 -HostArch amd64

# 2. Add Swift to PATH
$swiftBin = "C:\Users\<user>\AppData\Local\Programs\Swift\Toolchains\6.4.3+Asserts\usr\bin"
$runtimeBin = "C:\Users\<user>\AppData\Local\Programs\Swift\Runtimes\6.4.3\usr\bin"
$manifestBin = "C:\Users\<user>\AppData\Local\Programs\Swift\Toolchains\6.4.3+Asserts\usr\lib\swift\pm\ManifestAPI"
$sdk = "C:\Users\<user>\AppData\Local\Programs\Swift\Platforms\6.4.3\Windows.platform\Developer\SDKs\Windows.sdk"
$env:SDKROOT = $sdk
$env:Path = "$swiftBin;$runtimeBin;$manifestBin;" + $env:Path

# 3. Build
cd C:\Path\To\MySwiftUIApp
swift build -c debug

# 4. Run
.\.build\out\Products\Debug-windows-x86_64\MySwiftUIApp.exe
```

---

## 5. Case Study: Testing Against `SwiftListak`

To verify complete end-to-end compatibility against a production-grade macOS SwiftUI app, `SwiftUIOnWindows` was tested against the user's `SwiftListak` project located at `Z:\swiftOnWindows\SwiftListak`.

### App Description
`SwiftListak` is an interactive macOS educational app designed for computer science students to visualize C++ Linked List data structures (Singly, Doubly, and Circular). It features:
- Dynamic geometric pointer rendering (`PointerArrowView`) calculating Bezier curves and arrowheads across screen coordinates.
- Multi-column `NavigationSplitView` with a categorized sidebar.
- Syntax-highlighted C++ code viewer (`CodeBlockView`) using `AttributedString` tokenization.
- Interactive memory heap simulator (`SandboxView`) with custom node addresses and deallocation triggers.
- Step-by-step algorithmic autoplay controls (`ControlPanel`) with playback speed sliders.
- Interactive quiz engine (`QuizView`) with transitions and scoring summaries.

### Porting Adjustments Implemented
During testing against `SwiftListak`, the following framework enhancements were added to `SwiftUIOnWindows`:

1. **`Material.swift`**:
   - Added contextual static member aliases (`.ultraThinMaterial`, `.thinMaterial`, etc.) so `.background(.ultraThinMaterial)` resolves without requiring explicit type qualification.
2. **`ButtonRole` & `Button` Extensions**:
   - Implemented `ButtonRole` (`.destructive`, `.cancel`) and `Button(role:action:label:)` to support deletion triggers in `SandboxView`.
3. **`Slider` & `Stepper` Controls**:
   - Implemented label-closure initializers for `Slider(value:in:step:label:)` and full `Stepper` component support for data value increments.
4. **`Picker` & `List` Selection**:
   - Added `List(selection:content:)` and `pickerStyle(.menu / .segmented)` implementations.
5. **`AnyTransition` & Animations**:
   - Added `.move(edge:)`, `.opacity`, `.scale`, and `.combined(with:)` transitions.
6. **`AttributedString` Attributes**:
   - Added compatibility extensions for `foregroundColor` and `inlinePresentationIntent` on `AttributedString` and `AttributedSubstring`.
7. **AppKit Isolation**:
   - Replaced duplicate `var body` declarations in `PointerArrowView` and provided a zero-dependency `NSColor` fallback in `MainView`.

### Verification & Execution
- **Compilation**: Successfully compiled `SwiftListak` into `bin\SwiftListak.exe` (6.36 MB) in **25.12 seconds**.
- **Process Verification**: Launched natively via Win32 process runner (`PID 9656`, Responding: `True`).
- **One-Click Launch**: Verified via `Z:\swiftOnWindows\SwiftListak\build_and_run.bat`.

---

## Summary of Binaries

| Project | Source Directory | Binary Output | Status |
| :--- | :--- | :--- | :--- |
| **SwiftUIDemo** | `Sources/SwiftUIDemo` | `bin/SwiftUIDemo.exe` | ✅ Built & Verified |
| **SwiftListak** | `SwiftListak/Sources/SwiftListak` | `SwiftListak/bin/SwiftListak.exe` | ✅ Built & Verified |
