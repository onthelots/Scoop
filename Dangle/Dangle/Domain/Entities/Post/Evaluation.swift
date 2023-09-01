//
//  Evaluation.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

//import Foundation
//import Firebase
//import FirebaseFirestore
//
//struct Evaluation {
//    var documentID: String
//    var authorUID: String
//    var category: String
//    var address: String
//    var content: String
//    var imageURL: String
//    var latitude: Double
//    var longitude: Double
//
//    // QueryDocumentSnapshot -> 문서(document)를 나타냄)
//    init?(document: QueryDocumentSnapshot) {
//        guard let data = document.data() as? [String: Any],
//              let authorUID = data["작성자 UID"] as? String,
//              let category = data["카테고리"] as? String,
//              let address = data["주소"] as? String,
//              let content = data["평가 내용"] as? String,
//              let imageURL = data["이미지 URL"] as? String,
//              let latitude = data["위도"] as? Double,
//              let longitude = data["경도"] as? Double
//        else {
//            return nil
//        }
//
//        self.documentID = document.documentID
//        self.authorUID = authorUID
//        self.category = category
//        self.address = address
//        self.content = content
//        self.imageURL = imageURL
//        self.latitude = latitude
//        self.longitude = longitude
//    }
//
//    func toDictionary() -> [String: Any] {
//        return [
//            "작성자 UID": authorUID,
//            "카테고리": category,
//            "주소": address,
//            "평가 내용": content,
//            "이미지 URL": imageURL,
//            "위도": latitude,
//            "경도": longitude
//        ]
//    }
//}
