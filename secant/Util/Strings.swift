import Foundation

//#if DEBUG
extension String {
    init<T>(dumping value: T) {
        var output = String()
        dump(value, to: &output)
        self.init(stringLiteral: output)
    }
}
//#endif
