//
//  Model.swift
//  DatePickerView
//
//  Created by Tip on 17/03/2016.
//  Copyright © 2016 tip. All rights reserved.

import UIKit

// PRAGMA MARK: - RegionFormat enum:
enum RegionFormat:Int{
    case en_US = 0, he ,ja_JP,de_DE, /*yourCaseHere, andHere,...,*/ local // Feel free to add your own RegionFormat by adding a case, but please keep ALWAYS .local at the last position => the segmenteControl will auto-update according to local.rawValue
    var description: String {
        switch self {
        case .en_US: return "en_US"
        case .he: return "he_HE"
        case .ja_JP: return "ja_JP"
        case .de_DE: return "de_DE"
        case .local: return Locale.current.identifier
            /* Don't forget to fill the description method if you add your own Format ! */
            /*case .yourCase: return "yourCase_YOURCASE"*/ } }
}
// PRAGMA MARK: - DateFormat Protocol:
protocol DateFormat {
    /// The locale to use to display date format and months translations.
    var locale: Locale? {get set}
    
    /// Use it to create date from string and vice versa.
    var description: String {get}
    
    /// Use it to show the user how the format will looks like. **Warning:** Don't use it to perform your date conversion !
    var convenienceDescription: String {get}
    
    var numberOfComponents: Int {get}
    func numberOfRowsInComponent(component: Int) -> Int
    func titleForRowInComponent(component: Int, row: Int) -> String
    func widthForComponent(component: Int) -> CGFloat
    
    /** Returns the range of each components for the current locale and dateFormat.
    - returns: [String:Int] where String is the name of the component (e.g "year" or "month") and Int the relative position.
      e.g. The return value for a full date (YYYY.MM.DD) with US format will give: ["Year":2, "month":0, "day":1].
     */
    func rangeOfComponents() -> [String:Int]
    
    /** Returns the selected rows of the picker
    - returns: [String:Int] where String is the name of the component (e.g "thousand", "unit", "month"...) and Int the selectedRow in component.
     */
    func selectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int]
    
    /** Returns the date actually displayed in the picker as String.
    - returns: String representing the date actually displayed in the picker.
    - **Warning:** It will always returns the picker values as String, whether the date is valid or not.
     */
    func stringRepresentationOfPicker(picker:UIPickerView) -> String
  
    /** Returns the date actually displayed in the picker as Date or nil.
    - returns: Date representing the date actually displayed in the picker or nil.
    - **Warning:** It returns nil if the date is not valid (e.g: feb. 31)
     */
    func dateRepresentationOfPicker(picker:UIPickerView) -> Date?
    
    /** Set the picker selectedRows in specified component.
    - parameter selectedRows [String:Int] where String is the name of the component (e.g "thousand, "unit", "month") and Int the row to select.
    */
    func setPickerWithSeletedRows(picker: UIPickerView, selectedRows: [String:Int])

    /** Set the picker selectedRows to the date passed in argument.
    - parameter date: the valid date you want the picker to display.
     */
    func setPickerToDate(picker:UIPickerView, date:Date)

    /** Give you a chance to handle the errors that could occur with user choice. */
    func handleErrorsFromUserChoice(picker:UIPickerView)
}

// PRAGMA MARK: - DateFormat Struct:
// PRAGMA MARK: yyyyMMdd
struct YearMonthDayDateFormat: DateFormat {
    var description: String {
        return "y/M/d/G"
    }
    var convenienceDescription: String {
        return "yyyyMMdd"
    }
    init() {
        self.locale = Locale(identifier:RegionFormat.local.description)
    }
    
    var locale: Locale?
    
    var numberOfComponents: Int {
        return 4 }
  }
// PRAGMA MARK: yyyyMM
struct YearMonthDateFormat: DateFormat {
    var numberOfComponents: Int {
        return 3
    }
    
    init() {
        self.locale = Locale(identifier:RegionFormat.local.description)
    }
    
    var locale: Locale?
    
    var description: String {
        return "y/M/G"
    }
    
    var convenienceDescription: String {
        return "yyyyMM"
    }
}
// PRAGMA MARK: yyyy
struct YearDateFormat: DateFormat {
    var numberOfComponents: Int {
        return 2
    }
    
    init() {
        self.locale = Locale(identifier:RegionFormat.local.description)
    }
    
    var locale: Locale?

    var description: String {
        return "y/G"
    }
    
