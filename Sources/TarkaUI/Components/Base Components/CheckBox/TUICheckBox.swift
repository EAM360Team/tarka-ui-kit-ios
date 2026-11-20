//
//  TUICheckBox.swift
//
//
//  Created by Arvindh Sukumar on 21/02/24.
//

import SwiftUI

public struct TUICheckBox: View {
  var style: Style
  
  public init(isSelected: Bool) {
    style = isSelected ? .checked : .unchecked
  }
  
  public init(style: Style) {
    self.style = style
  }
  
  public var body: some View {
    Image(icon: style.icon)
      .scaledToFit()
      .frame(width: 24, height: 24)
      .clipped()
      .accessibilityIdentifier(Accessibility.root)
  }
}

// MARK: - Style

extension TUICheckBox {
  
  public enum Style {
    case unchecked
    case mixed
    case checked
    
    public var icon: TUIIcon {
      switch self {
      case .unchecked: return .checkBoxUnChecked
      case .mixed: return .checkBoxMixed
      case .checked: return .checkBoxChecked
      }
    }
  }
}

extension TUICheckBox {
  enum Accessibility: String, TUIAccessibility {
    case root = "TUICheckBox"
  }
}

#Preview {
  Group {
    TUICheckBox(isSelected: true)
    TUICheckBox(isSelected: false)
    TUICheckBox(style: .mixed)
  }
}
