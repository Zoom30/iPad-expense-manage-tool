
import UIKit
import CoreData


class DetailCustomCell: UITableViewCell {
    @IBOutlet weak var expenseNameLabel: UILabel!
    @IBOutlet weak var expenseAmountLabel: UILabel!
    @IBOutlet weak var expenseNotesLabel: UILabel!
    @IBOutlet weak var expenseDateLabel: UILabel!
    @IBOutlet weak var expenseReminderSetTable: UILabel!
    @IBOutlet weak var expenseOccurrenceLabel: UILabel!
    @IBOutlet weak var customProportionBar: CurrentExpenseVSBudget!
    
}


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Expense>!
    var expenses: [Expense]!
    var accessToDetailCustomCell = DetailCustomCell()
    var totalExpen : Double = 0.0
    var arrayOfExpenses = [Double]()
    var remainingBudg : Double = 0.0
    var noOfExpense = 0
    var expenseArray = [Expense]()
    var details: [NSManagedObject] = []
  

    
    func configureView() {
        // Update the user interface for the detail item.
        //        self.tableView.delegate = self
        //       self.tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest <NSManagedObject> (entityName: "Expense")

        do {
            details =
                try managedContext.fetch(fetchRequest)
        } catch
            let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    
    }
    
    
    
    
    //MARK:- prepare segue function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var totalExpenditure : Double = 0
        expenses = fetchedResultsController.fetchedObjects
        
        //calculates total expenses
        for everyExpense in expenses {
            totalExpenditure += everyExpense.amount
        }
        
        print(totalExpenditure)
        print("totalExpen before \(totalExpen)")
        
        totalExpen = totalExpenditure
        print("totalExpen after \(totalExpen)")
        
        
        
        var arrayOfExpenditure = [Double]()
        for everyExpense in expenses{
            arrayOfExpenditure.append(everyExpense.amount)
        }
        
        print("array of expenditure is \(arrayOfExpenditure)")
        
        //expenses and their names are mapped to generate piechart with correct expenses names as legend
        var titleAmountMap = [String : Double]()
        for everyExpense in expenses {
            titleAmountMap.updateValue(everyExpense.amount, forKey: everyExpense.name!)
        }
        
        print("titleAmountMap looks like this: \(titleAmountMap)")
        
        //mapped expenses and their names are sorted
        let sortedTitleAmountDictionary = titleAmountMap.sorted{$0.1 > $1.1}
        
        
        ///  print("Long sorted array \((Array(titleAmountMap).sorted{$0.1 < $1.1}).forEach{(k,v) in print("\(k):\(v)")})")
        
        //every time a segue is performed, this view passes data to the relevant viewController's objects
        if segue.identifier == "topExpenseView"
        {
            if let topViewController = segue.destination as? TopCategoryViewController{
                
                
                topViewController.categoryName = category?.name
                if let budget = category?.budget{
                    topViewController.categoryBudgetAllocation = String(budget)
                    topViewController.overallBudgetForSecondPieChart = budget
                    topViewController.remainingBudget = String (budget - totalExpen)
                }
                topViewController.totalExpenses = String(totalExpen)
                topViewController.sumOfExpensesToVC = totalExpen
                topViewController.arrayOfExpensesToVc = arrayOfExpenditure
                
                print("sortedTitleAmountDictionary.count \(sortedTitleAmountDictionary.count)")
                
                if sortedTitleAmountDictionary.count == 0 {
                    print("no expenses yet")
                    
                }else if sortedTitleAmountDictionary.count == 1 {
                    print("sortedTitleAmountDictionary[0].key \(sortedTitleAmountDictionary[0].key)")
                    topViewController.biggestAmount = sortedTitleAmountDictionary[0].key
                    
                }else if sortedTitleAmountDictionary.count == 2 {
                    topViewController.biggestAmount = sortedTitleAmountDictionary[0].key
                    topViewController.secondBiggest = sortedTitleAmountDictionary[1].key
                    
                }else if sortedTitleAmountDictionary.count == 3 {
                    topViewController.biggestAmount = sortedTitleAmountDictionary[0].key
                    topViewController.secondBiggest = sortedTitleAmountDictionary[1].key
                    topViewController.thirdBiggest = sortedTitleAmountDictionary[2].key
                    
                }else if sortedTitleAmountDictionary.count > 3 {
                    topViewController.biggestAmount = sortedTitleAmountDictionary[0].key
                    topViewController.secondBiggest = sortedTitleAmountDictionary[1].key
                    topViewController.thirdBiggest = sortedTitleAmountDictionary[2].key
                    topViewController.fourthBiggest = sortedTitleAmountDictionary[3].key
                    topViewController.misc = "miscellaneous"
                }
                
                else{
                    print("doing nothing")
                }
                
            }
        }
        
        
        
        
        
        if segue.identifier == "addExpense"
        {
            if let addAlbumViewController = segue.destination as? AddExpenseViewController{
                addAlbumViewController.currentCategory = category
            }
        }
    }
    
    
    
    
    //MARK:- configureView()
    var category: Category? {
        didSet {
            // Update the view.
            
            configureView()
        }
    }
    
    var expense: Expense? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
    
    // MARK: - tableView delegate section
    
    
    //swipe actions for each cells
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete") { action, indexPath in
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
       
        let editAction = UITableViewRowAction(style: .default, title: "edit") { action, indexPath in
            let fetchRequest : NSFetchRequest <NSFetchRequestResult> = NSFetchRequest.init(entityName: "Expense")
            let currentCategory  = self.category
            fetchRequest.predicate = NSPredicate(format: "parentCategory = %@", currentCategory!)
            
            let alert = UIAlertController(title: "Update details", message: "update Name, amount and notes", preferredStyle: .alert)
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Name"
            }
            
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Amount"
            }
            
            alert.addTextField { (textField : UITextField) in
                textField.placeholder = "Update Notes"
            }
            
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { (action) -> Void in
                guard let newNameTF = alert.textFields?.first, let newExpenseName = newNameTF.text else { return }
                guard let newAmountTF = alert.textFields?[1], let newExpenseAmount = newAmountTF.text else { return }
                guard let newNotesTF = alert.textFields?[2], let newExpenseNotes = newNotesTF.text else { return }
                
                
                do {
                    let test = try self.managedObjectContext.fetch(fetchRequest)
                    let objectUpdate = test[indexPath.row] as! NSManagedObject
                    objectUpdate.setValue(newExpenseName, forKey: "name")
                    objectUpdate.setValue(Double(newExpenseAmount), forKey: "amount")
                    objectUpdate.setValue(newExpenseNotes, forKey: "notes")
                    do {
                        try self.managedObjectContext.save()
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
        }
        editAction.backgroundColor = .brown
        return [deleteAction, editAction]
    }
  
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 0.8959771991, green: 0.9552046657, blue: 0.8436564803, alpha: 1)
        self.configureCell(cell as! DetailCustomCell,indexPath: indexPath)
        return cell
    }
    
    
    //configure cell view
    func configureCell(_ cell: DetailCustomCell, indexPath: IndexPath) {
        
        
        //   cell.detailTextLabel?.text = "test label"
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y, HH:mm E"
        var occurrenceInString = ""
        var reminderString = ""
        
        
        let name = self.fetchedResultsController.fetchedObjects?[indexPath.row].name
        let amount = self.fetchedResultsController.fetchedObjects?[indexPath.row].amount
        let note = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
        let date = self.fetchedResultsController.fetchedObjects?[indexPath.row].date
        let occurrence = self.fetchedResultsController.fetchedObjects?[indexPath.row].occurence
        let reminder = self.fetchedResultsController.fetchedObjects?[indexPath.row].reminder
        
        
        switch occurrence {
        case 0:
            occurrenceInString = "once"
        case 1:
            occurrenceInString = "daily"
        case 2:
            occurrenceInString = "weekly"
        case 3:
            occurrenceInString = "monthly"
        default:
            return
        }
        
        switch reminder {
        case true:
            reminderString = "ON"
        case false:
            reminderString = "OFF"
        default:
            return
        }
        
        cell.expenseNameLabel.text = "Title: \(name!.uppercased())"
        cell.expenseAmountLabel.text = "Amount: £\(amount!)"
        cell.expenseNotesLabel.text = "Notes: \(note!)"
        if reminder == true {
            cell.expenseDateLabel.text = "Due on: \(formatter.string(from: date!))"
        }else {
            cell.expenseDateLabel.text = "Registered on: \(formatter.string(from: date!))"
        }
        
        cell.expenseOccurrenceLabel.text = "Occurrence: \(occurrenceInString)"
        cell.expenseReminderSetTable.text = "Reminder: \(reminderString)"
        let overAllBudget = category!.budget
        let currentAmount = amount!
        cell.customProportionBar.proportion = CGFloat(currentAmount/overAllBudget)
        
    }
    
    
    
    //MARK: - fetch results controller
    
    
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil

    var fetchedResultsController: NSFetchedResultsController<Expense> {

        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }


        let currentCategory  = self.category
        let request:NSFetchRequest<Expense> = Expense.fetchRequest()
      
        

        request.fetchBatchSize = 20
       
        let expenseSortDescriptor = NSSortDescriptor(key: "parentCategory", ascending: true)

        request.sortDescriptors = [expenseSortDescriptor]
        
        
        if(self.category != nil){
            let predicate = NSPredicate(format: "parentCategory = %@", currentCategory!)
            request.predicate = predicate
        }
        else {
            
            let predicate = NSPredicate(format: "name = %@","no name")
            request.predicate = predicate


        }
        let frc = NSFetchedResultsController<Expense>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Expense.parentCategory),
            cacheName:nil)
        frc.delegate = self
        _fetchedResultsController = frc

        do {
            //    try frc.performFetch()
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }


        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Expense>
    }//end var
    

    
    
    
    
    //MARK: - fetch results table view functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    
    //must have a NSFetchedResultsController to work
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            // iOS 8 bug - Do nothing if we get an invalid change type.
            break
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)! as! DetailCustomCell, indexPath: indexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        //    default: break
        
        @unknown default:
            fatalError()
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        
    }
    
    

    
    
}





