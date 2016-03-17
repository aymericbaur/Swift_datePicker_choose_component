//
//  Model.swift
//  DatePickerView
//
//  Created by Tip on 17/03/2016.
//  Copyright © 2016 tip. All rights reserved.
//

import UIKit

enum RegionFormat:Int{
    case en_US = 0, he ,ja_JP,de_DE, /*yourCaseHere, andHere,...,*/ local // Feel free to add your own RegionFormat by adding a case, but please keep ALWAYS .local at the last position => the segmenteControl will auto-update according to local.rawValue
    var description : String {
        switch self {
        case .en_US: return "en_US";
        case .he: return "he_HE";
        case .ja_JP: return "ja_JP";
        case .de_DE: return "de_DE";
        case .local: return NSLocale.currentLocale().localeIdentifier
            /* Don't forget to fill the description method if you add your own Format ! */
            /*case .yourCase: return "yourCase_YOURCASE";*/ } }
}

protocol DateFormat
{
    var description : String {get}
    var numberOfComponents : Int {get}
    var locale: NSLocale {get set}
    init();

    func numberOfRowsInComponent(component: Int) -> Int;
    func titleForRowInComponent(component: Int, row: Int) -> String;
    func widthForComponent(component: Int) -> CGFloat;
    func getRangeOfComponents() -> [String:Int];
    func getSelectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int];
    func getStringRepresentationOfPicker(picker :UIPickerView) -> String;
    func setPickerAtStart(picker :UIPickerView);
    func setPickerWithSeletedRows(picker: UIPickerView, lastSelectedRows: [String:Int]);
}

// PRAGMA MARK: DateFormat Struct:
struct YearMonthDayDateFormat: DateFormat {
    
    var description : String {
        return "yyyyMMdd";
    }

    var locale: NSLocale {
        get{
         return self.locale
        }
        set(newLocale){
            self.locale = newLocale;
        }
    }

    var numberOfComponents : Int {
        return 4; }
    
