//
//  ViewController.swift
//  DatePickerView
//
//  Created by Tip on 02/03/2016.
//  Copyright © 2016 tip. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UpdateViewProtocol
{
    @IBOutlet weak var dateFormatControl: UISegmentedControl!
    @IBOutlet weak var regionFormatControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var dateLabel: UILabel!
   
    let yAMDatePickerHelper = YAMDatePickerHelper();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Give the PickerView its delegate and dataSource:
        datePicker.delegate = yAMDatePickerHelper;
        datePicker.dataSource = yAMDatePickerHelper;
        yAMDatePickerHelper.updateViewDelegate = self;
        
        // Update SegmentedControlRegionFormat number of component and title according to RegionFormat enum:
        regionFormatControl.removeAllSegments()
        for index in 0...RegionFormat.local.rawValue {
            regionFormatControl.insertSegmentWithTitle(RegionFormat(rawValue:index)!.description, atIndex: regionFormatControl.numberOfSegments, animated: false)
        }
        
        // Select segment :
        regionFormatControl.selectedSegmentIndex = regionFormatControl.numberOfSegments-1;

        // Set date at start:
        yAMDatePickerHelper.setPickerToCurrentDate(datePicker)
        
        // Update SegmentedControlDateFormat title according to locale format:
        setSegmentedFormatTitle()
    }
    
    //PRAGMA MARK: segmentedControl action
    @IBAction func dateFormatChange(sender: UISegmentedControl)
    {
        yAMDatePickerHelper.setDateFormat(yAMDatePickerHelper.getFormatArray()[sender.selectedSegmentIndex], inPicker: datePicker)
    }
    
    @IBAction func regionFormatChange(sender: UISegmentedControl) {
        yAMDatePickerHelper.setRegionFormat(RegionFormat(rawValue: sender.selectedSegmentIndex)!, inPicker: datePicker);
        setSegmentedFormatTitle()
    }
    
    // PRAGMA MARK: set date and segmentedTitle
    func setSegmentedFormatTitle()
    {
        let locale = yAMDatePickerHelper.locale;
        let LongFormat : String =  NSDateFormatter.dateFormatFromTemplate(yAMDatePickerHelper.getFormatArray()[0].description, options: 0, locale:locale)!
        dateFormatControl.setTitle(LongFormat, forSegmentAtIndex: 0);

        let mediumFormat : String =  NSDateFormatter.dateFormatFromTemplate(yAMDatePickerHelper.getFormatArray()[1].description, options: 0, locale:locale)!
        dateFormatControl.setTitle(mediumFormat, forSegmentAtIndex: 1);
        
        let shortFormat : String =  NSDateFormatter.dateFormatFromTemplate(yAMDatePickerHelper.getFormatArray()[2].description, options: 0, locale:locale)!
        dateFormatControl.setTitle(shortFormat, forSegmentAtIndex: 2);
    }
    
    func updateLabel()
    {
        dateLabel.text = yAMDatePickerHelper.getStringRepresentationOfPicker(datePicker);
    }
}