# Swift_DatePickerLike_component_with_format

A Swift `UIPickerView` to emulate the `UIDatePicker` behavior. It allows you to choose **YearMonth** or **Year** format and **quick** select a date *far in the past*.

<img src="https://cloud.githubusercontent.com/assets/17645306/14368420/e28d9f0c-fd1d-11e5-8cec-dacd62efdeb3.png" height="400"> <img src="https://cloud.githubusercontent.com/assets/17645306/14368422/e2902376-fd1d-11e5-8058-fccc5bf4328f.png" height="400"> <img src="https://cloud.githubusercontent.com/assets/17645306/14368421/e28eaf8c-fd1d-11e5-9e2d-d05f9139cda0.png" height="400"> <img src="https://cloud.githubusercontent.com/assets/17645306/14368419/e28b7902-fd1d-11e5-9672-d9f3c7c712f9.png" height="400"> <img src="https://cloud.githubusercontent.com/assets/17645306/14368418/e28a979e-fd1d-11e5-9616-48a507b98e31.png" height="400">

-----------------------------------------------------------------------------------------------------------------------
## How to use YAMDatePickerHelper ?
-----------------------------------------------------------------------------------------------------------------------

1. Just add the ***YAMDatePickerHelper*** file to your project and make sure "Copy if needed" is checked.
2. Add an `UIPickerView` to your view and make a referenced outlet if it was created with stroyboard.
3. Create an instance of ***YAMDatePickerHelper*** and pass in argument the picker you want to control. It will set the *delegate* and *dataSource* automatically (Do NOT set the *delegate* and *dataSource* with the storyboard !).
4. Set the updateViewProtocol delegate to provide a call-back mechanism and tell the VC to tell the views to update.
5. Eventually customise the appearance (*dateFormat* and *regionFormat*) with the set methods.
6. Eventually but recommended, set the picker to current date.

  
-----------------------------------------------------------------------------------------------------------------------
#### You can use 3 set methods to configure the picker:
-----------------------------------------------------------------------------------------------------------------------

- `setDateFormat(dateFormat: DateFormat)` If you only want months and years or only year.          
    - default to YearMonthDayDateFormat: yyyyMMdd             
    - YearMonthDateFormat: yyyyMM              
    - YearDateFormat: yyyy              

- `setRegionFormat(regionFormat: RegionFormat)` If you want to force an US format for example.               
      - default to .local               
      - .en : en_US               
      - .de : de_DE             
      - ....            

- `setPickerToDate(date: NSDate)` Set the picker to the date passed in argument.

-----------------------------------------------------------------------------------------------------------------------
#### You can use 2 get methods to retrieve the picker's value:
-----------------------------------------------------------------------------------------------------------------------

- `stringRepresentationOfPicker()` : Returns the date displayed in the picker as `String`.
- `dateRepresentationOfPicker()` : Returns the date displayed in the picker as `NSDate` or nil if date is *invalid*.

-----------------------------------------------------------------------------------------------------------------------
#### Typically you will put this code in your `viewController`:
-----------------------------------------------------------------------------------------------------------------------

    var yAMDatePickerHelper: YAMDatePickerHelper!;

    override func viewDidLoad() {
    super.viewDidLoad()

    // Init the helper with the desired picker:
    yAMDatePickerHelper = YAMDatePickerHelper(picker: datePicker)

    // Set the delegate to self to have a call-back mechanism:
    yAMDatePickerHelper.updateViewDelegate = self

    // Customize the RegionFormat or the DateFormat:
    yAMDatePickerHelper.setDateFormat(YearMonthDayDateFormat()) // Optional                    
    yAMDatePickerHelper.setRegionFormat(.local)  // Optional                             

    // Set the picker to current date:
    yAMDatePickerHelper.setPickerToDate(NSDate())
    ... // your own code
    }
    

-----------------------------------------------------------------------------------------------------------------------
#### Tell the `viewController` to update the Views:
-----------------------------------------------------------------------------------------------------------------------

- Use the `UpdateViewProtocol` declare in `YAMDatePickerHelper.swift`
- Make your `viewController` conform to `UpdateViewProtocol` and implement the methods
- Set your `viewController` as delegate e.g in the `viewDidLoad` method : `yAMDatePickerHelper.updateViewDelegate = self`

-----------------------------------------------------------------------------------------------------------------------
#### License 
-----------------------------------------------------------------------------------------------------------------------
[License](https://github.com/aymericbaur/datePicker-component/blob/master/LICENSE)

-----------------------------------------------------------------------------------------------------------------------
#### Compatibility
-----------------------------------------------------------------------------------------------------------------------
##### *iOS 7 and later*


-----------------------------------------------------------------------------------------------------------------------
#### Special thanks
-----------------------------------------------------------------------------------------------------------------------

