//
//  TUIEmailSubjectField.swift
//
//
//  Created by Arvindh Sukumar on 15/08/23.
//

import SwiftUI
import SwiftUIIntrospect

public struct TUIEmailSubjectField: View {
  @Binding public var text: String

  private var title: String

  /// When `true`, the title/placeholder is rendered with the error style.
  private var isError = false

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
          .foregroundColor(isError ? .error : .outline)
      )
      .addDoneButtonOnKeyboard()
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
}

public extension TUIEmailSubjectField {
  
  /// Applies the error style to the field, rendering the title in the error color.
  /// - Parameter value: A bool that decides whether the error style is applied.
  /// - Returns: A `TUIEmailSubjectField` updated with the error style.
  func isError(_ value: Bool) -> Self {
    var view = self
    view.isError = value
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
