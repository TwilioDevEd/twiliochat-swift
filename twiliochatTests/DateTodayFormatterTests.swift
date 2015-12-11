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

  func testStringFromDate() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.dateFromString("1990-05-14")

    let dateString = dateTodayFormatter.stringFromDate(date!)

    XCTAssertEqual(dateString, "May. 14 - 12:00AM")
  }

  func testStringFromDateToday() {
    let dateToday = NSDate()
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateTodayString = dateFormatter.stringFromDate(dateToday)
    let date = dateFormatter.dateFromString(dateTodayString)
    let dateString = dateTodayFormatter.stringFromDate(date!)

    XCTAssertEqual(dateString, "Today - 12:00AM")
  }

  func testDateFromString() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = "1990-05-14 21:04:12"

    let dateFromTestClass = NSDate.dateFromString(dateString, withFormat: "yyyy-MM-dd HH:mm:ss")

    XCTAssertEqual(dateFromTestClass, dateFormatter.dateFromString("1990-05-14 21:04:12"))
  }

  func testDateWithISO8601String() {
    let dateString = "1990-05-14T12:05:12.003"
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.dateFromString(dateString)

    let dateFromTestClass = NSDate.dateWithISO8601String(dateString)

    XCTAssertEqual(dateFromTestClass, date)
  }

  func testDateWithISO8601StringWithSuffix() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.dateFromString("1990-05-14T12:05:12.003-00:00")

    let dateFromTestClass = NSDate.dateWithISO8601String("1990-05-14T12:05:12.003Z")

    XCTAssertEqual(dateFromTestClass, date)
  }
}
