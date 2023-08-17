//
//  UserDefaultsService.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

class UserDefaultsService {
    func saveCacheUserLocation(viewModel: RegionCode, key: String) {
        let defaults = UserDefaults.standard

        let encoder = JSONEncoder()
        if let encodedUserLoction = try? encoder.encode(viewModel) {
            defaults.set(encodedUserLoction, forKey: key)
            print("UserDefaults에 \(key)이름으로 저장되었습니다.")
        }

        if let savedUserData = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let saveUser = try? decoder.decode(RegionCode.self, from: savedUserData) {
                print("저장된 데이터 : \(saveUser)")
            }
        }
    }

    // Get Data
    func getCachedUserLocation(key: String) -> RegionCode? {
        if let savedUserData = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let savedUser = try? decoder.decode(RegionCode.self, from: savedUserData) {
                return savedUser
            }
        }
        return nil
    }
}
