//
//  Connection.swift
//  TestApiTest
//
//  Created by MacbookAir M1 FoodStory on 27/10/2565 BE.
//

import Foundation

protocol ConnectionDelegate {
    func onSuccess(_ result: String)
    func onLostConnection()
}

protocol ConnectionUpdateDelegate {
    func onUpdate(_ progress: Int...)
}

class Connection: NSObject {

    var url: String!
    var delay: TimeInterval!
    var requestMethod: String = "POST"
    
    var function = "";
    
    fileprivate var postData: [NameValue]!, fileData: [NameValue]!
    fileprivate var timer: Timer!
    
    var delegate: ConnectionDelegate!
    var updateDelegate: ConnectionUpdateDelegate!
    
    typealias completionClosure = (_ result: String) -> Void
    typealias lostConnectionClosure = () -> Void
    
    fileprivate var completeAction: (completionClosure)?
    fileprivate var lostConnectionAction: (lostConnectionClosure)?
    
    init(url: String) {
        self.url = url
        delay = 0
    }
    
    func addPostData(_ name: String, value: String) {
        if (postData == nil) {
            postData = []
        }
        
        if(name == "function") {
            function = value;
        }
        
        postData.append(NameValue(name: name, value: value))
    }
    
    func addFileData(_ name: String, value: String) {
        if (fileData == nil) {
            fileData = []
        }
        fileData.append(NameValue(name: name, value: value))
    }
    
    public func onComplete(_ innerAction: (completionClosure)?) {
        if let options = innerAction {
            self.completeAction = options
        }
    }
    
    public func onLostConnection(_ innerAction: (lostConnectionClosure)?) {
        if let options = innerAction {
            self.lostConnectionAction = options
        }
    }
    
    public func execute() {
        timer = Timer.scheduledTimer(timeInterval: delay
            , target: self
            , selector: #selector(Connection.doPost)
            , userInfo: nil
            , repeats: false)
    }
    
