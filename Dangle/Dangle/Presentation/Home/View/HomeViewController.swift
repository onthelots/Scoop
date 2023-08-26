//
//  HomeViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

/*
 [ ] CollectionView 형식에 따라,

 */

import Combine
import UIKit
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController {

    // 뷰 모델 가져오기
    private var viewModel: HomeViewModel!

    // MOCK-UP
    private var newIssueItems: [DangleIssueDTO] = DangleIssueDTO.mock

    // section 구분을 위한 선언, 각 섹션별로는 내부에 DTO 타입이 존재함
    private var sections = [HomeSectionType]()

    // 구독자
    private var subscription: Set<AnyCancellable> = []

    // 컬렉션뷰 -> CompositonalLayout -> sectionIndex별로 선언해두기 (createSectionLayout)
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return createSectionLayout(section: sectionIndex)
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        initalizerViewModel()
        configureCollectionView()
        viewModel.userInfoFetch()
        bind()
    }

    // 1. viewModel 초기화
    private func initalizerViewModel() {
        let localEventUseCase = DefaultLocalEventUseCase(
            localEventRepository: DefaultsLocalEventRepository(
                networkManager: NetworkService(configuration: .default),
                seoulOpenDataManager: SeoulOpenDataMaanger()
            )
        )
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        viewModel = HomeViewModel(localEventUseCase: localEventUseCase, userInfoUseCase: userInfoUseCase)
    }

    // 3. bind
    private func bind() {
        // 3-2. 문화 퍼블리셔와 교육 퍼블리셔를 함께 구독, viewcontroller에서 사용할 데이터에 전달
        viewModel.culturalEventSubject
            .combineLatest(viewModel.educationEventSubject)
            .receive(on: RunLoop.main)
            .sink { [weak self] culturalEvent, educationEvent in
                let culturalEventItems = culturalEvent.map { items in
                    EventDetailDTO(title: items.title,
                                   category: items.codename,
                                   useTarget: items.useTrgt,
                                   date: items.date,
                                   location: items.place,
                                   description: items.program,
                                   thumbNail: items.mainImg,
                                   url: items.hmpgAddr)
                }

                self?.sections.append(.culturalEvent(viewModels: culturalEventItems)) // section에도 데이터 전달하기

                // 빈 배열에 데이터 할당하기
                let educationEventItems = educationEvent.compactMap { items in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"

                    if let startDate = dateFormatter.date(from: items.svcopnbgndt),
                       let endDate = dateFormatter.date(from: items.svcopnenddt) {
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        return EventDetailDTO(
                            title: items.svcnm,
                            category: items.maxclassnm,
                            useTarget: items.usetgtinfo,
                            date: "\(dateFormatter.string(from: startDate))~\(dateFormatter.string(from: endDate))",
                            location: items.placenm,
                            description: items.dtlcont,
                            thumbNail: items.imgurl,
                            url: items.svcurl)
                    }
                    return nil
                }
                self?.sections.append(.educationEvent(viewModels: educationEventItems)) // section에도 데이터 전달하기

                self?.collectionView.reloadData() // 데이터를 받아온 후에 리로드
            }
            .store(in: &subscription)

        // 빈 배열에 데이터 할당하기
        self.configureModels(newIssue: self.newIssueItems)

    }

    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // 컬렉션뷰 선언
    private func configureCollectionView() {
        view.addSubview(collectionView)

        collectionView.register(
            NewIssueCollectionViewCell.self,
            forCellWithReuseIdentifier: NewIssueCollectionViewCell.identifier
        )

        collectionView.register(
            InformationCollectionViewCell.self,
            forCellWithReuseIdentifier: InformationCollectionViewCell.identifier
        )

        // headerview(ReusableView)
        collectionView.register(HomeSectionHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HomeSectionHeaderReusableView.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }

    // MARK: - newIssue 임시 파싱
    private func configureModels(newIssue: [DangleIssueDTO]) {
        // Section 1
        sections.append(.newIssue(viewModels: newIssue.compactMap({ item in
            return DangleIssueDTO(
                category: item.category,
                description: item.description,
                location: item.location,
                thumbNail: item.thumbNail)
        })))

        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]

        switch type {
        case .newIssue(viewModels: let event):
            return event.count
        case .culturalEvent(viewModels: let event):
            return event.count
        case .educationEvent(viewModels: let event):
            return event.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let type = sections[indexPath.section]

        switch type {
        case .newIssue(viewModels: let event):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewIssueCollectionViewCell.identifier, for: indexPath) as? NewIssueCollectionViewCell else {
                return UICollectionViewCell()
            }

            let event = event[indexPath.item]
            cell.configure(item: DangleIssueDTO(
                category: event.category,
                description: event.description,
                location: event.location,
                thumbNail: event.thumbNail
            ))
            
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemGray5
            return cell

        case .culturalEvent(viewModels: let event):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.identifier, for: indexPath) as? InformationCollectionViewCell else {
                return UICollectionViewCell()
            }

            let event = event[indexPath.item]
            cell.configure(title: event.title, period: event.date, location: event.location, thumbnail: event.thumbNail ?? "")
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemGray5
            return cell

        case .educationEvent(viewModels: let event):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.identifier, for: indexPath) as? InformationCollectionViewCell else {
                return UICollectionViewCell()
            }

            let event = event[indexPath.item]
            cell.configure(title: event.title, period: event.date, location: event.location, thumbnail: event.thumbNail ?? "")
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemGray5
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case .newIssue(let items):
            let item = items[indexPath.item]
            
        case .culturalEvent(let items):
            let item = items[indexPath.item]
            let viewController = EventDetailViewController(eventDetailItem: item)
            viewController.title = item.title
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(viewController, animated: true)

        case .educationEvent(let items):
            let item = items[indexPath.item]
            let viewController = EventDetailViewController(eventDetailItem: item)
            viewController.title = item.title
            viewController.hidesBottomBarWhenPushed = true
            viewController.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(viewController, animated: true)
        }
    }


    // setting headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: HomeSectionHeaderReusableView.identifier,
                                                                           for: indexPath) as? HomeSectionHeaderReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let model = sections[section].title
        header.configure(with: model)
        return header
    }

    // MARK: - createSectionLayout
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {

        // header Layout
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]

        // Secton Layout
        switch section {

        case 0:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                             heightDimension: .estimated(140))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 1)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section

        case 1:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75),
                                                             heightDimension: .estimated(140))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 1)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section

        case 2:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75),
                                                             heightDimension: .estimated(140))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 1)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section

        // Mock-up
        default:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                             heightDimension: .estimated(100))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 2)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section
        }
    }
}
