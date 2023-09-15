//
//  PostRepository.swift
//  Scoop
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
        images: [UIImage],
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 중심 좌표 주변의 데이터 가져오기
    func fetchPostsAroundCoordinate(
        category: PostCategory,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 해당 점포의 리뷰 가져오기
    func fetchPostsStore(
        storeName: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 유저가 작성한 게시물 가져오기
    func fetchUserPosts(
        uid: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 작성한 Post 업데이트
    func updatePost(
        _ post: Post,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 작성한 Post 삭제
    func deletePost(
        storeName: String,
        nickname: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
