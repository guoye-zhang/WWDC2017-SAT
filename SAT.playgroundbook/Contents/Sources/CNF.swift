import Foundation

public struct CNF: CustomStringConvertible, CustomPlaygroundQuickLookable {
    public var formula: [[(Var, Bool)]]
    
    public init(formula: [[(Var, Bool)]]) {
        self.formula = formula
    }
    
    public var description: String {
        let strings = formula.map {
            $0.map {
                $1 ? $0.name : "!\($0.name)"
            }
        }
        let result = strings.reduce("") {
            let next = String($1.reduce("") {
                "\($0) || \($1)"
            }.characters.dropFirst(4))
            return "\($0) && (\(next))"
        }
        return String(result.characters.dropFirst(4))
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
    
    public func solve(delay: TimeInterval? = nil) -> Answer? {
        return Solver(cnf: self).solve(delay: delay)
    }
}
