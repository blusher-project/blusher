public struct DBusIntrospection {
    internal class Builder {
        public var value: String

        public init() {
            self.value = DBusIntrospection.doctype
        }

        public func nodeBegin() {
            self.value += "<node>\n"
        }

        public func nodeEnd() {
            self.value += "</node>\n"
        }

        public func interfaceBegin(name: String) {
            self.value += "<interface name=\"\(name)\"\n"
        }

        public func interfaceEnd() {
            self.value += "</interface>\n"
        }

        public func method(name: String) {
            self.value += "<method name=\"\(name)\"/>\n"
        }

        public func methodBegin(name: String) {
            self.value += "<method name=\"\(name)\">\n"
        }

        public func methodEnd() {
            self.value += "</method>\n"
        }

        public func arg(name: String, type: String, direction: String) {
            self.value += "<arg name=\"\(name)\" type=\"\(type)\" direction=\"\(direction)\"/>\n"
        }
    }

    public static let doctype: String = """
        <!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
        "https://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
        """

    public var rawValue: String
}
