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
  private var state: TUIInputFieldState = .none
  private var maxCharacters: Int = 0

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
      .focused($isFocused)
      .onChange(of: text) { _, newValue in limitText(newValue) }
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
      .color(state.highlightBarColor ?? .surfaceVariantHover)

      if let helperText = state.helperText() {
        helperText
          .padding(.top, Spacing.halfVertical)
      }
    }
    .frame(maxWidth: .infinity)
    .accessibilityIdentifier(Accessibility.root)
  }
  
  /// Trims the text to `maxCharacters` without splitting an emoji.
  private func limitText(_ newValue: String) {
    guard maxCharacters > 0, newValue.utf16.count > maxCharacters else { return }
    var length = 0
    text = String(newValue.prefix {
      length += $0.utf16.count
      return length <= maxCharacters
    })
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

  /// Sets the field's validation state — drives the highlight bar color under the
  /// field and an inline helper/error message below it, matching `TUIInputField`.
  /// - Parameter value: A `TUIInputFieldState` (e.g. `.error("message")`).
  /// - Returns: A `TUIEmailSubjectField` updated with the given state.
  func state(_ value: TUIInputFieldState) -> Self {
    var view = self
    view.state = value
    return view
  }

  /// Limits the text length in UTF-16 units (emoji = 2); `0` means no limit.
  func maxCharacters(_ limit: Int) -> Self {
    var view = self
    view.maxCharacters = limit
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
