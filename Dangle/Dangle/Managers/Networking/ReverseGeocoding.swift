//
//  ReverseGeocoding.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//

import Foundation
import CoreLocation

class ReverseGeocoding {
    let clientID = "6s9gpzi23j"
    let clientSecret = "CfWgGZ3jxLPoitULdZW7S9E1dMSEeo4U8C8zavYC"

    public func reverseGeocode(location: CLLocation, completion: @escaping (Result<ReverseGeocodeResponse, Error>) -> Void) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
        let coords = "\(location.coordinate.longitude),\(location.coordinate.latitude)"

        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "request", value: "coordsToaddr"),
            URLQueryItem(name: "coords", value: coords),
            URLQueryItem(name: "sourcecrs", value: "epsg:4326"),
            URLQueryItem(name: "orders", value: "admcode"),
            URLQueryItem(name: "output", value: "json")
        ]

        var request = URLRequest(url: components.url!)
        request.addValue(clientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

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
//                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                if let results = json?["results"] as? [[String: Any]],
//                   let region = results.first?["region"] as? [String: Any],
//                   let area3 = region["area3"] as? [String: Any],
//                   let name = area3["name"] as? String {
//                    completion(.success(name))
                let result = try JSONDecoder().decode(ReverseGeocodeResponse.self, from: data)
                completion(.success(result))
                print("변환된 주소값은? : \(result)")
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
