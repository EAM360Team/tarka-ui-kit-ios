//
//  TUITooltip+Modifiers.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

public extension TUITooltip {

  /// Lines the pointer up with whatever opened the tooltip
  func arrowAlignment(_ alignment: TUITooltipArrowAlignment) -> Self {
    var newView = self
    newView.style.arrowAlignment = alignment
    return newView
  }

  /// Calls a message out below a divider, under the listed items
  ///
  /// - Parameters:
  ///   - message: The message to show, or `nil` to show none
  ///   - style: How to call it out. Defaults to `.error`
  ///
  func message(_ message: String?, style: MessageStyle = .error) -> Self {
    var newView = self
    newView.style.message = message
    newView.style.messageStyle = style
    return newView
  }
}

public extension View {

  /// Shows a tooltip anchored below this view.
  ///
  /// The tooltip is laid out as an overlay whose top edge meets this view's bottom edge, so
  /// it needs no coordinate-space measurement and scrolls with its anchor. It is drawn above
  /// later siblings, and tapping it dismisses itself.
  ///
  /// Dismissing on a tap *outside* the tooltip is the caller's job: the tooltip cannot see
  /// taps beyond its own bounds, so put a full-screen dismiss layer behind it at screen
  /// level, or clear `isPresented` from the control that set it.
  ///
  /// - Parameters:
  ///   - isPresented: Whether the tooltip is showing
  ///   - width: Width of the tooltip card
  ///   - tooltip: The tooltip to show
  ///
  func tooltip(isPresented: Binding<Bool>,
               width: CGFloat = 272,
               _ tooltip: @autoclosure @escaping () -> TUITooltip) -> some View {
    overlay(alignment: .bottomTrailing) {
      if isPresented.wrappedValue {
        tooltip()
          .frame(width: width)
          // Aligns the tooltip's top to the anchor's bottom, placing it just below.
          .alignmentGuide(VerticalAlignment.bottom) { $0[.top] }
          .onTapGesture { isPresented.wrappedValue = false }
          .zIndex(1)
      }
    }
    .zIndex(isPresented.wrappedValue ? 1 : 0)
  }
}
