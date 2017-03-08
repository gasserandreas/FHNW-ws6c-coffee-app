//
//  MainTableViewController.swift
//  FHNW-WS6C-CoffeeApp
//
//  Created by Andreas Gasser on 28.02.17.
//  Copyright © 2017 FHNW. All rights reserved.
//

import UIKit
import Foundation

protocol MainTableViewControllerDelegate {
    func mainTableViewControllerDelegateDidSelectUser(_ controller: MainTableViewController, user: User)
    func mainTableViewControllerDelegateDidSelectCountUpCoffee(_ controller: MainTableViewController, user: User, coffee: CoffeeType)
}

class MainTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = HelperConsts.backgroundColor
        addObservers()
    }
    
    var delegate: MainViewController?
    
    lazy var dataManager: DataManager = {
        return DataManager.sharedInstance
    }()
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        let mainQueue = OperationQueue.main
        
        // new data
        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: HelperConsts.DataManagerNewDataNotification), object: nil, queue: mainQueue, using: { _ in
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.usersSortedArray().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MainTableViewControllerCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewControllerCell", for: indexPath) as! MainTableViewControllerCell
       
        let users: [User] = dataManager.usersSortedArray()
        let user = users[indexPath.row]
        
        // set tableViewCell
        cell.setUserNameLabel(name: user.name)
        cell.setUserFirstnameLabel(firstname: user.firstname)
        cell.setUserCoffeeCounter(user: user)
        
        // set cell style
        cell.backgroundColor = HelperConsts.backgroundColor
        
        // set image style
        cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.frame.size.width / 2
        cell.userProfileImageView.clipsToBounds = true
        cell.userProfileImageView.layer.borderWidth = 1.0
        cell.userProfileImageView.layer.borderColor = HelperConsts.imageBorderColor.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let users: [User] = dataManager.usersSortedArray()
        let user = users[indexPath.row]
        
        //delegate!.mainTableViewControllerDelegateDidSelectUser(self, user: user)

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
