/*:
 You may wonder how we judged your answer in the previous **Knights and Knaves** puzzles. Of course we did not try every assignment, because **equality of Boolean expressions can be converted into [SAT](glossary://Boolean%20Satisfiability%20Problem)**!
 
 Here, try to implement the operator `==` by using **SAT solvers**. Note that `solve()` returns `nil` when no solution is possible.
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, nil)
//#-code-completion(identifier, hide, Var, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController)
//#-code-completion(identifier, show, ||, &&, !, (, ., ==)
extension Formula {
    func imply(_ f: Formula) -> Formula {
        return !self || f
    }
    
    func iff(_ f: Formula) -> Formula {
        return self.imply(f) && f.imply(self)
    }
}

func ==(lhs: Formula, rhs: Formula) -> Bool {
    return /*#-editable-code*/<#T##condition##Bool#>/*#-end-editable-code*/
}

func !=(lhs: Formula, rhs: Formula) -> Bool {
    return !(lhs == rhs)
}
//#-hidden-code
import PlaygroundSupport

do {
    let a = Var("A"), b = Var("B")
    let tests = [
        (a && a) == a,
        (a || a) == a,
        a != !a,
        a != b,
        a != (a || b),
        (a && !a) == (b && !b),
        (a || !a) == (b || !b),
        !(a && b) == (!a || !b),
        !(a || b) == (!a && !b),
        (a && b) != (!a || !b)
    ]
    if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
        proxy.send(.array(tests.map { .boolean($0) }))
    }
    if !tests.contains(false) {
        PlaygroundPage.current.assessmentStatus = .pass(message: "Good job! Go to the [next page](@next)")
    }
}
//#-end-hidden-code
