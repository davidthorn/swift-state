import UIKit
import Foundation

let d: URL = URL(string: "https://google.com")!



func isCodable(a: Any) -> Bool {
    return a is Codable
}

do {
    let e = try JSONEncoder.init().encode(d)
} catch let error{
    print(error)
}


isCodable(a: d)
