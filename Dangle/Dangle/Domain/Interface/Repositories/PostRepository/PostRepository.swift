//
//  PostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import CoreLocation
import UIKit
import Foundation

protocol PostRepository {
    // 주소 검색
    func searchLocation(
        query: String,
        longitude: String,
        latitude: String,
        radius: Int,
        completion: @escaping (Result<KeywordSearchResult, Error>) -> Void
    )

    // Post 등록
    func addPost(
        _ post: Post,
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 모든 Post 가져오기
    func fetchPosts(
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 카테고리 별 Post 가져오기
    func fetchPostsForCategory(
        _ category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 중심 좌표 주변의 데이터 가져오기
     func fetchPostsAroundCoordinate(
         coordinate: CLLocationCoordinate2D,
         radius: CLLocationDistance,
         completion: @escaping (Result<[Post], Error>) -> Void
     )

    // 작성한 Post 업데이트
    func updatePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 작성한 Post 삭제
    func deletePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
