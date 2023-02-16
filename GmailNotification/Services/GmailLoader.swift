import Combine
import GoogleSignIn

final class GmailLoader: ObservableObject {
    static let gmailReadScope = "https://www.googleapis.com/auth/gmail.readonly"
    private let baseUrlString = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
    private let unreadQuery = URLQueryItem(name: "q", value: "in:inbox label:unread")
    
    /*
     private lazy var session: URLSession? = {
     guard let accessToken = GIDSignIn
     .sharedInstance
     .currentUser?
     .accessToken
     .tokenString else { return nil }
     let configuration = URLSessionConfiguration.default
     configuration.httpAdditionalHeaders = [
     "Authorization": "Bearer \(accessToken)"
     ]
     return URLSession(configuration: configuration)
     }()
     */
    
    private func sessionWithFreshToken(completion: @escaping (Result<URLSession, Error>) -> Void) {
        GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
            guard let token = user?.accessToken.tokenString else {
                completion(.failure(.couldNotCreateURLSession(error)))
                return
            }
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            let session = URLSession(configuration: configuration)
            completion(.success(session))
        }
    }
    
    private func httpComponents(url: String, param: [URLQueryItem]) -> URLComponents?  {
        var comps = URLComponents(string: url)
        comps?.queryItems = param
        return comps
    }
    
    private func httpRequest(comps: URLComponents?) -> URLRequest?  {
        guard let components = comps, let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }
    
    func httpPublisher(url: String, param: [URLQueryItem], callback: @escaping (Data, URLResponse) throws -> Any, completion: @escaping (AnyPublisher<Any, Error>) -> Void){
        sessionWithFreshToken { [weak self] result in
            switch result {
            case .success(let authSession):
                let component = self?.httpComponents(url: url, param: param)
                let request = self?.httpRequest(comps: component)
                guard let request = request else {
                    return completion(Fail(error: .couldNotCreateURLRequest).eraseToAnyPublisher())
                }
                
                let gPublisher = authSession.dataTaskPublisher(for: request)
                    .tryMap(callback)
                    .mapError { error -> Error in
                        guard let loaderError = error as? Error else {
                            return Error.couldNotFetchGmail(underlying: error)
                        }
                        return loaderError
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                completion(gPublisher)
            case .failure(let error):
                completion(Fail(error: error).eraseToAnyPublisher())
            }
        }
    }
    
    public func unreadPublisher(completion: @escaping (AnyPublisher<Any, Error>) -> Void){
        func callback(data: Data, error: URLResponse) throws -> Any {
            let responseDictionary = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] ?? [:]
            if let num = responseDictionary["resultSizeEstimate"] as? Int {
                
                if num == 0 {
                    return (0, "")
                } else {
                    if let messages = responseDictionary["messages"] {
                        var id: String? = nil
                        let messagesArray = (messages as? NSArray)?.compactMap{ $0 as? [String: AnyObject]}
                        if let mArray = messagesArray, mArray.count > 0  {
                            id = mArray[0]["id"] as? String
                        }
                        return (num, id)
                    }
                }
            }
            // error
            return (-1, "error")
        }
        
        let url = baseUrlString
        let param = [unreadQuery]
        httpPublisher(url: url, param: param, callback: callback, completion: completion)
    }
    
    public func newestPublisher(id: String, completion: @escaping (AnyPublisher<Any, Error>) -> Void){
        func callback(data: Data, error: URLResponse) throws -> Any {
            let responseDictionary = try JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any] ?? [:]
            if let payload = responseDictionary["payload"] as? [AnyHashable: Any]{
                var subject = "", from = ""
                if let headers = payload["headers"] as? [[String: String]] {
                    for header in headers {
                        if header["name"] == "Subject" {
                            subject = header["value"]!
                        }
                        
                        if header["name"] == "From" {
                            from = header["value"]!
                        }
                    }
                }
                return (subject, from)
            } else {
                return ("", "")
            }
        }
        
        let url = baseUrlString + "/\(id)"
        let param: [URLQueryItem] = []
        httpPublisher(url: url, param: param, callback: callback, completion: completion)
    }
}

extension GmailLoader {
    enum Error: Swift.Error {
        case couldNotCreateURLSession(Swift.Error?)
        case couldNotCreateURLRequest
        case couldNotFetchGmail(underlying: Swift.Error)
    }
}
