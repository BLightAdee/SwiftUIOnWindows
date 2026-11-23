// Preferences.swift - PreferenceKey protocol and view modifiers
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

public protocol PreferenceKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static func reduce(value: inout Value, nextValue: () -> Value)
}

public extension View {
    func preference<K: PreferenceKey>(key: K.Type = K.self, value: K.Value) -> some View {
        self
    }

    func onPreferenceChange<K: PreferenceKey>(_ key: K.Type = K.self, perform action: @escaping (K.Value) -> Void) -> some View {
        self
    }

    func coordinateSpace<T: Hashable>(name: T) -> some View {
        self
    }
}
