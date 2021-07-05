import Foundation

@propertyWrapper
public struct FakeProperty<Fake, Protocol> {
    public let wrappedValue: Protocol
    public let projectedValue: Fake
    
    public init(_ fakeValue: Fake, as convert: (Fake) -> Protocol) {
        self.wrappedValue = convert(fakeValue)
        self.projectedValue = fakeValue
    }
}
