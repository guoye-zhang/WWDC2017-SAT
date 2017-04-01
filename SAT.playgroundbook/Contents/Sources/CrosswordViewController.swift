import UIKit
import PlaygroundSupport

@objc(CrosswordViewController)
public class CrosswordViewController: UIViewController, PlaygroundLiveViewMessageHandler {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    
    enum Cell {
        case wall
        case blank
        case c(Character)
        
        init?(_ value: PlaygroundValue) {
            switch value {
            case .integer(0):
                self = .wall
            case .integer(1):
                self = .blank
            case .string(let str):
                if let char = str.characters.first {
                    self = .c(char)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
    }
    
    var puzzle = [[Cell]]() {
        didSet {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
            labels = []
            guard puzzle.count > 0 else { return }
            stackView.removeConstraint(aspectRatioConstraint)
            aspectRatioConstraint = NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: CGFloat(puzzle[0].count) / CGFloat(puzzle.count), constant: 0)
            stackView.addConstraint(aspectRatioConstraint)
            for row in puzzle {
                var labelRow = [UILabel]()
                for cell in row {
                    let label = UILabel()
                    label.textAlignment = .center
                    label.font = .systemFont(ofSize: 50)
                    label.numberOfLines = 0
                    label.adjustsFontSizeToFitWidth = true
                    switch cell {
                    case .c(let c):
                        label.text = String(c)
                        fallthrough
                    case .blank:
                        label.backgroundColor = .white
                    default: break
                    }
                    labelRow.append(label)
                }
                labels.append(labelRow)
                let stackViewRow = UIStackView(arrangedSubviews: labelRow)
                stackViewRow.distribution = .fillEqually
                stackViewRow.spacing = 1
                stackView.addArrangedSubview(stackViewRow)
            }
        }
    }
    
    var labels = [[UILabel]]()
    
    private static func puzzle(for value: PlaygroundValue) -> [[Cell]]? {
        if case .dictionary(let dict) = value, let puzzle = dict["puzzle"], case .array(let array) = puzzle {
            return array.flatMap {
                if case .array(let row) = $0 {
                    return row.flatMap { Cell($0) }
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    public func receive(_ message: PlaygroundValue) {
        if let puzzle = CrosswordViewController.puzzle(for: message) {
            self.puzzle = puzzle
        }
        if let message = Message(message) {
            switch message {
            case .start(let variables), .assign(let variables):
                let vars = variables.flatMap { $1 ? $0 : nil }
                for variable in vars {
                    let parts = variable.characters.split(separator: "_").map(String.init)
                    guard parts.count == 3, let i = Int(parts[1]), let j = Int(parts[2]) else { continue }
                    labels[i][j].text = parts[0]
                }
            default: break
            }
        }
    }
    
    public static func instantiateFromStoryboard() -> CrosswordViewController {
        let bundle = Bundle(for: CrosswordViewController.self)
        let storyboard = UIStoryboard(name: "Crossword", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! CrosswordViewController
    }
}
