public struct Answer: CustomStringConvertible, CustomPlaygroundQuickLookable {
    public let ans: [(Var, Bool)]
    
    public var description: String {
        let string = ans.map { $1 ? $0.name : "!\($0.name)" }.reduce("") { "\($0), \($1)" }
        return String(string.characters.dropFirst(2))
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
}
