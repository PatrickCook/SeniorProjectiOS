import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class Api {
    
    static let api: Api = Api()
    let localStorage = UserDefaults.standard
    let baseURL: String = "http://192.168.1.202:3000/api"
    
    func login(username: String, password: String) -> Promise<Bool> {
        let parameters: [String: Any] = [
            "username": username,
            "password_hash": password
        ]
        
        return Promise{ fulfill, reject in
            Alamofire.request(baseURL + "/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
    
    func getAllQueues() -> Promise<[Queue]> {
        Store.currentQueues = []
        return Promise { fulfill, reject in
            Alamofire.request(baseURL + "/queue", method: .get)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
       
                        if let array = json["data"].array {
                            for item in array {
                                guard let dictionary = item.dictionaryObject else {
                                    continue
                                }
                                if let queue = Queue(data: dictionary) {
                                    print(queue.description)
                                    Store.currentQueues.append(queue)
                                }
                            }
                            fulfill(Store.currentQueues)
                        }
                    case .failure(let error):
                        reject(error)
                        print(error)
                    }
            }
        }
    }
    
    func getSelectedQueue() -> Promise<Queue> {
        let queueId = Store.selectedQueue?.id
        Store.selectedQueue?.songs.removeAll()
        
        return Promise { fulfill, reject in
            Alamofire.request(baseURL + "/queue/\(queueId ?? -1)", method: .get)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(json["data"]["Songs"])
                        if let array = json["data"]["Songs"].array {
                            print(array.count)
                            for item in array {
                                guard let dictionary = item.dictionaryObject else {
                                    continue
                                }
                                if let song = Song(data: dictionary) {
                                    print(song.description)
                                    Store.selectedQueue?.queue(song: song)
                                }
                            }
                            fulfill(Store.selectedQueue!)
                        }
                    case .failure(let error):
                        reject(error)
                        print(error)
                    }
            }
        }
    }
}

/*
 * TEMPLATES:
 *
 * Add this in the Api.swift file
 * func apiAction(completion: @escaping (RETURN_TYPE) -> Void) {
 *        Alamofire.request(baseURL + "ENDPOINT_URL").responseJSON { response in
 *            guard let value = response.result.value as? [String : Any], let status = value["status"] as? String, let data = value["data"] as? [Any] else {
 *                print("Invalid response")
 *                return
 *            }
 *            if status == "success" {
 *                completion(RETURN_TYPE)
 *            } else {
 *                completion(RETURN_TYPE)
 *            }
 *        }
 *    }
 *
 * Call this new Api function in a ViewControler by doing this
 * api.ENDPOINT_ACTION(PARAMETERS, completion: { [weak self] response in
 *    //Use response
 * })
 */
