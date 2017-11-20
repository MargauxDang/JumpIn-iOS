//
//  MainViewController.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 8/14/17.
//

import UIKit

class AllStatsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History - Statistics"
    }
}

extension AllStatsViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let indexPath = tableView.indexPathForSelectedRow!
        let destinationVC = segue.destination as! DetailViewController
        switch indexPath.row {
        case 0:
            destinationVC.chartName = "Calories"
        case 1:
            destinationVC.chartName = "Jumps"
        case 2:
            destinationVC.chartName = "Duration"
        default:
            break
        }
    }
}

extension AllStatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartTableViewCell
        switch indexPath.row {
        case 0:
            cell.cellLabel.text = "Calories"
        case 1:
            cell.cellLabel.text = "Jumps"
        case 2:
            cell.cellLabel.text = "Duration"
        default:
            break
        }
        return cell
    }
}


