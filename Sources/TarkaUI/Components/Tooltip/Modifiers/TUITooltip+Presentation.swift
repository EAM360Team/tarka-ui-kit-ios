//
//  TUITooltip+Presentation.swift
//
//
//  Created by Santhosh Kumar K on 19/08/26.
//

import SwiftUI

/// Carries the bounds of every tooltip anchor up to the host, keyed by the caller's id.
struct TUITooltipAnchorKey: PreferenceKey {

  static var defaultValue: [AnyHashable: Anchor<CGRect>] = [:]

  static func reduce(value: inout [AnyHashable: Anchor<CGRect>],
                     nextValue: () -> [AnyHashable: Anchor<CGRect>]) {
    value.merge(nextValue()) { _, next in next }
  }
}

public extension View {

  /// Marks this view as the anchor a tooltip points at.
  ///
  /// Pair it with `tooltipHost(presenting:tooltip:)` further up the hierarchy. Only the
  /// bounds travel upward, so the anchor can sit inside a scroll view without the tooltip
  /// being clipped by it.
  ///
  /// - Parameters:
  ///   - id: Identifies this anchor to the host
  ///
  func tooltipAnchor<ID: Hashable>(_ id: ID) -> some View {
    anchorPreference(key: TUITooltipAnchorKey.self, value: .bounds) { bounds in
      [AnyHashable(id): bounds]
    }
  }

  /// Draws tooltips for the anchors inside this view, above its content.
  ///
  /// Put this outside anything that clips — a scroll view, say — so a tooltip near an edge
  /// stays whole. The host picks the side with room, flipping a tooltip that would otherwise
  /// run off the bottom, and keeps the pointer on the control it belongs to. Tapping
  /// anywhere dismisses.
  ///
  /// - Parameters:
  ///   - id: The anchor currently showing a tooltip, or `nil` for none
  ///   - tooltip: Builds the tooltip for that anchor
  ///
  func tooltipHost<ID: Hashable>(presenting id: Binding<ID?>,
                                tooltip: @escaping (ID) -> TUITooltip) -> some View {
    overlayPreferenceValue(TUITooltipAnchorKey.self) { anchors in
      GeometryReader { proxy in
        if let presented = id.wrappedValue,
           let anchor = anchors[AnyHashable(presented)] {
          TUITooltipHost(
            tooltip: tooltip(presented),
            anchor: proxy[anchor],
            container: proxy.size,
            onDismiss: { id.wrappedValue = nil })
        }
      }
    }
  }
}

/// Positions one tooltip against its anchor within the host's coordinate space.
struct TUITooltipHost: View {

  let tooltip: TUITooltip
  let anchor: CGRect
  let container: CGSize
  let onDismiss: () -> Void

  @State private var tooltipHeight: CGFloat = 0

  /// Gap kept between the tooltip and the container edge when clamping.
  private static let margin: CGFloat = 8

  var body: some View {
    ZStack(alignment: .topLeading) {
      dismissLayer
      placedTooltip
    }
    .frame(width: container.width, height: container.height, alignment: .topLeading)
  }

  private var dismissLayer: some View {
    Color.clear
      .contentShape(Rectangle())
      .frame(width: container.width, height: container.height)
      .onTapGesture(perform: onDismiss)
  }

  private var placedTooltip: some View {
    resolvedTooltip
      .background(heightReader)
      .offset(x: origin.x, y: origin.y)
      .onTapGesture(perform: onDismiss)
  }

  /// The caller's tooltip, flipped to the other edge when there is no room below.
  ///
  /// Flipping moves the pointer to the opposite edge, so its inset is measured from the
  /// other side too — recomputed here to keep it over the same control.
  private var resolvedTooltip: TUITooltip {
    guard shouldFlipAbove else { return tooltip }
    let inset = TUITooltip.cardWidth - tooltip.style.pointerCenterInset
    return tooltip
      .pointer(.bottom)
      .pointerCenterInset(inset)
  }

  /// `true` when the tooltip would run past the container's bottom edge.
  ///
  /// Until the tooltip has been measured its height reads as zero, so the first pass places
  /// it below and a flip settles on the next.
  private var shouldFlipAbove: Bool {
    guard tooltipHeight > 0, tooltip.style.pointer.isOnHorizontalEdge else { return false }
    let spaceBelow = container.height - anchor.maxY
    return spaceBelow < tooltipHeight + Self.margin && anchor.minY > tooltipHeight
  }

  /// Top-left corner of the tooltip, clamped to stay inside the container.
  private var origin: CGPoint {
    let width = TUITooltip.cardWidth
    let unclampedX = anchor.maxX - width
    let maxX = max(Self.margin, container.width - width - Self.margin)
    let x = min(max(Self.margin, unclampedX), maxX)
    let y = shouldFlipAbove ? anchor.minY - tooltipHeight : anchor.maxY
    return CGPoint(x: x, y: y)
  }

  private var heightReader: some View {
    GeometryReader { proxy in
      Color.clear
        .onAppear { tooltipHeight = proxy.size.height }
        .onChange(of: proxy.size.height) { newHeight in
          tooltipHeight = newHeight
        }
    }
  }
}
