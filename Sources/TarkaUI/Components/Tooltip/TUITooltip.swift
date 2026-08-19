//
//  TUITooltip.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

/// `TUITooltip` is a floating card with a pointer along its top edge, used to explain or
/// expand on the control that opened it.
///
/// It shows a bulleted list of label and value pairs, and optionally a message called out
/// below a divider. To anchor one below a view, use the `tooltip(isPresented:_:)` modifier
/// rather than placing this directly.
///
/// Example usage:
///
///      TUITooltip([
///        .init(label: "From Parent", value: "(#6886) Pump"),
///        .init(label: "From Location", value: "(#4485) Main Office")
///      ])
///      .message("Asset cannot move to this location", style: .error)
///      .arrowAlignment(.trailing)
///
/// - Parameters:
///   - items: The label and value pairs to list
///
public struct TUITooltip: View {

  var style: Style

  /// Creates a tooltip listing the given label and value pairs.
  ///
  /// - Parameters:
  ///   - items: The pairs to list, one per line.
  ///
  public init(_ items: [Item]) {
    self.style = .init(items: items)
  }

  public var body: some View {
    mainView
  }

  private var mainView: some View {
    VStack(alignment: .leading, spacing: Spacing.none) {
      arrowView
      contentView
    }
    .compositingGroup()
    .shadow(color: .black.opacity(0.16), radius: Spacing.halfHorizontal, y: Spacing.custom(5))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(Accessibility.root)
  }

  /// The pointer, drawn in the surface colour so it reads as part of the card.
  private var arrowView: some View {
    TUITooltipArrow()
      .fill(Color.surface)
      .frame(width: Spacing.custom(38), height: Spacing.custom(12))
      .padding(.horizontal, style.arrowAlignment.inset)
      .frame(maxWidth: .infinity, alignment: style.arrowAlignment.frameAlignment)
      .accessibilityIdentifier(Accessibility.arrow)
  }

  private var contentView: some View {
    VStack(alignment: .leading, spacing: Spacing.baseHorizontal) {
      itemsView
      messageView
    }
    .padding(Spacing.baseHorizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: Spacing.custom(24)))
  }

  private var itemsView: some View {
    VStack(alignment: .leading, spacing: Spacing.halfVertical) {
      ForEach(style.items) { item in
        itemView(item)
      }
    }
    .accessibilityIdentifier(Accessibility.items)
  }

  private func itemView(_ item: Item) -> some View {
    HStack(alignment: .top, spacing: Spacing.halfHorizontal) {
      Text(verbatim: "\u{2022}")
      Text(item.label + ":").fontWeight(.semibold) + Text(verbatim: " ") + Text(item.value)
    }
    .font(.body7)
    .foregroundColor(.inputText)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var messageView: some View {
    if let message = style.message {
      VStack(alignment: .leading, spacing: Spacing.baseHorizontal) {
        TUIDivider(orientation: .horizontal(hPadding: .zero, vPadding: .zero))

        HStack(alignment: .top, spacing: Spacing.halfHorizontal) {
          Image(fluent: style.messageStyle.icon)
            .scaledToFit()
            .frame(width: 24, height: 24)

          Text(message)
            .font(.body7)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(style.messageStyle.color)
      }
      .accessibilityIdentifier(Accessibility.message)
    }
  }
}

// MARK: - Arrow

/// The tooltip pointer: an upward triangle with a softened tip.
struct TUITooltipArrow: Shape {

  func path(in rect: CGRect) -> Path {
    let tipRadius = rect.height / 3

    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addQuadCurve(
      to: CGPoint(x: rect.midX + tipRadius, y: rect.minY + tipRadius),
      control: CGPoint(x: rect.midX - tipRadius, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

// MARK: - Item

public extension TUITooltip {

  /// One line of the tooltip: a label and the value it describes.
  struct Item: Identifiable, Hashable {
    public let id: String
    public let label: String
    public let value: String

    public init(label: String, value: String) {
      self.id = label
      self.label = label
      self.value = value
    }
  }
}

// MARK: - Style

extension TUITooltip {

  struct Style {
    var items: [Item]
    var arrowAlignment: TUITooltipArrowAlignment = .trailing
    var message: String?
    var messageStyle: MessageStyle = .error
  }
}

// MARK: - Accessibility

public extension TUITooltip {

  enum Accessibility: String, TUIAccessibility {
    case root = "TUITooltip"
    case arrow = "TooltipArrow"
    case items = "TooltipItems"
    case message = "TooltipMessage"
  }
}

// MARK: - Preview

struct TUITooltip_Previews: PreviewProvider {

  private static let items: [TUITooltip.Item] = [
    .init(label: "From Parent", value: "(#6886) Pump"),
    .init(label: "From Location", value: "(#4485) Main Office"),
    .init(label: "From Bin", value: "Not Available")
  ]

  static var previews: some View {
    ForEach(TUITooltipArrowAlignment.allCases) { alignment in
      VStack(spacing: Spacing.custom(40)) {
        TUITooltip(items)
          .arrowAlignment(alignment)
          .frame(width: 272)

        TUITooltip(items)
          .message("Asset cannot move to this location XYZ Reason")
          .arrowAlignment(alignment)
          .frame(width: 272)
      }
      .padding(Spacing.custom(24))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.background)
      .previewDisplayName("\(alignment)")
    }
  }
}
