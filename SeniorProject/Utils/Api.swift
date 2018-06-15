import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit
import SpotifyLogin

class Api {
    
    static let shared: Api = Api()
    let localStorage = UserDefaults.standard

    let baseURL: String = "http://129.65.251.54:3001/api"
    var sessionManager: SessionManager
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4 // seconds
        configuration.timeoutIntervalForResource = 4
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func login(username: String, password: String) -> Promise<User> {
        let parameters: [String: Any] = [
            "username": username,
            "password_hash": password
        ]
        
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        guard let dictionary = json["data"].dictionaryObject else {
                            return
                        }
                        if let user = User(data: dictionary) {
                            fulfill(user)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func createUser(username: String, password: String) -> Promise<User> {
        let parameters: [String: Any] = [
            "username": username,
            "password_hash": password,
            "role": "user"
        ]
        
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/user", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)

                        guard let dictionary = json["data"].dictionaryObject else {
                            return
                        }
                        if let user = User(data: dictionary) {
                            fulfill(user)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func getAllQueues(with: String!) -> Promise<[Queue]> {
        let parameters: [String: Any] = [
            "name": with ?? ""
        ]
        
        return Promise { fulfill, reject in
            sessionManager.request(baseURL + "/queue",
                                   method: .get,
                                   parameters: parameters,
                                   encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        if let array = json["data"].array {
                            var queues: [Queue] = []
                            for item in array {
                                guard let dictionary = item.dictionaryObject else {
                                    continue
                                }
                                if let queue = Queue(data: dictionary) {
                                    queues.append(queue)
                                }
                            }
                            fulfill(queues)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func getMyQueues() -> Promise<[Queue]> {
        
        return Promise { fulfill, reject in
            sessionManager.request(baseURL + "/queue/my",
                                   method: .get,
                                   encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        if let array = json["data"][0]["Queues"].array {
                            var queues: [Queue] = []
                            for item in array {
                                guard var dictionary = item.dictionaryObject else {
                                    continue
                                }
                                
                                dictionary["ownerUsername"] = "--"
                                if let queue = Queue(data: dictionary) {
                                    queues.append(queue)
                                }
                            }
                            fulfill(queues)
                        }
                        fulfill([])
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func getSelectedQueue(queue: Queue) -> Promise<Queue> {
        queue.clearQueue()
        
        return Promise { fulfill, reject in
            sessionManager.request(baseURL + "/queue/\(queue.id)", method: .get)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if let queue = self.instantiateQueueFromData(json: json) {
                            fulfill(queue)
                        }
                        queue.sort()
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func searchUsers(query: String) -> Promise<[User]> {
        let parameters: [String: Any] = [
            "search": query
        ]
        
        return Promise { fulfill, reject in
            sessionManager.request(baseURL + "/user",
                                   method: .get,
                                   parameters: parameters,
                                   encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        if let array = json["data"].array {
                            var users: [User] = []
                            for item in array {
                                guard let dictionary = item.dictionaryObject else {
                                    continue
                                }
                                if let user = User(data: dictionary) {
                                    users.append(user)
                                }
                            }
                            fulfill(users)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func createQueue(name: String, isPrivate: Bool, password: String, members: [User]) -> Promise<Bool> {
        
        let parameters: [String : Any] = [
            "name": name,
            "private": isPrivate,
            "password": password,
            "members": members.map { $0.id }
        ]
        
        return Promise { fulfill, reject in
            sessionManager.request(baseURL + "/queue", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func joinQueue(queueId: Int, password: String!) -> Promise<Bool> {
        
        var parameters: [String : Any] = [:]
        
        if password != nil {
            parameters["password"] = password!
        }
        
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/queue/\(queueId)/join", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func setQueueIsPlaying(queueId: Int, isPlaying: Bool) {
        let parameters: [String : Any] = [
            "isPlaying": isPlaying
        ]
        
        sessionManager.request(baseURL + "/queue/\(queueId)/playing", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success:
                    print("Set is playing: \(isPlaying)")
                case .failure(let error):
                    self.requestErrorHandler(response: response)
                    print(error)
                }
        }
    }
    
    func queueSong(queueId: Int, song: SpotifySong) -> Promise<Bool> {
        let parameters: [String : Any] = [
            "title": song.title,
            "artist": song.artist,
            "album_uri": song.imageURI,
            "preview_uri": song.previewURI,
            "spotify_uri": song.spotifyURI
        ]
        
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/queue/\(queueId)/songs", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func dequeueSong(queueId: Int, songId: Int) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/queue/\(queueId)/songs/\(songId)", method: .delete, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func voteSong(song: Song) -> Promise<Any> {
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/song/\(song.id)/vote", method: .put)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func unvoteSong(song: Song) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/song/\(song.id)/unvote", method: .put)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func getSpotifyAccessToken() -> Promise<String> {
        return Promise { fulfill, reject in
            SpotifyLogin.shared.getAccessToken { (token, error) in
                if error != nil, token == nil {
                    print(error.debugDescription)
                    reject(error!)
                }
                fulfill(token!)
            }
        }
    }
    
    func searchSpotify(query: String, spotifyToken: String) -> Promise<[SpotifySong]> {
        let modifiedWord = query.replacingOccurrences(of: " ", with: "+")
        let searchURL = "https://api.spotify.com/v1/search?q=\(modifiedWord)&type=track"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(spotifyToken)"]
        
        return Promise { fulfill, reject in
            sessionManager.request(searchURL, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let tracks = json["tracks"]
                        
                        if let items = tracks["items"].array {
                            var songs: [SpotifySong] = []
                            for item in items {
                                guard item.dictionaryObject != nil else {
                                    continue
                                }
                                let title = item["name"].stringValue
                                let artist = item["album"]["artists"][0]["name"].stringValue
                                let previewURI: String
                                let songURI = item["uri"].stringValue
                                let albumURI = item["album"]["images"][0]["url"].stringValue
                                
                                if (item["preview_url"] == JSON.null) {
                                    previewURI = "null"
                                } else {
                                    previewURI = item["preview_url"].stringValue
                                }

                                let song = SpotifySong(data: ["title": title, "artist": artist, "album_uri": albumURI, "spotify_uri": songURI, "preview_uri": previewURI])
                                
                                songs.append(song!)
                            }  
                            fulfill(songs)
                        }
                    case .failure(let error):
                        self.requestErrorHandler(response: response)
                        reject(error)
                    }
            }
        }
    }
    
    func instantiateQueueFromData(json: JSON) -> Queue? {
        guard var dictionary = json["data"].dictionaryObject else {
            print("Error: cannot instantiate queue from data")
            return nil
        }
        
        dictionary["ownerUsername"] = "--"
        if let queue = Queue(data: dictionary) {
            if let array = json["data"]["Songs"].array {
                for item in array {
                    guard var dict = item.dictionaryObject else {
                        print("Error: cannot instantiate song from data")
                        continue
                    }
                    dict["votes"] = item["votes"].array?.count
                    if let song = Song(data: dict) {
                        queue.enqueue(song: song)
                    }
                }
                queue.sort()
                return queue
            }
        }
        
        return nil
    }
    
    func requestErrorHandler(response: DataResponse<Data>) {
        print("Success: \(response.result.isSuccess)")
        print("Response String: \(String(describing: response.result.value))")
        
        var statusCode = response.response?.statusCode
        if let error = response.result.error as? AFError {
            statusCode = error._code // statusCode private
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    print("Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    print("Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    print("Response status code was unacceptable: \(code)")
                    statusCode = code
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            }
            
            print("Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = response.result.error as? URLError {
            print("URLError occurred: \(error)")
        } else {
            print("Unknown error: \(String(describing: response.result.error))")
        }
    }
    
    func refreshUserSession () {
        print("refresh user session")
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let password = UserDefaults.standard.value(forKey: "password") as! String
        
        firstly {
            login(username: username, password: password)
            }.then { (result) -> Void in
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                mainStore.dispatch(SetLoggedInUserAction(user: result))
            }.catch { (error) in
                print(error)
        }
    }
}
