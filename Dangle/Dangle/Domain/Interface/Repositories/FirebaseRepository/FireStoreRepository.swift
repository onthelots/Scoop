//
//  FireStoreRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import Foundation
import FirebaseFirestore

protocol FireStoreRepository {
    func saveUserData(uid: String, email: String, nickname: String, location: String, completion: @escaping (Result<Void, Error>) -> Void) // 데이터 저장하기
}
