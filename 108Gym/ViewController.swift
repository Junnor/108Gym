//
//  ViewController.swift
//  108Gym
//
//  Created by dq on 2018/9/28.
//  Copyright © 2018 moelove. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
        
    let realm = try! Realm()
    
    var results = try! Realm().objects(GymCheckModel.self)
    var notification: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "108天签到"
        
        let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addAction))
        self.navigationItem.rightBarButtonItem = addItem
        
        notification = results.observe({ (changes) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.endUpdates()
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                print("realm error = \(err)")
            }
        })
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath)
        
        let object = results[indexPath.row]
        cell.textLabel?.text = object.title
        cell.detailTextLabel?.text = object.detail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            realm.beginWrite()
            realm.delete(results[indexPath.row])
            try! realm.commitWrite()
        }
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
