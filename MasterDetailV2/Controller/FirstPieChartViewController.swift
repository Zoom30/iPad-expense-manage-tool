
import UIKit
import CoreData
class FirstPieChartViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    
    var sumOfExpenses : Double?
    var arrayOfExpenses : [Double]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //the array of expenses are sorted from larget to smallest
        let valuesSorted = arrayOfExpenses!.sorted(by: >)
      
        var sumOfRestExpenses = 0.0
        
        //if there are more than 4 expenses, they need to be added as miscellaneous
        if valuesSorted.count > 4{
            for position in 4...arrayOfExpenses!.count - 1{
                sumOfRestExpenses += valuesSorted[position]
            }
        }else{
            sumOfRestExpenses = 0.0
        }
        
        
        if valuesSorted.count == 0 {

        }
        else if valuesSorted.count == 1 {
            pieChartView.slices  = [
                Slice(percent: CGFloat(2), color: .red)
            ]
        }else if valuesSorted.count == 2 {
            pieChartView.slices  = [
                Slice(percent: CGFloat(valuesSorted[0]/sumOfExpenses!), color: .red),
                Slice(percent: CGFloat(valuesSorted[1]/sumOfExpenses!), color: .green)
            ]
        }else if valuesSorted.count == 3 {
            pieChartView.slices  = [
                Slice(percent: CGFloat(valuesSorted[0]/sumOfExpenses!), color: .red),
                Slice(percent: CGFloat(valuesSorted[1]/sumOfExpenses!), color: .green),
                Slice(percent: CGFloat(valuesSorted[2]/sumOfExpenses!), color: .blue)
            ]
        }else if valuesSorted.count == 4 {
            pieChartView.slices  = [
                Slice(percent: CGFloat(valuesSorted[0]/sumOfExpenses!), color: .red),
                Slice(percent: CGFloat(valuesSorted[1]/sumOfExpenses!), color: .green),
                Slice(percent: CGFloat(valuesSorted[2]/sumOfExpenses!), color: .blue),
                Slice(percent: CGFloat(valuesSorted[3]/sumOfExpenses!), color: .yellow)
            ]
        }
        else{
            pieChartView.slices  = [
                Slice(percent: CGFloat(valuesSorted[0]/sumOfExpenses!), color: .red),
                Slice(percent: CGFloat(valuesSorted[1]/sumOfExpenses!), color: .green),
                Slice(percent: CGFloat(valuesSorted[2]/sumOfExpenses!), color: .blue),
                Slice(percent: CGFloat(valuesSorted[3]/sumOfExpenses!), color: .yellow),
                Slice(percent: CGFloat(sumOfRestExpenses/sumOfExpenses!), color: .purple)
            ]
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pieChartView.animateChart()
    }
    
    
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}

