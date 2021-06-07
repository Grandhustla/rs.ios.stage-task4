import Foundation

public extension Int {
    
    var roman: String? {
        
        let romanNumbers = [1: "I", 4: "IV", 5: "V", 9: "IX", 10: "X",
                            40: "XL", 50: "L", 90: "XC", 100: "C",
                            400: "CD", 500: "D", 900: "CM", 1000: "M"]
        
        if self <= 0 || self > 3999 {
            return nil
        } else {
            var result : String = ""
            var intNum = self

            for key in romanNumbers.keys.sorted(by: >) {
                while intNum >= key {
                    intNum -= key
                    result.append(romanNumbers[key]!)
                }
            }
        return result
        }
    }
}
