import UIKit
import PlaygroundSupport

@objc(FormulaViewController)
public class FormulaViewController: UIViewController, UICollectionViewDataSource, UITableViewDataSource, PlaygroundLiveViewMessageHandler {
    @IBOutlet weak var variableCollectionView: UICollectionView!
    @IBOutlet weak var formulaTableView: UITableView!
    
    private var timer: Timer?
    
    private var variables = [(Var, Bool)]()
    private var assignments = [Var: Bool]()
    public var formulas = [Formula]() {
        didSet {
            let vars = formulas.reduce(Set()) {
                $0.union($1.f.variables)
            }
            let sorted = vars.sorted { $0.name < $1.name }
            variables = sorted.map { ($0, true) }
            assignments = [:]
            for v in sorted {
                assignments[v] = true
            }
            variableCollectionView.reloadData()
            formulaTableView.reloadData()
            if timer?.isValid != true {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
                    guard self.variables.count > 0 else { return }
                    let index = Int(arc4random()) % self.variables.count
                    if let cell = self.variableCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VariableCell {
                        self.flipVariable(at: index, in: cell)
                    }
                }
            }
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variables.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let v = variables[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Variable Cell", for: indexPath) as! VariableCell
        cell.variableLabel.text = v.0.name
        cell.variableBackLabel.text = v.0.name
        if v.1 != cell.state {
            cell.flip(animated: false)
        }
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formulas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formula = formulas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Formula Cell", for: indexPath)
        cell.textLabel?.text = formula.f.description
        let b = formula.f.eval(with: assignments)
        cell.detailTextLabel?.text = b ? "T" : "F"
        UIView.animate(withDuration: 0.5) {
            cell.backgroundColor = b ? #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1) : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        }
        return cell
    }
    
    private func flipVariable(at index: Int, in cell: VariableCell) {
        let v = variables[index]
        variables[index].1 = !v.1
        assignments[v.0] = !v.1
        cell.flip(animated: true)
        formulaTableView.reloadData()
    }
    
    @IBAction func changeAssignment(_ sender: UIButton) {
        timer?.invalidate()
        if let cell = sender.superview?.superview?.superview?.superview as? VariableCell, let indexPath = variableCollectionView.indexPath(for: cell) {
            let v = variables[indexPath.row]
            variables[indexPath.row].1 = !v.1
            assignments[v.0] = !v.1
            cell.flip(animated: true)
            formulaTableView.reloadData()
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        if case .array(let array) = message {
            let vars = array.reduce(Set()) { $0.union(FormulaImp.variables(in: $1)) }
            var dict = [String: Var]()
            for v in vars {
                dict[v] = Var(v)
            }
            formulas = array.flatMap { FormulaImp($0, variables: dict) }
        }
    }
    
    public static func instantiateFromStoryboard() -> FormulaViewController {
        let bundle = Bundle(for: FormulaViewController.self)
        let storyboard = UIStoryboard(name: "Formula", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! FormulaViewController
    }
}

@objc(VariableCell)
class VariableCell: UICollectionViewCell {
    @IBOutlet weak var variableLabel: UILabel!
    @IBOutlet weak var variableBackLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trueView: UIStackView!
    @IBOutlet weak var falseView: UIStackView!
    
    var state: Bool {
        return falseView.isHidden
    }
    
    func flip(animated: Bool) {
        if animated {
            if state {
                UIView.transition(from: trueView, to: falseView, duration: 0.5, options: [.showHideTransitionViews, .allowUserInteraction, .transitionFlipFromLeft])
            } else {
                UIView.transition(from: falseView, to: trueView, duration: 0.5, options: [.showHideTransitionViews, .allowUserInteraction, .transitionFlipFromRight])
            }
        } else {
            trueView.isHidden = !trueView.isHidden
            falseView.isHidden = !falseView.isHidden
        }
    }
}

extension FormulaImp {
    public func eval(with assignments: [Var: Bool]) -> Bool {
        switch self {
        case .variable(let v):
            return assignments[v]!
        case .and(let l, let r):
            return l.eval(with: assignments) && r.eval(with: assignments)
        case .or(let l, let r):
            return l.eval(with: assignments) || r.eval(with: assignments)
        case .not(let f):
            return !f.eval(with: assignments)
        }
    }
    
    public var variables: [Var] {
        switch self {
        case .variable(let v):
            return [v]
        case .and(let l, let r), .or(let l, let r):
            return l.variables + r.variables
        case .not(let f):
            return f.variables
        }
    }
}
