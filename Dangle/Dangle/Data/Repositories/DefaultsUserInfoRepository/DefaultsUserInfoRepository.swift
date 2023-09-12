//
//  DefaultsUserInfoRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import Firebase

class DefaultsUserInfoRepository: UserInfoRepository {
    func getUserInfo(userId: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let email = data["email"] as? String,
                  let location = data["location"] as? String,
                  let nickname = data["nickname"] as? String,
                  let longitude = data["longitude"] as? String,
                  let latitude = data["latitude"] as? String
            else {
                let error = NSError(domain: "FirestoreError", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }

            let userInfo = UserInfo(email: email, password: "", location: location, nickname: nickname, longitude: longitude, latitude: latitude)
            completion(.success(userInfo))
        }
    }

    // MARK: - 변경된 닉네임 저장
    func updateNickname(uid: String, newNickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("users").document(uid)

        userRef.updateData(["nickname": newNickname]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - 변경된 이메일을 저장
    func updateEmail(uid: String, newEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("users").document(uid)

        userRef.updateData(["email": newEmail]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
