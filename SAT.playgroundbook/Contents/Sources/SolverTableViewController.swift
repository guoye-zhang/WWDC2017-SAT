import UIKit
import PlaygroundSupport

@objc(SolverTableViewController)
public class SolverTableViewController: UITableViewController, PlaygroundLiveViewMessageHandler {
    private var initialPropagation: [(String, Bool)]?
    private var assignments = [([(String, Bool)], Bool)]()
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return assignments.count + (initialPropagation == nil ? 0 : 1)
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let initialPropagation = initialPropagation {
            if section == 0 {
                return initialPropagation.count
            } else {
                return assignments[section - 1].0.count
            }
        } else {
            return assignments[section].0.count
        }
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let assignment: (String, Bool)
        if let initialPropagation = initialPropagation {
            if indexPath.section == 0 {
                assignment = initialPropagation[indexPath.row]
                cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                assignment = assignments[indexPath.section - 1].0[indexPath.row]
                cell.backgroundColor = !assignments[indexPath.section - 1].1 ? #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1) : indexPath.row == 0 ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        } else {
            assignment = assignments[indexPath.section].0[indexPath.row]
            cell.backgroundColor = !assignments[indexPath.section].1 ? #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1) : indexPath.row == 0 ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        cell.textLabel?.text = assignment.0
        cell.detailTextLabel?.text = assignment.1 ? "T" : "F"
        return cell
    }
    
    public func receive(_ message: PlaygroundValue) {
        if let message = Message(message) {
            switch message {
            case .start(let variables):
                start(variables: variables)
            case .assign(let variables):
                assign(variables: variables)
            case .failed(let variable):
                failed(variable: variable)
            case .backtrack:
                backtrack()
            }
        }
    }
    
    private func start(variables: [(String, Bool)]) {
        initialPropagation = nil
        assignments = []
        if tableView.numberOfSections > 0 {
            tableView.deleteSections(IndexSet(integersIn: 0..<tableView.numberOfSections), with: .automatic)
        }
        if !variables.isEmpty {
            initialPropagation = variables
            tableView.insertSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    private func assign(variables: [(String, Bool)]) {
        assignments.append((variables, true))
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: .automatic)
    }
    
    private func failed(variable: (String, Bool)) {
        assignments.append(([variable], false))
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: .automatic)
    }
    
    private func backtrack() {
        assignments.removeLast()
        tableView.deleteSections(IndexSet(integer: tableView.numberOfSections - 1), with: .automatic)
    }
    
    public static func instantiateFromStoryboard() -> SolverTableViewController {
        let bundle = Bundle(for: SolverTableViewController.self)
        let storyboard = UIStoryboard(name: "Solver", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! SolverTableViewController
    }
}
