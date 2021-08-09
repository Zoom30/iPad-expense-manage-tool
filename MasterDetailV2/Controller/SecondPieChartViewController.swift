
import UIKit
import CoreData

class SecondPieChartViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var secondPieChartView: PieChartView!
    
    
    var totalExpenses = 0.0
    var totalBudget = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        
        if (totalExpenses < totalBudget) && (totalExpenses != 0){
            secondPieChartView.slices = [Slice(percent: CGFloat(totalExpenses/totalBudget), color: .black),
                                         Slice(percent: CGFloat(1 - totalExpenses/totalBudget), color: .systemGray4)]
        }
        
        //if there is a category and a budget and their amount is equal...
        else if (totalExpenses == totalBudget) && !(totalExpenses == 0 || totalBudget == 0){
            secondPieChartView.slices = [Slice(percent: CGFloat(2), color: .black)]
        }
        
        //if there is a category but not an expense...
        else if totalExpenses == 0 && totalBudget != 0{
            secondPieChartView.slices = [Slice(percent: CGFloat(2), color: .systemGray4)]
        }
        
        //if no category is set, there is no need for second piechart, so the degree is set to zero. You can also comment out the code completely if you want to
        else if totalExpenses == 0 && totalBudget == 0 {
            secondPieChartView.slices = [Slice(percent: CGFloat(0), color: .systemGray4)]
        }
        else{
            secondPieChartView.slices = [Slice(percent: CGFloat(2), color: .black)]
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        secondPieChartView.animateChart()
    }
    
    
}




