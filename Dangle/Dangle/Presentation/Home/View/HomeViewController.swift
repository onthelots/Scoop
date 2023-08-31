//
//  HomeViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Combine
import UIKit
import Firebase

class HomeViewController: UIViewController {

    private var viewModel: HomeViewModel!

    private lazy var newIssueCategoryView: NewIssueCategoryView = {
        let categoryView = NewIssueCategoryView()
        categoryView.delegate = self
        return categoryView
    }()

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
    enum Item: Hashable {
        case newIssue(NewIssueDTO)
        case event(EventDetailDTO)
    }

    // MARK: - DataSource (3개의 섹션, 2개의 아이템)
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // 구독자
    private var subscription: Set<AnyCancellable> = []

    // 컬렉션뷰 -> CompositonalLayout
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

    // ViewModel 초기화
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

        // Cell 및 ReusableView 등록
        collectionView.register(InformationCollectionViewCell.self, forCellWithReuseIdentifier: InformationCollectionViewCell.identifier)
        collectionView.register(NewIssueCollectionViewCell.self, forCellWithReuseIdentifier: NewIssueCollectionViewCell.identifier)
        collectionView.register(HomeSectionHeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HomeSectionHeaderReusableView.identifier)
        view.addSubview(collectionView)
        configuration()
        applyInitialSnapshot()
    }

    // Snapshot 초기화
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.newIssue, .culturalEvent, .educationEvent])
        dataSource.apply(snapshot) // 섹션만 추가하고 아이템은 추가하지 않음
    }

    private func getCategoryCode(for categoryName: String) -> String? {
        switch categoryName {
        case "경제":
            return "24"
        case "교통":
            return "21"
        case "안전":
            return "22"
        case "주택":
            return "23"
        case "환경":
            return "25"
        default:
            return nil
        }
    }

    private func configuration() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .event(let eventItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.identifier, for: indexPath) as? InformationCollectionViewCell else {
                    return nil
                }
                cell.configure(items: eventItem)
                cell.backgroundColor = .systemGray6
                cell.layer.cornerRadius = 5
                cell.layer.masksToBounds = true
                return cell
            case .newIssue(let newIssueItem):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewIssueCollectionViewCell.identifier, for: indexPath) as? NewIssueCollectionViewCell else {
                    return nil
                }
                cell.configure(items: newIssueItem)
                cell.backgroundColor = .systemGray6
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 0 {
                    guard let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: HomeSectionHeaderReusableView.identifier,
                        for: indexPath) as? HomeSectionHeaderReusableView else {
                        return UICollectionViewCell()
                    }

                    // 카테고리 Bar 할당
                    header.categoryBar = self.newIssueCategoryView
                    let allSections = Section.allCases
                    let section = allSections[indexPath.section]
                    header.configure(with: section.title)
                    return header
                } else {
                    guard let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: HomeSectionHeaderReusableView.identifier,
                        for: indexPath) as? HomeSectionHeaderReusableView else {
                        return nil
                    }
                    let allSections = Section.allCases
                    let section = allSections[indexPath.section]
                    header.configure(with: section.title)
                    return header
                }
            } else {
                return nil
            }
        }
        collectionView.delegate = self
    }

    // Data binding
    private func bind() {
        viewModel.newIssueSubject
            .combineLatest(viewModel.culturalEventSubject, viewModel.educationEventSubject)
            .receive(on: RunLoop.main)
            .sink { [weak self] newIssue, culturalEvent, educationEvent in
                var newIssues: [NewIssueDTO] = []
                newIssues = newIssue.compactMap { items in
                    NewIssueDTO(
                        blogId: items.blogID,
                        title: items.postTitle,
                        category: items.blogName.rawValue,
                        thumbURL: items.thumbURI,
                        excerpt: items.postExcerpt,
                        publishDate: items.publishDate,
                        modifyDate: items.modifyDate,
                        postContent: items.postContent,
                        managerDept: items.managerDept
                    )
                }
                var culturalEvents: [EventDetailDTO] = []
                culturalEvents = culturalEvent.compactMap { items in
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
                self?.applyItem(newIssues: newIssues, culturalEvents: culturalEvents, educationEvents: educationEvents)
            }
            .store(in: &subscription)

        viewModel.itemTapped
            .sink { item in
                switch item {
                case .newIssue(let newIssue): break
//                    let viewController = EventDetailViewController(eventDetailItem: item)
//                    viewController.navigationItem.largeTitleDisplayMode = .never
//                    self.navigationController?.pushViewController(viewController, animated: true)
                case .event(let event):
                    let viewController = EventDetailViewController(eventDetailItem: event)
                    viewController.navigationItem.largeTitleDisplayMode = .never
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }.store(in: &subscription)
    }

    // Item 할당 (to dataSource)
    private func applyItem(newIssues: [NewIssueDTO], culturalEvents: [EventDetailDTO], educationEvents: [EventDetailDTO]) {
        var snapshot = dataSource.snapshot()

        // 중복 아이템 필터링
        let newIssuesToAdd = newIssues.filter { newItem in
            !snapshot.itemIdentifiers.contains { item in
                if case .newIssue(let existingItem) = item, existingItem == newItem {
                    return true
                }
                return false
            }
        }
        let culturalEventsToAdd = culturalEvents.filter { newEvent in
            !snapshot.itemIdentifiers.contains { item in
                if case .event(let existingEvent) = item, existingEvent == newEvent {
                    return true
                }
                return false
            }
        }
        let educationEventsToAdd = educationEvents.filter { newEvent in
            !snapshot.itemIdentifiers.contains { item in
                if case .event(let existingEvent) = item, existingEvent == newEvent {
                    return true
                }
                return false
            }
        }

        // 필터링한 아이템들을 스냅샷에 추가
        snapshot.appendItems(newIssuesToAdd.map { Item.newIssue($0) }, toSection: .newIssue)
        snapshot.appendItems(culturalEventsToAdd.map { Item.event($0) }, toSection: .culturalEvent)
        snapshot.appendItems(educationEventsToAdd.map { Item.event($0) }, toSection: .educationEvent)

        // 새로운 스냅샷을 적용
        self.dataSource.apply(snapshot)
    }


    // MARK: - CollectionView Layout (2가지 Case)
    private func layout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]
            if section == .newIssue {
                return self.createNewIssueSectionLayout()
            } else {
                return self.createSectionLayout()
            }
        }
    }

    // Layout1 ->0번째 Section
    private func createNewIssueSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(30)) // Adjust the height as needed
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 5)

        let sectionLayout = NSCollectionLayoutSection(group: group)

        sectionLayout.boundarySupplementaryItems = [createIssueSectionHeader()]
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        return sectionLayout
    }

    // Layout2 -> 1, 2번째 Section
    private func createSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75),
                                                         heightDimension: .estimated(140))
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 1)

        let sectionLayout = NSCollectionLayoutSection(group: horizontalGroup)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        sectionLayout.boundarySupplementaryItems = [createSectionHeader()]
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return sectionLayout
    }

    private func createIssueSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(120)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }


    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch selectedItem {
        case .event(let eventItem):
            viewModel.itemTapped.send(.event(eventItem))
        case .newIssue(let newIssueItem):
            viewModel.itemTapped.send(.newIssue(newIssueItem))
            print("선택된 Item --> : \(newIssueItem.title)")
        }
    }
}

extension HomeViewController: NewIssueCategoryViewDelegate {
    func categoryLabelTapped(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel,
           let categoryCode = getCategoryCode(for: label.text ?? "") {
            self.viewModel.selectedCategory = categoryCode

            var snapshot = dataSource.snapshot()
            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .newIssue))
            dataSource.apply(snapshot)
        }
    }
}
