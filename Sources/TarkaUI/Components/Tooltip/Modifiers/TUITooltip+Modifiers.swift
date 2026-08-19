//
//  TUITooltip+Modifiers.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

public extension TUITooltip {

  /// Sets which edge the pointer sits on, and where along that edge
  func pointer(_ pointer: TUITooltipPointer) -> Self {
    var newView = self
    newView.style.pointer = pointer
    return newView
  }

  /// Aims the pointer at a control by its distance from the pointer's own edge
  ///
  /// Only applies to the pointers inset from a corner — `.top`, `.topRight` and `.bottom`.
  ///
  /// - Parameters:
  ///   - inset: Distance from that edge to the pointer's centre
  ///
  func pointerCenterInset(_ inset: CGFloat) -> Self {
    var newView = self
    newView.style.pointerCenterInset = inset
    return newView
  }

  /// Calls a validation message out below a divider, under the listed items
  ///
  /// - Parameters:
  ///   - message: The message to show, or `nil` to show none
  ///   - style: How to call it out. Defaults to `.error`
  ///
  func errorValidation(_ message: String?, style: MessageStyle = .error) -> Self {
    var newView = self
    newView.style.errorValidation = message
    newView.style.messageStyle = style
    return newView
  }
}

public extension View {

  /// Shows a tooltip anchored to this view, on the side its pointer faces.
  ///
  /// Dismissing on a tap *outside* the tooltip is the caller's job: the tooltip cannot see
  /// taps beyond its own bounds, so put a full-screen dismiss layer behind it at screen
  /// level, or clear `isPresented` from the control that set it.
  ///
  /// - Parameters:
  ///   - isPresented: Whether the tooltip is showing
  ///   - tooltip: The tooltip to show, built only while it is presented
  ///
  func tooltip(isPresented: Binding<Bool>,
               _ tooltip: @autoclosure @escaping () -> TUITooltip) -> some View {
    modifier(TUITooltipModifier(isPresented: isPresented, tooltip: tooltip))
  }
}

/// Places a tooltip beside its anchor, on whichever side the pointer faces.
///
/// The anchor is measured and the tooltip offset by that size. An earlier version leaned on
/// `alignmentGuide` instead, which reads well but left the tooltip over its anchor.
struct TUITooltipModifier: ViewModifier {

  @Binding var isPresented: Bool
  let tooltip: () -> TUITooltip

  @State private var anchorSize: CGSize = .zero

  func body(content: Content) -> some View {
    content
      .background(sizeReader)
      .overlay(alignment: overlayAlignment) {
        if isPresented {
          tooltip()
            .offset(x: offset.width, y: offset.height)
            .onTapGesture { isPresented = false }
            .zIndex(1)
        }
      }
      .zIndex(isPresented ? 1 : 0)
  }

  /// Which corner of the anchor the tooltip hangs from, given where its pointer faces.
  private var overlayAlignment: Alignment {
    switch tooltip().style.pointer {
    case .top, .topRight: return .topTrailing
    case .bottom: return .topLeading
    case .left: return .topTrailing
    case .right: return .topLeading
    }
  }

  /// A pointer on the top edge means the tooltip sits below the anchor, and so on round.
  private var offset: CGSize {
    switch tooltip().style.pointer {
    case .top, .topRight:
      return CGSize(width: 0, height: anchorSize.height)
    case .bottom:
      return CGSize(width: 0, height: -anchorSize.height)
    case .left:
      return CGSize(width: anchorSize.width, height: 0)
    case .right:
      return CGSize(width: -anchorSize.width, height: 0)
    }
  }

  private var sizeReader: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear { anchorSize = proxy.size }
        .onChange(of: proxy.size) { newSize in
          anchorSize = newSize
        }
    }
  }
}