    @objc func doPost() {
        
        //if(attrreference.sharedInstance.getValueBoolean("ConnectInternet")) {
            
            let lineEnd = "\r\n";
            let twoHyphens = "--";
            let boundary = "*****";
            
            //  Start request
            let url: URL = URL(string: self.url)!
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = requestMethod
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            //  Check if upload file
            if (fileData == nil) {
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            } else {
                request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
                request.addValue("multipart/form-data;boundary=" + boundary, forHTTPHeaderField: "Content-Type")
            }
            
            //  Add some parameter
//            addPostData("android_id", value: Constant.android_id)
//            addPostData("mac_id", value: Constant.mac_id)
//            addPostData("device_type", value: Constant.device_type)
//            addPostData("user_id", value: AppPreference.sharedInstance.getValueString("user_id"))
//            addPostData("token_key", value: AppPreference.sharedInstance.getValueString("token_key"))
        
            //  Check if upload file
            let body = NSMutableData()
            let encryptString: String = getPostDataString()
            /*do {
             encryptString = try MCrypt.encode(getPostDataString())
             } catch _ {
             encryptString = ""
             }*/
            if (fileData == nil) {
                body.append(NSString(format: "%@", encryptString).data(using: String.Encoding.utf8.rawValue)!)
            } else {
                let encodeString = encryptString
                let key = "input";
                let value = encodeString;
                NSLog("value \(value)")
                
                //  Define content data
                body.append(NSString(format: "%@%@%@", twoHyphens, boundary, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                body.append(NSString(format: "Content-Disposition: form-data; name=\"%@\"%@", key, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                body.append(NSString(format: "Content-Type: text/plain; charset=UTF-8%@", lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                body.append(NSString(format: "Content-Length: %d%@%@", value.count, lineEnd, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                body.append(NSString(format: "%@", value).data(using: String.Encoding.utf8.rawValue)!)
                body.append(NSString(format: "%@", lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                
                /*dos.writeBytes(twoHyphens + boundary + lineEnd);
                 dos.writeBytes("Content-Disposition: form-data; name=\"" + key + "\"" + lineEnd);
                 dos.writeBytes("Content-Type: text/plain; charset=UTF-8" + lineEnd);
                 dos.writeBytes("Content-Length: " + value.length() + lineEnd + lineEnd);
                 dos.writeBytes(value);
                 dos.writeBytes(lineEnd);*/
                
                //  Define file data
                var fileIndex = 0
                for data: NameValue in fileData {
                    let fileName = data.value.components(separatedBy: "/").last
                    let mimeType = "application/octet-stream"
                    body.append(NSString(format: "%@%@%@", twoHyphens, boundary, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                    body.append(NSString(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", data.name, fileName!, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                    body.append(NSString(format: "Content-Type: %@%@%@", mimeType, lineEnd, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                    //                NSLog("data.value) \(data.value)")
                    
                    //  Get file lenght
                    let contentData = try? Data(contentsOf: URL(string: data.value)!)
                    //                body.appendData(contentData!)
                    let fileLength: Int = contentData == nil ? 1 : contentData!.count
                    //                NSLog("fileLength \(fileLength)")
                    
                    //  Open stream
                    let fileUrl = URL(string: data.value)
                    let stream: InputStream = InputStream(url: fileUrl!)!
                    stream.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
                    stream.open()
                    var buffer = [UInt8](repeating: 0, count: 1024)
                    var total: Int = 0
                    while stream.hasBytesAvailable {
                        let count = stream.read(&buffer, maxLength: buffer.count)
                        total += count
                        body.append(buffer, length: count)
                        let progress = Int(total * 100 / fileLength)
                        publishProgress(fileIndex, progress)
                    }
                    
                    body.append(NSString(format: "%@", lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                    body.append(NSString(format: "%@%@%@%@", twoHyphens, boundary, twoHyphens, lineEnd).data(using: String.Encoding.utf8.rawValue)!)
                    
                    fileIndex += 1
                }
            }
            request.httpBody = body as Data
            let task = session.dataTask(with: request as URLRequest) {
                (data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error \(error)")
                    if self.delegate == nil {
                        if let options = self.lostConnectionAction {
                            options()
                        }
                    } else {
                        self.delegate.onLostConnection()
                    }
                    return
                }
                let resultText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                //NSLog("resultText \(resultText)")
                let decryptString: String = resultText
                /*do {
                 decryptString = try MCrypt.decode(resultText)
                 } catch _ {
                 decryptString = ""
                 }*/
                
                //  Send to main thread
                DispatchQueue.main.async(execute: {
                    
                    print("save json");
//                    JsonCoreDataManagement.sharedInstance.insertORupdateJson(String(describing: url), parameter: self.getPostDataString(), function: self.function, result: decryptString);
                    
                    if self.delegate == nil {
                        if let options = self.completeAction {
                            options(decryptString)
                        }
                    } else {
                        self.delegate.onSuccess(decryptString)
                    }
                })
            }
            task.resume()
//        }
        /*else {
            
//            let jsonLocal = JsonCoreDataManagement.sharedInstance.fetchJson(String(url), parameter: self.getPostDataString(), function: self.function);
            
            if self.delegate == nil {
                if let options = self.completeAction {
                    options(jsonLocal)
                }
            } else {
                self.delegate.onSuccess(jsonLocal)
            }
            
        }*/
        
    }
    
    fileprivate func publishProgress(_ progress: Int...) {
//        if (updateDelegate != nil) {
//            //  Send to main thread
//            DispatchQueue.main.async(execute: {
//                self.updateDelegate.onUpdate(progress[0], progress[1])
//            })
//
//        }
    }
    
    fileprivate func getPostDataString() -> String {
        var result = ""
        var isFirst = true
        if (postData != nil) {
            for data: NameValue in postData {
                if (isFirst) {
                    isFirst = false
                } else {
                    result += "&"
                }
                result += (data.name + "=" + data.value)
            }
        }
        
        print("getPostDataString : \(result)")
        return result
    }
    
}

class NameValue {
    
    var name: String!
    var value: String!
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
}

