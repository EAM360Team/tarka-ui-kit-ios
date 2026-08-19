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

  /// Shows a tooltip anchored directly below this view.
  ///
  /// Dismissing on a tap *outside* the tooltip is the caller's job: the tooltip cannot see
  /// taps beyond its own bounds, so put a full-screen dismiss layer behind it at screen
  /// level, or clear `isPresented` from the control that set it.
  ///
  /// - Parameters:
  ///   - isPresented: Whether the tooltip is showing
  ///   - width: Width of the tooltip card
  ///   - tooltip: The tooltip to show, built only while it is presented
  ///
  func tooltip(isPresented: Binding<Bool>,
               width: CGFloat = 272,
               _ tooltip: @autoclosure @escaping () -> TUITooltip) -> some View {
    modifier(TUITooltipModifier(isPresented: isPresented, width: width, tooltip: tooltip))
  }
}

/// Places a tooltip below its anchor by measuring the anchor and offsetting by its height.
///
/// An earlier version leaned on `alignmentGuide` to align the tooltip's top edge to the
/// anchor's bottom. That reads well but did not hold in a real row, where the tooltip landed
/// over the anchor and hid it — hence the explicit measurement.
struct TUITooltipModifier: ViewModifier {

  @Binding var isPresented: Bool
  let width: CGFloat
  let tooltip: () -> TUITooltip

  @State private var anchorHeight: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .background(heightReader)
      .overlay(alignment: .topTrailing) {
        if isPresented {
          tooltip()
            .frame(width: width)
            .offset(y: anchorHeight)
            .onTapGesture { isPresented = false }
            .zIndex(1)
        }
      }
      .zIndex(isPresented ? 1 : 0)
  }

  private var heightReader: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear { anchorHeight = proxy.size.height }
        .onChange(of: proxy.size.height) { newHeight in
          anchorHeight = newHeight
        }
    }
  }
}
