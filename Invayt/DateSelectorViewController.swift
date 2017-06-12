//
//  DateSelectorViewController.swift
//  Invayt
//
//  Created by Vincent Villalta on 12/8/16.
//  Copyright © 2016 Vincent Villalta. All rights reserved.
//

import UIKit
import CVCalendar

protocol SetDateForEventDelegate: class {
    func setDateForEvent(selectedDate: Date)
}


class DateSelectorViewController: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var selectedDateTIme: UILabel!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var startDate: UIButton!
    @IBOutlet weak var endDate: UIButton!
    struct Color {
        static let selectedText = UIColor.white
        static let text = UIColor.black
        static let textDisabled = UIColor.gray
        static let selectionBackground = UIColor(red: 0.2, green: 0.2, blue: 1.0, alpha: 1.0)
        static let sundayText = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        static let sundayTextDisabled = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        static let sundaySelectionBackground = sundayText
    }
    
    var currentCalendar: Calendar?
    var shouldShowDaysOut = true
    var animationFinished = true
    var day = 0
    var month = 0
    var year = 0
    var hour = 0
    var minute = 0
    var selectedDate : Date!
    var selectedEndDate: Date!
    var settingEndDate = false
    weak var delegate: SetDateForEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentCalendar = Calendar.init(identifier: .gregorian)
        if let currentCalendar = currentCalendar {
            monthLabel.text = CVDate(date: Date(), calendar: currentCalendar).globalDescription
        }
        self.startDate.setTitleColor(.blue, for: .normal)
        self.createInitialDate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    func calendar() -> Calendar? {
        return currentCalendar
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        //selectedDay = dayView
        print(dayView.date.day)
        print(dayView.date.month)
        print(dayView.date.year)
        self.day = dayView.date.day
        self.month = dayView.date.month
        self.year = dayView.date.year
        self.createDateTime()
    }
    

    
    func shouldSelectRange() -> Bool {
        return true
    }
    
    func didSelectRange(from startDayView: DayView, to endDayView: DayView) {
        print("RANGE SELECTED: \(startDayView.date.commonDescription) to \(endDayView.date.commonDescription)")
    }
    
    func disableScrollingBeforeDate() -> Date {
        return Date()
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                self.monthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
            }) { _ in
                
                self.animationFinished = true
                self.monthLabel.frame = updatedMonthLabel.frame
                self.monthLabel.text = updatedMonthLabel.text
                self.monthLabel.transform = CGAffineTransform.identity
                self.monthLabel.alpha = 1
                updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }

    @IBAction func selectedTime(_ sender: UIDatePicker) {
        let unitFlags = Set<Calendar.Component>([.hour, .minute])
        let calendar = Calendar.current
        let components = calendar.dateComponents(unitFlags, from: sender.date)
        self.hour = components.hour!
        self.minute = components.minute!
        self.createDateTime()
    }
    
    func createInitialDate() {
        let unitFlags = Set<Calendar.Component>([.hour, .minute, .day, .month, .year])
        let calendar = Calendar.current
        let components = calendar.dateComponents(unitFlags, from: Date())
        self.hour = components.hour!
        self.minute = components.minute!
        self.day = components.day!
        self.month = components.month!
        self.year = components.year!
        //self.createDateTime()
    }
   
    func createDateTime(){
        let dateString = "\(self.day)-\(self.month)-\(self.year) \(self.hour):\(String(format: "%02d", self.minute))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let d = dateFormatter.date(from: dateString)
        
        if self.settingEndDate {
            self.selectedEndDate = d
            self.endDate.setTitle(dateString,for: .normal)
        } else {
            self.selectedDate = d
            self.startDate.setTitle(dateString,for: .normal)
        }
        
        print(dateString)
        print(d)
        

    }
    
    @IBAction func endDate(_ sender: Any) {
        settingEndDate = true
        self.startDate.setTitleColor(.blue, for: .normal)
        self.endDate.setTitleColor(.lightGray, for: .normal)
    }
    
    @IBAction func startDate(_ sender: Any) {
        settingEndDate = false
        self.endDate.setTitleColor(.blue, for: .normal)
        self.startDate.setTitleColor(.lightGray, for: .normal)
    }
    
    
    @IBAction func done(_ sender: Any) {
        delegate?.setDateForEvent(selectedDate: self.selectedDate)
        self.dismiss(animated: true, completion: nil)
    }
}
