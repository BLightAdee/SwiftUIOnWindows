// TextField.swift - TextField and SecureField views
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public struct TextField: View {
    public typealias Body = Never
    internal let titleKey: String
    internal let text: Binding<String>

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey; self.text = text
    }

    public var body: Never { fatalError("TextField is a leaf view") }
}

public struct SecureField: View {
    public typealias Body = Never
    internal let titleKey: String
    internal let text: Binding<String>

    public init(_ titleKey: String, text: Binding<String>) {
        self.titleKey = titleKey; self.text = text
    }

    public var body: Never { fatalError("SecureField is a leaf view") }
}
