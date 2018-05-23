import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit
import SpotifyLogin

class Api {
    
    static let shared: Api = Api()
    let localStorage = UserDefaults.standard
    let baseURL: String = "http://192.168.1.202:3000/api"
    var sessionManager: SessionManager
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4 // seconds
        configuration.timeoutIntervalForResource = 4
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func login(username: String, password: String) -> Promise<Bool> {
        let parameters: [String: Any] = [
            "username": username,
            "password_hash": password
        ]
        
        return Promise{ fulfill, reject in
            sessionManager.request(baseURL + "/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        fulfill(true)
                    case .failure(let error):
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
                                    print(queue.description)
                                    queues.append(queue)
                                }
                            }
                            fulfill(queues)
                        }
                    case .failure(let error):
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
                        if let array = json["data"]["Songs"].array {
                            for item in array {
                                guard let dictionary = item.dictionaryObject else {
                                    continue
                                }
                                if let song = Song(data: dictionary) {
                                    print(song.description)
                                    queue.enqueue(song: song)
                                }
                            }
                            fulfill(queue)
                        }
                    case .failure(let error):
                        reject(error)
                        print(error)
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
                        reject(error)
                        print(error)
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
                        reject(error)
                        print(error)
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
                                let previewURL: String
                                let title = item["name"].stringValue
                                let songURL = item["uri"].stringValue
                                let artistName = item["album"]["artists"][0]["name"].stringValue
                                let imageString = item["album"]["images"][0]["url"].stringValue
                                
                                if (item["preview_url"] == JSON.null) {
                                    previewURL = "null"
                                } else {
                                    previewURL = item["preview_url"].stringValue
                                }
                                
                                let song = SpotifySong(title: title, image: imageString, artist: artistName, songURL: songURL, previewURL: previewURL, time: "" )
                                songs.append(song)
                            }  
                            fulfill(songs)
                        }
                    case .failure(let error):
                        reject(error)
                        print(error)
                    }
            }
        }
    }
}
