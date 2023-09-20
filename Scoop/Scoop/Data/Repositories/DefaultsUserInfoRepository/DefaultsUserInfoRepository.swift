//
//  DefaultsUserInfoRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import Firebase

class DefaultsUserInfoRepository: UserInfoRepository {
    // 유저 정보 가져오기
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

    // 변경된 닉네임 저장
    func updateNickname(uid: String, newNickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("users").document(uid)

        userRef.updateData(["nickname": newNickname]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.updatePostsForUser(uid: uid, newNickname: newNickname, completion: completion)
            }
        }
    }

    // 리뷰 업데이트
    func updatePostsForUser(uid: String, newNickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = Firestore.firestore()

        // "UserReviews" 컬렉션에서 해당 사용자(uid)가 작성한 게시물을 찾습니다.
        let query = database.collectionGroup("UserReviews")
            .whereField("authorUID", isEqualTo: uid)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            let batch = database.batch()
            for document in querySnapshot?.documents ?? [] {
                let postReference = document.reference
                batch.updateData(["nickname": newNickname], forDocument: postReference)
            }

            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // 이메일 업데이트
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

    // 유저 탈퇴(Auth, FireStore 사용자 데이터 삭제)
    func deleteUser(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = Firestore.firestore()
        let auth = Auth.auth()

        // "users" 컬렉션에서 사용자 문서 삭제
        let userRef = database.collection("users").document(uid)
        userRef.delete { userError in
            if let userError = userError {
                completion(.failure(userError))
                return
            }

            // Firebase Authentication에서 사용자 삭제
            auth.currentUser?.delete { authError in
                if let authError = authError {
                    completion(.failure(authError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
