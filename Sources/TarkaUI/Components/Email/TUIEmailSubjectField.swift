//
//  TUIEmailSubjectField.swift
//
//
//  Created by Arvindh Sukumar on 15/08/23.
//

import SwiftUI

public struct TUIEmailSubjectField: View {
  @Binding public var text: String
  @FocusState private var isFocused: Bool

  private var title: String
  private var foregroundColor: Color = .outline

  public init(text: Binding<String>, title: String = "Subject") {
    self._text = text
    self.title = title.localized
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      TextField(
        "",
        text: $text,
        prompt: Text(title)
          .font(.body7)
          .foregroundColor(foregroundColor)
      )
      .focused($isFocused)
      .toolbar(content: toolbarDoneButtonView)
      .font(.heading7)
      .padding(.leading, Spacing.custom(24))
      .padding(.trailing, Spacing.halfHorizontal)
      .padding(.vertical, Spacing.custom(15))
      
      TUIDivider(
        orientation: .horizontal(
          hPadding: .zero,
          vPadding: .zero
        )
      )
    }
    .frame(maxWidth: .infinity)
    .accessibilityIdentifier(Accessibility.root)
  }
  
  @ToolbarContentBuilder
  private func toolbarDoneButtonView() -> some ToolbarContent {
    ToolbarItemGroup(placement: .keyboard) {
      Spacer()
      Button("Done") { isFocused = false }
    }
  }
}

public extension TUIEmailSubjectField {

  /// Overrides the color used to render the title/placeholder.
  /// - Parameter color: The color to apply to the title/placeholder. Defaults to `.outline`.
  /// - Returns: A `TUIEmailSubjectField` updated with the given title color.
  func foregroundColor(_ color: Color) -> Self {
    var view = self
    view.foregroundColor = color
    return view
  }
}

extension TUIEmailSubjectField {
  enum Accessibility: String, TUIAccessibility {
    case root = "TUIEmailSubjectField"
  }
}

struct TUIEmailSubjectField_Previews: PreviewProvider {
  static var previews: some View {
    TUIEmailSubjectField(text: .constant("Subject"), title: "Subject")
  }
}
