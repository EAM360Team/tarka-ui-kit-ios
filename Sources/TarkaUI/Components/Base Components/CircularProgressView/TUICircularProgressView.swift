//
//  TUICircularProgressView.swift
//
//  Performance-improved version:
//  - Bool-driven, value-scoped spinner animation (no asyncAfter hack)
//  - Animation stops when the view goes offscreen (onDisappear)
//  - Removed structural branch on progress >= 1.0 (identity churn)
//  - Clamped progress for .trim
//

import SwiftUI

public enum TUICircularProgressViewStyle: EnvironmentKey {
  case determinate, indeterminate

  public static var defaultValue: TUICircularProgressViewStyle = .indeterminate
}

/// A view that displays a circular progress indicator.
public struct TUICircularProgressView<Label: View>: View {
  /// The progress of the task, 0...1. Ignored if the style is `indeterminate`.
  public var progress: Double = 0.0

  /// A view to display alongside the progress view.
  public let label: () -> Label

  public var backgroundCircleColor = Color.surfaceVariantHover

  var style: TUICircularProgressViewStyle = .indeterminate

  private let lineWidth: CGFloat = 4

  @State private var isSpinning = false

  public init(progress: Double, @ViewBuilder labelView: @escaping () -> Label) {
    self.progress = progress
    self.label = labelView
  }

  public var body: some View {
    ZStack {
      label()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      progressCircleView
    }
  }

  @ViewBuilder
  private var progressCircleView: some View {
    switch style {
    case .determinate:
      // Constant -90° so progress starts at 12 o'clock.
      // No branch on progress >= 1.0: rotating a full circle is invisible,
      // and branching would change structural identity mid-animation.
      circularView
        .rotationEffect(.degrees(-90))
        .animation(.easeIn, value: progress)

    case .indeterminate:
      circularView
        .rotationEffect(.degrees(isSpinning ? 360 : 0))
        .animation(
          isSpinning
            ? .linear(duration: 2).repeatForever(autoreverses: false)
            : .default,
          value: isSpinning
        )
        .onAppear { isSpinning = true }
        .onDisappear { isSpinning = false } // stop burning frames offscreen
    }
  }

  private var circularView: some View {
    ZStack {
      Circle()
        .stroke(backgroundCircleColor, lineWidth: lineWidth)

      Circle()
        .trim(
          from: 0,
          to: style == .determinate
            ? min(max(progress, 0), 1)
            : 0.25
        )
        .stroke(
          Color.primaryTUI,
          style: StrokeStyle(lineWidth: lineWidth)
        )
    }
  }
}

struct CircularProgressView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TUICircularProgressView(progress: 0.4) {
        Image(fluent: .reOrder24Regular)
          .scaledToFit()
          .clipped()
      }
      .circularProgressViewStyle(.determinate)
      .frame(width: 40, height: 40)

      TUICircularProgressView(progress: 0.4) {
        Image(fluent: .reOrder24Regular)
          .scaledToFit()
          .clipped()
      }
      .circularProgressViewStyle(.indeterminate)
      .frame(width: 100, height: 100)
    }
  }
}
