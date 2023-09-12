//
//  Dangle++Bundle.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Foundation

extension Bundle {
    var kakaoAPI: String {
        guard let file = self.path(forResource: "DangleInfo", ofType: "plist") else { return ""}
        guard let resource = NSDictionary(contentsOfFile: file) else { return ""}
        guard let key = resource["KAKAO_API_KEY"] as? String else { fatalError("DangleInfo.plist에 KAKAO_API_KEY를 설정해주세요.")}
        return key
    }

    var seoulAPI: String {
        guard let file = self.path(forResource: "DangleInfo", ofType: "plist") else { return ""}
        guard let resource = NSDictionary(contentsOfFile: file) else { return ""}
        guard let key = resource["SEOUL_API_KEY"] as? String else { fatalError("DangleInfo.plist에 SEOUL_API_KEY를 설정해주세요.")}
        return key
    }
}
