//
//  ViewController.swift
//  DatePickerView
//
//  Created by Tip on 02/03/2016.
//  Copyright © 2016 tip. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UpdateViewProtocol {
    @IBOutlet weak var dateFormatControl: UISegmentedControl!
    @IBOutlet weak var regionFormatControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
    
    /* Give an index for each Struct (Used for associate dateFormatSegmentedControl selected index to DateFormat value, otherwise you can comment it). */
    private let dateFormatArray: [DateFormat] = [YearMonthDayDateFormat(), YearMonthDateFormat(), YearDateFormat()]
    
    var yAMDatePickerHelper: YAMDatePickerHelper!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init the helper with the desired picker:
        yAMDatePickerHelper = YAMDatePickerHelper(picker: datePicker)
    
        // Set the delegate to self to have a call-back mechanism:
        yAMDatePickerHelper.updateViewDelegate = self
        
        // Customize the RegionFormat or the DateFormat if needed:
        //yAMDatePickerHelper.setDateFormat(YearMonthDayDateFormat()) // Optional
        //yAMDatePickerHelper.setRegionFormat(.locale)  // Optional
        
        // Set picker to current date at start (customisation):
        yAMDatePickerHelper.setPickerToDate(NSDate())
        
        // Or you can here set a custom date:
        /* let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = yAMDatePickerHelper.currentDateFormat.description;
        yAMDatePickerHelper.setPickerToDate(dateFormatter.dateFromString("1774/07/04/AD")!); */ // Assume for the example: currentDateFormat = YearMonthDayDateFormat !
    
        /* ######### Set the titles of dateFormat/regionFormatSegmentedControls ######### */
        // Update regionFormatControl number of component and title according to RegionFormat enum:
        regionFormatControl.removeAllSegments()
        for index in 0...RegionFormat.locale.rawValue {
            regionFormatControl.insertSegmentWithTitle(RegionFormat(rawValue:index)!.description, atIndex: regionFormatControl.numberOfSegments, animated: false) }
        // Select last segment(should be locale.):
        regionFormatControl.selectedSegmentIndex = regionFormatControl.numberOfSegments-1
        
        // Update dateFormatControl title according to locale format:
        setSegmentedFormatTitle()
    }
    
    //PRAGMA MARK: - segmentedControl action
    @IBAction func dateFormatChange(sender: UISegmentedControl) {
        yAMDatePickerHelper.setDateFormat(dateFormatArray[sender.selectedSegmentIndex])
    }
    
    @IBAction func regionFormatChange(sender: UISegmentedControl) {
        yAMDatePickerHelper.setRegionFormat(RegionFormat(rawValue: sender.selectedSegmentIndex)!)
        setSegmentedFormatTitle()
    }
    
    // PRAGMA MARK: - set date and segmentedTitle
    func setSegmentedFormatTitle() {
        let locale = yAMDatePickerHelper.currentDateFormat.locale
        let LongFormat: String =  NSDateFormatter.dateFormatFromTemplate(dateFormatArray[0].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(LongFormat, forSegmentAtIndex: 0)
        
        let mediumFormat: String =  NSDateFormatter.dateFormatFromTemplate(dateFormatArray[1].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(mediumFormat, forSegmentAtIndex: 1)
        
        let shortFormat: String =  NSDateFormatter.dateFormatFromTemplate(dateFormatArray[2].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(shortFormat, forSegmentAtIndex: 2)
    }
    
    func updateLabel() {
        // Update the views:
        dateLabel.text = yAMDatePickerHelper.stringRepresentationOfPicker()
        
        // Print the NSDate represented by the picker as String.
        let dateFormat = NSDateFormatter();
        dateFormat.dateFormat = yAMDatePickerHelper.currentDateFormat.description;
        if let date = yAMDatePickerHelper.dateRepresentationOfPicker() {
            print(dateFormat.stringFromDate(date))
        }
    }
}