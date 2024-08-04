//
//  RealmManager.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 8/4/24.
//

import Foundation

// MARK: - RealmManager
class RealmManager {

    // singleton
    static let shared = RealmManager()

    var realmConfigurations: [String: Realm.Configuration] = [:]

    private init() { }

    // MARK: - 마이그레이션이 필요한 경우
    // Storage name의 경우, 다중 로그인을 위해 활용됨
    // 각각의 userId (Primary key)를 기반으로, DB 저장 로직을 수행할 것 (폴더링) 
    func realmConfiguration(forStorageName storageName: String) -> Realm.Configuration {
        if let existingConfiguration = realmConfigurations[storageName] {
            return existingConfiguration
        }

        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(storageName).realm")

        // 새로운 스키마 버전 설정 (예를 들어 이전 버전이 0이라면 새 버전은 1로 설정)
        // MARK: - schemaVersion update (v1.0.8)
        let schemaVersion: UInt64 = 1

        let configuration = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: schemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                print("Old Schema Version: \(oldSchemaVersion)")
                print("Update to Migartion Schema Version: \(migration)")
            }
        )
        realmConfigurations[storageName] = configuration
        return configuration
    }

    // realm DB 폴더 링크
    func realm(forStorageName storageName: String) -> Realm {
        let configuration = realmConfiguration(forStorageName: storageName)
        do {
            return try Realm(configuration: configuration)
        } catch {
            fatalError("Failed to create Realm instance: \(error)")
        }
    }

    // MARK: - Create
    func createObject<T: Object>(storageName: String, object: T) {
        let realm = realm(forStorageName: storageName)
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Failed to create object: \(error)")
        }
    }

    // MARK: - Read
    func getObject<T: Object>(storageName: String, ofType type: T.Type) -> Results<T> {
        let realm = realm(forStorageName: storageName)
        return realm.objects(type)
    }

    // MARK: - Update
    func updateObject<T: Object>(storageName: String, object: T) {
        let realm = realm(forStorageName: storageName)

        guard let primaryKey = T.primaryKey() else {
            print("Primary key is not defined for the object type \(T.self)")
            return
        }

        let existingObject = realm.object(ofType: T.self, forPrimaryKey: object[primaryKey])

        do {
            try realm.write {
                if let existingObject = existingObject {
                    realm.delete(existingObject) // Delete the existing object
                }
                // Add the updated object
                realm.add(object, update: .modified)
            }
        } catch {
            print("Failed to update object: \(error)")
        }
    }


    // MARK: - Delete
    func deleteObject<T: Object>(storageName: String, object: T) {
        let realm = realm(forStorageName: storageName)
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Failed to delete object: \(error)")
        }
    }

    // MARK: - Delete All Object
    func deleteObjects<T: Object>(storageName: String, objects: Results<T>) {
        let realm = realm(forStorageName: storageName)
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            print("Failed to delete objects: \(error)")
        }
    }

    func deleteRealmFiles(forUserId userId: String) {
        // Remove the main realm file and its auxiliary files
        let realmURL = realmConfiguration(forStorageName: userId).fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("management")
        ]

        for URL in realmURLs {
            if FileManager.default.fileExists(atPath: URL.path) {
                do {
                    // Remove the file
                    try FileManager.default.removeItem(at: URL)
                    print("Successfully deleted file at \(URL)")
                } catch {
                    print("Failed to delete file at \(URL): \(error)")
                }
            } else {
                print("No file exists at \(URL), no need to delete")
            }
        }

        // Remove the configuration from the cache
        realmConfigurations.removeValue(forKey: userId)
    }
}
