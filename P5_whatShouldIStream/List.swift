////
////  List.swift
////  P5_whatShouldIStream
////
////  Created by Michael Harper on 5/12/16.
////  Copyright © 2016 MJH. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class List : NSManagedObject, CoreDataModelable {
//    
//    static let entityName = "List"
//    let log = XCGLogger.defaultInstance()
//    
//    override var description: String {
//        return "Listid \(id), Name \(name), Date \(date)"
//    }
//    
//    struct keys {
//        static let date = "date"
//        static let id = "id"
//        static let name = "name"
//        static let type = "type"
//        static let service = "service"
//        static let index = "index"
//        static let group = "group"
//        
//        static let list = entityName
//        
//    }
//    
//    @NSManaged var date: NSDate?
//    @NSManaged var id: String?
//    @NSManaged var name: String?
//    @NSManaged var movies: NSMutableOrderedSet // relationship
//    @NSManaged var type: String?
//    @NSManaged var service: String?
//    @NSManaged var index: NSNumber?
//    @NSManaged var group: String?
//    
//    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
//    
//    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
//        
//        // Core Data
//        if let entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: context) {
//            
//            super.init(entity: entity, insertIntoManagedObjectContext: context)
//            // Dictionary
//            self.id = dictionary[keys.id] as? String
//            self.name = dictionary[keys.name] as? String
//            self.type = dictionary[keys.type] as? String
//            self.index = dictionary[keys.index] as? NSNumber
//            self.group = dictionary[keys.group] as? String
//            
//            if let dateStr = dictionary[keys.date] as? String { // extract date
//                date = TheMovieDB.sharedDateFormatter.dateFromString(dateStr)
//                if date == nil {
//                    date = NSDate()
//                    log.verbose("Could not get date of list: \(self.description)")
//                }
//            }
//            
//            self.movies = NSMutableOrderedSet()
//            
//        } else {
//            fatalError("could not find entity List")
//        }
//    }
//    
//    func downloadMovies() -> Int {
//
//        //self.managedObjectContext
//        self.managedObjectContext!.performBlockAndWait() {
//            TheMovieDB.sharedInstance().getMoviesFromList(self) {
//                result, error in
//                if error != nil {
//                    self.log.error("Could not download movies on list")
//                    return
//                }
//                else {
//                    
//                    if let movieResults  = result {
//                        
//                        for movie in movieResults {
//                            // strip optional from movieFromDictionary
//                            if let myMovie = Movie.movieFromDictionary(movie, inManagedObjectContext: self.managedObjectContext!) {
//                                myMovie.list = self
//                                self.log.info("added \(myMovie.title)")
//                            }
//                        }
//                        self.managedObjectContext!.saveContext()
//                        self.log.info("\(self.movies.count) TOTAL movies added)")
//
//                    }
//                    //}
//                } // End of else
//            } // End of getMoviesFromList
//            // } // End if list movie count == 0
//            self.managedObjectContext!.saveContext()
//        }
//        
//        return movies.count
//    }
//    
//    
//    class func ListFromDictionary(dictionary: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext ) -> List? {
//        
//        let log = XCGLogger.defaultInstance()
//        
//        // Dictionary
//        guard let id = dictionary[keys.id] as? String else {
//            log.error("Could not get list id")
//            return nil
//        }
//        
//        guard let newListDate = dateFromDictionary(dictionary) else {
//            log.error("could not parse data from list json with id \(id)")
//            return nil
//        }
//        
//        let request = NSFetchRequest(entityName: List.entityName)
//        request.predicate = NSPredicate(format: "id = %@", id)
//        
//        if let list = (try? context.executeFetchRequest(request))?.first as? List {
//            
//            // check if the new list is some how older or the same
//            // return the existingObjet
//            if let existingListDate = list.date {
//                if newListDate.isLessThanDate(existingListDate) ||
//                    newListDate.isEqualToDate(existingListDate)
//                {
//                    return list
//                }
//                    // if newListDate is the same date as the existing list
//                    // then the existing list is deleted and a new list is created
//                else {
//                    
//                    context.deleteObject(list)
//                    let list = List(dictionary: dictionary, context: context)
//                    return list
//                }
//            }
//        }
//        else {
//            let list = List(dictionary: dictionary, context: context)
//            return list
//        }
//        return nil
//    }
//    
//    
//    class func dateFromDictionary(dictionary: [String:AnyObject]   ) -> NSDate? {
//        
//        var thisDate: NSDate?
//        if let dateStr = dictionary[keys.date] as? String { // extract date
//            thisDate = NSDate.sharedDateFormatter.dateFromString(dateStr)!
//            //            if thisDate == nil {
//            //                thisDate = NSDate()
//            //            }
//        }
//        return thisDate!
//    }
//    
//    /* Helper: Given an array of dictionaries, convert them to an array of List objects */
//    class func listsFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext?) -> NSMutableOrderedSet {
//        
//        let lists = NSMutableOrderedSet()
//        let log = XCGLogger.defaultInstance()
//        log.info("Creating Lists")
//        
//        for var result in results {
//            
//            // prevent list duplicates
//            if let listId = result[List.keys.id] as? String {
//                let predicate = NSPredicate(format: "id == %@", listId)
//                do {
//                    let foundIt = try List.findFirstInContext(context!, predicate: predicate)
//                    if foundIt == nil {
//                        lists.addObject( List(dictionary: result, context: context!) )
//                    }
//                }
//                catch _ {
//                }
//            }
//        }
//        
//        log.info("added \(lists.count) lists" )
//        return lists
//    }
//    
//    // Helper: get all lists
//    static func fetchLists(inManagedObjectContext context: NSManagedObjectContext ) -> [List] {
//        let error: NSError? = nil
//        
//        var results: [AnyObject]?
//        
//        let fetchRequest = NSFetchRequest(entityName: List.entityName)
//        do {
//            results = try context.executeFetchRequest(fetchRequest)
//        } catch error! as NSError {
//            results = nil
//        } catch _ {
//            results = nil
//        }
//        
//        if error != nil {
//            let log = XCGLogger.defaultInstance()
//            log.error("Could not fetch lists: \(error?.localizedDescription)" )
//        }
//        
//        return results as! [List]
//        
//    }
//    
//    
//} // End of List
