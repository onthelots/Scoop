//
//  RegionCodeManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

import Foundation
import CoreLocation

class RegionCodeManager {
    let restAPIKey = "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes"

    public func convertCodeToRegionName(code: String, completion: @escaping (Result<RegionCodeResponse, Error>) -> Void) {

        let regionCode: String = maskLastFiveCharacters(of: code)
        let urlString = restAPIKey
        var components = URLComponents(string: urlString)!

        components.queryItems = [
            URLQueryItem(name: "regcode_pattern", value: regionCode),
            URLQueryItem(name: "is_ignore_zero", value: "true")
        ]
        let request = URLRequest(url: components.url!)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.app", code: 0, userInfo: nil)))
                return
            }
            do {
                let result = try JSONDecoder().decode(RegionCodeResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    // wildcard Pattern을 통해 뒷 5자리 대체하기
    private func maskLastFiveCharacters(of input: String) -> String {
        guard input.count >= 5 else {
            return input
        }

        let startIndex = input.index(input.endIndex, offsetBy: -5)
        let maskedSubstring = String(repeating: "*", count: 5)

        return input.replacingCharacters(in: startIndex..<input.endIndex, with: maskedSubstring)
    }
}
