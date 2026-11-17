import Foundation

/// Counts the edits between two words.
enum EditDistance {
    /// The Damerau–Levenshtein distance (optimal string alignment): the fewest single-letter
    /// insertions, deletions, replacements and swaps of neighbouring letters that turn `a` into
    /// `b`. "teh" → "the" is 1 (one swap). Returns nil as soon as it must exceed `maxDistance`,
    /// which keeps lookups fast because most candidates are rejected after a row or two.
    static func damerauLevenshtein(_ a: [UInt32], _ b: [UInt32], maxDistance: Int) -> Int? {
        guard abs(a.count - b.count) <= maxDistance else { return nil }
        if a.isEmpty || b.isEmpty {
            let distance = max(a.count, b.count)
            return distance <= maxDistance ? distance : nil
        }

        // Three rolling rows of the distance table: two rows back (for swaps), the last row and
        // the row being filled.
        var twoRowsBack = [Int](repeating: 0, count: b.count + 1)
        var lastRow = Array(0...b.count)
        var row = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            row[0] = i
            var rowMinimum = i
            for j in 1...b.count {
                let replaceCost = a[i - 1] == b[j - 1] ? 0 : 1
                var distance = min(lastRow[j] + 1, row[j - 1] + 1, lastRow[j - 1] + replaceCost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    distance = min(distance, twoRowsBack[j - 2] + 1)
                }
                row[j] = distance
                rowMinimum = min(rowMinimum, distance)
            }
            if rowMinimum > maxDistance {
                return nil
            }
            (twoRowsBack, lastRow, row) = (lastRow, row, twoRowsBack)
        }
        let distance = lastRow[b.count]
        return distance <= maxDistance ? distance : nil
    }
}
