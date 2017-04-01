public class Var: Formula, Hashable, CustomStringConvertible, CustomPlaygroundQuickLookable {
    public let name: String
    
    public init(_ name: String) {
        precondition(!name.hasPrefix("_"), "Underscore is reserved for switching variables")
        self.name = name
    }
    
    private static var switchingCount = 0
    init() {
        Var.switchingCount += 1
        name = "_\(Var.switchingCount)"
    }
    
    public var f: FormulaImp {
        return .variable(self)
    }
    
    public var description: String {
        return name
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public static func ==(lhs: Var, rhs: Var) -> Bool {
        return lhs === rhs
    }
}
