//  YAMDatePickerHelper.swift
//  DatePickerView
//  Created by Tip on 13/03/2016.
//  Copyright © 2016 tip. All rights reserved.

import UIKit


/* ########### ########### ########### ############ ############
||             HOW TO USE YAMDatePickerHelper ?
|| ########### ########### ########### ############ ############
||
|| 1) Just add the YAMDatePickerHelper file to your project and make sure "Copy if needed" is checked.
|| 2) Add an UIPickerView to your view and make a referenced outlet if it was created with stroyboard.
|| 3) Set the delegate of the picker with an instance of YAMDatePickerHelper (Do NOT set the delegate and dataSource with storyboard !).
|| 4) Eventually customise the appearance with the set methods.
|| 5) Eventually but recommended, set the picker to current date.*/

/* ########### ########### ########### ############ ############
|| You can use 3 set methods on the picker:
||
||  • setDateFormat : If you only want months and years or only year..
||      - default to :.fullDate : yyyyMMdd
||      - .mediumDate : yyyyMM
||      - .yearDate : yyyy
||
||  • setRegionFormat: If you want to force an US format for example.
||      - default to :.local
||      - .en : en_US
||      - .de : de_DE
||      - ....
||
||  • setPickerToCurrentDate: Set the selectedRows of the picker passed
||      in argument to current date.
||
|| ########### ########### ########### ############ ############ */

enum DateFormat:Int {
    case fullDate = 0
    case mediumDate
    case yearDate;
    
    var description : String {
        switch self {
        case .fullDate: return "yyyyMMdd";
        case .mediumDate: return "yyyyMM";
        case .yearDate: return "yyyy"; } }
}

enum RegionFormat:Int{
    case en_US = 0, he ,ja_JP,de_DE, /*yourCaseHere, andHere,...,*/ local // Feel free to add your own RegionFormat by adding a case, but please keep ALWAYS local at the last position => the segmenteControl will auto-update according to local.rawValue
    var description : String {
        switch self {
        case .en_US: return "en_US";
        case .he: return "he_HE";
        case .ja_JP: return "ja_JP";
        case .de_DE: return "de_DE";
        case .local: return NSLocale.currentLocale().localeIdentifier
            /* Don't forget to fill the description method if add your on Format ! */
            /*case .yourCase: return "yourCase_YOURCASE";*/ } }
}

class YAMDatePickerHelper: NSObject
{
    //    static let sharedInstance = YAMDatePickerHelper();
    
    private var currentDateFormat : DateFormat = .fullDate;
    private var currentRegionFormat : RegionFormat = .local
    private var dateFormater : NSDateFormatter = NSDateFormatter();
    private(set) var locale = NSLocale(localeIdentifier:RegionFormat.local.description);
    // Data arrays :
    private lazy var days: [String] = self.getDays();
    private lazy var months: [String] = self.getMonth();
    private lazy var thousand: [String] = self.getYearThousand();
    private lazy var unit: [String] = self.getYearDecimalAndUnit();
    weak var updateViewDelegate : UpdateViewProtocol?;
    
}
// PRAGMA MARK: Set Methods:
extension YAMDatePickerHelper
{
    func setRegionFormat(regionFormat: RegionFormat, inPicker picker: UIPickerView)
    {
        let lastSelectedRows = getSelectedRowsWithFormatIndex(inPicker: picker);
        
        self.currentRegionFormat = regionFormat;
        locale = NSLocale(localeIdentifier: currentRegionFormat.description)
        
        dateFormater.locale = locale;
        months = getMonth(); // localized months' name
        picker .reloadAllComponents();
        picker.setNeedsLayout()
        
        let newFormatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        // Set Year component
        picker.selectRow(lastSelectedRows["thousand"]!, inComponent: newFormatIndex["year"]!, animated: false)
        picker.selectRow(lastSelectedRows["unit"]!, inComponent: newFormatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = lastSelectedRows["month"], formatIndex =  newFormatIndex["month"]
        {   // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent:formatIndex, animated: false)
        }
        
        if let selectedDayRow = lastSelectedRows["day"], formatIndex = newFormatIndex["day"]
        {   // Set Day Component:
            picker.selectRow(selectedDayRow, inComponent: formatIndex, animated: false)
        }
        // tell the viewController to refresh the View
        updateViewDelegate?.updateLabel();
    }
    
    func setDateFormat(dateFormat: DateFormat, inPicker picker: UIPickerView)
    {
        /* Take care of year and eventually month to keep track of selectedIndexs after reloadData*/
        let lastSelectedRows = getSelectedRowsWithFormatIndex(inPicker: picker);
        
        currentDateFormat = dateFormat;
        picker .reloadAllComponents();
        picker.setNeedsLayout()
        
        let newFormatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        /*Update new component according to index*/
        picker.selectRow(lastSelectedRows["thousand"]!, inComponent: newFormatIndex["year"]!, animated: false)
        picker.selectRow(lastSelectedRows["unit"]!, inComponent: newFormatIndex["year"]!+1, animated: false)
        
        if let selectedMonthRow = lastSelectedRows["month"], formatIndex = newFormatIndex["month"] {
            // Set Month Component:
            picker.selectRow(selectedMonthRow, inComponent: formatIndex, animated: false)
        }
        // tell the viewController to refresh the View
        updateViewDelegate?.updateLabel();
    }
    
    func setPickerToCurrentDate(datePicker: UIPickerView)
    {
        let date = NSDate()
        let components = NSCalendar(calendarIdentifier: "gregorian")!.components([.Year, .Month, .Day], fromDate: date)
        
        let year =  String(components.year)
        let characters = Array(year.characters)
        let thousandNumbers =  "\(characters[0])" + "\(characters[1])";
        let unitNumbers = "\(characters[2])" + "\(characters[3])"
        
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        datePicker.selectRow(thousand .indexOf(thousandNumbers)!, inComponent: formatIndex["year"]!, animated: false)
        datePicker.selectRow(unit .indexOf(unitNumbers)!, inComponent: formatIndex["year"]!+1, animated: false)
        
        if let indexMonth = formatIndex["month"]
        { datePicker.selectRow(components.month-1, inComponent: indexMonth, animated: false) }
        
        if let indexDay = formatIndex["day"]
        { datePicker.selectRow(components.day-1, inComponent: indexDay, animated: false) }
        
        // tell the viewController to refresh the View
        updateViewDelegate?.updateLabel();
    }
}
// PRAGMA MARK: Get Methods:
extension YAMDatePickerHelper
{
    private func getMonth() -> [String]
    {
        return dateFormater.monthSymbols;
    }
    
