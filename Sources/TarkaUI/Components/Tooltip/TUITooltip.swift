//
//  TUITooltip.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

/// `TUITooltip` is a floating card with a pointer on one edge, used to explain or expand on
/// the control that opened it.
///
/// It lists title and value pairs, and can call out an error validation message below a
/// divider. To anchor one to a view and dismiss it on an outside tap, mark the view with
/// `tooltipAnchor(_:)` and put `tooltipHost(presenting:tooltip:)` above anything that clips,
/// rather than placing this directly.
///
/// Example usage:
///
///      TUITooltip([
///        .init(title: "From Parent", value: "(#6886) Pump"),
///        .init(title: "From Location", value: "(#4485) Main Office")
///      ])
///      .pointer(.topRight)
///      .errorValidation("Asset cannot move to this location")
///
/// - Parameters:
///   - items: The title and value pairs to list
///
public struct TUITooltip: View {

  var style: Style

  /// Size of the pointer, per the design.
  public static let pointerSize = CGSize(width: 38, height: 11.5)

  /// Width of the card, excluding a pointer sitting on a vertical edge.
  public static let cardWidth: CGFloat = 272

  /// Where the pointer rests along its edge, per the design, measured to its centre.
  ///
  /// Override it with `pointerCenterInset(_:)` to aim the pointer at a particular control.
  public static let defaultPointerCenterInset: CGFloat = 51

  /// Creates a tooltip listing the given title and value pairs.
  ///
  /// - Parameters:
  ///   - items: The pairs to list, one per line.
  ///
  public init(_ items: [Item]) {
    self.style = .init(items: items)
  }

  public var body: some View {
    mainView
      .compositingGroup()
      // Shadow lvl 1 — two layers, so the card lifts without a hard edge.
      .shadow(color: .black.opacity(0.16), radius: Spacing.custom(12), y: Spacing.custom(5))
      .shadow(color: .black.opacity(0.14), radius: Spacing.quarterHorizontal, y: Spacing.custom(5))
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(Accessibility.root)
  }

  /// Stacks the pointer and the card along whichever axis the pointer's edge implies.
  @ViewBuilder
  private var mainView: some View {
    if style.pointer.isOnHorizontalEdge {
      VStack(alignment: .leading, spacing: Spacing.none) {
        if style.pointer.isAfterCard {
          cardView
          pointerView
        } else {
          pointerView
          cardView
        }
      }
      .frame(width: Self.cardWidth)
    } else {
      HStack(alignment: .center, spacing: Spacing.none) {
        if style.pointer.isAfterCard {
          cardView
          pointerView
        } else {
          pointerView
          cardView
        }
      }
      .frame(width: Self.cardWidth + Self.pointerSize.height)
    }
  }

  /// The pointer, drawn in the surface colour so it reads as part of the card.
  ///
  /// Drawn once pointing up and turned to face its edge, so one shape serves all five
  /// variants.
  private var pointerView: some View {
    TUITooltipArrow()
      .fill(Color.surface)
      .frame(width: Self.pointerSize.width, height: Self.pointerSize.height)
      .rotationEffect(style.pointer.rotation)
      .frame(width: pointerFrame.width, height: pointerFrame.height)
      .padding(pointerInsetEdge, pointerInset)
      .frame(maxWidth: style.pointer.isOnHorizontalEdge ? .infinity : nil,
             maxHeight: style.pointer.isOnHorizontalEdge ? nil : .infinity,
             alignment: style.pointer.alignment)
      .accessibilityIdentifier(Accessibility.pointer)
  }

  /// The pointer's footprint once turned — the axes swap on a vertical edge.
  private var pointerFrame: CGSize {
    style.pointer.isOnHorizontalEdge
    ? Self.pointerSize
    : CGSize(width: Self.pointerSize.height, height: Self.pointerSize.width)
  }

  private var pointerInsetEdge: Edge.Set {
    style.pointer.isOnHorizontalEdge ? .horizontal : .vertical
  }

  /// Distance from the pointer's edge to the start of its inset run.
  private var pointerInset: CGFloat {
    guard style.pointer.isInsetFromCorner else { return 0 }
    return max(0, style.pointerCenterInset - Self.pointerSize.width / 2)
  }

  private var cardView: some View {
    VStack(alignment: .leading, spacing: Spacing.baseHorizontal) {
      itemsView
      errorValidationView
    }
    .padding(Spacing.baseHorizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.surface)
    .clipShape(RoundedRectangle(cornerRadius: Spacing.custom(24)))
  }

  private var itemsView: some View {
    VStack(alignment: .leading, spacing: Spacing.none) {
      ForEach(style.items, id: \.self) { item in
        itemView(item)
      }
    }
    .accessibilityIdentifier(Accessibility.items)
  }

