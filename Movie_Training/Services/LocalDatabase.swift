//
//  LocalDatabase.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class LocalDatabase: NSObject {
    lazy var manageObjectContext : NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    func saveLocalDataBase() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func fetchObjectWith(className: String?=nil, limit: Int=0, sort:NSArray?=nil, predicate:NSPredicate?=nil, groupBy:NSArray?=nil, handleComplete:(_ list:NSArray?)->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: className!)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = sort as? [NSSortDescriptor]
        if limit > 0 {
            fetchRequest.fetchLimit = limit
        }
        if groupBy != nil {
            fetchRequest.propertiesToFetch = groupBy as? [Any]
            fetchRequest.returnsDistinctResults = true
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        }
        do {
            let fetchResults = try GlobalServices.localDatabse.manageObjectContext.fetch(fetchRequest)
            if fetchResults.count > 0 {
                handleComplete(fetchResults as NSArray)
            } else {
                handleComplete(nil)
            }
        } catch {
            print("error")
        }
    }
}