    var convenienceDescription: String {
        return "yyyy"
    }
}
// PRAGMA MARK: - DateFormat default implementation:
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
        { return Model.getMonth(locale: locale).count }
            
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
        { return Model.getMonth(locale: locale)[row] }
            
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
        let format: String =  DateFormatter.dateFormat(fromTemplate: self.description, options: 0, locale:locale)!
        
        var componentRelativePlace:[String: Int] = [String: Int]()
        let yearRange: Range = format.range(of:"y")!
        var dayRange: Range<Substring.Index>?
        var monthRange: Range<Substring.Index>?
        var ranges = [yearRange]
        
        if let monthRanges: Range = format.range(of:"M")
        { monthRange = monthRanges; ranges.append(monthRange!) }
        
        if let dayRanges = format.range(of:"d")
        { dayRange = dayRanges; ranges.append(dayRange!) }
        
        let sortedRanges = ranges.sorted(by: { $0.lowerBound < $1.lowerBound });
        
        let lastRelativeYearPlace = sortedRanges.index(of: yearRange)!
        componentRelativePlace["year"] = lastRelativeYearPlace
        
        if let _ = monthRange {
            componentRelativePlace["month"] = sortedRanges.index(of:monthRange!)! < lastRelativeYearPlace ? sortedRanges.index(of:monthRange!)!: sortedRanges.index(of:monthRange!)!+1 // "+1" because year fill 2 components !
        }
        if let _ = dayRange {
            componentRelativePlace["day"] = sortedRanges.index(of:dayRange!)! < lastRelativeYearPlace ? sortedRanges.index(of:dayRange!)!: sortedRanges.index(of:dayRange!)!+1 // "+1" because year fill 2 components !
        }
        return componentRelativePlace  // Output -> ["year": 2, "month": 0, "day": 1]
    }
    
    func selectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int] {
        let formatIndex = self.rangeOfComponents()
        
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRow(inComponent: formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRow(inComponent: formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRow(inComponent: index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRow(inComponent: index)}
        
        return componentRelativeIndex
    }
    
    func stringRepresentationOfPicker(picker:UIPickerView) -> String {
        let formatIndex = self.rangeOfComponents()  // Output -> ["year": 2, "month": 0, "day": 1]
        let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker: picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]
        
        var stringComponent:[String:String] = ["thousand": Model.thousand[selectedRows["thousand"]!], "unit": Model.unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = Model.getMonth(locale: locale)[selectedRow] }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = Model.days[selectedRow] }
        //stringComponent  Output -> ["thousand": "20", "unit": "16", "month": "March", "day": "1"]
        
        var stringDateRepresentation = ""
        let orderedFormatIndex:[(String,Int)] = formatIndex.sorted{ $0.1 < $1.1 } // Output -> ["month": 0, "day": 1, "year": 2]
        for (name, _) in orderedFormatIndex {
            if name == "year"
            { stringDateRepresentation.append(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.append(stringComponent[name]! + "  ")}
        }
        return stringDateRepresentation
    }
    
    func dateRepresentationOfPicker(picker:UIPickerView) -> Date? {
        let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker: picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]
        var year : Int = Int(Model.thousand[selectedRows["thousand"]!] + Model.unit[selectedRows["unit"]!])!;
        
        // Build the era symbol;
        var era : String = "AD";
        if (year < 0) { era = "BC"; year = abs(year) };
        
        var dateString = "";
        dateString.append("00" + "\(year)"); // Add "00" to avoid Date to convert year 16 in 2016 or 01 in 2001 !
        if let _ = selectedRows["month"]
        {dateString.append("/" + "\(selectedRows["month"]! + 1)");}
        if let _ = selectedRows["day"]
        { dateString.append("/" + "\(selectedRows["day"]! + 1)");}
        dateString.append("/" + "\(era)");

        let formatter = DateFormatter();
        formatter.dateFormat = self.description;
        
        let date: Date? = formatter.date(from: dateString);
        return date ?? nil;
    }
    
    func setPickerToDate(picker:UIPickerView, date: Date) {
        let components = NSCalendar(calendarIdentifier: .gregorian)!.components([.year, .month, .day, .era], from: date)
        let characters : [Character] = String(components.year!).map {$0};
      
        var unitNumbers : String = String();
        var thousandNumbers : String = String();
        // Check the lenght of the year value to fill accordingly one or two components
        for (index, value) in characters.reversed().enumerated() {
            if index <= 1 {
                unitNumbers.insert(value, at: unitNumbers.startIndex); // The unit are building:
            } else {
                thousandNumbers.insert(value, at: unitNumbers.startIndex); // The thousand are building:
            }
        }
        // Check if era is BCE, add "-" to thousandNumbers:
        if components.era == 0
        { thousandNumbers.insert("-", at: thousandNumbers.startIndex); }
        
        // Set the rows to desired indexes:
        let formatIndex = self.rangeOfComponents() // Output -> ["year": 2, "month": 0, "day": 1]
        
        if !thousandNumbers.isEmpty
        { picker.selectRow(Model.thousand .index(of:thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false) }
        
        if !unitNumbers.isEmpty
        { picker.selectRow(Model.unit .index(of:unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false) }
        
        if let indexMonth = formatIndex["month"]
        { picker.selectRow(components.month!-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { picker.selectRow(components.day!-1, inComponent: indexDay, animated: false) }
    }
    
    func setPickerWithSeletedRows(picker: UIPickerView, selectedRows: [String:Int]) {
        let formatIndex =  self.rangeOfComponents()
        // Set Year component
        picker.selectRow(selectedRows["thousand"]!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(selectedRows["unit"]!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = selectedRows["month"], let formatIndex = formatIndex["month"] {
            // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = selectedRows["day"], let formatIndex = formatIndex["day"] {
            // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
    }
    
    func handleErrorsFromUserChoice(picker:UIPickerView) {
        self.checkIfDisplayedYearEqualToZero(picker: picker);
        /*
        // This next piece of code relies on `dateRepresentationOfPicker` which currently fails on parsing dates with era:
        // That's why it is commented out
        */
        //        var escapeValue = 0;
        //        while escapeValue < 3 && self.dateRepresentationOfPicker(picker: picker) == nil {
        //            // We know that the days are wrong, because it is the only error that can occur if year is not equal to 0.
        //            // So we try to decrease days one by one three times to be sure it returns a valid date. E.g: If the user had chosen "feb. 31" it will returns at least "feb. 28" wich is always a valid date or "feb. 29" if the date is valid for the selected year.
        //            let formatIndex =  self.rangeOfComponents()
        //            let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker: picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]
        //            picker.selectRow(selectedRows["day"]! - 1, inComponent: formatIndex["day"]!, animated: false)
        //            escapeValue += 1;
        //        }
        //        if self.dateRepresentationOfPicker(picker: picker) == nil {
        //                print("*** ERROR *** \n The date is nil because an unexpected error occurs, please double check your tests cases in handleErrors method or the date syntax if you try to set a date programmaticaly. \n *** ERROR ***")
        //        }
    }
    
    /** Avoid the year currently displayed in the picker to be equal to 0. */
    private func checkIfDisplayedYearEqualToZero(picker:UIPickerView) {
        let selectedRows:[String:Int] = selectedRowsIndexInPicker(picker: picker) // Output -> ["thousand": 71, "unit" 63, "month": 2, "day":0]
        let year: Int = Int(Model.thousand[selectedRows["thousand"]!] + Model.unit[selectedRows["unit"]!])!;
        
        /* Prevent to create year 0 with picker component ->
         https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/DatesAndTimes/Articles/dtHist.html#//apple_ref/doc/uid/TP40010240-SW3
         */
        if year == 0 {
            // Move the unit component to show "01":
            let formatIndex =  self.rangeOfComponents()
            picker.selectRow(1, inComponent: formatIndex["year"]!+1, animated: true)
        }
    }
}
// PRAGMA MARK: - Data Model:
class Model: NSObject {
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    /* Use static let to avoid call build data methods every times you need it: */
    /* No months because it can be translated according to regionFormat,
    || -> If you don't care about translation, you can use a static var. */
    //private static let months: [String] = Model.getMonth(locale)
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    fileprivate static let days: [String] = Model.getDays()
    fileprivate static let thousand: [String] = Model.getYearThousand()
    fileprivate static let unit: [String] = Model.getYearDecimalAndUnit()
    fileprivate static var dateFormater: DateFormatter = DateFormatter()
    // Add your own data here for custom component.
    
    // PRAGMA MARK: - Get Data Methods:
    
    /** Returns the translated months' name as [String].
    - returns: [String] representing the translated months' name.
    */
    fileprivate class func getMonth(locale:Locale?) -> [String] {
        dateFormater.locale = locale
        return dateFormater.monthSymbols
    }
    
    /** Returns year thousands as [String].
     - returns: [String] representing years thousands from -50 to 50.
     */
    fileprivate class func getYearThousand() -> [String] {
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
    
    /** Returns year decimals and units as [String]
     - returns: [String] representing years decimals and units from 0 to 99.
     */
    fileprivate class func getYearDecimalAndUnit() -> [String] {
        var years = [String]()
        for index in 00...99 {
            years .append(String(format: "%02d", index))
        }
        return years
    }
    
    /** Returns the days as [String]
     - returns: [String] representing days from 1 to 31.
     */
    fileprivate class func getDays() -> [String] {
        var days = [String]()
        let numberMaxOfDayPerMonthForTheCurrentCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!.maximumRange(of: NSCalendar.Unit.day)
        
        for index in 1...numberMaxOfDayPerMonthForTheCurrentCalendar.length {
            days .append(String(format: "%02d", index))
        }
        return days
    }
}
