import XCTest
@testable import twiliochat

class DateTodayFormatterTests: XCTestCase {
  var dateTodayFormatter: DateTodayFormatter!

  override func setUp() {
    super.setUp()
    dateTodayFormatter = DateTodayFormatter()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testStringFromDateToday() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.dateFromString("1990-05-14")
    let dateString = dateTodayFormatter.stringFromDate(date!)

    assert(dateString == "May. 14 - 12:00AM")
  }
}
