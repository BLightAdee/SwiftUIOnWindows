# SwiftUI on Windows 🪟

A **SwiftUI compatibility layer** that lets you write, compile, and run **SwiftUI code natively on Windows** — no macOS required.

> **Write once in SwiftUI. Run on Windows.**

## ✨ What is this?

This project is a **translation layer** that reimplements Apple's SwiftUI framework API on top of native Win32 and GDI rendering. You write standard SwiftUI code using familiar constructs like `VStack`, `Text`, `Button`, `@State`, and `@Binding` — and it compiles and runs as a native Windows application.

```swift
import SwiftUIOnWindows

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, Windows!")
                .font(.largeTitle)
                .foregroundColor(.blue)

            Text("Count: \(count)")
                .font(.title2)

            Button("Increment") {
                count += 1
            }
        }
        .padding(20)
    }
}
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              Your SwiftUI Code                  │
│   (Views, Modifiers, State, Layout)             │
├─────────────────────────────────────────────────┤
│          SwiftUIOnWindows Framework             │
│  ┌────────────┬────────────┬──────────────┐     │
│  │ View Proto │ ViewBuilder│ @State/      │     │
│  │ & Types    │ (result    │ @Binding/    │     │
│  │            │  builder)  │ @Observable  │     │
│  ├────────────┼────────────┼──────────────┤     │
│  │  Layout    │  Modifiers │   Shapes     │     │
│  │  Engine    │            │   & Paths    │     │
│  ├────────────┴────────────┴──────────────┤     │
│  │         Render Tree Builder            │     │
│  ├────────────────────────────────────────┤     │
│  │         Win32 GDI Renderer             │     │
│  ├────────────────────────────────────────┤     │
│  │    Win32 Window & Event Loop           │     │
│  └────────────────────────────────────────┘     │
├─────────────────────────────────────────────────┤
│            Windows OS (Win32 API)               │
└─────────────────────────────────────────────────┘
```

## 📦 Supported SwiftUI Features

### Views
| Feature | Status |
|---------|--------|
| `Text` | ✅ Full (font, color, weight, alignment, line limit) |
| `Button` | ✅ Full (label, action, styles) |
| `Image` | ✅ System symbols via SF→MDL2 mapping |
| `TextField` | ✅ Basic (placeholder, binding) |
| `SecureField` | ✅ Basic |
| `Toggle` | ✅ Full |
| `Slider` | ✅ Full |
| `Picker` | ✅ Basic |
| `ProgressView` | ✅ Basic |
| `Divider` | ✅ Full |
| `Spacer` | ✅ Full |

### Layout
| Feature | Status |
|---------|--------|
| `VStack` | ✅ Full (alignment, spacing) |
| `HStack` | ✅ Full (alignment, spacing) |
| `ZStack` | ✅ Full (alignment) |
| `LazyVStack`/`LazyHStack` | ✅ Basic |
| `ScrollView` | ✅ Basic |
| `List` | ✅ Basic |
| `ForEach` | ✅ Full (Identifiable, id:, Range) |
| `NavigationView`/`NavigationStack` | ✅ Basic |
| `NavigationLink` | ✅ Basic |
| `TabView` | ✅ Basic |
| `GeometryReader` | ✅ Full |
| `Group` | ✅ Full |
| `Form` | ✅ Basic |
| `Section` | ✅ Basic |

### State Management
| Feature | Status |
|---------|--------|
| `@State` | ✅ Full |
| `@Binding` | ✅ Full |
| `@ObservedObject` | ✅ Full |
| `@StateObject` | ✅ Full |
| `@EnvironmentObject` | ✅ Full |
| `@Environment` | ✅ Basic |
| `@Published` | ✅ Full |
| `ObservableObject` | ✅ Full |

### Modifiers
| Feature | Status |
|---------|--------|
| `.padding()` | ✅ Full (edges, length) |
| `.frame()` | ✅ Full (fixed and flexible) |
| `.background()` | ✅ Full |
| `.foregroundColor()` / `.foregroundStyle()` | ✅ Full |
| `.font()` | ✅ Full |
| `.cornerRadius()` | ✅ Full |
| `.border()` | ✅ Full |
| `.shadow()` | ✅ Full |
| `.opacity()` | ✅ Full |
| `.hidden()` | ✅ Full |
| `.disabled()` | ✅ Full |
| `.clipShape()` | ✅ Full |
| `.overlay()` | ✅ Full |
| `.rotationEffect()` | ✅ Full |
| `.scaleEffect()` | ✅ Full |
| `.offset()` | ✅ Full |
| `.onAppear()` / `.onDisappear()` | ✅ Full |
| `.navigationTitle()` | ✅ Full |
| `.tabItem()` | ✅ Basic |
| `.tag()` | ✅ Full |
| `.aspectRatio()` / `.scaledToFit()` | ✅ Full |
| `.lineLimit()` | ✅ Full |
| `.minimumScaleFactor()` | ✅ Full |
| `.environmentObject()` | ✅ Full |

### Shapes
| Feature | Status |
|---------|--------|
| `Rectangle` | ✅ Full |
| `RoundedRectangle` | ✅ Full |
| `Circle` | ✅ Full |
| `Ellipse` | ✅ Full |
| `Capsule` | ✅ Full |
| `Path` | ✅ Full (move, line, curve, arc) |
| `.fill()` / `.stroke()` | ✅ Full |

### App Lifecycle
| Feature | Status |
|---------|--------|
| `App` protocol | ✅ Full |
| `WindowGroup` | ✅ Full |
| `@main` | ✅ Full |
| `Scene` protocol | ✅ Full |

