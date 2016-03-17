# DatePicker-component-with-format
UIDatePicker to choose easily a datFormat and a date far in the past.
-----------------------------------------------------------------------------------------------------------------------
                                  How to use YAMDatePickerHelper ?
-----------------------------------------------------------------------------------------------------------------------

1) Just add the YAMDatePickerHelper file to your project and make sure "Copy if needed" is checked.   
2) Add an UIPickerView to your view and make a referenced outlet if it was created with stroyboard.   
3) Set the delegate of the picker with an instance of YAMDatePickerHelper (Do NOT set the delegate and dataSource with the storyboard !).    
4) Eventually customise the appearance with the set methods.  
5) Eventually but recommended, set the picker to current date.
  
  ****** ******** ******** 
                              You can use 3 set methods on the picker:
  ****** ******** ******** 
• setDateFormat : If you only want months and years or only year.          
    - default to YearMonthDayDateFormat: yyyyMMdd             
    - YearMonthDateFormat: yyyyMM              
    - YearDateFormat: yyyy              

• setRegionFormat: If you want to force an US format for example.               
    - default to .local               
    - .en : en_US               
    - .de : de_DE             
    - ....            

• setPickerToCurrentDate: Set the selectedRows of the picker passed
    in argument to current date.

  ****** ******** ******** 
                        You can get a String representation of the date :
  ****** ******** ******** 

• stringRepresentationOfPicker: just pass in argument the picker you want to get the String representation of date.         

****** ******** ******** 
                Typically you will put this in your viewController:
****** ******** ******** 

let yAMDatePickerHelper = YAMDatePickerHelper()

// Just set the delegate of the picker with yAMDatePickerHelper     
picker.delegate = yAMDatePickerHelper                 
picker.dataSource = yAMDatePickerHelper

yAMDatePickerHelper.setDateFormat(YearMonthDayDateFormat, inPicker: picker) // Optional                    
yAMDatePickerHelper.setRegionFormat(.local, inPicker: picker)  // Optional                             
yAMDatePickerHelper.setPickerToCurrentDate(picker)                


****** ******** ******** 
                         To tell the viewController to update the View:
****** ******** ******** 

• Use the UpdateViewProtocol declare in YAMDatePickerHelper.swift                       
• Make your viewController conform to UpdateViewProtocol and implement the methods                            
• Set your viewController as delagate e.g in the viewDidLoad method : yAMDatePickerHelper.updateViewDelegate = self                   







