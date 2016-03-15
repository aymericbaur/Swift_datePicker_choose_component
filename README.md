# DatePicker-component-with-format
UIDatePicker to choose easily a datFormat and a date far in the past.
-----------------------------------------------------------------------------------------------------------------------
                                  How to use YAMDatePickerHelper ?
-----------------------------------------------------------------------------------------------------------------------

1) Just add the YAMDatePickerHelper file to your project and make sure "Copy if needed" is checked.   
2) Add an UIPickerView to your view and make a referenced outlet if it was created with stroyboard.   
3) Set the delegate of the picker with an instance of YAMDatePickerHelper (Do NOT set the delegate and dataSource with storyboard !).    
4) Eventually customise the appearance with the set methods.  
5) Eventually but recommended, set the picker to current date.
  
  ****** ******** ******** 
                              You can use 3 set methods on the picker:
  ****** ******** ******** 
• setDateFormat : If you only want months and years or only year..          
    - default to .fullDate : yyyyMMdd             
    - .mediumDate : yyyyMM              
    - .yearDate : yyyy              

• setRegionFormat: If you want to force an US format for example.               
    - default to .local               
    - .en : en_US               
    - .de : de_DE             
    - ....            

• setPickerToCurrentDate: Set the selectedRows of the picker passed
    in argument to current date.

****** ******** ******** 
              //  Typically you will put this code in the viewDidLoad method of your viewController :
****** ******** ******** 
// Just set the delegate of the picker with YAMDatePickerHelper     
picker.delegate = YAMDatePickerHelper.sharedInstance;                 
picker.dataSource = YAMDatePickerHelper.sharedInstance;

YAMDatePickerHelper.sharedInstance.setDateFormat(.fullDate, inPicker: picker);        
YAMDatePickerHelper.sharedInstance.setRegionFormat(.local, inPicker: picker);         
YAMDatePickerHelper.sharedInstance.setPickerToCurrentDate(picker)
****** ******** ******** 
