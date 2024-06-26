import Vapor

extension Environment {
    /// Fetches an environment variable, throwing an error if it is undefined.
    ///
    /// - Parameter key: the name of the variable
    /// - Throws: Throws an error if the variable is undefined.
    /// - Returns: the raw string value of the variable
    static func ensure(_ key: String) throws -> String {
        guard let value = get(key), !value.isEmpty else {
            throw EnvironmentVarError(key: key, reason: .missing)
        }
        return value
    }

    /// Fetches an environment variable, and if defined, converts the raw value to a string-based `RawRepresentable`
    /// type.
    ///
    /// If the variable is undefined, `nil` is returned.
    ///
    /// - Parameter key: the name of the variable
    /// - Throws: Throws an error if the variable is defined but cannot be converted to the given type.
    /// - Returns: the converted value, or `nil` if the variable is undefined
    static func convert<Value: RawRepresentable>(_ key: String) throws -> Value?
    where Value.RawValue == String {
        guard let rawValue = get(key), !rawValue.isEmpty else { return nil }
        guard let value = Value(rawValue: rawValue) else {
            throw EnvironmentVarError(key: key, reason: .malformed)
        }
        return value
    }

    /// Fetches an environment variable and converts the raw value to a string-based `RawRepresentable`
    /// type, throwing an error if the variable is undefined.
    ///
    /// - Parameter key: the name of the variable
    /// - Throws: Throws an error if the variable is undefined, or if it's defined but cannot be converted to the given
    ///   type.
    /// - Returns: the converted value
    static func ensure<Value: RawRepresentable>(_ key: String) throws -> Value
    where Value.RawValue == String {
        guard let value: Value = try convert(key) else {
            throw EnvironmentVarError(key: key, reason: .missing)
        }

        return value
    }

    /// Fetches an environment variable, and if defined, converts the raw value to a `LosslessStringConvertible` type.
    ///
    /// If the variable is undefined, `nil` is returned.
    ///
    /// - Parameter key: the name of the variable
    /// - Throws: Throws an error if the variable is defined but cannot be converted to the given type.
    /// - Returns: the converted value, or `nil` if the variable is undefined
    static func convert<Value: LosslessStringConvertible>(_ key: String) throws -> Value? {
        guard let rawValue = get(key) else { return nil }
        guard let value = Value(rawValue) else {
            throw EnvironmentVarError(key: key, reason: .malformed)
        }
        return value
    }

    /// Fetches an environment variable and converts the raw value to a `LosslessStringConvertible` type throwing an
    /// error if the variable is undefined.
    ///
    /// - Parameter key: the name of the variable
    /// - Throws: Throws an error if the variable is undefined, or if it's defined but cannot be converted to the given
    ///   type.
    /// - Returns: the converted value
    static func ensure<Value: LosslessStringConvertible>(_ key: String) throws -> Value {
        guard let value: Value = try convert(key) else {
            throw EnvironmentVarError(key: key, reason: .missing)
        }

        return value
    }
}

struct EnvironmentVarError: Error {
    let key: String
    let reason: Reason

    enum Reason {
        case missing
        case malformed
    }
}
