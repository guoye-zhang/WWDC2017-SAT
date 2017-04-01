/*:
 [Conjunctive normal form](glossary://CNF) (abbreviated as **CNF**) is a format of Boolean formula that follows `(A or not B or …) and (not C or D or …) and …` (conjunction of disjunction of literals). It is used by **SAT solvers** because it's simpler to deal with, and any Boolean formula can be converted into **CNF**.
 
 Here, you can use `toCNF()` on any formula to convert it into **CNF**.
 
 *Live view shows what is the basis of this conversion:*
 * *Distributive law*
   * `1st line = 2nd line`
   * `3rd line = 4th line`
 * *De Morgan's law*
   * `5th line = 6th line`
   * `7th line = 8th line`
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
// Declare some Boolean variables
let a = Var("A"), b = Var("B"), c = Var("C"), d = Var("D"), e = Var("E"), f = Var("F"), g = Var("G")

// Simple formulas
(a && b).toCNF()
(a || b).toCNF()

// Complex formulas
(a || (b && c)).toCNF()
(!a && !(!(b && c) || d)).toCNF()

// This is already CNF
((a || b) && !c).toCNF()

// This formula gets much longer after conversion
((a && b) || (c && d) || (e && f && g)).toCNF()
//#-end-editable-code
//: *Tap "Run My Code" then the "abc" icon to the right to see the results.* When you are ready, go to the [next page](@next)
