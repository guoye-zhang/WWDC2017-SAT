import Foundation
import PlaygroundSupport

public class Solver {
    private var cnf: CNF
    private var ordering = [Var]() {
        didSet {
            watching = [Set<Int>](repeating: [], count: ordering.count)
            nwatching = [Set<Int>](repeating: [], count: ordering.count)
            answers = [Bool?](repeating: nil, count: ordering.count)
        }
    }
    private var formula = [[(Int, Bool)]]()
    private var watching = [Set<Int>]()
    private var nwatching = [Set<Int>]()
    private var stack = [(Int, Bool)]()
    private var answers = [Bool?]()
    private var delay: TimeInterval?
    
    private lazy var proxy = PlaygroundPage.current.liveView as! PlaygroundRemoteLiveViewProxy
    
    private func assign(_ v: (Int, Bool)) -> [Int] {
        answers[v.0] = v.1
        stack.append(v)
        var assigned = [v.0]
        for n in v.1 ? nwatching[v.0] : watching[v.0] {
            var f = formula[n]
            if answers[f[0].0] == f[0].1 || answers[f[1].0] == f[1].1 {
                continue
            }
            var newWatch: Int?
            for i in 2..<f.count {
                if let ans = answers[f[i].0], ans != f[i].1 {
                    continue
                }
                newWatch = i
                break
            }
            if let newWatch = newWatch {
                let oldWatch = f[0].0 == v.0 ? 0 : 1
                if v.1 {
                    nwatching[v.0].remove(n)
                } else {
                    watching[v.0].remove(n)
                }
                if f[newWatch].1 {
                    watching[f[newWatch].0].insert(n)
                } else {
                    nwatching[f[newWatch].0].insert(n)
                }
                swap(&f[oldWatch], &f[newWatch])
                formula[n] = f
            } else {
                let i = f[0].0 == v.0 ? 1 : 0
                if answers[f[i].0] == nil {
                    let propagation = assign(f[i])
                    if propagation.isEmpty {
                        unassign(assigned)
                        return []
                    } else {
                        assigned += propagation
                    }
                } else {
                    unassign(assigned)
                    return []
                }
            }
        }
        return assigned
    }
    
    private func unassign(_ vars: [Int]) {
        for v in vars {
            answers[v] = nil
            stack.removeLast()
        }
    }
    
    private func tryAssign(_ v: (Int, Bool)) -> Bool {
        let assigned = assign(v)
        if !assigned.isEmpty {
            if let delay = delay {
                let variables = assigned.map { (ordering[$0].name, answers[$0]!) }
                proxy.send(Message.assign(variables).value)
                Thread.sleep(forTimeInterval: delay)
            }
            if solve(next: v.0 + 1) {
                return true
            }
            unassign(assigned)
            if delay != nil {
                proxy.send(Message.backtrack.value)
            }
        } else {
            if let delay = delay {
                proxy.send(Message.failed(ordering[v.0].name, false).value)
                Thread.sleep(forTimeInterval: delay)
                proxy.send(Message.backtrack.value)
            }
        }
        return false
    }
    
    private func solve(next: Int) -> Bool {
        if let i = answers[next..<answers.count].index(where: { $0 == nil }) {
            return tryAssign((i, true)) || tryAssign((i, false))
        } else {
            return !formula.contains {
                !$0.contains {
                    answers[$0] == $1
                }
            }
        }
    }
    
    public func solve(delay: TimeInterval? = nil) -> Answer? {
        self.delay = delay
        var priority = [Var: Double]()
        for f in cnf.formula {
            for v in f {
                let p = priority[v.0] ?? 0
                priority[v.0] = p + 1 / Double(f.count)
            }
        }
        ordering = priority.sorted { $0.1 > $1.1 }.map { $0.0 }
        var orderedIndex = [Var: Int]()
        for variable in priority.keys {
            orderedIndex[variable] = ordering.index(of: variable)
        }
        formula = cnf.formula.flatMap {
            $0.count < 2 ? nil : $0.map {
                (orderedIndex[$0]!, $1)
            }
        }
        for (i, f) in formula.enumerated() {
            if f[0].1 {
                watching[f[0].0].insert(i)
            } else {
                nwatching[f[0].0].insert(i)
            }
            if f[1].1 {
                watching[f[1].0].insert(i)
            } else {
                nwatching[f[1].0].insert(i)
            }
        }
        var initialPropagation = [Int]()
        for f in cnf.formula.filter({ $0.count == 1 }) {
            let assigned = assign((ordering.index(of: f[0].0)!, f[0].1))
            if assigned.isEmpty {
                return nil
            }
            initialPropagation += assigned
        }
        if delay != nil {
            let assigned = initialPropagation.map { (ordering[$0].name, answers[$0]!) }
            proxy.send(Message.start(assigned).value)
        }
        if solve(next: 0) {
            let ans = stack.map { (ordering[$0], $1) }.filter { !$0.0.name.hasPrefix("_") }
            return Answer(ans: ans)
        } else {
            return nil
        }
    }
    
    public init(cnf: CNF) {
        self.cnf = cnf
    }
}
