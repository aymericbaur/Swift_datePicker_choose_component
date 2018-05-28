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
|| 3) Create an instance of YAMDatePickerHelper and pass in argument the picker you want to control. It will set the delegate and dataSource automatically (Do NOT set the delegate and dataSource with the storyboard !).
|| 4) Set the updateViewProtocol delegate to provide a call-back mechanism and tell the VC to tell the views to update.
|| 5) Eventually customise the appearance (dateFormat and regionFormat) with the set methods.
|| 6) Eventually but recommended, set the picker to current date.*/

/* ########### ########### ########### ############ ############
|| You can use 3 set methods on the picker:
||
||  • setDateFormat: If you only want months and years or only year..
||      - default to: YearMonthDayDateFormat: yyyyMMdd
||      - mediumformat: YearMonthDateFormat yyyyMM
||      - shortFormat: YearDateFormat yyyy
||
||  • setRegionFormat: If you want to force an US format for example.
||      - default to:.local
||      - .en: en_US
||      - .de: de_DE
||      - ....
||
||  • setPickerToDate(date: Date): Set the picker to the date passed in argument.
||
|| ########### ########### ########### ############ ############ */

/* ########### ########### ########### ############ ############
 || You can use 2 get methods on the picker:
 ||
 ||  • stringRepresentationOfPicker(): Returns the date displayed in the picker as String.
 ||
 ||  • dateRepresentationOfPicker(): Returns the date displayed in the picker as Date or nil if date is invalid.
 ||
 || ########### ########### ########### ############ ############ */

// PRAGMA MARK: - YAMDatePickerHelper Class:
class YAMDatePickerHelper: NSObject {
    private(set) var currentDateFormat: DateFormat = YearMonthDayDateFormat()
    private(set) var currentRegionFormat: RegionFormat = .local
    private(set) var picker: UIPickerView!;

    weak var updateViewDelegate: UpdateViewProtocol?
    
    init(picker: UIPickerView) {
        super.init();
        self.picker = picker;
        self.picker.delegate = self;
        self.picker.dataSource = self;
    }
}

// PRAGMA MARK: Reachable Methods Set:
extension YAMDatePickerHelper {
    /** Set the RegionFormat to display.
    - E.g: "July 4. 1776" will become "4 Juli 1776" in German.
     */
    func setRegionFormat(regionFormat: RegionFormat) {
        /* Take care of year, eventually months and days to keep track of selectedIndexes after reloadData */
        let selectedRows = currentDateFormat.selectedRowsIndexInPicker(picker: picker)
        
        self.currentRegionFormat = regionFormat
        self.currentDateFormat.locale = Locale(identifier: currentRegionFormat.description)
        
        picker .reloadAllComponents()
        picker .setNeedsLayout()
        
        currentDateFormat.setPickerWithSeletedRows(picker: picker, selectedRows: selectedRows)
        
        // tell the viewController to refresh the views if needed (e.g the dateLabel)
        updateViewDelegate?.updateLabel()
    }
    /** Set the DateFormat (yyyyMMdd, yyyyMM, yyyy) to display.  */
    func setDateFormat(dateFormat:DateFormat) {
        /* Take care of year and eventually months to keep track of selectedIndexes after reloadData */
        let selectedRows = currentDateFormat.selectedRowsIndexInPicker(picker: picker)
        
        currentDateFormat = dateFormat
        currentDateFormat.locale = Locale(identifier: currentRegionFormat.description)
        picker .reloadAllComponents()
        picker.setNeedsLayout()
        
        currentDateFormat.setPickerWithSeletedRows(picker: picker, selectedRows: selectedRows)
        
        // tell the viewController to refresh the views if needed (e.g the dateLabel)
        updateViewDelegate?.updateLabel()
    }
    
    func setPickerToDate(date: Date) {
        currentDateFormat.setPickerToDate(picker: picker, date:date);
       
        // tell the viewController to refresh the View
        updateViewDelegate?.updateLabel()
    }
}

// PRAGMA MARK: Reachable Methods Get:
extension YAMDatePickerHelper {
    /** Returns the date actually displayed in the picker as String.
     - returns: String which is the date actually displayed in the picker.
     */
    func stringRepresentationOfPicker() -> String {
        return currentDateFormat.stringRepresentationOfPicker(picker: picker)
    }

    /** Returns the date actually displayed in the picker as Date.
     - returns: Date which is the date actually displayed in the picker.
     */
    func dateRepresentationOfPicker() -> Date? {
        return currentDateFormat.dateRepresentationOfPicker(picker: picker)
    }
}

// PRAGMA MARK: - PickerDelegate and dataSource:
extension YAMDatePickerHelper:UIPickerViewDataSource,UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentDateFormat.numberOfRowsInComponent(component: component)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return currentDateFormat.numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentDateFormat.titleForRowInComponent(component: component, row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return currentDateFormat.widthForComponent(component: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Solve the errors when the user select a new row;
        currentDateFormat.handleErrorsFromUserChoice(picker: pickerView);
        updateViewDelegate?.updateLabel()
    }
}

// PRAGMA MARK: Update view protocol
protocol UpdateViewProtocol: class {
    /** Tell the viewController to update the views */
    func updateLabel()
}