    func numberOfRowsInComponent(component: Int) -> Int
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand.count }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit.count; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale).count; }
            
        else if component == formatIndex["day"]
        { return Model.days.count; }
        return 0
    }
    
    func titleForRowInComponent(component: Int, row: Int) -> String
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand[row]; }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit[row]; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale)[row]; }
            
        else if component == formatIndex["day"]
        { return Model.days[row]; }
        return "case is not defined";
    }
    
    func widthForComponent(component: Int) -> CGFloat
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"] || component == formatIndex["year"]!+1
        { return 50; }
            
        else if component == formatIndex["month"]
        { return 125; }
            
        else if component == formatIndex["day"]
        { return 60; }
        return 0
    }
    
    func getRangeOfComponents() -> [String:Int]
    {
        let format : String =  NSDateFormatter.dateFormatFromTemplate(self.description, options: 0, locale:locale)!
        
        var componentRelativePlace:[String: Int] = [String: Int]()
        let yearRange : Range = format.rangeOfString("y")!;
        var dayRange : Range<String.CharacterView.Index>?;
        var monthRange : Range<String.CharacterView.Index>?;
        var ranges = [yearRange];
        
        if let monthRanges : Range = format.rangeOfString("M")
        { monthRange = monthRanges; ranges.append(monthRange!); }
        
        if let dayRanges = format.rangeOfString("d")
        { dayRange = dayRanges; ranges.append(dayRange!); }
        
        let sortedRanges = ranges.sort { $0.startIndex < $1.startIndex }
        
        let lastRelativeYearPlace = sortedRanges.indexOf(yearRange)!;
        componentRelativePlace["year"] = lastRelativeYearPlace;
        
        if let _ = monthRange{
            componentRelativePlace["month"] = sortedRanges.indexOf(monthRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(monthRange!)! : sortedRanges.indexOf(monthRange!)!+1 // "+1" because year fill 2 components !
        }
        if let _ = dayRange{
            componentRelativePlace["day"] = sortedRanges.indexOf(dayRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(dayRange!)! : sortedRanges.indexOf(dayRange!)!+1 // "+1" because year fill 2 components !
        }
        return componentRelativePlace;  // Output -> ["year" : 2, "month" : 0, "day": 1]
    }
    
    func getSelectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int]
    {
        let formatIndex = self.getRangeOfComponents();
        
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRowInComponent(formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRowInComponent(formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRowInComponent(index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRowInComponent(index)}
        
        return componentRelativeIndex;
    }
    
    func getStringRepresentationOfPicker(picker :UIPickerView) -> String
    {
        let formatIndex = self.getRangeOfComponents();  // Output -> ["year" : 2, "month" : 0, "day": 1]
        let selectedRows:[String:Int] = getSelectedRowsIndexInPicker(picker) // Output -> ["thousand" : 71, "unit" 63, "month" : 2, "day" :0]
        
        var stringComponent:[String:String] = ["thousand" : Model.thousand[selectedRows["thousand"]!], "unit" : Model.unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = Model.getMonth(locale)[selectedRow]; }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = Model.days[selectedRow]; }
        //stringComponent ; Output -> ["thousand" : "20", "unit" : "16", "month" : "3", "day" : "1"]
        
        var stringDateRepresentation = "";
        let orderedFormatIndex:[(String,Int)] = formatIndex.sort{ $0.1 < $1.1 } // Output -> ["month" : 0, "day" : 1, "year" : 2]
        for (name, _) in orderedFormatIndex
        {
            if name == "year"
            { stringDateRepresentation.appendContentsOf(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.appendContentsOf(stringComponent[name]! + "  ")}
        }
        return stringDateRepresentation;
    }
    
    func setPickerAtStart(picker :UIPickerView)
    {
        let date = NSDate()
        let components = NSCalendar(calendarIdentifier: "gregorian")!.components([.Year, .Month, .Day], fromDate: date)
        
        let year =  String(components.year)
        let characters = Array(year.characters)
        let thousandNumbers =  "\(characters[0])" + "\(characters[1])";
        let unitNumbers = "\(characters[2])" + "\(characters[3])"
        
        let formatIndex = self.getRangeOfComponents();
        picker.selectRow(Model.thousand .indexOf(thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(Model.unit .indexOf(unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let indexMonth = formatIndex["month"]
        { picker.selectRow(components.month-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { picker.selectRow(components.day-1, inComponent: indexDay, animated: false) }
    }
    
    func setPickerWithSeletedRows(picker: UIPickerView, lastSelectedRows: [String:Int])
    {
        let formatIndex =  self.getRangeOfComponents();
        // Set Year component
        picker.selectRow(lastSelectedRows["thousand"]!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(lastSelectedRows["unit"]!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = lastSelectedRows["month"], formatIndex =  formatIndex["month"]
        {   // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = lastSelectedRows["day"], formatIndex = formatIndex["day"]
        {   // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
    }
}

struct YearMonthDateFormat: DateFormat {
    
    var numberOfComponents : Int {
        return 3;
    }

    var locale: NSLocale {
        get{
            return self.locale
        }
        set(newLocale){
            self.locale = newLocale;
        }
    }
    
    var description : String {
        return "yyyyMM";
    }
    
    func numberOfRowsInComponent(component: Int) -> Int
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand.count }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit.count; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale).count; }
            
        else if component == formatIndex["day"]
        { return Model.days.count; }
        return 0
    }
    
    func titleForRowInComponent(component: Int, row: Int) -> String
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand[row]; }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit[row]; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale)[row]; }
            
        else if component == formatIndex["day"]
        { return Model.days[row]; }
        return "case is not defined";
    }
    
    func widthForComponent(component: Int) -> CGFloat
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"] || component == formatIndex["year"]!+1
        { return 50; }
            
        else if component == formatIndex["month"]
        { return 125; }
            
        else if component == formatIndex["day"]
        { return 60; }
        
        return 0
    }
    
    func getRangeOfComponents() -> [String:Int]
    {
        let format : String =  NSDateFormatter.dateFormatFromTemplate(self.description, options: 0, locale:locale)!
        
        var componentRelativePlace:[String: Int] = [String: Int]()
        let yearRange : Range = format.rangeOfString("y")!;
        var dayRange : Range<String.CharacterView.Index>?;
        var monthRange : Range<String.CharacterView.Index>?;
        var ranges = [yearRange];
        
        if let monthRanges : Range = format.rangeOfString("M")
        { monthRange = monthRanges; ranges.append(monthRange!); }
        
        if let dayRanges = format.rangeOfString("d")
        { dayRange = dayRanges; ranges.append(dayRange!); }
        
        let sortedRanges = ranges.sort { $0.startIndex < $1.startIndex }
        
        let lastRelativeYearPlace = sortedRanges.indexOf(yearRange)!;
        componentRelativePlace["year"] = lastRelativeYearPlace;
        
        if let _ = monthRange{
            componentRelativePlace["month"] = sortedRanges.indexOf(monthRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(monthRange!)! : sortedRanges.indexOf(monthRange!)!+1 // "+1" because year fill 2 components !
        }
        if let _ = dayRange{
            componentRelativePlace["day"] = sortedRanges.indexOf(dayRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(dayRange!)! : sortedRanges.indexOf(dayRange!)!+1 // "+1" because year fill 2 components !
        }
        return componentRelativePlace;  // Output -> ["year" : 2, "month" : 0, "day": 1]
    }
    
    func getSelectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int]
    {
        let formatIndex = self.getRangeOfComponents();
        
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRowInComponent(formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRowInComponent(formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRowInComponent(index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRowInComponent(index)}
        
        return componentRelativeIndex;
    }
    
    func getStringRepresentationOfPicker(picker :UIPickerView) -> String
    {
        let formatIndex = self.getRangeOfComponents();  // Output -> ["year" : 2, "month" : 0, "day": 1]
        let selectedRows:[String:Int] = getSelectedRowsIndexInPicker(picker) // Output -> ["thousand" : 71, "unit" 63, "month" : 2, "day" :0]
        
        var stringComponent:[String:String] = ["thousand" : Model.thousand[selectedRows["thousand"]!], "unit" : Model.unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = Model.getMonth(locale)[selectedRow]; }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = Model.days[selectedRow]; }
        //stringComponent ; Output -> ["thousand" : "20", "unit" : "16", "month" : "3", "day" : "1"]
        
        var stringDateRepresentation = "";
        let orderedFormatIndex:[(String,Int)] = formatIndex.sort{ $0.1 < $1.1 } // Output -> ["month" : 0, "day" : 1, "year" : 2]
        for (name, _) in orderedFormatIndex
        {
            if name == "year"
            { stringDateRepresentation.appendContentsOf(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.appendContentsOf(stringComponent[name]! + "  ")}
        }
        return stringDateRepresentation;
    }
    
    func setPickerAtStart(picker :UIPickerView)
    {
        let date = NSDate()
        let components = NSCalendar(calendarIdentifier: "gregorian")!.components([.Year, .Month, .Day], fromDate: date)
        
        let year =  String(components.year)
        let characters = Array(year.characters)
        let thousandNumbers =  "\(characters[0])" + "\(characters[1])";
        let unitNumbers = "\(characters[2])" + "\(characters[3])"
        
        let formatIndex = self.getRangeOfComponents();
        picker.selectRow(Model.thousand .indexOf(thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(Model.unit .indexOf(unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let indexMonth = formatIndex["month"]
        { picker.selectRow(components.month-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { picker.selectRow(components.day-1, inComponent: indexDay, animated: false) }
    }
    
    func setPickerWithSeletedRows(picker: UIPickerView, lastSelectedRows: [String:Int])
    {
        let formatIndex =  self.getRangeOfComponents();
        // Set Year component
        picker.selectRow(lastSelectedRows["thousand"]!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(lastSelectedRows["unit"]!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = lastSelectedRows["month"], formatIndex =  formatIndex["month"]
        {   // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = lastSelectedRows["day"], formatIndex = formatIndex["day"]
        {   // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
    }
}
struct YearDateFormat: DateFormat {
    
    var numberOfComponents : Int {
        return 2;
    }
    
    var locale: NSLocale {
        get{
            return self.locale
        }
        set(newLocale){
            self.locale = newLocale;
        }
    }
    var description : String {
        return "yyyy";
    }
    
    func numberOfRowsInComponent(component: Int) -> Int
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand.count }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit.count; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale).count; }
            
        else if component == formatIndex["day"]
        { return Model.days.count; }
        return 0
    }
    
    func titleForRowInComponent(component: Int, row: Int) -> String
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"]
        { return Model.thousand[row]; }
            
        else if component == formatIndex["year"]!+1
        { return Model.unit[row]; }
            
        else if component == formatIndex["month"]
        { return Model.getMonth(locale)[row]; }
            
        else if component == formatIndex["day"]
        { return Model.days[row]; }
        return "case is not defined";
    }
    
    func widthForComponent(component: Int) -> CGFloat
    {
        let formatIndex = self.getRangeOfComponents();
        if component == formatIndex["year"] || component == formatIndex["year"]!+1
        { return 50; }
            
        else if component == formatIndex["month"]
        { return 125; }
            
        else if component == formatIndex["day"]
        { return 60; }
        
        return 0
    }
    
    func getRangeOfComponents() -> [String:Int]
    {
        let format : String =  NSDateFormatter.dateFormatFromTemplate(self.description, options: 0, locale:locale)!
        
        var componentRelativePlace:[String: Int] = [String: Int]()
        let yearRange : Range = format.rangeOfString("y")!;
        var dayRange : Range<String.CharacterView.Index>?;
        var monthRange : Range<String.CharacterView.Index>?;
        var ranges = [yearRange];
        
        if let monthRanges : Range = format.rangeOfString("M")
        { monthRange = monthRanges; ranges.append(monthRange!); }
        
        if let dayRanges = format.rangeOfString("d")
        { dayRange = dayRanges; ranges.append(dayRange!); }
        
        let sortedRanges = ranges.sort { $0.startIndex < $1.startIndex }
        
        let lastRelativeYearPlace = sortedRanges.indexOf(yearRange)!;
        componentRelativePlace["year"] = lastRelativeYearPlace;
        
        if let _ = monthRange{
            componentRelativePlace["month"] = sortedRanges.indexOf(monthRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(monthRange!)! : sortedRanges.indexOf(monthRange!)!+1 // "+1" because year fill 2 components !
        }
        if let _ = dayRange{
            componentRelativePlace["day"] = sortedRanges.indexOf(dayRange!)! < lastRelativeYearPlace ? sortedRanges.indexOf(dayRange!)! : sortedRanges.indexOf(dayRange!)!+1 // "+1" because year fill 2 components !
        }
        return componentRelativePlace;  // Output -> ["year" : 2, "month" : 0, "day": 1]
    }
    
    func getSelectedRowsIndexInPicker (picker: UIPickerView) -> [String:Int]
    {
        let formatIndex = self.getRangeOfComponents();
        
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRowInComponent(formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRowInComponent(formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRowInComponent(index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRowInComponent(index)}
        
        return componentRelativeIndex;
    }
    
    func getStringRepresentationOfPicker(picker :UIPickerView) -> String
    {
        let formatIndex = self.getRangeOfComponents();  // Output -> ["year" : 2, "month" : 0, "day": 1]
        let selectedRows:[String:Int] = getSelectedRowsIndexInPicker(picker) // Output -> ["thousand" : 71, "unit" 63, "month" : 2, "day" :0]
        
        var stringComponent:[String:String] = ["thousand" : Model.thousand[selectedRows["thousand"]!], "unit" : Model.unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = Model.getMonth(locale)[selectedRow]; }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = Model.days[selectedRow]; }
        //stringComponent ; Output -> ["thousand" : "20", "unit" : "16", "month" : "3", "day" : "1"]
        
        var stringDateRepresentation = "";
        let orderedFormatIndex:[(String,Int)] = formatIndex.sort{ $0.1 < $1.1 } // Output -> ["month" : 0, "day" : 1, "year" : 2]
        for (name, _) in orderedFormatIndex
        {
            if name == "year"
            { stringDateRepresentation.appendContentsOf(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.appendContentsOf(stringComponent[name]! + "  ")}
        }
        return stringDateRepresentation;
    }
    
    func setPickerAtStart(picker :UIPickerView)
    {
        let date = NSDate()
        let components = NSCalendar(calendarIdentifier: "gregorian")!.components([.Year, .Month, .Day], fromDate: date)
        
        let year =  String(components.year)
        let characters = Array(year.characters)
        let thousandNumbers =  "\(characters[0])" + "\(characters[1])";
        let unitNumbers = "\(characters[2])" + "\(characters[3])"
        
        let formatIndex = self.getRangeOfComponents();
        picker.selectRow(Model.thousand .indexOf(thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(Model.unit .indexOf(unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let indexMonth = formatIndex["month"]
        { picker.selectRow(components.month-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { picker.selectRow(components.day-1, inComponent: indexDay, animated: false) }
    }
    
    func setPickerWithSeletedRows(picker: UIPickerView, lastSelectedRows: [String:Int])
    {
        let formatIndex =  self.getRangeOfComponents();
        // Set Year component
        picker.selectRow(lastSelectedRows["thousand"]!, inComponent: formatIndex["year"]!, animated: false)
        picker.selectRow(lastSelectedRows["unit"]!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = lastSelectedRows["month"], formatIndex =  formatIndex["month"]
        {   // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = lastSelectedRows["day"], formatIndex = formatIndex["day"]
        {   // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
    }
}

class Model: NSObject
{
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    /* Use static let to avoid call build data methods every times you need it: */
    /* No months because it can be translated according to regionFormat, 
    || -> If you don't care about translation, you can use a static var. */
    //private static let months: [String] = Model.getMonth(locale);
    /* ######## ######## ######## ######## ######## ######## ######## ######## ######## ######## */
    private static let days: [String] = Model.getDays();
    private static let thousand: [String] = Model.getYearThousand();
    private static let unit: [String] = Model.getYearDecimalAndUnit();
    private static var dateFormater : NSDateFormatter = NSDateFormatter();
    // Add your own data here for custom component.
    
        // PRAGMA MARK: Get Data Methods:
    private class func getMonth(locale:NSLocale) -> [String]
        {
            dateFormater.locale = locale;
            return dateFormater.monthSymbols;
        }
        
        private class func getYearThousand() -> [String]
        {
            var years = [String]();
            for index in -50..<0
            {
                years .append(String(index));
            }
            years.append("-");
            years.append("");
            for index in 1...50
            {
                years .append(String(index));
            }
            return years;
        }
        
        private class func getYearDecimalAndUnit() -> [String]
        {
            var years = [String]();
            for index in 00...99
            {
                years .append(String(format: "%02d", index));
            }
            return years;
        }
        
        private class func getDays() -> [String]
        {
            var days = [String]();
            let numberMaxOfDayPerMonthForTheCurrentCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.maximumRangeOfUnit(NSCalendarUnit.Day);
            
            for index in 1...numberMaxOfDayPerMonthForTheCurrentCalendar.length
            {
                days .append(String(format: "%02d", index));
            }
            return days;
        }
}
