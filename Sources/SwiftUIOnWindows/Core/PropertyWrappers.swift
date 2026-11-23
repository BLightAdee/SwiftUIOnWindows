// PropertyWrappers.swift - SwiftUI state management
// SwiftUIOnWindows - A SwiftUI compatibility layer for Windows

import Foundation

// MARK: - StateStorage

internal final class StateStorage<Value>: @unchecked Sendable {
    private var _value: Value
    private var _observers: [() -> Void] = []

    init(_ value: Value) { self._value = value }

    var value: Value {
        get { _value }
        set {
            _value = newValue
            for observer in _observers { observer() }
            StateManager.shared.scheduleUpdate()
        }
    }

    func addObserver(_ observer: @escaping () -> Void) {
        _observers.append(observer)
    }
}

// MARK: - State

@propertyWrapper
public struct State<Value>: @unchecked Sendable {
    private let storage: StateStorage<Value>

    public init(wrappedValue: Value) {
        self.storage = StateStorage(wrappedValue)
    }

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        Binding(get: { self.storage.value }, set: { self.storage.value = $0 })
    }
}

// MARK: - Binding

@propertyWrapper
public struct Binding<Value>: @unchecked Sendable {
    private let getter: () -> Value
    private let setter: (Value) -> Void

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.getter = get; self.setter = set
    }

    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public var projectedValue: Binding<Value> { return self }

    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}

// MARK: - ObservableObject

public protocol ObservableObject: AnyObject {
    var objectDidChange: ObservableObjectPublisher { get }
}

public final class ObservableObjectPublisher: @unchecked Sendable {
    private var observers: [() -> Void] = []
    public init() {}

    public func send() {
        for observer in observers { observer() }
        StateManager.shared.scheduleUpdate()
    }

    internal func addObserver(_ observer: @escaping () -> Void) {
        observers.append(observer)
    }
}

// MARK: - Published

@propertyWrapper
public struct Published<Value> {
    private var _value: Value
    public init(wrappedValue: Value) { self._value = wrappedValue }
    public var wrappedValue: Value {
        get { _value }
        set { _value = newValue }
    }
    public var projectedValue: Published<Value> {
        get { self }
        set { self = newValue }
    }
}

// MARK: - ObservedObject

@propertyWrapper
public struct ObservedObject<ObjectType: ObservableObject>: @unchecked Sendable {
    private let object: ObjectType
    public init(wrappedValue: ObjectType) { self.object = wrappedValue }
    public var wrappedValue: ObjectType { return object }

    public var projectedValue: Wrapper { Wrapper(object: object) }

    public struct Wrapper {
        let object: ObjectType
        public subscript<Value>(
            dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Value>
        ) -> Binding<Value> {
            Binding(get: { self.object[keyPath: keyPath] },
                    set: { self.object[keyPath: keyPath] = $0 })
        }
    }
}

// MARK: - StateObject

@propertyWrapper
public struct StateObject<ObjectType: ObservableObject>: @unchecked Sendable {
    private let storage: StateStorage<ObjectType>
    public init(wrappedValue: @autoclosure @escaping () -> ObjectType) {
        self.storage = StateStorage(wrappedValue())
    }
    public var wrappedValue: ObjectType { return storage.value }
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        ObservedObject<ObjectType>.Wrapper(object: storage.value)
    }
}

// MARK: - EnvironmentObject

@propertyWrapper
public struct EnvironmentObject<ObjectType: ObservableObject>: @unchecked Sendable {
    private var _object: ObjectType?
    public init() { self._object = EnvironmentStorage.shared.get(ObjectType.self) }
    public var wrappedValue: ObjectType {
        guard let obj = _object ?? EnvironmentStorage.shared.get(ObjectType.self) else {
            fatalError("No environment object of type \(ObjectType.self) found.")
        }
        return obj
    }
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        ObservedObject<ObjectType>.Wrapper(object: wrappedValue)
    }
}

// MARK: - Environment Storage

internal final class EnvironmentStorage: @unchecked Sendable {
    static let shared = EnvironmentStorage()
    private var objects: [String: AnyObject] = [:]
    private init() {}

    func set<T: ObservableObject>(_ object: T) {
        objects[String(describing: T.self)] = object
    }
    func get<T: ObservableObject>(_ type: T.Type) -> T? {
        objects[String(describing: T.self)] as? T
    }
}

// MARK: - Environment

@propertyWrapper
public struct Environment<Value>: @unchecked Sendable {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) { self.keyPath = keyPath }
    public var wrappedValue: Value { EnvironmentValues.current[keyPath: keyPath] }
}

public struct EnvironmentValues: Sendable {
    public static var current = EnvironmentValues()
    public var colorScheme: ColorScheme = .light
    public init() {}
}