### Other
| Feature | Status |
|---------|--------|
| `@ViewBuilder` (up to 10 views) | ✅ Full |
| `if`/`else` in view builders | ✅ Full |
| `AnyView` type erasure | ✅ Full |
| `Color` (all system colors) | ✅ Full (macOS palette) |
| `Font` (all text styles) | ✅ Full (macOS sizing) |
| SF Symbols → Segoe MDL2 | ✅ 25+ symbols mapped |

## 🚀 Getting Started

### Prerequisites

1. **Swift for Windows** — Install via winget:
   ```powershell
   winget install Swift.Toolchain
   ```

2. **Git** — Installed automatically as a Swift dependency.

### Build & Run

```powershell
# Clone the repository
git clone https://github.com/YOUR_USERNAME/SwiftUIOnWindows.git
cd SwiftUIOnWindows

# Build
swift build

# Run the demo
swift run SwiftUIDemo
```

### Use in Your Project

Add SwiftUIOnWindows as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/SwiftUIOnWindows.git", from: "1.0.0")
]
```

Then import it:

```swift
import SwiftUIOnWindows

struct MyView: View {
    var body: some View {
        Text("Hello from Windows!")
    }
}
```

## 🔧 How It Works

### Translation Layer Architecture

1. **SwiftUI API Surface** — Implements the same protocols, structs, and property wrappers as Apple's SwiftUI (`View`, `@State`, `@ViewBuilder`, etc.)

2. **Layout Engine** — Computes view sizes and positions using SwiftUI's layout algorithm (parent proposes size → child returns ideal size → parent positions child)

3. **Render Tree Builder** — Traverses the view hierarchy and produces a flat list of render commands (text, rectangles, borders, etc.)

4. **Win32 GDI Renderer** — Translates render commands into Win32 GDI calls:
   - `Text` → `DrawTextW` with `CreateFontW` (Segoe UI for San Francisco parity)
   - Shapes → `FillRect`, `RoundRect`, `Ellipse` with GDI brushes/pens
   - Colors → macOS system color palette mapped to `COLORREF`

5. **Win32 Window** — Native window with:
   - Double-buffered painting (no flicker)
   - Mouse/keyboard event handling
   - Custom message for state-driven re-renders (`WM_USER + 100`)

### State Management

State changes trigger re-renders through the same mechanism as real SwiftUI:
1. `@State` property is modified
2. `StateStorage` notifies `StateManager`
3. `StateManager` posts `WM_SWIFTUI_UPDATE` to the Win32 message queue
4. Window procedure calls `InvalidateRect` → `WM_PAINT` → full re-render

## 📁 Project Structure

```
SwiftUIOnWindows/
├── Package.swift
├── Sources/
│   ├── SwiftUIOnWindows/
│   │   ├── Core/
│   │   │   ├── ViewProtocol.swift    # View, EmptyView, AnyView, TupleView
│   │   │   ├── ViewBuilder.swift     # @resultBuilder (up to 10 views)
│   │   │   ├── PropertyWrappers.swift # @State, @Binding, @ObservedObject, etc.
│   │   │   ├── StateManager.swift    # State change → re-render coordinator
│   │   │   ├── GeometryTypes.swift   # Edge, Alignment, Angle, etc.
│   │   │   ├── Color.swift           # Color with macOS system palette
│   │   │   └── Font.swift            # Font with macOS text styles
│   │   ├── Views/
│   │   │   ├── Text.swift            # Text view
│   │   │   ├── Button.swift          # Button view
│   │   │   ├── Image.swift           # Image with SF→MDL2 mapping
│   │   │   ├── TextField.swift       # TextField, SecureField
│   │   │   ├── Toggle.swift          # Toggle
│   │   │   ├── Slider.swift          # Slider
│   │   │   └── Picker.swift          # Picker
│   │   ├── Layout/
│   │   │   ├── Stacks.swift          # VStack, HStack, ZStack, Lazy variants
│   │   │   ├── Spacer.swift          # Spacer, Divider
│   │   │   ├── ScrollView.swift      # ScrollView
│   │   │   ├── List.swift            # List, ForEach, Section
│   │   │   ├── NavigationView.swift  # NavigationView, TabView, etc.
│   │   │   ├── GeometryReader.swift  # GeometryReader, GeometryProxy
│   │   │   ├── Group.swift           # Group, Form
│   │   │   └── LayoutEngine.swift    # Layout computation
│   │   ├── Modifiers/
│   │   │   └── ViewModifiers.swift   # All view modifiers (~30+)
│   │   ├── Shapes/
│   │   │   └── Shapes.swift          # Shape, Path, Rectangle, Circle, etc.
│   │   ├── Rendering/
│   │   │   ├── RenderContext.swift   # Render context & properties
│   │   │   ├── RenderTreeBuilder.swift # View tree → render commands
│   │   │   └── Win32Renderer.swift   # GDI rendering backend
│   │   ├── Platform/
│   │   │   └── Win32Window.swift     # Win32 window & event loop
│   │   ├── App/
│   │   │   └── AppProtocol.swift     # App, Scene, WindowGroup, @main
│   │   └── Exports.swift             # Module exports
│   └── SwiftUIDemo/
│       └── main.swift                # Demo application
├── README.md
├── LICENSE
└── .gitignore
```

## 🤝 Contributing

Contributions are welcome! Areas that could use improvement:

- **More complete layout engine** — Full flexbox-like layout with alignment, distribution
- **Animation system** — `withAnimation`, implicit/explicit animations
- **More controls** — `DatePicker`, `ColorPicker`, `TextEditor`, `Menu`
- **Accessibility** — Windows UI Automation support
- **Direct2D renderer** — Hardware-accelerated rendering (replace GDI)
- **WinUI 3 backend** — Modern Windows controls
- **Dark mode** — Automatic system theme detection

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

**Made with ❤️ by developers who believe SwiftUI should run everywhere.**
