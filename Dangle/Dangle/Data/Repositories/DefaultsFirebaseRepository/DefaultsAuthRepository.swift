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
    func signUp(email: String, password: String, location: String, completion: @escaping (Result<AuthUser, Error>) -> Void) {
        checkEmailExists(email: email) { [weak self] exists in
            guard let self = self else { return }

            if exists {
                print("Email already exists")
                // 중복된 이메일 코드 처리
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                    guard self != nil else { return }

                    if let error = error {
                        print("Error : \(error)")
                        return
                    }

                    guard let uid = result?.user.uid else {
                        print("User UID not found")
                        return
                    }

                    // Firestore에 사용자 정보 저장
                    let database = Firestore.firestore()
                    database.collection("users").document(uid).setData([
                        "email": email,
                        "location": location
                    ]) { error in
                        if let error = error {
                            print("Error saving user info to Firestore: \(error)")
                        } else {
                            print("User info saved successfully")
                        }
                    }

                }
            }
        }

    }

    func checkEmailExists(email: String, completion: @escaping (Bool) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email exists: \(error)")
                completion(false)
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
