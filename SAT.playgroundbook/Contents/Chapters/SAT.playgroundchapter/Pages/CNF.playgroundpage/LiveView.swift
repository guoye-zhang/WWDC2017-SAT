import PlaygroundSupport

let formulaViewController = FormulaViewController.instantiateFromStoryboard()
PlaygroundPage.current.liveView = formulaViewController

let a = Var("A"), b = Var("B"), c = Var("C")
formulaViewController.formulas = [
    (a && b) || c,
    (a || c) && (b || c),
    (a || b) && c,
    (a && c) || (b && c),
    !(a && b),
    (!a || !b),
    !(a || b),
    (!a && !b)
]
