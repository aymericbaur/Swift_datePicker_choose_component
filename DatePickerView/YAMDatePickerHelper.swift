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
||      - default to : YearMonthDayDateFormat : yyyyMMdd
||      - mediumformat : YearMonthDateFormat yyyyMM
||      - shortFormat : YearDateFormat yyyy
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

class YAMDatePickerHelper: NSObject
{
    private(set) var currentDateFormat : DateFormat = YearMonthDayDateFormat();
    private(set) var currentRegionFormat : RegionFormat = .local

    weak var updateViewDelegate : UpdateViewProtocol?;
    
    /* Give an index for each Struct (Used for associate dateFormatSegmentedControl selected index to DateFormat value, otherwise you can comment it). */
    private let dateFormatArray: [DateFormat] = [YearMonthDayDateFormat(), YearMonthDateFormat(), YearDateFormat()];
}

// PRAGMA MARK: Reachable Methods Set:
extension YAMDatePickerHelper
{
    func setRegionFormat(regionFormat: RegionFormat, inPicker picker: UIPickerView)
    {
        let lastSelectedRows = currentDateFormat.getSelectedRowsIndexInPicker(picker)
        
        self.currentRegionFormat = regionFormat;
        self.currentDateFormat.locale = NSLocale(localeIdentifier: currentRegionFormat.description);
        
        picker .reloadAllComponents();
        picker.setNeedsLayout()

        currentDateFormat.setPickerWithSeletedRows(picker, lastSelectedRows: lastSelectedRows)
        
        // tell the viewController to refresh the views if needed (e.g the dateLabel)
        updateViewDelegate?.updateLabel();
    }
    
    func setDateFormat(dateFormat:DateFormat, inPicker picker: UIPickerView)
    {
        /* Take care of year and eventually month to keep track of selectedIndexs after reloadData*/
        let lastSelectedRows = currentDateFormat.getSelectedRowsIndexInPicker(picker)
        
        currentDateFormat = dateFormat
        picker .reloadAllComponents();
        picker.setNeedsLayout()
        
        currentDateFormat.setPickerWithSeletedRows(picker, lastSelectedRows: lastSelectedRows)
        // tell the viewController to refresh the views if needed (e.g the dateLabel)
        updateViewDelegate?.updateLabel();
    }
    
    func setPickerToCurrentDate(datePicker: UIPickerView)
    {
        currentDateFormat.setPickerAtStart(datePicker);
        // tell the viewController to refresh the View
        updateViewDelegate?.updateLabel();
    }
}

// PRAGMA MARK: Reachable Methods Get:
extension YAMDatePickerHelper
{
    func getFormatArray() -> [DateFormat]
    {
        return self.dateFormatArray;
    }
    
    func getStringRepresentationOfPicker(picker: UIPickerView) -> String
    {
        return currentDateFormat.getStringRepresentationOfPicker(picker);
    }
}

// PRAGMA MARK: PickerDelegate and dataSource:
extension YAMDatePickerHelper:UIPickerViewDataSource,UIPickerViewDelegate
{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return currentDateFormat.numberOfComponents;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentDateFormat.numberOfRowsInComponent(component)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentDateFormat.titleForRowInComponent(component, row: row)
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return currentDateFormat.widthForComponent(component);
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

