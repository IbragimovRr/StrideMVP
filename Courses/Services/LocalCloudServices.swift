//
//  LocalCloudServices.swift
//  Courses
//
//  Created by Руслан on 02.02.2025.
//

import Foundation
import Realm
import RealmSwift

class LocalCloudServices {
    
    // MARK: - Save Training Items
    func saveTrainingProgress(moduleId: Int, items: [TrainingItem]) {
        let realm = try! Realm()
        
        let itemsRealm = initialTrainingItemRealValue(items: items)
        let session = TrainingSession()
        session.moduleId = moduleId
        session.date = Date()
        session.items.append(objectsIn: itemsRealm)
        
        try! realm.write {
            realm.add(session)
        }
    }
    
    private func initialTrainingItemRealValue(items: [TrainingItem]) -> [TrainingItemRealmValue] {
        return items.map { item in
            let realmItem = TrainingItemRealmValue()
            realmItem.firstItemType = item.firstItemType?.rawValue
            realmItem.firstItemData = item.firstItemData
            realmItem.secondItemType = item.secondItemType?.rawValue
            realmItem.secondItemData = item.secondItemData
            return realmItem
        }
    }
    
    // MARK: - Get Training Items
    
    func loadTrainingProgress(moduleId: Int) -> [TrainingSession] {
        let realm = try! Realm()
        let sessions = realm.objects(TrainingSession.self).filter("moduleId == %@", moduleId).sorted(byKeyPath: "date", ascending: false)
        return Array(sessions)
    }
    
}
