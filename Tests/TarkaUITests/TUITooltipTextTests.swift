@testable import TarkaUI
import XCTest

final class TUITooltipTextTests: XCTestCase {

  func testTextInitStoresTheTextAndNoItems() {
    let tooltip = TUITooltip(text: "Explains the setting")
    XCTAssertEqual(tooltip.style.text, "Explains the setting")
    XCTAssertTrue(tooltip.style.items.isEmpty)
  }

  func testItemsInitHasNoText() {
    let tooltip = TUITooltip([.init(title: "From Bin", value: "A-01")])
    XCTAssertNil(tooltip.style.text)
  }
}
