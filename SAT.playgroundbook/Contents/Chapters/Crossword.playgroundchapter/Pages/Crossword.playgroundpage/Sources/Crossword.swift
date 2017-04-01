import PlaygroundSupport

public enum Cell {
    case wall
    case blank
    case c(Character)
    
    var value: PlaygroundValue {
        switch self {
        case .wall:
            return .integer(0)
        case .blank:
            return .integer(1)
        case .c(let char):
            return .string(String(char))
        }
    }
}

func value(for puzzle: [[Cell]]) -> PlaygroundValue {
    return .dictionary(["puzzle": .array(puzzle.map {
        .array($0.map { $0.value })
    })])
}

public class Trie {
    var next = [Character: Trie]()
}

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters

public func align(puzzle: [[Cell]]) -> [[Cell]] {
    var puzzle = puzzle
    let width = puzzle.reduce(0) { max($0, $1.count) }
    for i in puzzle.indices {
        if puzzle[i].count < width {
            puzzle[i] += [Cell](repeating: .wall, count: width - puzzle[i].count)
        }
    }
    if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
        proxy.send(value(for: puzzle))
    }
    return puzzle
}

public func createVariables(for puzzle: [[Cell]]) -> [[[Character: Var]]] {
    var variables = [[[Character: Var]]]()
    for i in puzzle.indices {
        var row = [[Character: Var]](repeating: [:], count: puzzle[i].count)
        for j in puzzle[i].indices {
            if case .wall = puzzle[i][j] {
                continue
            }
            for c in alphabet {
                row[j][c] = Var("\(c)_\(i)_\(j)")
            }
        }
        variables.append(row)
    }
    return variables
}

public func appendVariableRules(to cnf: inout CNF, for variables: [[[Character: Var]]], in puzzle: [[Cell]]) {
    for i in puzzle.indices {
        for j in puzzle[i].indices {
            let vars = variables[i][j]
            switch puzzle[i][j] {
            case .c(let c):
                cnf.formula.append([(vars[c]!, true)])
                fallthrough
            case .blank:
                cnf.formula.append(vars.values.map { ($0, true) } )
                for c1 in alphabet {
                    for c2 in alphabet {
                        if c1 < c2 {
                            cnf.formula.append([(vars[c1]!, false), (vars[c2]!, false)])
                        }
                    }
                }
            default: break
            }
        }
    }
}

public func createTries(with words: [String]) -> [Int: Trie] {
    var tries = [Int: Trie]()
    for word in words {
        let trie = tries[word.characters.count] ?? Trie()
        var start = trie
        for char in word.characters {
            if let next = start.next[char] {
                start = next
            } else {
                let new = Trie()
                start.next[char] = new
                start = new
            }
        }
        tries[word.characters.count] = trie
    }
    return tries
}

func generateWordRules(trie: Trie, variables: [[[Character: Var]]], prefix: [(Var, Bool)], start: (Int, Int), direction: (Int, Int)) -> [[(Var, Bool)]] {
    guard trie.next.count > 0 else { return [] }
    var formulas = [[(Var, Bool)]]()
    formulas.append(prefix + trie.next.keys.map { (variables[start.0][start.1][$0]!, true) })
    for (char, next) in trie.next {
        formulas += generateWordRules(trie: next, variables: variables, prefix: prefix + [(variables[start.0][start.1][char]!, false)], start: (start.0 + direction.0, start.1 + direction.1), direction: direction)
    }
    return formulas
}

public func appendHorizontalRules(to cnf: inout CNF, for variables: [[[Character: Var]]], in puzzle: [[Cell]], with tries: [Int: Trie]) {
    for i in puzzle.indices {
        var lastOpen: Int?
        for j in puzzle[i].indices {
            if case .wall = puzzle[i][j] {
                if let lastOpen = lastOpen, let trie = tries[j - lastOpen] {
                    cnf.formula += generateWordRules(trie: trie, variables: variables, prefix: [], start: (i, lastOpen), direction: (0, 1))
                }
                lastOpen = nil
            } else {
                if lastOpen == nil {
                    lastOpen = j
                }
            }
        }
        if let lastOpen = lastOpen, let trie = tries[puzzle[i].count - lastOpen] {
            cnf.formula += generateWordRules(trie: trie, variables: variables, prefix: [], start: (i, lastOpen), direction: (0, 1))
        }
    }
}

public func appendVerticalRules(to cnf: inout CNF, for variables: [[[Character: Var]]], in puzzle: [[Cell]], with tries: [Int: Trie]) {
    for j in puzzle.first?.indices ?? 0..<0 {
        var lastOpen: Int?
        for i in puzzle.indices {
            if case .wall = puzzle[i][j] {
                if let lastOpen = lastOpen, let trie = tries[i - lastOpen] {
                    cnf.formula += generateWordRules(trie: trie, variables: variables, prefix: [], start: (lastOpen, j), direction: (1, 0))
                }
                lastOpen = nil
            } else {
                if lastOpen == nil {
                    lastOpen = i
                }
            }
        }
        if let lastOpen = lastOpen, let trie = tries[puzzle.count - lastOpen] {
            cnf.formula += generateWordRules(trie: trie, variables: variables, prefix: [], start: (lastOpen, j), direction: (1, 0))
        }
    }
}
