import UIKit

class DateTodayFormatter {
    func stringFromDate(date: NSDate?) -> String? {
        guard let date = date else {
            return nil
        }
        
        let messageDate = roundDateToDay(date: date)
        let todayDate = roundDateToDay(date: NSDate())
        
        let formatter = DateFormatter()
        
        if messageDate == todayDate {
            formatter.dateFormat = "'Today' - hh:mma"
        }
        else {
            formatter.dateFormat = "MMM. dd - hh:mma"
        }
        
        return formatter.string(from: date as Date)
    }
    
    func roundDateToDay(date: NSDate) -> NSDate {
        let calendar  = Calendar.current
        let flags = Set<Calendar.Component>([.day, .month, .year])
        let components = calendar.dateComponents(flags, from: date as Date)
        
        return calendar.date(from:components)! as NSDate
    }
}

extension NSDate {
    class func dateWithISO8601String(dateString: String) -> NSDate? {
        var formattedDateString = dateString
        
        if dateString.hasSuffix("Z") {
            let lastIndex = dateString.indices.last!
            formattedDateString = dateString.substring(to: lastIndex) + "-000"
        }
        return dateFromString(str: formattedDateString, withFormat:"yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    class func dateFromString(str: String, withFormat dateFormat: String) -> NSDate? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        return formatter.date(from: str) as NSDate?
    }
}
