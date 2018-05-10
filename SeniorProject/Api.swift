import Foundation
import Alamofire
import SwiftyJSON

class Api {
    
    static let api: Api = Api()
    
    let appDefaults = UserDefaults.standard
    let baseURL: String = "http://192.168.1.202:3000/api"
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let parameters: [String: Any] = [
            "username": username,
            "password_hash": password
        ]
        
        Alamofire.request(baseURL + "/auth", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(true)
                case .failure(let error):
                    completion(false)
                    print(error)
                }
        }
    }
    
    func getQueues(completion: @escaping (Bool) -> Void) {
        
        Alamofire.request(baseURL + "/queue", method: .get)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("Received Queues: \(json)")
                    
                    if let array = json["data"].array {
                        var queueArray: [Queue] = []
                        for item in array {
                            guard let dictionary = item.dictionaryObject else {
                                continue
                            }
                            if let queue = Queue(data: dictionary) {
                                print(queue.description)
                                queueArray.append(queue)
                            }
                        }
                    }
                    completion(true)
                case .failure(let error):
                    completion(false)
                    print(error)
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
