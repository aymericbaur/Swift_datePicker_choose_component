//
//  Model.swift
//  DatePickerView
//
//  Created by Tip on 17/03/2016.
//  Copyright © 2016 tip. All rights reserved.

import UIKit

enum RegionFormat:Int{
    case en_US = 0, he ,ja_JP,de_DE, /*yourCaseHere, andHere,...,*/ local // Feel free to add your own RegionFormat by adding a case, but please keep ALWAYS .local at the last position => the segmenteControl will auto-update according to local.rawValue
    var description: String {
        switch self {
        case .en_US: return "en_US"
        case .he: return "he_HE"
        case .ja_JP: return "ja_JP"
        case .de_DE: return "de_DE"
        case .local: return NSLocale.currentLocale().localeIdentifier
            /* Don't forget to fill the description method if you add your own Format ! */
            /*case .yourCase: return "yourCase_YOURCASE"*/ } }
}

protocol DateFormat {
    var locale: NSLocale? {get set}
    var description: String {get}
    var numberOfComponents: Int {get}
    
    func numberOfRowsInComponent(component: Int) -> Int
    func titleForRowInComponent(component: Int, row: Int) -> String
    func widthForComponent(component: Int) -> CGFloat
    func setPickerToDate(picker:UIPickerView, date:NSDate)
    
    /** Returns the range of each components for the current locale and dateFormat.
    - returns: [String:Int] where String is the name of the component (e.g "year" or "month") and Int the relative position.
      e.g. The return value for a full date (YYYY.MM.DD) with US format will year: ["Year":2, "month":0, "day":1].
     */
    func rangeOfComponents() -> [String:Int]
    
    /** Returns the selected rows of the picker
    - returns: [String:Int] where String is the name of the component (e.g "thousand", "unit", "month"...) and Int the selectedRow in component.
     */
    func selectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int]
    
    /** Returns the date actually displayed in the picker as String.
    - returns: String which is the date actually displayed in the picker.
     */
    func stringRepresentationOfPicker(picker:UIPickerView) -> String
  
    /** Returns the date actually displayed in the picker as NSDate.
    - returns: NSDate which is the date actually displayed in the picker.
     */
    func dateRepresentationOfPicker(picker:UIPickerView) -> NSDate
    
    /** Set the picker selectedRows in specified component with a set of indexes.
    - parameter selectedRows [String:Int] where String is the name of the component (e.g "thousand, "unit", "month") and Int the row to select.
    */
    func setPickerWithSeletedRows(picker: UIPickerView, selectedRows: [String:Int])
}

// PRAGMA MARK: DateFormat Struct:
struct YearMonthDayDateFormat: DateFormat {
    var description: String {
        return "y/M/d"
    }
    
    init() {
        self.locale = NSLocale(localeIdentifier:RegionFormat.local.description)
    }
    
    var locale: NSLocale?
    
    var numberOfComponents: Int {
        return 4 }
  }

struct YearMonthDateFormat: DateFormat {
    var numberOfComponents: Int {
        return 3
    }
    
    init() {
        self.locale = NSLocale(localeIdentifier:RegionFormat.local.description)
    }
    
    var locale: NSLocale?
    
    var description: String {
        return "y/M"
    }
}
struct YearDateFormat: DateFormat {
    var numberOfComponents: Int {
        return 2
    }
    
    init() {
        self.locale = NSLocale(localeIdentifier:RegionFormat.local.description)
    }
    
    var locale: NSLocale?

    var description: String {
        return "y"
    }
}

