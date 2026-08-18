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
  private var foregroundColor: Color = .outline
  private var state: TUIInputFieldState = .none

  public init(text: Binding<String>, title: String = "Subject") {
    self._text = text
    self.title = title.localized
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      TextField(
        "",
        text: $text,
        prompt: Text(title)
          .font(.body7)
          .foregroundColor(foregroundColor)
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
      .color(state.highlightBarColor ?? .surfaceVariantHover)

      if let helperText = state.helperText() {
        helperText
          .padding(.top, Spacing.halfVertical)
      }
    }
    .frame(maxWidth: .infinity)
    .accessibilityIdentifier(Accessibility.root)
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

  /// Sets the field's validation state — drives the highlight bar color under the
  /// field and an inline helper/error message below it, matching `TUIInputField`.
  /// - Parameter value: A `TUIInputFieldState` (e.g. `.error("message")`).
  /// - Returns: A `TUIEmailSubjectField` updated with the given state.
  func state(_ value: TUIInputFieldState) -> Self {
    var view = self
    view.state = value
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
