import PlaygroundSupport

let formulaViewController = FormulaViewController.instantiateFromStoryboard()
PlaygroundPage.current.liveView = formulaViewController

let a = Var("A"), b = Var("B"), c = Var("C"), d = Var("D"), z = Var("Z")
formulaViewController.formulas = [
    (a && b) || (c && d),
    (!z || (a && b)) && (z || (c && d)),
    (!z || a) && (!z || b) && (z || c) && (z || d)
]
