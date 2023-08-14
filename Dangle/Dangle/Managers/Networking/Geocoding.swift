//
//  Geocoding.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/12.
//

import Foundation
import CoreLocation

class Geocoding {
    let restAPIKey = GeocodingManager.Constants.restAPIKey

    public func geocode(query: String, completion: @escaping (Result<GeocodeResponse, Error>) -> Void) {
        let urlString = "https://dapi.kakao.com/v2/local/search/address"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        var request = URLRequest(url: components.url!)

        request.addValue("KakaoAK \(restAPIKey)", forHTTPHeaderField: "Authorization")

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
                let result = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