    private func getYearThousand() -> [String]
    {
        var years = [String]();
        for index in -50..<0
        {
            years .append(String(index));
        }
        years.append("-0");
        for index in 0...50
        {
            years .append(String(index));
        }
        return years;
    }
    
    private func getYearDecimalAndUnit() -> [String]
    {
        var years = [String]();
        for index in 00...99
        {
            years .append(String(format: "%02d", index));
        }
        return years;
    }
    
    private func getDays() -> [String]
    {
        var days = [String]();
        let numberMaxOfDayPerMonthForTheCurrentCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.maximumRangeOfUnit(NSCalendarUnit.Day);
        
        for index in 1...numberMaxOfDayPerMonthForTheCurrentCalendar.length
        {
            days .append(String(index));
        }
        return days;
    }
    
    private func getRangeOfComponentsWithFormat(dateFormat: DateFormat) -> [String:Int]
    {
        /* Return a dictionnary which contains by convention range for Year, Month and Day in current RegionFomat :*/
        let format : String =  NSDateFormatter.dateFormatFromTemplate(dateFormat.description, options: 0, locale:locale)!
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
        return componentRelativePlace;
    }
    
    private func getSelectedRowsWithFormatIndex(inPicker picker: UIPickerView) -> [String:Int]
    {
        /* Return a dictionnary wich contains the selectedRow in Picker for relative index: */
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        var componentRelativeIndex:[String: Int] = [String: Int]()
        
        componentRelativeIndex["thousand"] = picker.selectedRowInComponent(formatIndex["year"]!)
        componentRelativeIndex["unit"] = picker.selectedRowInComponent(formatIndex["year"]!+1)
        
        if let index = formatIndex["month"] {
            componentRelativeIndex["month"] = picker.selectedRowInComponent(index)}
        
        if let index = formatIndex["day"] {
            componentRelativeIndex["day"] = picker.selectedRowInComponent(index)}
        
        return componentRelativeIndex;
    }
}
// PRAGMA MARK: PickerDelegate and dataSource:
extension YAMDatePickerHelper:UIPickerViewDataSource,UIPickerViewDelegate
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        switch currentDateFormat {
        case .fullDate:
            return 4
        case .mediumDate:
            return 3
        case.yearDate:
            return 2;
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        if component == formatIndex["year"]
        { return thousand.count }
            
        else if component == formatIndex["year"]!+1
        { return unit.count; }
            
        else if component == formatIndex["month"]
        { return months.count; }
            
        else if component == formatIndex["day"]
        { return days.count; }
        
        return 0;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        if component == formatIndex["year"]
        { return thousand[row]; }
            
        else if component == formatIndex["year"]!+1
        { return unit[row]; }
            
        else if component == formatIndex["month"]
        { return months[row]; }
            
        else if component == formatIndex["day"]
        { return days[row]; }
        
        return "case is not defined";
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        
        if component == formatIndex["year"] || component == formatIndex["year"]!+1
        { return 50; }
            
        else if component == formatIndex["month"]
        { return 125; }
            
        else if component == formatIndex["day"]
        { return 60; }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateViewDelegate?.updateLabel();
    }
}

// PRAGMA MARK: Update view protocol
protocol UpdateViewProtocol: class
{
    func updateLabel();
}

// PRAGMA MARK: Convert pickerSelection to String
extension YAMDatePickerHelper
{
    func getStringRepresentationOfPicker(picker: UIPickerView) -> String
    {
        let selectedRows = getSelectedRowsWithFormatIndex(inPicker: picker);
        // get the Strings of selectedIndex in picker
        var stringComponent = ["thousand" : thousand[selectedRows["thousand"]!], "unit" : unit[selectedRows["unit"]!]]
        if let selectedRow = selectedRows["month"]
        { stringComponent["month"] = months[selectedRow]; }
        if let selectedRow = selectedRows["day"]
        { stringComponent["day"] = days[selectedRow]; }
        
        let formatIndex = getRangeOfComponentsWithFormat(currentDateFormat);
        let orderedFormatIndex = formatIndex.sort{ $0.1 < $1.1 }
        
        var stringDateRepresentation = "";
        for couple in orderedFormatIndex
        {
            if couple.0 == "year"
            { stringDateRepresentation.appendContentsOf(stringComponent["thousand"]! + stringComponent["unit"]! + "  ") }
            else
            { stringDateRepresentation.appendContentsOf(stringComponent[couple.0]! + "  ")}
        }
        return stringDateRepresentation;
    }
}