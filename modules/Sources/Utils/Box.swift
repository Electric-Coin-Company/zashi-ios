//
//  Box.swift
//  modules
//
//  Created by Lukáš Korba on 2025-03-15.
//

private final class Ref<T: Equatable>: Equatable {
    var val: T
    init(_ v: T) {
        self.val = v
    }

    static func == (lhs: Ref<T>, rhs: Ref<T>) -> Bool {
        lhs.val == rhs.val
    }
}

@propertyWrapper
public struct Box<T: Equatable>: Equatable {
    private var ref: Ref<T>

    public init(_ x: T) {
        self.ref = Ref(x)
    }

    public var wrappedValue: T {
        get { ref.val }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
                return
            }
            ref.val = newValue
        }
    }

    public var projectedValue: Box<T> {
        self
    }
}

@propertyWrapper
public struct CoW<T> {
  private final class Ref {
    var val: T
    init(_ v: T) { val = v }
  }
  private var ref: Ref

  public init(wrappedValue: T) { ref = Ref(wrappedValue) }
  
  public var wrappedValue: T {
    get { ref.val }
    set {
      if !isKnownUniquelyReferenced(&ref) {
        ref = Ref(newValue)
        return
      }
      ref.val = newValue
    }
  }
}

//Restore automatic protocol conformance:
extension CoW: Equatable where T: Equatable {
  public static func == (lhs: CoW<T>, rhs: CoW<T>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension CoW: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension CoW: Decodable where T: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(T.self)
    self = CoW(wrappedValue: value)
  }
}

extension CoW: Encodable where T: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}
