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
/// It draws the surface, the pointer and the shadow; the caller supplies the content. To
/// anchor one below a view and dismiss it on an outside tap, use the `tooltip(isPresented:)`
/// modifier rather than placing this directly.
///
/// Example usage:
///
///      TUITooltip {
///        Text("Asset cannot move to this location")
///      }
///      .arrowAlignment(.trailing)
///
/// - Parameters:
///   - content: A closure that returns the tooltip's content
///
public struct TUITooltip<Content: View>: View {

  var style: Style
  private let content: Content

  /// Creates a tooltip around the given content.
  ///
  /// - Parameters:
  ///   - content: The content to show inside the tooltip.
  ///
  public init(@ViewBuilder _ content: () -> Content) {
    self.style = .init()
    self.content = content()
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

  /// The pointer, drawn as a rounded triangle so it reads as part of the surface.
  private var arrowView: some View {
    TUITooltipArrow()
      .fill(Color.surface)
      .frame(width: Spacing.custom(38), height: Spacing.custom(12))
      .padding(.horizontal, style.arrowAlignment.inset)
      .frame(maxWidth: .infinity, alignment: style.arrowAlignment.frameAlignment)
      .accessibilityIdentifier(Accessibility.arrow)
  }

  private var contentView: some View {
    content
      .padding(Spacing.baseHorizontal)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.surface)
      .clipShape(RoundedRectangle(cornerRadius: Spacing.custom(24)))
      .accessibilityIdentifier(Accessibility.content)
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

// MARK: - Style

extension TUITooltip {

  struct Style {
    var arrowAlignment: TUITooltipArrowAlignment = .trailing
  }
}

// MARK: - Accessibility

public extension TUITooltip {

  enum Accessibility: String, TUIAccessibility {
    case root = "TUITooltip"
    case arrow = "TooltipArrow"
    case content = "TooltipContent"
  }
}

// MARK: - Preview

struct TUITooltip_Previews: PreviewProvider {

  static var previews: some View {
    VStack(spacing: Spacing.custom(40)) {
      ForEach(TUITooltipArrowAlignment.allCases) { alignment in
        TUITooltip {
          VStack(alignment: .leading, spacing: Spacing.baseVertical) {
            Text("From Parent: (#6886) Pump")
              .font(.body7)
              .foregroundColor(.inputText)
            Text("From Location: (#4485) Main Office")
              .font(.body7)
              .foregroundColor(.inputText)
          }
        }
        .arrowAlignment(alignment)
        .frame(width: 272)
      }
    }
    .padding(Spacing.custom(24))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
  }
}
