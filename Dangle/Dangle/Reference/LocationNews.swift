//
//  LocationNews.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//

import Foundation
import CoreLocation

class LocationNews {
    let clientID = "PJ_nG__tPPelC23zHFJf"
    let clientSecret = "rUp9uO24zZ"

    public func getLocationNews(location: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://openapi.naver.com/v1/search/news.json"

        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "query", value: location),
            URLQueryItem(name: "display", value: "10"),
            URLQueryItem(name: "start", value: "1"),
            URLQueryItem(name: "sort", value: "sim")
        ]

        var request = URLRequest(url: components.url!)
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")

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
                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print(json)
//                let result = try JSONDecoder().decode(ReverseGeocodeResponse.self, from: data)
//                completion(.success(result))
//                print("변환된 주소값은? : \(result)")
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
