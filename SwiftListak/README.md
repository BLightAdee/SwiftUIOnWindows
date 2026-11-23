# SwiftListak: C/C++ Linked List Educator for macOS

A native macOS application written in SwiftUI that visualizes and dynamically teaches the internal mechanics, memory allocation, and operations of **Linked Lists in C/C++**.

The application is built matching **native Apple & Xcode aesthetics**, including dynamic pointer tracking via SwiftUI Coordinate Spaces, interactive sandboxes, step-by-step code debugger walkthroughs, stack vs. heap allocation visualizers, and fully functional pointer simulators.

---

## 🛠️ How to Open and Run in Xcode

Because the project is fully organized as a modern **Swift Package (SPM)**, you can open and run it natively in Xcode with zero configuration:

1. **Launch Xcode** (version 15.0 or newer recommended).
2. Go to **File > Open...** (or double-click the `Package.swift` file).
3. Select the `SwiftListak` folder and click **Open**.
4. Xcode will automatically resolve the package structure and index the files.
5. Create a simple macOS App wrapper target in Xcode and import the components, or use the modular SwiftUI views directly inside your existing SwiftUI project.

### Running with a minimal Mac App wrapper:
If you created a new macOS App project in Xcode, you can simply **drag and drop** the `Sources/SwiftListak` directory directly into your project navigation sidebar. It has no external dependencies and relies entirely on native **SwiftUI** and **Foundation** libraries.

---

## 📂 Project Architecture

*   **`Theme/`**: Tailored typography, layout metrics, and Xcode-inspired color themes for syntax highlighting and pointer visualizations.
*   **`Models/`**: Core logic and virtual pointer step-by-step state-machines that drive the visual debugger.
*   **`Components/`**: Custom coordinate preference engines, syntax highlight viewers, and macOS style controls.
*   **`Views/`**: Rich educational lessons, heap/stack simulations, singly/doubly/circular visual debuggers, a sandbox builder, and dynamic quizzes.

---

## ✨ Features and Visual Highlights

- **Dynamic Coordinate-Based Arrow Renderers**: Pointers between memory nodes are drawn live using `CoordinateSpace` mapping and dynamic SwiftUI path curves. As nodes slide, transition, or fade, the pointers bend and adjust automatically.
- **Unified Inspector Panels**: A native sidebar inspector (like Xcode's Utility panel) lets you see the details of the selected node, edit values in real-time, and view the precise simulated hex address.
- **Synced debugger line highlighting**: Watch C++ instructions highlight step-by-step in sync with the nodes' physical pointer animations.
