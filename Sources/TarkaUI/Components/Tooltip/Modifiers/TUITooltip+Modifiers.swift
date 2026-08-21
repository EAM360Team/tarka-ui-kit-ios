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
