import CoreData
import SwiftUI

class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    init() {
        let model = CoreDataStack.createModel()
        container = NSPersistentContainer(name: "FluxLearn", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData load failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "PerformanceLog"
        entity.managedObjectClassName = "PerformanceLog"

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = false

        let scoreAttr = NSAttributeDescription()
        scoreAttr.name = "score"
        scoreAttr.attributeType = .integer16AttributeType
        scoreAttr.isOptional = false
        scoreAttr.defaultValue = 0

        let maxScoreAttr = NSAttributeDescription()
        maxScoreAttr.name = "maxScore"
        maxScoreAttr.attributeType = .integer16AttributeType
        maxScoreAttr.isOptional = false
        maxScoreAttr.defaultValue = 0

        let xpAttr = NSAttributeDescription()
        xpAttr.name = "xp"
        xpAttr.attributeType = .integer32AttributeType
        xpAttr.isOptional = false
        xpAttr.defaultValue = 0

        let secondsAttr = NSAttributeDescription()
        secondsAttr.name = "seconds"
        secondsAttr.attributeType = .floatAttributeType
        secondsAttr.isOptional = false
        secondsAttr.defaultValue = Float(0)

        entity.properties = [dateAttr, categoryAttr, scoreAttr, maxScoreAttr, xpAttr, secondsAttr]
        model.entities = [entity]
        return model
    }

    func saveLog(category: String, score: Int16, maxScore: Int16, xp: Int32, seconds: Float) {
        let ctx = container.viewContext
        let log = NSManagedObject(entity: container.managedObjectModel.entitiesByName["PerformanceLog"]!, insertInto: ctx)
        log.setValue(Date(), forKey: "date")
        log.setValue(category, forKey: "category")
        log.setValue(score, forKey: "score")
        log.setValue(maxScore, forKey: "maxScore")
        log.setValue(xp, forKey: "xp")
        log.setValue(seconds, forKey: "seconds")
        try? ctx.save()
    }

    func fetchLogs() -> [NSManagedObject] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "PerformanceLog")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? container.viewContext.fetch(req)) ?? []
    }

    func deleteLog(_ obj: NSManagedObject) {
        container.viewContext.delete(obj)
        try? container.viewContext.save()
    }
}

@objc(PerformanceLog)
class PerformanceLog: NSManagedObject {}
