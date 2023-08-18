//
//  UserDefaultStorage.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

class UserDefaultStorage<T: Codable> {
    func saveCache(entity: T, key: String) {
        let defaults = UserDefaults.standard

        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(entity) {
            defaults.set(encodedData, forKey: key)
            print("UserDefaults에 \(key) 이름으로 저장되었습니다.")
        }
    }

    func getCached(key: String) -> T? {
        if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let savedEntity = try? decoder.decode(T.self, from: savedData) {
                return savedEntity
            }
        }
        return nil
    }
}
