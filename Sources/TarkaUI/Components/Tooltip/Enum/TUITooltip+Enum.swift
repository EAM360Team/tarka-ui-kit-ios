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

  /// Inset from the tooltip edge, so the pointer clears the corner radius.
  var inset: CGFloat {
    switch self {
    case .leading, .trailing: return Spacing.doubleHorizontal
    case .center: return 0
    }
  }
}
