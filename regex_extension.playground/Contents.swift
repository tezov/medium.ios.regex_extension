import Foundation


// MARK: - Without Extension
print("************* MARK: - Without Extension")
let _ = {
    //example 1: extract matching part in string
    let input = "|prefix|12|sperator|17|"
    let pattern = "\\|(.*?)(?=\\|)"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let inputNsRange = NSRange(input.startIndex ..< input.endIndex, in: input)
    let matches = regex.matches(in: input, options: [], range:  inputNsRange)
    var output:[String] = []
    matches.forEach { match in
        if 1 < match.numberOfRanges {
            let matchRange = Range(match.range(at: 1), in: input)!
            let value = String(input[matchRange])
            output.append(value)
        }
    }
    print("********RESULT:\(output)")
}()

let _ = {
    //example 2: replace placeholder in string with content of map
    let placeHolder = [
        "verb" : "are",
        "adjectif" : "cool"
    ]
    let input = "extension ${verb} so ${adjectif}"
    let pattern = "\\$\\{([^}]*)\\}"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: input, options: [], range:  NSRange(input.startIndex ..< input.endIndex, in: input))
    var output = input
    for match in matches.reversed() {
        if 1 < match.numberOfRanges {
            let matchRange = Range(match.range, in: input)!
            let matchKeyRange = Range(match.range(at: 1), in: input)!
            let key = String(input[matchKeyRange])
            output.replaceSubrange(matchRange, with: placeHolder[key] ?? "!!MISSING PLACE_HOLDER!!")
        }
    }
    print("********RESULT:\(output)")
}()


// MARK: - Extension
public extension String {
    var range: Range<String.Index> {
        startIndex ..< endIndex
    }
    
    var nsRange: NSRange {
        NSRange(startIndex ..< endIndex, in: self)
    }
    
    subscript(_ range: NSRange) -> String {
        String(self[Range(range, in: self)!])
    }
    
    mutating func replaceSubrange(_ range: NSRange, with subString: String) {
        replaceSubrange(Range(range, in: self)!, with: subString)
    }
}

public extension String {
    @available(iOS 4.0, *)
    var toRegex: NSRegularExpression {
        try! NSRegularExpression(pattern: self, options: [])
    }
}

public extension NSRegularExpression {
    func matches(_ input: String) -> [NSTextCheckingResult] {
        matches(in: input, options: [], range: input.nsRange)
    }
}

public extension NSTextCheckingResult {
    func getOrNil(at index: Int) -> NSRange? {
        if index >= 0, index < numberOfRanges {
            return self.range(at: 1)
        }
        return nil
    }
}


// MARK: - With Extension
print("**************** MARK: - With Extension")

let _ = {
    //example 1: extract matching part in string
    let input = "|prefix|12|sperator|17|"
    let matches = "\\|(.*?)(?=\\|)".toRegex.matches(input)
    var output:[String] = []
    matches.forEach { match in
        if let range = match.getOrNil(at: 1) {
            output.append(input[range])
        }
    }
    print("********RESULT:\(output)")
}()



let _ = {
    //example 2: replace matching part in string
    let placeHolder = [
        "verb" : "are",
        "adjectif" : "cool"
    ]
    let input = "extension ${verb} so ${adjectif}"
    let matches = "\\$\\{([^}]*)\\}".toRegex.matches(input)
    var output = input
    for match in matches.reversed() {
        if let matchKeyRange = match.getOrNil(at: 1) {
            let key = input[matchKeyRange]
            output.replaceSubrange(match.range, with: placeHolder[key] ?? "!!MISSING PLACE_HOLDER!!")
            
        }
    }
    print("********RESULT:\(output)")
}()
