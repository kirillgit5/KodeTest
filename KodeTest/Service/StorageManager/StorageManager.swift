//
//  StorageMenager.swift
//  KodeTest
//
//  Created by Кирилл Крамар on 19.10.2020.
//  Copyright © 2020 Кирилл Крамар. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private let dataManager = DataManager()
    private let networkFetcher = NetworkDataFetcher()
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CityAttraction")
        let description = NSPersistentStoreDescription()
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private init() {}
    
    func saveContext () {
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
    
    func createAttractions() {
        
        
        for (cityID, attractions) in dataManager.attractionsBeta {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext) else { return }
            guard let city = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as? City else { return }
            city.id = cityID
            for attraction in attractions {
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "Attarction", in: self.managedObjectContext) else { return }
                guard let attractionEntity = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as? Attarction else { return }
                attractionEntity.name = attraction.name
                attractionEntity.city = city
                attractionEntity.desc = attraction.desc
                attractionEntity.descfull = attraction.descFull
                attractionEntity.imageURL = attraction.imageURL
                attractionEntity.lan = attraction.lan
                attractionEntity.lon = attraction.lon
                city.attractions?.adding(attractionEntity)
            }
        }
        
        saveManagedObjectContext()
        
    }
    
    func getCityForID(id: String) -> City? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
        guard let resultsRequest = try? self.managedObjectContext.fetch(fetchRequest) else { return nil }
        guard  let cities =  resultsRequest as? [City] else { return nil }
        for city in cities {
            if city.id == id {
                return city
            }
        }
        return nil
    }
    
    func getRecentRequests() -> [RecentRequest] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentRequest")
        guard let resultsRequest = try? self.managedObjectContext.fetch(fetchRequest) else { return [] }
        guard  let  requests =  resultsRequest as? [RecentRequest] else { return [] }
        return requests
    }
    
    func addRecentRequest(id: String, name: String, nameForRearch: String, lat: Double, lon: Double) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentRequest")
        guard let resultsRequest = try? self.managedObjectContext.fetch(fetchRequest) else { return }
        guard  var  requests =  resultsRequest as? [RecentRequest] else { return }
        
        for i in 0...requests.count - 1 {
            if requests[i].id == id {
                saveManagedObjectContext()
                requests[i].date = Date()
                return
            }
        }
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "RecentRequest", in: self.managedObjectContext) else { return }
        guard let requestEntity = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as? RecentRequest else { return }
        
        requestEntity.date = Date()
        requestEntity.name = name
        requestEntity.id = id
        requestEntity.nameForSearch = nameForRearch
        requestEntity.lat = lat
        requestEntity.lon = lon
        
        if requests.count  == 5 {
            requests.sort { $0.date! < $1.date! }
            managedObjectContext.delete(requests.first!)
        }
        
        saveManagedObjectContext()
        
    }
    
    func updateDateForRequestID(id: String) {
        let predicate = NSPredicate(format: "id == %@", "\(id)")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentRequest")
        fetchRequest.predicate = predicate
        guard let resultRequest = try? self.managedObjectContext.fetch(fetchRequest) else { return }
        guard  let  requests =  resultRequest as? [RecentRequest] else { return }
        guard let request = requests.first else { return }
        request.date = Date()
        saveManagedObjectContext()
    }
    
    private func saveManagedObjectContext() {
        do {
            try self.managedObjectContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}



//        DispatchQueue.global(qos: .utility).async { [unowned self] in
//            for  (placeID, atractiveIDs) in DataManager().getAttractive() {
//                guard let entityDescription = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext) else { return }
//                guard let city = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as? City else { return }
//                city.id = placeID
//                sleep(3)
//                for attrcativeID in atractiveIDs {
//                    self.networkFetcher.getData(text: attrcativeID, searchType: NetworkService.SearchType.attractive, decodeType: Attractive.self) {[unowned self]  (decodable) in
//                        guard let decodableQ = decodable else { return }
//                        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Attarction", in: self.managedObjectContext) else { return }
//                        guard let attraction = NSManagedObject(entity: entityDescription, insertInto: self.managedObjectContext) as? Attarction else { return }
//                        attraction.city = city
//
//                        attraction.imageURL = decodableQ.preview.source
//                        attraction.lan = decodableQ.point.lat
//                        attraction.lon = decodableQ.point.lon
//                        attraction.name = decodableQ.name
//
//                        let words = decodableQ.info.text.countingWords()
//
//                        if words.count > 15 {
//                            var desc = ""
//                            for word in words {
//                                desc += word + " "
//                            }
//                            attraction.desc = desc
//                            attraction.descfull = decodableQ.info.text
//                        } else {
//                            attraction.desc = decodableQ.info.text
//                            attraction.descfull = ""
//                        }
//                        city.attractions?.adding(attraction)
//
//                        do {
//                            try self.managedObjectContext.save()
//                        } catch let error {
//                            print(error.localizedDescription)
//                        }
//
//                    }
//                }
//
//            }
//        }