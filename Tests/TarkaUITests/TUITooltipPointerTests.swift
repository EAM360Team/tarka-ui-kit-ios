@testable import TarkaUI
import SwiftUI
import XCTest

final class TUITooltipPointerTests: XCTestCase {

  /// Padding both sides by the inset widened the pointer strip past the card and shifted the
  /// whole tooltip sideways once the host flipped it.
  func testInsetIsAppliedOnlyOnTheSideItIsMeasuredFrom() {
    XCTAssertEqual(TUITooltipPointer.top.insetEdge, .leading)
    XCTAssertEqual(TUITooltipPointer.bottom.insetEdge, .leading)
    XCTAssertEqual(TUITooltipPointer.topRight.insetEdge, .trailing)
  }
}
