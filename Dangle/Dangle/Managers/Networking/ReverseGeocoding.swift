//
//  ReverseGeocoding.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//

/*
[ ] 1차 : 지역구를 기준으로 모든 행정동을 나타낸다면, 내가 위치하고 있는 '지역코드(5자리)'를 기준으로 지역코드가 모두 동일한 행정동을 Cell에 뿌림
[ ] 우선, 현재 위치를 기준으로
 */



import Foundation
import CoreLocation

class ReverseGeocoding {
    let clientID = GeocodingManager.Constants.clientID
    let clientSecret = GeocodingManager.Constants.clientSecret

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
                let result = try JSONDecoder().decode(ReverseGeocodeResponse.self, from: data)
                completion(.success(result))
                print("변환된 주소값은? : \(result)")
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
