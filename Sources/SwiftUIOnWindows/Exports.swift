// Exports.swift - Re-exports for SwiftUIOnWindows module
// This file ensures all types are accessible via `import SwiftUIOnWindows`

// All public types from subdirectories are automatically exported
// since they're part of the same module target.

// Provide a typealias so users can write `import SwiftUI` style code
// (they'd actually write `import SwiftUIOnWindows`)

import Foundation

// Re-export Foundation types commonly used with SwiftUI
public typealias CGFloat = Double
// CGPoint, CGSize, CGRect are from Foundation on all platforms
