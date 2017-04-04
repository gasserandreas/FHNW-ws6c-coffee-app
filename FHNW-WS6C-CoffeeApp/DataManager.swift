//
//  DataManager.swift
//  FHNW-WS6C-CoffeeApp
//
//  Created by Andreas Gasser on 27.02.17.
//  Copyright © 2017 FHNW. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// needed for singleton
struct DataManagerStatic {
    static var onceToken: Int = 0
    static var instance: DataManager? = nil
}

class DataManager: NSObject {
    
    // singleton instance
    private static var __once: () = { () -> Void in
        DataManagerStatic.instance = DataManager()
    }()
    
    class var sharedInstance : DataManager {
        _ = DataManager.__once
        return DataManagerStatic.instance!
    }
    
    private lazy var communicationManager: CommunicationManager = {
        return CommunicationManager.sharedInstance
    }()
    
    private var fileManager: FileManager {
        get {
            return FileManager.sharedInstance
        }
    }
    
    private var realm: Realm {
        get {
            return try! Realm()
        }
    }
    
    private var selectedUserId: String?
    
    private lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    
    private lazy var mainQueue: OperationQueue = {
        return OperationQueue.main
    }()
    
    override init() {
        super.init()
        
        // load data
        loadCoffees()
        loadUsers()
        
        addObservers()
    }
    
    func addObservers() {
        
//        _ = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: HelperConsts.CommunicationManagerNewUserFileNotification), object: nil, queue: mainQueue, using: { _ in
//            self.loadUserDataFromFileSystem()
//        })
//        
//        _ = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: HelperConsts.CommunicationManagerNewCoffeeFileNotification), object: nil, queue: mainQueue, using: { _ in
//            self.loadCoffeeDataFromFileSystem()
//        })
    }
    
    func usersSortedArray() -> [User] {
        return Array(realm.objects(User.self))
    }
    
    func coffeeTypesSortedArray() -> [CoffeeType] {
        return Array(realm.objects(CoffeeType.self))
    }
    
    func selectedUser() -> User? {
        if let userId = selectedUserId {
            return realm.object(ofType: User.self, forPrimaryKey: userId)
        }
        return nil
    }
    
    func setSelectedUser(user: User) {
        selectedUserId = user.id
    }
    
    // load data
    func loadUsers() {
        communicationManager.getUsers(completionHandler: self.saveUsers)
    }
    
    func loadCoffees() {
        communicationManager.getCoffees(completionHandler: self.saveCoffees)
    }
    
    // data manipulation methods
    func countUpCoffee(coffee: CoffeeType) {
        if let selectedUser = selectedUser() {
            communicationManager.countUpCoffee(completionHandler: self.saveUser, user: selectedUser, coffee: coffee)
        }
    }
    
    func countDownCoffee(coffee: CoffeeType) {
        if let selectedUser = selectedUser() {
            communicationManager.countDownCoffee(completionHandler: self.saveUser, user: selectedUser, coffee: coffee)
        }
    }
    
    private func saveCoffees(coffees: [CoffeeType]) {
        do {
            try realm.write {
                for coffee in coffees {
                    realm.add(coffee, update: true)
                }
            }
            notificationCenter.post(name: Notification.Name(rawValue: Consts.Notification.DataManagerNewCoffeeData.rawValue), object: nil)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveUsers(users: [User]) {
        do {
            try realm.write {
                for user in users {
                    realm.add(user, update: true)
                }
            }
            notificationCenter.post(name: Notification.Name(rawValue: Consts.Notification.DataManagerNewUserData.rawValue), object: nil)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveUser(user: User) {
        do {
            try realm.write {
                realm.add(user, update: true)
            }
            notificationCenter.post(name: Notification.Name(rawValue: Consts.Notification.DataManagerNewUserData.rawValue), object: nil)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
