/*:
 [Trie](glossary://Trie) is a recursive tree data structure that stores words letter by letter.
 
 Naively, we might want to use rules like `(A_0_0 and B_0_1) or (A_0_0 and C_0_1)` to represent "ab" or "ac". However, it is inefficient to convert it into [CNF](glossary://CNF).
 
 Here, we use rules like `A_0_0 imply (B_0_1 or C_0_1)` instead. It is equivalent to rules above, yet much more efficient. **Trie** is the perfect data structure we can use to generate these rules.
 */
//#-hidden-code
import PlaygroundSupport

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(literal, show, string)
class Trie {
    var next = [Character: Trie]()
}

func createTries(with words: [String]) -> [Int: Trie] {
    var tries = [Int: Trie]()
    for word in words {
        let trie = tries[word.characters.count] ?? Trie()
        var start = trie
        for char in word.characters {
            if let next = start.next[char] {
                start = next
            } else {
                let new = Trie()
                start.next[char] = new
                start = new
            }
        }
        tries[word.characters.count] = trie
    }
    return tries
}

createTries(with: /*#-editable-code words*/["ab", "ac", "bc"]/*#-end-editable-code*/)
//: [Next page](@next) has the full source of our **crossword** encoder
//#-hidden-code
extension Trie: CustomStringConvertible, CustomPlaygroundQuickLookable {
    var description: String {
        let strings = next.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value.description)" }
        let result = strings.reduce("") { "\($0), \($1)" }
        return "{\(String(result.characters.dropFirst(2)))}"
    }
    
    var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(description)
    }
}
//#-end-hidden-code
