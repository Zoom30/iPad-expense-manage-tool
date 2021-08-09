
import UIKit
import CoreData


class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var categoryNotesTextField: UITextField!
    @IBOutlet weak var categoryBudgetTextField: UITextField!
    @IBOutlet var categoryColorCollection: [UIButton]!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedColor = UIColor()
    var isColorSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameTextField.becomeFirstResponder()
    }
    
    
    //MARK:- choosing colors
    //temporarily saves chosen colour value
    @IBAction func colorChosen(_ sender: UIButton) {
        
        //this resets every buttons alpha color to 1 indicating that there is no chosen color
        for eachColor in categoryColorCollection{
            eachColor.alpha = 1
        }
        
        //if the user chooses a category color, then the chosen color's alpha will be lowered to show the chosen color
        selectedColor = sender.backgroundColor!
        sender.alpha = 0.15
        isColorSelected = true
        
    }
    
    //MARK:- saveCategory() function
    @IBAction func saveCategory(_ sender: UIButton) {
        let newCategory = Category(context: context)
        newCategory.name = categoryNameTextField.text
        newCategory.notes = categoryNotesTextField.text ?? "no notes added"
        newCategory.budget = Double(categoryBudgetTextField.text!) ?? 100.0
        if isColorSelected == true {
            newCategory.color = selectedColor
        }else {
            newCategory.color = UIColor.white
        }
        newCategory.date = Date().timeIntervalSince1970 + 1
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    }
    
    
    //confirmButton is disabled by default to prevent crashes if user doesn't enter name or budget
    @IBAction func editingChanged(_ sender: UITextField) {
        if (categoryNameTextField.text != "") && (categoryBudgetTextField.text != ""){
            confirmButton.isEnabled = true
        }else{
            confirmButton.isEnabled = false
        }
    }
    
    
}
