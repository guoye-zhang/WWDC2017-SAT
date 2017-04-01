import UIKit
import PlaygroundSupport

@objc(EqualityTableViewController)
public class EqualityTableViewController: UITableViewController, PlaygroundLiveViewMessageHandler {
    @IBOutlet var cells: [UITableViewCell]! {
        didSet {
            cells.sort { $0.tag < $1.tag }
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .array(let array) = message else { return }
        let bools: [Bool] = array.flatMap {
            if case .boolean(let b) = $0 {
                return b
            } else {
                return nil
            }
        }
        guard bools.count == cells.count else { return }
        for (cell, b) in zip(cells, bools) {
            cell.accessoryType = b ? .checkmark : .none
        }
    }
    
    public static func instantiateFromStoryboard() -> EqualityTableViewController {
        let bundle = Bundle(for: EqualityTableViewController.self)
        let storyboard = UIStoryboard(name: "Equality", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! EqualityTableViewController
    }
}
