/*:
 Our [SAT](glossary://Boolean%20Satisfiability%20Problem) solver uses a backtracking-based search algorithm. In addition, we've implemented variable ordering and unit propagation as optimizations.
 
 First, we convert the formula into [CNF](glossary://CNF) using **switching variables**, then we reorder the variables so that the more constraint ones are tried first. Last, we enumerate variable assignments until a solution is found, or we run out of possible assignments.
 
 Unit propagation runs at the very beginning, and after each assignment. It finds unit clause that forces the assignment of certain variable. It can also find conflict which means that assignment failed.
 
 Background color:
 
 * **Blue**: Assignment attempt
 * **Red**: Conflict
 * **White**: Unit propagation
 
 *For color blind people, last assignment before backtracking is always red.*
 */
//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, string)
//#-code-completion(identifier, hide, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController)
//#-code-completion(identifier, show, ||, &&, !, (, .)
//#-editable-code
let a = Var("A"), b = Var("B"), c = Var("C"), d = Var("D")
let formula =
    (!a ||  b || !c) &&
    ( a || !c || !d) &&
    ( a || !c ||  d) &&
    ( a ||  c || !d) &&
    ( a ||  c ||  d) &&
    (!b ||  c || !d) &&
    (!a ||  b ||  c) &&
    (!a || !b || !c)

// Solve SAT with 1s delay between assignments
formula.solve(delay: 1)
//#-end-editable-code
//: [Next chapter](@next) will show you some interesting problems that can be converted into **SAT**.
