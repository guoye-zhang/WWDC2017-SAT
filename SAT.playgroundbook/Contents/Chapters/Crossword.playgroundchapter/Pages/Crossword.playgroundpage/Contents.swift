/*:
 Here we will take part our program which converts [crossword](glossary://Crossword) puzzles into [SAT](glossary://Boolean%20Satisfiability%20Problem).
 
 Below is our main encoder function:
 */
//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
func encode(puzzle: [[Cell]], words: [String]) -> CNF {
    // Align puzzle to have the same width each row 
    let puzzle = align(puzzle: puzzle)
    // Create variables
    let variables = createVariables(for: puzzle)
    // Here it is simpler to construct CNF directly
    var cnf = CNF(formula: [])
    // Apply rules that ensure each cell has exactly one letter
    appendVariableRules(to: &cnf, for: variables, in: puzzle)
    // Convert words into trie
    let tries = createTries(with: words)
    // Apply rules for rows and columns
    appendHorizontalRules(to: &cnf, for: variables, in: puzzle, with: tries)
    appendVerticalRules(to: &cnf, for: variables, in: puzzle, with: tries)
    return cnf
}
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(pageauxiliarymodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, array, string)
//#-code-completion(identifier, hide, Var, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController, Trie, align(puzzle:), createVariables(for:), appendVariableRules(to:for:in:), createTries(with:), appendHorizontalRules(to:for:in:with:), appendVerticalRules(to:for:in:with:))
//#-code-completion(identifier, show, .)
//#-editable-code
let cnf = encode(
    puzzle: [
        [.blank, .blank],
        [.blank, .blank]
    ],
    words: [
        "FI", "HI", "OF", "OH"
    ]
)
cnf.solve(delay: 0.1)
//#-end-editable-code
//: [Next up](@next), it's about variables.
