//
//  DefaultsAuthRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

class DefaultsAuthRepository: AuthRepository {

    // MARK: - 이메일 체크
    func checkEmail(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // MARK: - snapshot이 중복되는 경우인가, 그렇지 않은 경우인가??
            if let documents = snapshot?.documents, !documents.isEmpty {
                completion(.success(true))
                print("이메일이 중복됩니다.")
            } else {
                completion(.success(false))
                print("이메일이 중복되지 않습니다.")
            }
        }
    }

    // MARK: - 닉네임 체크
    func checkNickname(nickname: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").whereField("nickname", isEqualTo: nickname).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // MARK: - snapshot이 중복되는 경우인가, 그렇지 않은 경우인가??
            if let documents = snapshot?.documents, !documents.isEmpty {
                completion(.success(true))
                print("닉네임이 중복됩니다.")
            } else {
                completion(.success(false))
                print("닉네임이 중복되지 않습니다.")
            }
        }
    }

    // MARK: - 회원가입
    func signUp(email: String, password: String, location: String, nickname: String, longitude: String, latitude: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard self != nil else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                print("uid가 동일하지 않습니다.")
                return
            }

            // Firestore에 사용자 정보 저장
            let database = Firestore.firestore()
            database.collection("users").document(uid).setData([
                "email": email,
                "location": location,
                "nickname": nickname,
                "longitude": longitude,
                "latitude": latitude
            ]) { error in
                if let error = error {
                    print("Error saving user info to Firestore: \(error)")
                    completion(.failure(error))
                } else {
                    print("User info saved successfully")
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - 로그인
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
          Auth.auth().signIn(withEmail: email, password: password) { result, error in
              if let error = error {
                  completion(.failure(error))
              } else if let user = result?.user {
                  let userModel = User(uid: user.uid, email: user.email ?? "")
                  completion(.success(userModel))
              } else {
                  let unknownError = NSError(domain: "Unknown Error", code: 0, userInfo: nil)
                  completion(.failure(unknownError))
              }
          }
      }
}
