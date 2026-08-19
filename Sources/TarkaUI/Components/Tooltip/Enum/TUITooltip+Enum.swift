//
//  TUITooltip+Enum.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

/// Which edge of a `TUITooltip` the pointer sits on, and where along that edge.
///
/// Pick the one facing whatever opened the tooltip: a control above the tooltip wants
/// `.top` or `.topRight`, a control below it wants `.bottom`.
///
/// Declared outside `TUITooltip` so it stays a single type — a type nested in a generic is
/// specialised along with it.
public enum TUITooltipPointer: String, CaseIterable, Identifiable {

  public var id: String { rawValue }

  /// Pointer on the top edge, inset from the leading side
  case top

  /// Pointer on the top edge, inset from the trailing side
  case topRight

  /// Pointer on the bottom edge, inset from the leading side
  case bottom

  /// Pointer centred on the leading edge
  case left

  /// Pointer centred on the trailing edge
  case right

  /// `true` when the pointer sits on a horizontal edge, so it stacks above or below the card.
  var isOnHorizontalEdge: Bool {
    switch self {
    case .top, .topRight, .bottom: return true
    case .left, .right: return false
    }
  }

  /// `true` when the pointer comes after the card in layout order.
  var isAfterCard: Bool {
    switch self {
    case .bottom, .right: return true
    case .top, .topRight, .left: return false
    }
  }

  /// How far the pointer turns from its resting position, which points up.
  var rotation: Angle {
    switch self {
    case .top, .topRight: return .zero
    case .bottom: return .degrees(180)
    case .left: return .degrees(-90)
    case .right: return .degrees(90)
    }
  }

  /// Where the pointer sits along its edge.
  var alignment: Alignment {
    switch self {
    case .top, .bottom: return .leading
    case .topRight: return .trailing
    case .left, .right: return .center
    }
  }

  /// `true` when the pointer is offset from a corner rather than centred on its edge.
  var isInsetFromCorner: Bool {
    isOnHorizontalEdge
  }
}

public extension TUITooltip {

  /// How the tooltip's error validation message is called out.
  enum MessageStyle {
    case error, warning, info

    var color: Color {
      switch self {
      case .error: return .error
      case .warning: return .warning
      case .info: return .secondaryTUI
      }
    }

    var icon: FluentIcon {
      switch self {
      case .error: return .errorCircle24Regular
      case .warning: return .warning24Regular
      case .info: return .info24Regular
      }
    }
  }
}
