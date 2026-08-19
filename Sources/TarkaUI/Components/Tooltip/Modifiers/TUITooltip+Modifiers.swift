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
  ///   - isPresented: Whether the tooltip is showing.
  ///   - width: Width of the tooltip card.
  ///   - arrowAlignment: Which edge the pointer sits near.
  ///   - content: The tooltip's content.
  ///
  func tooltip<Content: View>(
    isPresented: Binding<Bool>,
    width: CGFloat = 272,
    arrowAlignment: TUITooltipArrowAlignment = .trailing,
    @ViewBuilder content: @escaping () -> Content) -> some View {
      overlay(alignment: .bottomTrailing) {
        if isPresented.wrappedValue {
          TUITooltip(content)
            .arrowAlignment(arrowAlignment)
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
