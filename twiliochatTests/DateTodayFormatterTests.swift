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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: "1990-05-14")
        
        let dateString = dateTodayFormatter.stringFromDate(date: date! as NSDate)
        
        XCTAssertEqual(dateString, "May. 14 - 12:00AM")
    }
    
    func testStringFromDateToday() {
        let dateToday = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateTodayString = dateFormatter.string(from: dateToday as Date)
        let date = dateFormatter.date(from: dateTodayString)
        let dateString = dateTodayFormatter.stringFromDate(date: date! as NSDate)
        
        XCTAssertEqual(dateString, "Today - 12:00AM")
    }
    
    func testDateFromString() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = "1990-05-14 21:04:12"
        
        let dateFromTestClass = NSDate.dateFromString(str: dateString, withFormat: "yyyy-MM-dd HH:mm:ss")
        
        XCTAssertEqual(dateFromTestClass, dateFormatter.date(from: "1990-05-14 21:04:12")! as NSDate)
    }
    
    func testDateWithISO8601String() {
        let dateString = "1990-05-14T12:05:12.003"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: dateString)
        
        let dateFromTestClass = NSDate.dateWithISO8601String(dateString: dateString)
        
        XCTAssertEqual(dateFromTestClass, date as NSDate?)
    }
    
    func testDateWithISO8601StringWithSuffix() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: "1990-05-14T12:05:12.003-00:00")
        
        let dateFromTestClass = NSDate.dateWithISO8601String(dateString: "1990-05-14T12:05:12.003Z")
        
        XCTAssertEqual(dateFromTestClass, date as NSDate?)
    }
}