  private func itemView(_ item: Item) -> some View {
    HStack(alignment: .top, spacing: Spacing.halfHorizontal) {
      Text(verbatim: "\u{2022}")
      Text(item.title + ":").fontWeight(.semibold) + Text(verbatim: " ") + Text(item.value)
    }
    .font(.body7)
    .foregroundColor(.onSurface)
    .multilineTextAlignment(.leading)
    .fixedSize(horizontal: false, vertical: true)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var errorValidationView: some View {
    if let message = style.errorValidation {
      VStack(alignment: .leading, spacing: Spacing.baseHorizontal) {
        TUIDivider(orientation: .horizontal(hPadding: .zero, vPadding: .zero))

        HStack(alignment: .top, spacing: Spacing.halfHorizontal) {
          Image(fluent: style.messageStyle.icon)
            .scaledToFit()
            .frame(width: 24, height: 24)

          Text(message)
            .font(.body7)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(style.messageStyle.color)
      }
      .accessibilityIdentifier(Accessibility.errorValidation)
    }
  }
}

// MARK: - Pointer shape

/// The tooltip pointer: a symmetric nub that swells out of the card edge.
///
/// Curved on both flanks with a rounded apex, matching the design — a plain triangle reads
/// far sharper than the component does.
struct TUITooltipArrow: Shape {

  func path(in rect: CGRect) -> Path {
    let width = rect.width

    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addCurve(
      to: CGPoint(x: rect.midX, y: rect.minY),
      control1: CGPoint(x: rect.minX + width * 0.28, y: rect.maxY),
      control2: CGPoint(x: rect.minX + width * 0.36, y: rect.minY))
    path.addCurve(
      to: CGPoint(x: rect.maxX, y: rect.maxY),
      control1: CGPoint(x: rect.minX + width * 0.64, y: rect.minY),
      control2: CGPoint(x: rect.minX + width * 0.72, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

// MARK: - Item

public extension TUITooltip {

  /// One line of the tooltip: the name of a field and the value it holds.
  ///
  /// `Hashable` is all the list needs to tell one line from another, so there is no `id` to
  /// keep in step with the content — two lines differing only in value stay distinct.
  struct Item: Hashable {
    public let title: String
    public let value: String

    public init(title: String, value: String) {
      self.title = title
      self.value = value
    }
  }
}

// MARK: - Style

extension TUITooltip {

  struct Style {
    var items: [Item]
    var pointer: TUITooltipPointer = .topRight

    /// Distance from the pointer's edge to its centre, for pointers inset from a corner.
    ///
    /// Defaults to the design's resting position; aim it at a control by passing that
    /// control's offset from the same edge.
    var pointerCenterInset: CGFloat = TUITooltip.defaultPointerCenterInset
    var errorValidation: String?
    var messageStyle: MessageStyle = .error
  }
}

// MARK: - Accessibility

public extension TUITooltip {

  enum Accessibility: String, TUIAccessibility {
    case root = "TUITooltip"
    case pointer = "TooltipPointer"
    case items = "TooltipItems"
    case errorValidation = "TooltipErrorValidation"
  }
}

// MARK: - Preview

struct TUITooltip_Previews: PreviewProvider {

  private static let items: [TUITooltip.Item] = [
    .init(title: "From Parent", value: "(#6886) Pump"),
    .init(title: "From Location", value: "(#4485) Main Office"),
    .init(title: "From Bin", value: "Not Available")
  ]

  private static let longValueItems: [TUITooltip.Item] = [
    .init(title: "From Parent", value: "Not Available"),
    .init(title: "From Location",
          value: "(#AHU-0001) Air Handling Unit - CAS E03 VSD's - Champs- [Casino - Basement]")
  ]

  static var previews: some View {

    // Every pointer variant together, as the design sheet lays them out.
    canvas("Pointer") {
      ForEach(TUITooltipPointer.allCases) { pointer in
        TUITooltip(items)
          .pointer(pointer)
      }
    }

    // The same variants carrying an error validation message.
    canvas("Error validation") {
      ForEach(TUITooltipPointer.allCases) { pointer in
        TUITooltip(items)
          .pointer(pointer)
          .errorValidation("Asset cannot move to this location XYZ Reason")
      }
    }

    // Values long enough to wrap, with and without the message.
    canvas("Wrapping") {
      TUITooltip(longValueItems)
      TUITooltip(longValueItems)
        .errorValidation("Non Rotating assets cannot be moved to storeroom")
    }

    // A single item, to check the card collapses to its content.
    canvas("Single item") {
      TUITooltip([.init(title: "From Bin", value: "A-01-14")])
    }
  }

  /// Lays previewed tooltips out on a neutral ground, so their shadows stay visible.
  private static func canvas<Content: View>(
    _ name: String,
    @ViewBuilder _ content: () -> Content) -> some View {
      ScrollView {
        VStack(alignment: .leading, spacing: Spacing.custom(40)) {
          content()
        }
        .padding(Spacing.custom(24))
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.background)
      .previewDisplayName(name)
    }
}
