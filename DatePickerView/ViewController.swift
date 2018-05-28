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
        yAMDatePickerHelper.setPickerToDate(date: Date())
        
        // Or you can here set a custom date:
        /* let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = yAMDatePickerHelper.currentDateFormat.description;
        yAMDatePickerHelper.setPickerToDate(dateFormatter.dateFromString("1774/07/04/AD")!); */ // Assume for the example: currentDateFormat = YearMonthDayDateFormat !
    
        /* ######### Set the titles of dateFormat/regionFormatSegmentedControls ######### */
        // Update regionFormatControl number of component and title according to RegionFormat enum:
        regionFormatControl.removeAllSegments()
        for index in 0...RegionFormat.local.rawValue {
            regionFormatControl.insertSegment(withTitle: RegionFormat(rawValue:index)!.description, at: regionFormatControl.numberOfSegments, animated: false) }
        // Select last segment(should be locale.):
        regionFormatControl.selectedSegmentIndex = regionFormatControl.numberOfSegments-1
        
        // Update dateFormatControl title according to locale format:
        setSegmentedFormatTitle()
    }
    
    //PRAGMA MARK: - segmentedControl action
    @IBAction func dateFormatChange(sender: UISegmentedControl) {
        yAMDatePickerHelper.setDateFormat(dateFormat: dateFormatArray[sender.selectedSegmentIndex])
    }
    
    @IBAction func regionFormatChange(sender: UISegmentedControl) {
        yAMDatePickerHelper.setRegionFormat(regionFormat: RegionFormat(rawValue: sender.selectedSegmentIndex)!)
        setSegmentedFormatTitle()
    }
    
    // PRAGMA MARK: - set date and segmentedTitle
    func setSegmentedFormatTitle() {
        let locale = yAMDatePickerHelper.currentDateFormat.locale
        let LongFormat: String =  DateFormatter.dateFormat(fromTemplate: dateFormatArray[0].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(LongFormat, forSegmentAt: 0)
        
        let mediumFormat: String =  DateFormatter.dateFormat(fromTemplate: dateFormatArray[1].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(mediumFormat, forSegmentAt: 1)
        
        let shortFormat: String =  DateFormatter.dateFormat(fromTemplate: dateFormatArray[2].convenienceDescription, options: 0, locale:locale)!
        dateFormatControl.setTitle(shortFormat, forSegmentAt: 2)
    }
    
    func updateLabel() {
        // Update the views:
        dateLabel.text = yAMDatePickerHelper.stringRepresentationOfPicker()
        
        // Print the NSDate represented by the picker as String.
        let dateFormat = DateFormatter();
        dateFormat.dateFormat = yAMDatePickerHelper.currentDateFormat.description;
        /*
        // There is currently a bug in DateFormater that prenvent to parse a String date with an Era:
        // In Swift 2 "2018/01/01/AD" was perfectly valid while it fails in Swift 4:
        */

        //        if let date = yAMDatePickerHelper.dateRepresentationOfPicker() {
        //            print(dateFormat.string(from: date))
        //        }
    }
}
