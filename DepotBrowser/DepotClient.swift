import Dependencies
import Foundation
import XCTestDynamicOverlay

enum DepotError: Error {
    case invalid(Error)
}

extension DependencyValues {
    public var depot: Depot {
        get { self[Depot.self] }
        set { self[Depot.self] = newValue }
    }
}

extension Depot: DependencyKey {
    public static var liveValue: Depot { Depot(host: "depot.medizin.unibas.ch", token: "") }
}

public struct DepotEntry: Decodable, Equatable, Identifiable {
    public enum EntryType: String, Decodable {
        case FILE, FOLDER
    }

    public let id = UUID()
    public let name: String
    public let type: EntryType
}

public struct Depot {
    public let host: String
    public let token: String
    public var delegate: (URLSessionTaskDelegate & Sendable)?

    public func list(path: [String]) async throws -> [DepotEntry] {
        let wholePath = path.isEmpty ? "/" : path.joined(separator: "/")
        let url = URL(string: "https://\(host)/list?path=\(wholePath)")!

        print(url)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let bearer = "Bearer \(token)"
        request.setValue(bearer, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        let entries = try JSONDecoder().decode([DepotEntry].self, from: data)
        return entries
    }

    public func get(path: [String]) async throws -> Data {
        let url = URL(string: "")!
        let request = URLRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: request, delegate: delegate)

        return data
    }

    public func put(content: Data, atPath: [String]) async throws {
    }
}
