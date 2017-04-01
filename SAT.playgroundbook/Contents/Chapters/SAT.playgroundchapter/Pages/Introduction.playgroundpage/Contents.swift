/*:
 Have you ever wished that you could write a specification, and computer just solves your problem automatically? That's exactly what [declarative programming](glossary://Declarative%20programming) does!
 
 [SAT](glossary://Boolean%20Satisfiability%20Problem) is one of the simplest way of declarative programming. For the example below, a [crossword](glossary://Crossword) puzzle is encoded as **SAT**, then a **SAT solver** is used to solve it. Here, we only provided the specification for the puzzle, not how to find solutions, but the solver discovered itself where is the hardest part to search first.
 
 In this playground, you'll learn how **SAT solvers** work, and how to convert problems such as **crossword** into **SAT**.
 */
//#-hidden-code
import Foundation
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)

func readNewlineSeparatedWords(from url: URL) -> [String] {
    let file = try! String(contentsOf: url).uppercased()
    return file.characters.split(separator: "\n").map(String.init)
}
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(pageauxiliarymodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, array, string)
//#-code-completion(identifier, hide, Var, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController)
//#-code-completion(identifier, show, .)
//#-editable-code
let puzzle: [[Cell]] = [
[.blank, .blank, .blank, .wall,  .blank, .blank, .blank],
[.blank, .wall,  .c("A"),.c("O"),.c("R"),.c("T"),.c("A")],
[.blank, .c("U"),.blank, .wall,  .blank, .blank, .blank],
[.wall,  .c("N"),.wall,  .wall,  .wall,  .blank, .wall],
[.blank, .c("I"),.blank, .wall,  .blank, .blank, .blank],
[.blank, .c("T"),.blank, .blank, .blank, .wall,  .blank],
[.blank, .c("E"),.blank, .wall,  .blank, .blank, .blank]
]

let words = readNewlineSeparatedWords(from: #fileLiteral(resourceName: "words"))

let cnf = encode(puzzle: puzzle, words: words)

cnf.solve(delay: 0.005)
//#-end-editable-code
//: Let's [proceed](@next)
