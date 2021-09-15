# Coding Guidelines

Your contributions are very welcome, however we'd like you to please follow our coding guidelines. We've created them to be able to have a base structure that enable our maintainer to evaluate and review all contributions equally.

Some rules are being enforced by SwiftLint. Please look at [SwiftLint guidelines](../blob/master/SWIFTLINT.md) for more information.

# Creating new files
When creating new files, please use the provided templates when applicable. You can find them in the [xctemplates folder](../blob/master/xctemplates).

# Type definition structure

When defining new type or modificating an existing one, please follow the convention below:

````
Type
-nested types
-static properties
-constants
-variables
-computed properties
-init methods
-instance methods

# extension for static functions (optional)
# private extension for private functions (optional)
# extension for Type conformances to individual protocols (not optional)

(# denotes the usage of a mandatory pragma mark)
````