extension DateFormat {
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ########
    || This provide a default implementation for the DateFormat protocol working with the Structs:
    || YearMonthDay, YearMonth and Year which share the same logic.
    || You will probably have to use your own implementation inside your Struct protocol methods.
    ## ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    
    func numberOfRowsInComponent(component: Int) -> Int {
        let formatIndex = self.rangeOfComponents()
        if component == formatIndex["year"]
        { return Model.thousand.count }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit.count }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale).count }
            
        else if component == formatIndex["day"]
        { return Model.days.count }
        return 0
    }
    
    func titleForRowInComponent(component: Int, row: Int) -> String {
        let formatIndex = self.rangeOfComponents()
        if component == formatIndex["year"]
        { return Model.thousand[row] }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit[row] }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale)[row] }
            
        else if component == formatIndex["day"]
        { return Model.days[row] }
        return "case is not defined"
    }
    
    func widthForComponent(component: Int) -> CGFloat {
        let formatIndex = self.rangeOfComponents()
        if component == formatIndex["year"] || component == formatIndex["year"]!+1
        { return 50 }
            
        else if component == formatIndex["month"]
        { return 125 }
            
        else if component == formatIndex["day"]
        { return 60 }
        
        return 0
    }
    
    func rangeOfComponents() -> [String:Int] {
        let format: String =  NSDateFormatter.dateFormatFromTemplate(self.description, options: 0, locale:locale)!
        
        var componentRelativePlace:[String: Int] = [String: Int]()
        let yearRange: Range = format.rangeOfString("y")!
        var dayRange: Range<String.CharacterView.Index>?
        var monthRange: Range<String.CharacterView.Index>?
        var ranges = [yearRange]
        
        if let monthRanges: Range = format.rangeOfString("M")
        { monthRange = monthRanges; ranges.append(monthRange!) }
        
        if let dayRanges = format.rangeOfString("d")
        { dayRange = dayRanges; ranges.append(dayRange!) }
        
        let sortedRanges = ranges.sort { $0.startIndex < $1.startIndex }
        
        let lastRelativeYearPlace = sortedRanges.indexOf(yearRange)!
        componentRelativePlace["year"] = lastRelativeYearPlace
        
        if let _ = monthRange {
            componentRelativePlace["month"] = sortedRanges.indexOf(monthRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(monthRange!)!: sortedRanges.indexOf(monthRange!)!+1 // "+1" because year fill 2 components !
        }
        if let _ = dayRange {
            componentRelativePlace["day"] = sortedRanges.indexOf(dayRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(dayRange!)!: sortedRanges.indexOf(dayRange!)!+1 // "+1" because year fill 2 components !
        }
        return componentRelativePlace  // Output -> ["year": 2, "month": 0, "day": 1]
    }
    
    func selectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int] {
        let formatIndex = self.rangeOfComponents()
        
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRowInComponent(formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRowInComponent(formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRowInComponent(index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRowInComponent(index)}
        
        return componentRelativeIndex
    }
    
    func stringRepresentationOfPicker(picker:UIPickerView) -> String {
        let formatIndex = self.rangeOfComponents()  // Output -> ["year": 2, "month": 0, "day": 1]
        let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]
        
        var stringComponent:[String:String] = ["thousand": Model.thousand[selectedRows["thousand"]!], "unit": Model.unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = Model.getMonth(locale)[selectedRow] }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = Model.days[selectedRow] }
        //stringComponent  Output -> ["thousand": "20", "unit": "16", "month": "March", "day": "1"]
        
        var stringDateRepresentation = ""
        let orderedFormatIndex:[(String,Int)] = formatIndex.sort{ $0.1 < $1.1 } // Output -> ["month": 0, "day": 1, "year": 2]
        for (name, _) in orderedFormatIndex {
            if name == "year"
            { stringDateRepresentation.appendContentsOf(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.appendContentsOf(stringComponent[name]! + "  ")}
        }
        return stringDateRepresentation
    }
    
    func dateRepresentationOfPicker(picker:UIPickerView) -> NSDate {
        /* Months and days are the selectedRows + 1 */
        let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]

        // Build the year: 
        var year : Int = Int(Model.thousand[selectedRows["thousand"]!] + Model.unit[selectedRows["unit"]!])!;
        
        // Build the era symbol;
        var era : String = "AD";
        if (year < 0) { era = "BC"; year = abs(year) };
        
        // Build the string for the formater:
        let formatter = NSDateFormatter();
        
        formatter.dateFormat = self.description + "/G"; // add the era to keep track of dates before Jesus.
        var string = "";
       
        string.appendContentsOf("0" + "\(year)"); // Add "0" to avoid NSDate to convert year 16 in 2016 !
        if let _ = selectedRows["month"]
        {string.appendContentsOf("/" + "\(selectedRows["month"]! + 1)");}
        if let _ = selectedRows["day"]
        { string.appendContentsOf("/" + "\(selectedRows["day"]! + 1)");}
        string.appendContentsOf("/" + "\(era)");

        let date : NSDate = formatter.dateFromString(string)!;
        return date;
    }
    
    func setPickerToDate(picker:UIPickerView, date: NSDate) {
        let components = NSCalendar(calendarIdentifier: "gregorian")!.components([.Year, .Month, .Day], fromDate: date)
        
        let year =  String(components.year)
        let characters = Array(year.characters)
        let thousandNumbers =  "\(characters[0])" + "\(characters[1])"
        let unitNumbers = "\(characters[2])" + "\(characters[3])"
        
        let formatIndex = self.rangeOfComponents()
        picker.selectRow(Model.thousand .indexOf(thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(Model.unit .indexOf(unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let indexMonth = formatIndex["month"]
        { picker.selectRow(components.month-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { picker.selectRow(components.day-1, inComponent: indexDay, animated: false) }
    }
    
    func setPickerWithSeletedRows(picker: UIPickerView, selectedRows: [String:Int]) {
        let formatIndex =  self.rangeOfComponents()
        // Set Year component
        picker.selectRow(selectedRows["thousand"]!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(selectedRows["unit"]!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = selectedRows["month"], formatIndex =  formatIndex["month"] {
            // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = selectedRows["day"], formatIndex = formatIndex["day"] {
            // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
    }
}

class Model: NSObject {
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    /* Use static let to avoid call build data methods every times you need it: */
    /* No months because it can be translated according to regionFormat,
    || -> If you don't care about translation, you can use a static var. */
    //private static let months: [String] = Model.getMonth(locale)
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    private static let days: [String] = Model.getDays()
    private static let thousand: [String] = Model.getYearThousand()
    private static let unit: [String] = Model.getYearDecimalAndUnit()
    private static var dateFormater: NSDateFormatter = NSDateFormatter()
    // Add your own data here for custom component.
    
    // PRAGMA MARK: Get Data Methods:
    
    /** Returns the translated months' name
    - returns: [String] with the translated months' name.
    */
    private class func getMonth(locale:NSLocale?) -> [String] {
        dateFormater.locale = locale
        return dateFormater.monthSymbols
    }
    
    /** Returns year thousands.
     - returns: [String] with years thousands from -50 to 50.
     */
    private class func getYearThousand() -> [String] {
        var years = [String]()
        for index in -50..<0 {
            years .append(String(index))
        }
        years.append("-")
        years.append("")
        for index in 1...50 {
            years .append(String(index))
        }
        return years
    }
    
    /** Returns year decimal
     - returns: [String] with years decimals and units from 0 to 99.
     */
    private class func getYearDecimalAndUnit() -> [String] {
        var years = [String]()
        for index in 00...99 {
            years .append(String(format: "%02d", index))
        }
        return years
    }
    
    /** Returns the days as String
     - returns: [String] with days from 1 to 31.
     */
    private class func getDays() -> [String] {
        var days = [String]()
        let numberMaxOfDayPerMonthForTheCurrentCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.maximumRangeOfUnit(NSCalendarUnit.Day)
        
        for index in 1...numberMaxOfDayPerMonthForTheCurrentCalendar.length {
            days .append(String(format: "%02d", index))
        }
        return days
    }
}
