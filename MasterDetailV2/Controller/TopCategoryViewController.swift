
import UIKit

class TopCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryTotalBudgetLabel: UILabel!
    @IBOutlet weak var totalAmountSpentOnExpensesLabel: UILabel!
    @IBOutlet weak var totalBudgetRemaining: UILabel!
    @IBOutlet weak var largestAmountValueLabel: UILabel!
    @IBOutlet weak var secondLargestAmountLabel: UILabel!
    @IBOutlet weak var thirdLargestAmountLabel: UILabel!
    @IBOutlet weak var fourthLargestAmountLabel: UILabel!
    @IBOutlet weak var restOfExpensesAmountLabel: UILabel!
    
    
    var categoryName : String?
    var categoryBudgetAllocation : String?
    var overallBudgetForSecondPieChart : Double = 0.0
    var totalExpenses : String?
    var remainingBudget : String?
    
    var biggestAmount : String = ""
    var secondBiggest : String = ""
    var thirdBiggest : String = ""
    var fourthBiggest : String = ""
    var misc : String = ""
    
    
    var sumOfExpensesToVC : Double?
    var arrayOfExpensesToVc : [Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryNameLabel.text = categoryName
        if let cBA = categoryBudgetAllocation, let tE = totalExpenses, let rB = remainingBudget {
            categoryTotalBudgetLabel.text = "Total Budget Allocated: \(cBA)"
            totalAmountSpentOnExpensesLabel.text = "Total Amount Spent: \(tE)"
            if (Double(rB)! < 0.0){
                totalBudgetRemaining.textColor = .red
                totalBudgetRemaining.text = "Overspent: \(rB)"
            }else{
                totalBudgetRemaining.text = "Total Remaining Budget: \(rB)"
            }
            
        }
        
     
        
        largestAmountValueLabel.text = biggestAmount.lowercased()
        secondLargestAmountLabel.text = secondBiggest.lowercased()
        thirdLargestAmountLabel.text = thirdBiggest.lowercased()
        fourthLargestAmountLabel.text = fourthBiggest.lowercased()
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChart"{
            if let chartVC = segue.destination as? FirstPieChartViewController{
                chartVC.sumOfExpenses = sumOfExpensesToVC
                chartVC.arrayOfExpenses = arrayOfExpensesToVc
            }
        }
        
        if segue.identifier == "toSecondChart" {
            if let secondChartVC = segue.destination as? SecondPieChartViewController{
                secondChartVC.totalExpenses = sumOfExpensesToVC!
                secondChartVC.totalBudget = overallBudgetForSecondPieChart
            }
        }
        
    }
    
    
    
    
}
