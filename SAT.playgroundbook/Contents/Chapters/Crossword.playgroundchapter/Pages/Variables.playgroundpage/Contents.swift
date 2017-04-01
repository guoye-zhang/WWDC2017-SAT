/*:
 Each cell has 26 [Boolean](glossary://Boolean) variables representing 26 letters. They are named like `A_0_0`.
 
 Only one letter is allowed in a cell, so here we create rules to enforce exactly one of those 26 variables to be true.
 */
//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
enum Cell {
    case wall
    case blank
    case c(Character)
}

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters

func createVariables(for puzzle: [[Cell]]) -> [[[Character: Var]]] {
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

func appendVariableRules(to cnf: inout CNF, for variables: [[[Character: Var]]], in puzzle: [[Cell]]) {
    for i in puzzle.indices {
        for j in puzzle[i].indices {
            let vars = variables[i][j]
            switch puzzle[i][j] {
            case .c(let c):
                // Character already in cell
                cnf.formula.append([(vars[c]!, true)])
                fallthrough
            case .blank:
                // At least one character is in a cell
                cnf.formula.append(vars.values.map { ($0, true) } )
                // No two characters can be in the same cell
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
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let, var)
//#-code-completion(literal, show, array)
//#-code-completion(identifier, hide, Var, Formula, FormulaImp, Solver, Answer, CrosswordViewController, SolverTableViewController)
//#-code-completion(identifier, show, (, .)
//#-editable-code
let puzzle = [[Cell.blank]]
let variables = createVariables(for: puzzle)

var cnf = CNF(formula: [])
appendVariableRules(to: &cnf, for: variables, in: puzzle)
//#-end-editable-code
//: [Next up](@next), it's about a data structure to store words
