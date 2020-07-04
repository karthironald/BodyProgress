//
//  TodayViewController.swift
//  TodayWorkoutWidget
//
//  Created by Karthick Selvaraj on 04/07/20.
//  Copyright © 2020 Mallow Technologies Private Limited. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftUI
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BodyProgress")
        let storeURL = URL.storeURL(for: "group.com.mallowtech.TodayWidgetExtension", databaseName: "BodyProgress")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        #if DEBUG
        print(NSPersistentContainer.defaultDirectoryURL())
        #endif
        return container
    }()

    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBSegueAction func hostControllerSegue(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: WidgetView().environment(\.managedObjectContext, persistentContainer.viewContext))
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

struct WidgetView : View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Workout.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Workout.createdAt, ascending: true)]) var workouts: FetchedResults<Workout>
    
    init() {
        let fetchRequest = NSFetchRequest<Workout>(entityName: Workout.entity().name ?? "Workout")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.createdAt, ascending: true)]
        _workouts = FetchRequest(fetchRequest: fetchRequest)
    }
    var body: some View {
        List(workouts, id: \.self) { workout in
            Text(workout.wName)
                .onTapGesture {
                    self.updateName(w: workout)
                }
        }
    }
    
    func updateName(w: Workout) {
        w.name = "\(w.wName) 1"
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}

