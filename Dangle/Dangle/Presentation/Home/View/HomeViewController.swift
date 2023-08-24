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
    private var viewModel: HomeViewModel!

    private var culturalEventItems: [CulturalEventDetail] = []
    private var educationEventItmes: [EducationEventDetail] = []

    // section 구분을 위한 선언, 각 섹션별로는 내부에 DTO 타입이 존재함
    private var sections = [HomeSectionType]()

    private var subscription: Set<AnyCancellable> = []

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            return createSectionLayout(section: sectionIndex)
        }
    )

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "안녕하세요"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground

        let localEventUseCase = DefaultLocalEventUseCase(
            localEventRepository: DefaultsLocalEventRepository(
                networkManager: NetworkService(configuration: .default),
                seoulOpenDataManager: SeoulOpenDataMaanger()
            )
        )
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        viewModel = HomeViewModel(localEventUseCase: localEventUseCase, userInfoUseCase: userInfoUseCase)

        viewModel.userInfoFetch() // userInfo에 데이터 할당
        configureCollectionView()
        bind() // 전달된 퍼블리셔를 구독(sink)하여 할당함
        configureModels(cultural: self.culturalEventItems, education: self.educationEventItmes)
    }

    // MARK: - bind(데이터 받아오고 저장하기)
    private func bind() {

        // 바인드해서, 여기서 viewModeld의 패치 메서드를 구독자로?
        viewModel.$userInfo
            .sink { [weak self] userInfo in
                guard let self = self, let location = userInfo?.location else {
                    return
                }
                self.viewModel.culturalEventFetch(location: location)
                self.viewModel.educationEventFetch(location: location)
            }.store(in: &subscription)

        viewModel.culturalEventSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] culturalEvent in
                self?.culturalEventItems = culturalEvent
                self?.collectionView.reloadData()
            }
            .store(in: &subscription)

        viewModel.educationEventSubject
             .receive(on: RunLoop.main)
             .sink { [weak self] educationEvent in
                 self?.educationEventItmes = educationEvent
                 self?.collectionView.reloadData()
             }
             .store(in: &subscription)
    }

    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)

        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        collectionView.register(
            NewIssueCollectionViewCell.self,
            forCellWithReuseIdentifier: NewIssueCollectionViewCell.identifier
        )

        collectionView.register(
            InformationCollectionViewCell.self,
            forCellWithReuseIdentifier: InformationCollectionViewCell.identifier
        )

        // headerview(ReusableView)
        collectionView.register(TitleHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }

    // MARK: - ConfigureModel -> Section 값들 설정
    private func configureModels(cultural: [CulturalEventDetail], education: [EducationEventDetail]) {

        self.culturalEventItems = cultural
        self.educationEventItmes = education

        // Section 1
        sections.append(.culturalEvent(viewModels: cultural.compactMap({ item in
            return CultureEventDTO(
                title: item.title,
                time: item.date,
                location: item.place,
                thumbNail: item.mainImg
            )
        })))

        // Section 2
        sections.append(.educationEvent(viewModels: education.compactMap({ item in
            return EducationEventDTO(
                title: item.svcnm,
                time: item.dtlcont,
                location: item.placenm,
                thumbNail: item.imgurl
            )
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
        case .culturalEvent(viewModels: let event):
            return event.count
        case .educationEvent(viewModels: let event):
            return event.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let type = sections[indexPath.section]

        switch type {
        case .culturalEvent(viewModels: let event):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayCollectionViewCell.identifier, for: indexPath) as? TodayCollectionViewCell else {
                return UICollectionViewCell()
            }

            let event = event[indexPath.item]
            cell.configure(item: event)
            return cell

        case .educationEvent(viewModels: let event):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewIssueCollectionViewCell.identifier, for: indexPath) as? NewIssueCollectionViewCell else {
                return UICollectionViewCell()
            }

            let event = event[indexPath.item]
            cell.configure(item: event)
            return cell
        }
    }

    // setting headerView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
                                                                           for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
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

            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .estimated(150))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                 repeatingSubitem: item,
                                                                 count: 1)
            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                             heightDimension: .estimated(150))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 2)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section

        case 1:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .absolute(160))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                                     repeatingSubitem: item,
                                                                     count: 2)

            let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                             heightDimension: .absolute(320))
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                     repeatingSubitem: verticalGroup,
                                                                     count: 1)

            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)

            return section

        // Mock-up
        default:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                         repeatingSubitem: item,
                                                         count: 1)
            let section = NSCollectionLayoutSection(group: group)

            return section
        }
    }
}

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableView"

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(sectionTitleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            sectionTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // 재사용 되기전에 초기화
        sectionTitleLabel.text = nil
    }

    func configure(with title: String) {
        sectionTitleLabel.text = title
    }
}
