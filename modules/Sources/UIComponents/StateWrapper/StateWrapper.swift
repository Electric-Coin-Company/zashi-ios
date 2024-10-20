//
//  StateWrapper.swift
//  modules
//
//  Created by Lukáš Korba on 20.10.2024.
//

import SwiftUI

public struct BoolStateWrapper<Content: View>: View {
    @State var value: Bool
    let content: (Binding<Bool>) -> Content
    
    public init(initialValue: Bool = true, @ViewBuilder content: @escaping (Binding<Bool>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }
    
    public var body: some View {
        content($value)
    }
}

public struct StringStateWrapper<Content: View>: View {
    @State var value: String
    let content: (Binding<String>) -> Content
    
    public init(initialValue: String = "", @ViewBuilder content: @escaping (Binding<String>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }
    
    public var body: some View {
        content($value)
    }
}
