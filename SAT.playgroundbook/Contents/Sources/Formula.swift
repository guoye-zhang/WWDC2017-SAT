import Foundation
import PlaygroundSupport

public protocol Formula {
    var f: FormulaImp { get }
}

extension Formula {
    public func toCNF(switching: Bool = false) -> CNF {
        return f.toCNF(switching: switching)
    }
    
    public func solve(delay: TimeInterval? = nil) -> Answer? {
        return f.solve(delay: delay)
    }
}

public func &&(lhs: Formula, rhs: Formula) -> Formula {
    return FormulaImp.and(lhs.f, rhs.f)
}

public func ||(lhs: Formula, rhs: Formula) -> Formula {
    return FormulaImp.or(lhs.f, rhs.f)
}

public prefix func !(rhs: Formula) -> Formula {
    return FormulaImp.not(rhs.f)
}

public indirect enum FormulaImp: Formula, CustomStringConvertible, CustomPlaygroundQuickLookable {
    case variable(Var)
    case and(FormulaImp, FormulaImp)
    case or(FormulaImp, FormulaImp)
    case not(FormulaImp)
    
    public var f: FormulaImp {
        return self
    }
    
    public var description: String {
        switch self {
        case .variable(let v):
            return v.description
        case .and(let l, let r):
            return "(\(l.description) && \(r.description))"
        case .or(let l, let r):
            return "(\(l.description) || \(r.description))"
        case .not(let f):
            return "!\(f.description)"
        }
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
    
    func toCNF(switching: Bool) -> CNF {
        switch self {
        case .variable(let v):
            return CNF(formula: [[(v, true)]])
        case .and(let l, let r):
            let lcnf = l.toCNF(switching: switching)
            let rcnf = r.toCNF(switching: switching)
            return CNF(formula: lcnf.formula + rcnf.formula)
        case .or(let l, let r):
            let lcnf = l.toCNF(switching: switching)
            let rcnf = r.toCNF(switching: switching)
            var cnf = CNF(formula: [])
            if !switching || lcnf.formula.count == 1 || rcnf.formula.count == 1 {
                for l in lcnf.formula {
                    for r in rcnf.formula {
                        cnf.formula.append(l + r)
                    }
                }
            } else {
                let switching = Var()
                for l in lcnf.formula {
                    cnf.formula.append([(switching, false)] + l)
                }
                for r in rcnf.formula {
                    cnf.formula.append([(switching, true)] + r)
                }
            }
            return cnf
        case .not(let f):
            switch f {
            case .variable(let v):
                return CNF(formula: [[(v, false)]])
            case .and(let l, let r):
                return FormulaImp.or(.not(l), .not(r)).toCNF(switching: switching)
            case .or(let l, let r):
                return FormulaImp.and(.not(l), .not(r)).toCNF(switching: switching)
            case .not(let f):
                return f.toCNF(switching: switching)
            }
        }
    }
    
    func solve(delay: TimeInterval? = nil) -> Answer? {
        return toCNF(switching: true).solve(delay: delay)
    }
}

extension FormulaImp {
    public var value: PlaygroundValue {
        switch self {
        case .variable(let v):
            return .array([.integer(0), .string(v.name)])
        case .and(let l, let r):
            return .array([.integer(1), l.value, r.value])
        case .or(let l, let r):
            return .array([.integer(2), l.value, r.value])
        case .not(let f):
            return .array([.integer(3), f.value])
        }
    }
    
    public static func variables(in value: PlaygroundValue) -> Set<String> {
        if case .array(let array) = value, array.count > 1, case .integer(let type) = array[0] {
            switch type {
            case 0:
                if case .string(let v) = array[1] {
                    return [v]
                }
            case 1, 2:
                if array.count > 2 {
                    return variables(in: array[1]).union(variables(in: array[2]))
                }
            case 3:
                return variables(in: array[1])
            default: break
            }
        }
        return []
    }
    
    public init?(_ value: PlaygroundValue, variables: [String: Var]) {
        if case .array(let array) = value, array.count > 1, case .integer(let type) = array[0] {
            switch type {
            case 0:
                if case .string(let v) = array[1] {
                    self = .variable(variables[v]!)
                } else {
                    return nil
                }
            case 1, 2:
                if array.count > 2, let l = FormulaImp(array[1], variables: variables), let r = FormulaImp(array[2], variables: variables) {
                    self = type == 1 ? .and(l, r) : .or(l, r)
                } else {
                    return nil
                }
            case 3:
                if let f = FormulaImp(array[1], variables: variables) {
                    self = .not(f)
                } else {
                    return nil
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}
