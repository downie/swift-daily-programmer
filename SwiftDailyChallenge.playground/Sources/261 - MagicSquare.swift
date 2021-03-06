// This is the completed code from the 261 challenge series that I use later in the series.
// I'm pulling it out so I only have to write it one place and it can be used in later challenges.

import Foundation

public struct MagicSquare {
    public let size : Int
    public let linearContents : [Int?]
    public let twoDimensionalContents : [[Int?]]
    
    public var targetSum : Int {
        return size * (size * size + 1) / 2
    }
}

// Not really needed to solve the problem, but I wanted to play with ArrayLiteralConvertable
extension MagicSquare : ArrayLiteralConvertible {
    public typealias Element = Int
    
    public init(arrayLiteral elements: Int...) {
        self.init(withArray: elements)
    }
    
    public init(withArray elements : [Int]) {
        #if swift(>=3.0)
        self.init(withArray: elements.map({ .some($0) }))
        #else
        self.init(withArray: elements.map({ .Some($0) }))
        #endif
        
        #if swift(>=3.0)

        #else

        #endif
    }
    
    public init(withArray elements : [Int?]) {
        // Figure out the size of square
        let actualSize = Int(ceil(sqrt(Double(elements.count))))
        
        // Fill in any remaining squares if we weren't given sufficient information.
        let paddedElements : [Int?]
        if elements.count == actualSize {
            paddedElements = elements
        } else {
            #if swift(>=3.0)
                paddedElements = elements + Array(repeating: nil, count: actualSize)
            #else
                paddedElements = elements + Array(count: actualSize, repeatedValue: nil)
            #endif
        }
        
        // Build the 2d contents
        var twoDimensionalContents : [[Int?]] = []
        var startingIndex = 0
        
        #if swift(>=3.0)
            let range = stride(from: actualSize, through: actualSize * actualSize, by: actualSize)
        #else
            let range = actualSize.stride(through: actualSize * actualSize, by: actualSize)
        #endif
        
        range.forEach { newIndex in
            let subrange = paddedElements[startingIndex..<newIndex]
            twoDimensionalContents.append(Array(subrange))
            startingIndex = newIndex
        }
        
        // Save the properties
        size = actualSize
        linearContents = paddedElements
        self.twoDimensionalContents = twoDimensionalContents
    }
}

// This is the first problem, with the first bonus
extension MagicSquare {
    public func isValid() -> Bool {
        
        let areAllRowsValid = self.twoDimensionalContents.reduce(true) { (isValidSoFar, row) -> Bool in
            guard isValidSoFar else {
                // short circuit if we already found an invalid row
                return false
            }
            let areAnyValuesNil = row.reduce(true) { (isValidSoFar, value) -> Bool in
                guard isValidSoFar else {
                    return false
                }
                return value != nil
            }
            guard areAnyValuesNil else {
                return false
            }
            
            let rowSum = row.flatMap({ $0 }).reduce(0, combine: +)
            
            return rowSum == targetSum
        }
        
        let areAllColumnsValid = (0..<size).reduce(true) { (isValidSoFar, columnIndex) -> Bool in
            guard isValidSoFar else {
                return false
            }
            
            var noNilsFound = true
            let columnSum = twoDimensionalContents.reduce(0) { (sumSoFar, row) -> Int in
                if let value = row[columnIndex] {
                    return sumSoFar + value
                } else {
                    noNilsFound = false
                    return sumSoFar
                }
            }
            
            guard noNilsFound else {
                return false
            }
            
            return columnSum == targetSum
        }
        
        var noNilsFound = true
        let uphillSum = (0..<size).reduce(0) { (sumSoFar, index) -> Int in
            if let value = twoDimensionalContents[index][index] {
                return sumSoFar + value
            } else {
                noNilsFound = false
                return sumSoFar
            }
        }
        let downhillSum = (0..<size).reduce(0) { (sumSoFar, index) -> Int in
            if let value = twoDimensionalContents[index][size - index - 1] {
                return sumSoFar + value
            } else {
                noNilsFound = false
                return sumSoFar
            }
        }
        
        guard noNilsFound else {
            return false
        }
        
        let isUphillDiagonalValid = uphillSum == targetSum
        let isDownhillDiagonalValid = downhillSum == targetSum
        
        return areAllRowsValid
            && areAllColumnsValid
            && isUphillDiagonalValid
            && isDownhillDiagonalValid
    }
}

// This is the first problem with the second bonus
extension MagicSquare {
    public func canRepairLastRow() -> Bool {
        #if swift(>=3.0)
            let columnSums = Array(repeating: targetSum, count: size)
        #else
            let columnSums = Array(count: size, repeatedValue: targetSum)
        #endif
        
        // Compute last row from columns
        let possibleLastRow = twoDimensionalContents.reduce(columnSums) { (remainingSum, row) -> [Int] in
            #if swift(>=3.0)
                let enumerated = row.enumerated()
            #else
                let enumerated = row.enumerate()
            #endif
            
            return enumerated.map { (index, value) -> Int in
                return remainingSum[index] - (value ?? 0)
            }
        }
        
        
        var newLinearSquare = linearContents
        
        #if swift(>=3.0)
            let replaceRange = Range(uncheckedBounds: (lower: size*size-size, upper: size*size))
            newLinearSquare.replaceSubrange(replaceRange, with: possibleLastRow.map({ .some($0) }))
        #else
            let replaceRange = (size*size-size)..<(size*size)
            newLinearSquare.replaceRange(replaceRange, with: possibleLastRow.map({ .Some($0) }))
        #endif

        
        let testMagicSquare = MagicSquare(withArray: newLinearSquare)
        return testMagicSquare.isValid()
    }
}

extension MagicSquare : CustomStringConvertible {
    public var description: String {
        return twoDimensionalContents.reduce("", combine: { (inputSoFar, newRow) -> String in
            let newRowString = newRow.reduce("", combine: { (rowSoFar, possibleInt) -> String in
                var numberString = "x"
                if let actualInt = possibleInt {
                    numberString = String(actualInt)
                }
                return rowSoFar + " " + numberString
            })
            return inputSoFar + "\n" + newRowString
        })
    }
}
