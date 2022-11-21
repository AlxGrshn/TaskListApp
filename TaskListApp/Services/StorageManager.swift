//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Alexander Grishin on 21.11.2022.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        } )
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData(_ completion: ([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        do {
            let task = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(task)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
   private init() {}
}

