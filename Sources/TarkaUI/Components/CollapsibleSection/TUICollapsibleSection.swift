//
//  TUICollapsibleSection.swift
//
//
//  Created by Naren Krishnaa on 04/09/26.
//

import SwiftUI

/// A collapsible section with a tappable header chip and expandable content area.
///
/// The header displays a label and a chevron that rotates to indicate expand/collapse state.
/// Accordion behaviour (only one section open at a time) is managed by the consumer via
/// the `isExpanded` binding — toggling one section's binding off when another opens.
///
/// Example usage:
///
///     TUICollapsibleSection("WO#2335", isExpanded: $isExpanded) {
///       ForEach(directions, id: \.text) { step in
///         DirectionRow(step)
///       }
///     }
///
public struct TUICollapsibleSection<Content: View>: View {

  private var label: String
  @Binding private var isExpanded: Bool
  private var content: () -> Content

  /// - Parameters:
  ///   - label: The text displayed in the header chip (e.g. "WO#2335").
  ///   - isExpanded: Binding controlling whether the section is expanded.
  ///   - content: The content revealed when the section is expanded.
  public init(
    _ label: String,
    isExpanded: Binding<Bool>,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.label = label
    self._isExpanded = isExpanded
    self.content = content
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      headerChip
      if isExpanded {
        content()
          .transition(.opacity.combined(with: .move(edge: .top)))
      }
    }
    .animation(.easeInOut(duration: 0.25), value: isExpanded)
    .clipped()
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(Accessibility.root)
  }

  private var headerChip: some View {
    Button {
      isExpanded.toggle()
    } label: {
      HStack(spacing: Spacing.halfHorizontal) {
        Text(label)
          .font(.button7)
          .foregroundStyle(Color.onSurface)
        Image(icon: FluentIcon.chevronDown20Regular)
          .resizable()
          .scaledToFit()
          .frame(width: 16, height: 16)
          .foregroundStyle(Color.onSurface)
          .rotationEffect(.degrees(isExpanded ? 180 : 0))
          .animation(.easeInOut(duration: 0.25), value: isExpanded)
      }
      .padding(.horizontal, Spacing.baseHorizontal)
      .padding(.vertical, Spacing.halfVertical)
      .background(Color.surface, in: Capsule())
      .overlay(Capsule().strokeBorder(Color.outline, lineWidth: 1))
    }
    .buttonStyle(.plain)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, Spacing.baseHorizontal)
    .padding(.vertical, Spacing.baseVertical)
    .accessibilityIdentifier(Accessibility.header)
  }
}

// MARK: - Accessibility

extension TUICollapsibleSection {
  enum Accessibility: String, TUIAccessibility {
    case root = "TUICollapsibleSection"
    case header = "Header"
  }
}

// MARK: - Preview

struct CollapsibleSectionPreview: View {
  @State private var firstExpanded = true
  @State private var secondExpanded = false

  var body: some View {
    VStack(spacing: .zero) {
      TUICollapsibleSection("WO#2335", isExpanded: $firstExpanded) {
        VStack(alignment: .leading, spacing: Spacing.baseVertical) {
          Text("Go north on 19th Ave towards Uloa St")
          Text("Turn right on Traval St")
          Text("Arrive at WO#2335, on the right")
        }
        .padding(Spacing.baseHorizontal)
      }

      TUICollapsibleSection("SR#1001", isExpanded: $secondExpanded) {
        Text("Collapsed by default").padding(Spacing.baseHorizontal)
      }
    }
    .padding()
  }
}

#Preview {
  CollapsibleSectionPreview()
}
