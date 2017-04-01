/*:
 **Knights and Knaves** is a type of logic puzzle where
 
 * **Knights** always tell the truth
 * **Knaves** always lie
 
 You can use [SAT](glossary://Boolean%20Satisfiability%20Problem) solvers to easily solve these kind of puzzles.
 
 First, we've defined two advanced logical operators to help you:
 
 * **Imply** means if X then Y
 * **If and only if** (**iff** for short) means X and Y are equal
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(keyword, show, let)
//#-code-completion(literal, show, string)
//#-code-completion(identifier, hide, Formula, FormulaImp, CNF, Solver, Answer, CrosswordViewController, SolverTableViewController, p1)
//#-code-completion(identifier, show, ||, &&, !, (, .)
extension Formula {
    func imply(_ f: Formula) -> Formula {
        return !self || f
    }
    
    func iff(_ f: Formula) -> Formula {
        return self.imply(f) && f.imply(self)
    }
}
//: [Boolean](glossary://Boolean) variables
let a = Var("A_is_Knight"), b = Var("B_is_Knight")
//: Two people, **A** and **B**, stand before you. **B** says, “We are both knaves.”
let p1 = b.iff(!a && !b)
p1.solve(delay: 1)
//: Two people again. **A** says, “We are both the same type of people,” and **B** says, “We are each different types of people.”
let p2 = /*#-editable-code*/<#T##formula##Formula#>/*#-end-editable-code*/
p2.solve(delay: 1)

//#-editable-code Try more puzzles here
//#-end-editable-code
//#-hidden-code
import PlaygroundSupport

func ==(lhs: Formula, rhs: Formula) -> Bool {
    return (!lhs.iff(rhs)).solve() == nil
}

if p2 == (!a && b) {
    PlaygroundPage.current.assessmentStatus = .pass(message: "That is correct! Go to the [next page](@next)")
}
//#-end-hidden-code
