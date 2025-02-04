//
//  RealmModel.swift
//  Courses
//
//  Created by Руслан on 02.02.2025.
//

import Foundation
import Realm
import RealmSwift

// MARK: - Training Item

class TrainingItemRealmValue: EmbeddedObject {
    @Persisted var firstItemType: FormatTraining.RawValue?
    @Persisted var firstItemData: String?
    @Persisted var secondItemType: FormatTraining.RawValue?
    @Persisted var secondItemData: String?
}

class TrainingSession: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var moduleId: Int
    @Persisted var date: Date
    @Persisted var items: List<TrainingItemRealmValue>
}
