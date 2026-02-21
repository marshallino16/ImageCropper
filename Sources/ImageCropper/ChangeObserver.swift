//
//  ChangeObserver.swift
//
//  A ViewModifier that emulates `onChange(of:)` using Combine's `Just` publisher,
//  compatible with macOS 10.15+ and iOS 13+.
//

import SwiftUI
import Combine

struct ChangeObserver<V: Equatable>: ViewModifier {
  let value: V
  let action: (V) -> Void

  @State private var oldValue: V

  init(value: V, action: @escaping (V) -> Void) {
    self.value = value
    self.action = action
    _oldValue = State(initialValue: value)
  }

  func body(content: Content) -> some View {
    content
      .onReceive(Just(value)) { newValue in
        guard newValue != oldValue else { return }
        oldValue = newValue
        action(newValue)
      }
  }
}

extension View {
  func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
    modifier(ChangeObserver(value: value, action: action))
  }
}
