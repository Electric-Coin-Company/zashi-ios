import Foundation

// TODO: This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight
extension String {
    init<T>(dumping value: T) {
        var output = String()
        dump(value, to: &output)
        self.init(stringLiteral: output)
    }
}

extension String {
    private static let floatingPointRegex = "^[0-9]*.?[0-9]+"
    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    private static let phoneRegex = "^^\\+(?:[0-9]?){6,14}[0-9]$"

    public enum ValidationType: Equatable {
        case custom(String)
        case email
        case floatingPoint
        case maxLength(Int)
        case minLength(Int)
        case phoneNumber

        func isValid(text: String) -> Bool {
            switch self {
            case .custom(let regex):
                return text.validate(using: regex)

            case .email:
                return text.validate(using: .emailRegex)

            case .floatingPoint:
                return text.validate(using: .floatingPointRegex)

            case .maxLength(let length):
                return text.count <= length && !text.isEmpty

            case .minLength(let length):
                return text.count >= length

            case .phoneNumber:
                return text.validate(using: .phoneRegex)
            }
        }
    }

    private func validate(using regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return false }

        return regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)
        ) != nil
    }

    public func isValid(for validationType: ValidationType?) -> Bool {
        guard let validationType = validationType else { return true }

        return validationType.isValid(text: self)
    }
}
