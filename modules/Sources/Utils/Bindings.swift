import SwiftUI
import CasePaths

/// taken largely from: https://github.com/pointfreeco/episode-code-samples/blob/main/0167-navigation-pt8/SwiftUINavigation/SwiftUINavigation/SwiftUIHelpers.swift
extension Binding {
    public func isPresent<Wrapped>() -> Binding<Bool>
    where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public func isPresent<Enum, Case>(_ casePath: AnyCasePath<Enum, Case>) -> Binding<Bool>
    where Value == Enum? {
        Binding<Bool>(
            get: {
                if let wrappedValue = self.wrappedValue, casePath.extract(from: wrappedValue) != nil {
                    return true
                } else {
                    return false
                }
            },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public func `case`<Enum, Case>(_ casePath: AnyCasePath<Enum, Case>) -> Binding<Case?>
    where Value == Enum? {
        Binding<Case?>(
            get: {
                guard
                    let wrappedValue = self.wrappedValue,
                    let `case` = casePath.extract(from: wrappedValue)
                else { return nil }
                return `case`
            },
            
            set: { `case` in
                if let `case` = `case` {
                    self.wrappedValue = casePath.embed(`case`)
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }

    public func didSet(_ callback: @escaping (Value) -> Void) -> Self {
        .init(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                callback($0)
            }
        )
    }

    public init?(unwrap binding: Binding<Value?>) {
        guard let wrappedValue = binding.wrappedValue
        else { return nil }

        self.init(
            get: { wrappedValue },
            set: { binding.wrappedValue = $0 }
        )
    }

    public func map<T>(extract: @escaping (Value) -> T, embed: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { extract(wrappedValue) },
            set: { wrappedValue = embed($0) }
        )
    }

    public func compactMap<T>(extract: @escaping (Value) -> T, embed: @escaping (T) -> Value?) -> Binding<T> {
        Binding<T>(
            get: { extract(wrappedValue) },
            set: {
                guard let value = embed($0) else {
                    return
                }
                wrappedValue = value
            }
        )
    }
}
