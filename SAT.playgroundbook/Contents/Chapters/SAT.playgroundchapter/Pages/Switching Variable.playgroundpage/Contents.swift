/*:
 In the last example on the last page, conversion into [CNF](glossary://CNF) is slow and expensive. In the worst case, the formula could blow up exponentially. Fortunately, we could introduce **switching variables** to shorten the conversion process.
 
 For example, `(A and B) or (C and D)` is equivalent to `(Z → (A and B) and (not Z → (C and D))` using `Z` as **switching variable**, which is equivalent to **CNF** `(not Z or A) and (not Z or B) and (Z or C) and (Z or D)`.
 
 By adding parameter `switching: true` to `toCNF()`, you can enable **switching variables**.
 
 *Live view shows the example above. If the 1st line is true, you can always find a `Z` so that 2nd and 3rd line is true. However if the 1st line is false, no `Z` can make 2nd or 3rd line true*
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
// Variable declaration
let a = Var("A"), b = Var("B"), c = Var("C"), d = Var("D"), e = Var("E"), f = Var("F"), g = Var("G")

// Simple conversion
((a || b) && (c || d)).toCNF(switching: true)
((a && b) || (c && d)).toCNF(switching: true)

// Previous example
let formula = (a && b) || (c && d) || (e && f && g)
formula.toCNF()
formula.toCNF(switching: true)
//#-end-editable-code
//: *Tap "Run My Code" then the "abc" icon to the right to see the results.* Notice that not all formulas get **switching variables** as they are only used when there is benefit to do so. [Next page](@next) will show you the process of a SAT solver.
