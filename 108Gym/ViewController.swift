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
    var textView: UITextView!
    
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

        textView = UITextView()
        textView.backgroundColor = UIColor.lightGray
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: edge).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -edge).isActive = true
        textView.topAnchor.constraint(equalTo: self.calendarView.bottomAnchor, constant: 10).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -10).isActive = true

        CalendarView.Style.cellShape                = .bevel(8.0)
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellColorToday           = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        CalendarView.Style.cellSelectedBorderColor  = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        CalendarView.Style.cellEventColor           = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
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

//        notification = results.observe({ (changes) in
//            switch changes {
//            case .initial:
//                // Results are now populated and can be accessed without blocking the UI
//                self.tableView.reloadData()
//            case .update(_, let deletions, let insertions, let modifications):
//                // Query results have changed, so apply them to the TableView
//                self.tableView.beginUpdates()
//                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
//                self.tableView.endUpdates()
//            case .error(let err):
//                // An error occurred while opening the Realm file on the background worker thread
//                print("realm error = \(err)")
//            }
//        })
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let today = Date()
        
        var tomorrowComponents = DateComponents()
        tomorrowComponents.day = 1
        
        
        let tomorrow = self.calendarView.calendar.date(byAdding: tomorrowComponents, to: today)!
        self.calendarView.selectDate(tomorrow)
        
        self.calendarView.setDisplayDate(today)
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
    
    @objc private func addAction() {
        let alertVC = UIAlertController(title: nil, message: "打卡了", preferredStyle: .actionSheet)
    
        let exercise = UIAlertAction(title: "锻炼", style: .default) { (_) in
            self.add(isExercise: true)
        }
        let check = UIAlertAction(title: "简单签到", style: .default) { (_) in
            self.add(isExercise: false)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    
        alertVC.addAction(exercise)

        alertVC.addAction(check)
        alertVC.addAction(cancel)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func add(isExercise: Bool) {

        let obj = GymCheckModel()
        obj.date = Date().timeIntervalSince1970
        obj.exercise = isExercise
        obj.checked = !isExercise
        
        try! realm.write {
            realm.add(obj)
        }
        
    }
    
    
}
