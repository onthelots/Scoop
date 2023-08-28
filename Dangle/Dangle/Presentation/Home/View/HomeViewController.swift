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

class HomeViewController: UIViewController {

    // 뷰 모델 가져오기
    private var viewModel: HomeViewModel!

    // section 구분을 위한 선언, 각 섹션별로는 내부에 DTO 타입이 존재함
    //    private var sections = [HomeSectionType]()

    // MARK: - Section
    enum Section: CaseIterable, Hashable {
        case newIssue
        case culturalEvent
        case educationEvent

        var title: String {
            switch self {
            case .newIssue:
                return "분야별 서울 새 소식"
            case .culturalEvent:
                return "문화행사, 우리동네 즐길거리"
            case .educationEvent:
                return "교육강좌, 배우고 성장하기"
            }
        }
    }

    // MARK: - Item
    typealias Item = EventDetailDTO
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // 구독자
    private var subscription: Set<AnyCancellable> = []

    // 컬렉션뷰 -> CompositonalLayout -> sectionIndex별로 선언해두기 (createSectionLayout)
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        initalizerViewModel()
        viewModel.userInfoFetch()
        bind()

        configureCollectionView()
    }

//    private func configureCollectionView() {
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout(for: .newIssue))
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .systemBackground
//        collectionView.register(InformationCollectionViewCell.self, forCellWithReuseIdentifier: InformationCollectionViewCell.identifier)
//        collectionView.register(HomeSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderReusableView.identifier)
//        view.addSubview(collectionView)
//    }

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

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(InformationCollectionViewCell.self, forCellWithReuseIdentifier: InformationCollectionViewCell.identifier)
        collectionView.register(HomeSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderReusableView.identifier)
        view.addSubview(collectionView)

        configuration()
        // Snapshot 초기화
        applyInitialSnapshot()
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.newIssue, .culturalEvent, .educationEvent])
        snapshot.appendItems([], toSection: .newIssue)
        snapshot.appendItems([], toSection: .culturalEvent)
        snapshot.appendItems([], toSection: .educationEvent)
        dataSource.apply(snapshot)
    }

    private func configuration() {

        // Presentation 2 (Cultural, Education)
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.identifier, for: indexPath) as? InformationCollectionViewCell else {
                return nil
            }

            cell.configure(items: item)
            return cell
        })

        // HeaderView Presentaion
        dataSource.supplementaryViewProvider = { (collectionView, _, indexPath) in

            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: HomeSectionHeaderReusableView.identifier,
                                                                               for: indexPath) as? HomeSectionHeaderReusableView else {
                return nil
            }
            let allSectios = Section.allCases
            let section = allSectios[indexPath.section]
            header.configure(with: section.title)
            return header
        }
    }

    private func bind() {
        viewModel.culturalEventSubject
            .combineLatest(viewModel.educationEventSubject)
            .receive(on: RunLoop.main)
            .sink { [weak self] culturalEvent, educationEvent in
                let culturalEvents = culturalEvent.compactMap { items in
                    EventDetailDTO(title: items.title,
                                   category: items.codename,
                                   useTarget: items.useTrgt,
                                   date: items.date,
                                   location: items.place,
                                   description: items.program,
                                   thumbNail: items.mainImg,
                                   url: items.hmpgAddr)
                }
                var educationEvents: [EventDetailDTO] = []
                educationEvents = educationEvent.compactMap { items in
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
                self?.applyItem(culturalEvents: culturalEvents, educationEvents: educationEvents)
            }
            .store(in: &subscription)
    }

    private func applyItem(culturalEvents: [EventDetailDTO], educationEvents: [EventDetailDTO]) {
        var snapshot = dataSource.snapshot()

        snapshot.appendItems(culturalEvents, toSection: .culturalEvent)
        snapshot.appendItems(educationEvents, toSection: .educationEvent)

        self.dataSource.apply(snapshot)
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let section = Section.allCases[sectionIndex]
            return self.createSectionLayout(for: section)
        }
    }

    private func createSectionLayout(for section: Section) -> NSCollectionLayoutSection {

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

        switch section {
        case .newIssue:
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

        case .culturalEvent, .educationEvent:
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
        }
    }
}
