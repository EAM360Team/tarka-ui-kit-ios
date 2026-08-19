//
//  TUITooltip+Enum.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

/// Where the pointer sits along the top edge of a `TUITooltip`.
///
/// Line it up with whatever opened the tooltip — a trailing icon button wants `.trailing`.
///
/// Declared outside `TUITooltip` because a type nested in a generic is specialised along
/// with it, which would make `TUITooltip<A>.ArrowAlignment` a different type from
/// `TUITooltip<B>.ArrowAlignment`.
public enum TUITooltipArrowAlignment: CaseIterable, Identifiable {

  public var id: String {
    UUID().uuidString
  }

  case leading, center, trailing

  var frameAlignment: Alignment {
    switch self {
    case .leading: return .leading
    case .center: return .center
    case .trailing: return .trailing
    }
  }
}

public extension TUITooltip {

  /// How the tooltip's message is called out.
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
