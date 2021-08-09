
import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var managedOjectModel:NSManagedObject? = nil
    var accessToCustomCell = MasterCustomCell()
   
    //var sortBy = "selected"
    var ascendingSort = false
    var updateContextDatePosition = 0.0
    var updateContextPosition = 0
    var noOfTimesSelected = Int16(0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newCategory = Category(context: context)
        
        do {
            try context.save()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            print("triggered")
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.category = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    
    
    
    
    // MARK: - Table View
    
    //every time a cell category is clicked, the selected counter of that specific category will increase by one
    //a fetch is performed again to avoid crashes or any errors caused by the initial fetch
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "selected", ascending: ascendingSort)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            
            updateContextDatePosition = fetchedResultsController.fetchedObjects![indexPath.row].date
            let targetIndex = fetchedResultsController.fetchedObjects?.firstIndex(where: { category in
                category.date == updateContextDatePosition
            })
            noOfTimesSelected = fetchedResultsController.fetchedObjects![targetIndex!].selected + 1
            
            let test = try managedContext.fetch(fetchRequest)
            let objectUpdate = test[fetchedResultsController.fetchedObjects?.firstIndex(where: { category in
                category.date == fetchedResultsController.fetchedObjects![indexPath.row].date
            }) ?? 1000] as NSManagedObject
            objectUpdate.setValue(Int16(noOfTimesSelected), forKey: "selected")
            
            
            do {
                try managedContext.save()
                
            } catch {
                print(error)
            }
        } catch  {
            print(error)
        }
        tableView.reloadData()
    }
    
    
    
    //MARK:- Swipe to edit configurations
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete") { action, indexPath in
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            }catch{
                print("error deleting \(error)")
            }
            
            
        }
        let editAction = UITableViewRowAction(style: .default, title: "edit") { action, indexPath in
            self.updateContextPosition = indexPath.row
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "selected", ascending: self.ascendingSort)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            //creating 3 alert textfields to update the values of categories
            let alert = UIAlertController(title: "Update details", message: "update Name, amount and notes", preferredStyle: .alert)
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Budget Name"
            }
            
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Budget Amount"
                
            }
            
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Budget Notes"
            }
            
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (action) -> Void in
                
                guard let newNameTF = alert.textFields?.first, let newBudgetName = newNameTF.text else { return }
                guard let newAmountTF = alert.textFields?[1], let newBudgetAmount = newAmountTF.text else { return }
                guard let newNotesTF = alert.textFields?[2], let newBudgetNotes = newNotesTF.text else { return }
                
                do {
                    //assigning new values to the existing category values...
                    let temp = try managedContext.fetch(fetchRequest)
                    let objectUpdate = temp[self.updateContextPosition] as NSManagedObject
                    objectUpdate.setValue(newBudgetName, forKey: "name")
                    objectUpdate.setValue(Double(newBudgetAmount), forKey: "budget")
                    objectUpdate.setValue(newBudgetNotes, forKey: "notes")
                    
                    do {
                        try managedContext.save()
                        self.tableView.reloadData()
                    } catch {
                        print(error)
                    }
                } catch  {
                    print(error)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
            tableView.reloadData()
        }
        editAction.backgroundColor = .brown
        return [deleteAction, editAction]
    }
    
    
    
    
    //MARK:- tableView delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = fetchedResultsController.object(at: indexPath)
        accessToCustomCell.configureCell(cell as! MasterCustomCell, withCategory: category)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        
        fetchRequest.fetchBatchSize = 20
        
        
        let sortDescriptor = NSSortDescriptor(key: "selected", ascending: ascendingSort)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil
    
    
    
    //MARK:- NSFetchedResultsController tableView updates
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            accessToCustomCell.configureCell(tableView.cellForRow(at: indexPath!)! as! MasterCustomCell, withCategory: anObject as! Category)
        case .move:
            accessToCustomCell.configureCell(tableView.cellForRow(at: indexPath!)! as! MasterCustomCell, withCategory: anObject as! Category)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    
    
    
    //MARK:- Sort pressed
    @IBAction func sortPressed(_ sender: UIBarButtonItem) {
        
    }
    
}




//MARK:- MasterCustomCell Class
class MasterCustomCell : UITableViewCell {
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryBudget: UILabel!
    @IBOutlet weak var categoryNotes: UILabel!
    func configureCell(_ cell: MasterCustomCell, withCategory category: Category) {
        cell.categoryName.text = category.name
        cell.categoryBudget.text = String(category.budget)
        cell.categoryNotes.text = category.notes
        cell.backgroundColor = category.color as? UIColor
    }
}
