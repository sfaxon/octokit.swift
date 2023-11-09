import Foundation
import RequestKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class CheckRuns: Codable {
    open var totalCount: Int
    open var checkRuns: [CheckRun]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case checkRuns = "check_runs"
    }
}

open class CheckRun: Codable {
    open private(set) var id: Int
    open var headSHA: String
    open var url: URL?
    open var htmlURL: URL?
    open var detailsURL: URL?
    open var status: Status?
    open var conclusion: Conclusion?
    open var startedAt: Date?
    open var completedAt: Date?
    open var name: String?
    open var output: CheckRun.Output?

    public init(id: Int = -1,
                headSHA: String,
                url: URL? = nil,
                htmlURL: URL? = nil,
                detailsURL: URL? = nil,
                status: Status? = nil,
                conclusion: Conclusion? = nil,
                startedAt: Date? = nil,
                completedAt: Date? = nil,
                name: String? = nil,
                output: CheckRun.Output? = nil) {
        self.id = id
        self.headSHA = headSHA
        self.url = url
        self.htmlURL = htmlURL
        self.detailsURL = detailsURL
        self.status = status
        self.conclusion = conclusion
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.name = name
        self.output = output
    }

    enum CodingKeys: String, CodingKey {
        case id
        case headSHA = "head_sha"
        case url
        case htmlURL = "html_url"
        case detailsURL = "details_url"
        case status
        case conclusion
        case startedAt
        case completedAt
        case name
        case output
    }
}

public extension CheckRun {
    enum Status: String, Codable {
        case queued
        case inProgress = "in_progress"
        case completed
    }
}

public extension CheckRun {
    enum Conclusion: String, Codable {
        case success
        case failure
        case neutral
        case cancelled
        case skipped
        case timedOut = "timed_out"
        case actionRequired = "action_required"
    }
}

public extension CheckRun {
    class Output: Codable {
        open var title: String?
        open var summary: String?
        open var text: String?        
        open var annotationsCount: Int?
        open var annotationsURL: URL?
        
        
        enum CodingKeys: String, CodingKey {
            case title
            case summary
            case text
            case annotationsCount = "annotations_count"
            case annotationsURL = "annotations_url"
        }
    }
}


// MARK: Request

public extension Octokit {
    
#if compiler(>=5.5.2) && canImport(_Concurrency)
    /**
     Get a single pull request
     - parameter owner: The user or organization that owns the repositories.
     - parameter repository: The name of the repository.
     - parameter number: The commit reference. Can be a commit SHA, branch name (`heads/BRANCH_NAME`), or tag name (`tags/TAG_NAME`).
     */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func checkRuns(owner: String,
                   repository: String,
                   ref: String) async throws -> CheckRuns {
        let router = CheckRunRouter.readCheckRuns(configuration, owner, repository, ref)
        return try await router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: CheckRuns.self)
    }
#endif
}

enum CheckRunRouter: JSONPostRouter {
    case readCheckRuns(Configuration, String, String, String)

    var method: HTTPMethod {
        switch self {
        case .readCheckRuns:
            return .GET
        }
    }

    var encoding: HTTPEncoding {
        return .url
    }

    var configuration: Configuration {
        switch self {
        case let .readCheckRuns(config, _, _, _): return config
        }
    }

    var params: [String: Any] {
        switch self {
        case .readCheckRuns:
            return [:]
        }
    }

    var path: String {
        switch self {
        case let .readCheckRuns(_, owner, repository, ref):
            return "repos/\(owner)/\(repository)/commits/\(ref)/check-runs"
        }
    }
}
