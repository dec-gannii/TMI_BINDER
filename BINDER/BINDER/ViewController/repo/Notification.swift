//
//  Notification.swift
//  BINDER
//
//  Created by 양성혜 on 2022/05/17.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["title" : title, "body": body],
                                           "content_available": true
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAWSe6ETM:APA91bESa0uiZQ4wzc1qOJKvOU9fqtRlzXcaOIBEmDgTPh2PMpNWnzszPQwaLLCAEKtkOETd5NevzZZebuekXPwYVvXBU9bzaf80HjZNuNRDkQcism2fWxTfbzCrv1i5L8_2wtj8K5A3", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}

/*
struct Notification: Codable {
    let title: String
    let body: String
    let to: String

}

func requestPOST(title:String, body:String, to:String) {
            
        let comment = Notification(title: title, body:body, to:to)
       guard let uploadData = try? JSONEncoder().encode(comment)
       else {return}

       // URL 객체 정의
       let url = URL(string: "https://connect-boxoffice.run.goorm.io/comment")

       // URLRequest 객체를 정의
       var request = URLRequest(url: url!)
       request.httpMethod = "POST"
       // HTTP 메시지 헤더
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       // URLSession 객체를 통해 전송, 응답값 처리
       let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in

           // 서버가 응답이 없거나 통신이 실패
           if let e = error {
               NSLog("An error has occured: \(e.localizedDescription)")
               return
           }
           // 응답 처리 로직
           print("comment post success")
       }
       // POST 전송
       task.resume()
}
*/
