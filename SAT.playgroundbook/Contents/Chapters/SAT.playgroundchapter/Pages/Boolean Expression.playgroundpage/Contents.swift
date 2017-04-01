/*:
 [Boolean satisfiability problem](glossary://Boolean%20Satisfiability%20Problem) (abbreviated as **SAT**) is the problem of determining if there exists an variable assignment of a given [Boolean](glossary://Boolean) formula so that the formula evaluates to `true`.
 
 **SAT** is one of the first problems proven to be [NP-complete](glossary://NP-complete), which means that any problem within complexity NP can be reduced (transformed) into **SAT** within polynomial time.
 
 First, let's look at some **Boolean expressions**.
 */
//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)

var formulas = [Formula]()

func show(_ formula: Formula) {
    formulas.append(formula)
}
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, string)
//#-code-completion(identifier, hide, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController)
//#-code-completion(identifier, show, ||, &&, !, ()
//#-editable-code
// Declare some Boolean variables and give them each a name
let a = Var("A"), b = Var("B"), c = Var("C")

// Boolean expressions
show(a)
show(a && b)
show(a || b)
show(a && !a)
show(a || !a)
show((a && !b) || (!a && c))
//#-end-editable-code
//: *Tap "Run My Code" to see the results. You can toggle Boolean assignments at the top.* When you are ready, move on to the [next page](@next)
//#-hidden-code
if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.send(.array(formulas.map { $0.f.value }))
}
//#-end-hidden-code
