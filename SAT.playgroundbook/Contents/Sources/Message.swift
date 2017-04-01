import PlaygroundSupport

enum Message {
    case start([(String, Bool)])
    case assign([(String, Bool)])
    case failed(String, Bool)
    case backtrack
    
    var value: PlaygroundValue {
        switch self {
        case .start(let vars), .assign(let vars):
            let type: Int
            if case .start = self {
                type = 0
            } else {
                type = 1
            }
            let variables = vars.map {
                PlaygroundValue.array([.string($0), .boolean($1)])
            }
            return .array([.integer(type), .array(variables)])
        case .failed(let v, let b):
            return .array([.integer(2), .array([.string(v), .boolean(b)])])
        case .backtrack:
            return .array([.integer(3)])
        }
    }
    
    init?(_ value: PlaygroundValue) {
        if case .array(let array) = value, array.count > 0, case .integer(let type) = array[0] {
            switch type {
            case 0, 1:
                if array.count > 1, case .array(let variables) = array[1] {
                    let vars: [(String, Bool)] = variables.flatMap {
                        if case .array(let arr) = $0, arr.count == 2, case .string(let v) = arr[0], case .boolean(let b) = arr[1] {
                            return (v, b)
                        } else {
                            return nil
                        }
                    }
                    self = type == 0 ? .start(vars) : .assign(vars)
                } else {
                    return nil
                }
            case 2:
                if array.count > 1, case .array(let arr) = array[1], arr.count == 2, case .string(let v) = arr[0], case .boolean(let b) = arr[1] {
                    self = .failed(v, b)
                } else {
                    return nil
                }
            case 3:
                self = .backtrack
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}
