//
//  DefaultsAuthRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class DefaultsAuthRepository: AuthRepository {

    // 이메일 체크
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

    // 닉네임 체크
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

    func signUp(email: String, password: String, location: String, nickname: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
                "nickname": nickname
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
}
