import Foundation

// TODO: This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight
extension String {
    init<T>(dumping value: T) {
        var output = String()
        dump(value, to: &output)
        self.init(stringLiteral: output)
    }
}
