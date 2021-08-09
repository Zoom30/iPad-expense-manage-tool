
import UIKit
import CoreData
import EventKit
import EventKitUI

class AddExpenseViewController: UIViewController {
    
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseNotesTextField: UITextField!
    @IBOutlet weak var expenseDatePickerView: UIDatePicker!
    @IBOutlet weak var expenseReminderSwitch: UISwitch!
    @IBOutlet weak var expenseOccurrenceSegmentedControl: UISegmentedControl!
    
    var currentCategory : Category?
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTitleLabel.text = currentCategory?.name
    }
    
    
    
    //MARK:- Save button pressed
    @IBAction func saveExpensePressed(_ sender: UIButton) {
        
        if expenseNameTextField?.text != "" && expenseAmountTextField!.text != "" && expenseNotesTextField?.text != ""{
            
            let expense = Expense(context: context)
            expense.name = expenseNameTextField.text
            expense.amount = Double(expenseAmountTextField.text!)!
            expense.notes = expenseNotesTextField.text
            expense.date = expenseDatePickerView.date
            expense.reminder = expenseReminderSwitch.isOn
            expense.occurence = Int16(expenseOccurrenceSegmentedControl.selectedSegmentIndex)
            
            currentCategory?.addToExpenses(expense)
            
            //alert that shows successful creation of an expense
            let alert = UIAlertController(title: "Expenses added", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            
            //if the user toggles the reminder switch...
            if expenseReminderSwitch.isOn{
                let eventStore : EKEventStore = EKEventStore()
                
                eventStore.requestAccess(to: EKEntityType.reminder, completion:
                                            {(granted, error) in
                                                if !granted {
                                                    print("Access to store not granted")
                                                }
                                            })
                
                eventStore.requestAccess(to: .event) { (granted, error) in
                    
                    if (granted) && (error == nil) {
                        print("Request Access : GRANTED -> \(granted)")
                        print("Request Access : DENIED -> \(error)")
                        
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                            let event:EKEvent = EKEvent(eventStore: eventStore)
                            event.title = "Expense : " + self.expenseNameTextField!.text! + ", Amount due : " + self.expenseAmountTextField!.text!
                            event.startDate = self.expenseDatePickerView.date
                            event.endDate = self.expenseDatePickerView!.date
                            event.notes = self.expenseNotesTextField!.text!
                            
                            //Since by default the recurrenceRule is set to once only, there is no need to specify it
                            if self.expenseOccurrenceSegmentedControl.selectedSegmentIndex == 0 {
                                let alert = UIAlertController(title: "Occurrence Reminder", message: "One time only reminder has been set", preferredStyle: .alert)
                                let OkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alert.addAction(OkAction)
                                self.present(alert, animated: true, completion: nil)
                                
                            }else if self.expenseOccurrenceSegmentedControl.selectedSegmentIndex == 1 {
                                event.recurrenceRules = [.init(recurrenceWith: .daily, interval: 1, end: nil)]
                            }else if self.expenseOccurrenceSegmentedControl.selectedSegmentIndex == 2 {
                                event.recurrenceRules = [.init(recurrenceWith: .weekly, interval: 1, end: nil)]
                            }else if self.expenseOccurrenceSegmentedControl.selectedSegmentIndex == 3 {
                                event.recurrenceRules = [.init(recurrenceWith: .monthly, interval: 1, end: nil)]
                            }else{
                                print("not valid recurrence")
                            }
                            
                            
                            let alarm:EKAlarm = EKAlarm()
                            
                            //reminder will be set to 1 min before the event
                            
                            alarm.relativeOffset = 1 * -60
                            
                            event.addAlarm(alarm)
                            
                            event.calendar = eventStore.defaultCalendarForNewEvents
                            do {
                                try eventStore.save(event, span: .thisEvent)
                            } catch let error as NSError {
                                print("failed to save event with error : \(error)")
                                let err = (error as NSError).localizedDescription
                                let alert = UIAlertController(title: "Event could not be saved", message: err, preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(OKAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        let alert = UIAlertController(title: "Notification successful", message:"Expense has been saved to your Calendar and notification has been created",preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    else{
                        
                        print("failed to save expense with error : \(String(describing: error)) or access not granted")
                    }
                    
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "Confirmation", message: "No reminder has been set", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            
            //Alert if the fields are not populated
            let alert = UIAlertController(title: "Missing Expense information", message: "Please fill all the fields for adding an expense", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
}
