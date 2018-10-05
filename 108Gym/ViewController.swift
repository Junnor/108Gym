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
        CalendarView.Style.cellColorToday           = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        CalendarView.Style.cellSelectedBorderColor  = UIColor.cyan
        CalendarView.Style.cellEventColor           = UIColor.cyan
        CalendarView.Style.headerTextColor          = UIColor.white
        CalendarView.Style.cellTextColorDefault     = UIColor.white
        CalendarView.Style.cellTextColorToday       = UIColor(red:0.31, green:0.44, blue:0.47, alpha:1.00)
        
        CalendarView.Style.firstWeekday             = .monday
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true
        
        
        calendarView.backgroundColor = UIColor(red:0.31, green:0.44, blue:0.47, alpha:1.00)
        
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
        
        let today = Date()
        self.calendarView.setDisplayDate(today)
        refreshCalendarEvents()
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
            }
        } else {
            // add
            alert = UIAlertController(title: "签到", message: nil, preferredStyle: .alert)
            ok = UIAlertAction(title: "确定", style: .default) { (alert) in
                self.addExerciseDate(date)
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        
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
    
    private func addExerciseDate(_ date: Date) {
        
        let obj = GymCheckModel()
        obj.date = date.timeIntervalSince1970

        try! realm.write {
            realm.add(obj)
        }
        
        let event = createCalendarEvent(check: obj)
        self.calendarView.events.append(event)
        
    }
    
    
    private func removeExerciseDate(_ date: Date) {
        
    }

}
