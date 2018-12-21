//
//  ViewController.swift
//  108Gym
//
//  Created by dq on 2018/9/28.
//  Copyright © 2018 moelove. All rights reserved.
//

import UIKit
import RealmSwift
import KDCalendar

class ViewController: UIViewController {
    
    // Calendar
    var calendarView: CalendarView!
    
    // Ream
    let realm = try! Realm()
    
    var results = try! Realm().objects(GymCheckModel.self)
    var notification: NotificationToken?
    
    @IBOutlet weak var totalCountLabel: UILabel! {
        didSet {
            totalCountLabel.text = ""
        }
    }
    
    @IBOutlet weak var passDaysLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.addTarget(self, action: #selector(signInToday), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "108天签到"
        
        
        let edge: CGFloat = 16
        
        calendarView = CalendarView()
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: edge).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -edge).isActive = true
        calendarView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor).isActive = true

        CalendarView.Style.cellShape                = .bevel(8.0)
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellColorToday           = UIColor.red.withAlphaComponent(0.3)
        CalendarView.Style.cellSelectedBorderColor  = UIColor.cyan
        CalendarView.Style.cellEventColor           = UIColor.cyan
        CalendarView.Style.headerTextColor          = UIColor.white
        CalendarView.Style.cellTextColorDefault     = UIColor.white
        CalendarView.Style.cellTextColorToday       = UIColor.white
        
        CalendarView.Style.firstWeekday             = .monday
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true
        
        
        calendarView.backgroundColor = UIColor(red:0.31, green:0.44, blue:0.47, alpha:1.00)
        
        notification = results.observe({ (changes) in
            self.totalCountLabel.text = "共打卡：\(self.results.count)天"
        })
        
        // 今日已打卡
        if let _ = sameCheckModelForDate(today) {
            updateSignInButton(isEnabled: false)
        } else {
            updateSignInButton(isEnabled: true)
        }
        
        passDaysLabel.text = "过去\(self.daysInterval())天"
    }
    
    private func refreshCalendarEvents() {
        let items = results.map {
            return self.createCalendarEvent(check: $0)
        }
        print("items = \(items)")
        self.calendarView.events = Array(items)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.calendarView.reloadData()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.calendarView.setDisplayDate(today)
        refreshCalendarEvents()
    }
    
    var today = Date()
    
    func isDateInToday(_ date: Date) -> Bool {
        return calendarView.calendar.isDateInToday(date)
    }
    
    func daysInterval() -> Int {
        let cp = calendarView.calendar.dateComponents([.day], from: startDate(), to: today)
        let days = cp.day ?? 0
        return days
    }

    private func createCalendarEvent(check: GymCheckModel) -> CalendarEvent {
        let event = CalendarEvent(title: "签到", startDate: Date.init(timeIntervalSince1970: check.date), endDate: Date.init(timeIntervalSince1970: check.date))
        return event
    }
    
    private func planStartDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let date = dateFormatter.date(from: "2018-09-17")!
        return date
    }
    
    // 今日打卡
    @objc private func signInToday() {
        let alert = UIAlertController(title: "签到", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { (alert) in
            self.addExerciseDate(self.today, completion: { success in
                if success {
                    self.updateSignInButton(isEnabled: false)
                }
            })
        }
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateSignInButton(isEnabled: Bool) {
        self.signInButton.setTitle(isEnabled ? "今日打卡" : "已打卡", for: .normal)
        self.signInButton.isEnabled = isEnabled
    }

}

// MARK: - CalendarViewDataSource
extension ViewController: CalendarViewDataSource {
    
    func startDate() -> Date {
        return planStartDate()
    }
    
    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        let oneYearLate = self.calendarView.calendar.date(byAdding: dateComponents, to: planStartDate())!
        return oneYearLate
    }

}

extension ViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didDeselectDate date: Date) {
        
    }
    
    func calendar(_ calendar: CalendarView, didLongPressDate date: Date) {
        let alert: UIAlertController
        let ok: UIAlertAction
        
        // remove check
        if let check = sameCheckModelForDate(date) {
            alert = UIAlertController(title: "删除签到", message: nil, preferredStyle: .alert)
            ok = UIAlertAction(title: "确定", style: .default) { (alert) in
                try! self.realm.write {
                    self.realm.delete(check)
                }
                
                self.refreshCalendarEvents()
                
                // 是今日
                if self.isDateInToday(date) {
                    self.updateSignInButton(isEnabled: true)
                }
            }
        } else {
            // add
            alert = UIAlertController(title: "签到", message: nil, preferredStyle: .alert)
            ok = UIAlertAction(title: "确定", style: .default) { (alert) in
                self.addExerciseDate(date, completion: { success in
                    if success {
                        // 是今日
                        if self.isDateInToday(date) {
                            self.updateSignInButton(isEnabled: false)
                        }
                    }
                })

            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date: Date) {
        
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        
    }
    
    func calendar(_ calendar: CalendarView, canSelectDate date: Date) -> Bool {
        return true
    }
}


// MARK: - Add action
extension ViewController {
    
    
    
    private func sameCheckModelForDate(_ date: Date) -> GymCheckModel? {
        for item in results {
            let itemDate = Date.init(timeIntervalSince1970: item.date)
            if Calendar.current.isDate(date, inSameDayAs: itemDate) {
                return item
            }
        }
        return nil
    }
    
    private func addExerciseDate(_ date: Date, completion: @escaping(_ success: Bool) -> ()) {
        
        let obj = GymCheckModel()
        obj.date = date.timeIntervalSince1970

        try! realm.write {
            realm.add(obj)
        }
        
        let event = createCalendarEvent(check: obj)
        self.calendarView.events.append(event)
        
        completion(true)
    }
    
    
    private func removeExerciseDate(_ date: Date) {
        
    }

}
