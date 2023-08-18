//
//  TermsViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//
//
import UIKit
import Combine

class TermsViewController: UIViewController {

    private var viewModel = TermsViewModel()
    private var subscription = Set<AnyCancellable>()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "서비스 이용약관을 확인해주세요"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        return label
    }()

    private lazy var selectAllStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var selectAllButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var selectAllLabel: UILabel = {
        let label = UILabel()
        label.text = "약관 전체동의"
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(
            TermsTableViewCell.self,
            forCellReuseIdentifier: TermsTableViewCell.identifier
        )
        return tableView
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("동의하고 진행하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // 초기 값은, 비 활성화 상태
        return button
    }()

    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            resetAllTerms()
        }
    }

    // MARK: - viewDidLoda()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()

        view.addSubview(titleLabel)
        view.addSubview(selectAllStackView)
        selectAllStackView.addArrangedSubview(selectAllButton)
        selectAllStackView.addArrangedSubview(selectAllLabel)

        view.addSubview(separatorView)
        view.addSubview(tableView)
        view.addSubview(nextButton)

        // 전체 선택 버튼
        selectAllButton.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)

        // 다음 뷰로 넘어가는 버튼
        nextButton.addTarget(self, action: #selector(selectNextButtonTapped), for: .touchUpInside)

        tableView.delegate = self
        tableView.dataSource = self

        bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            selectAllStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            selectAllStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: selectAllStackView.bottomAnchor, constant: 15),
            separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1.0)
        ])

        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 50).withPriority(.defaultLow),
            nextButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 10),
            nextButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).withPriority(.required)
        ])
    }

    private func bind() {
        // MARK: - ViewModel 업데이트
        viewModel.$terms
            .sink { [weak self] _ in
                self?.updateNextButtonState() // nextButtonState 상태 업데이트
                self?.viewModel.printDebugInfo() // 디버깅
                self?.tableView.reloadData()
            }
            .store(in: &subscription)

        viewModel.itemTapped
            .sink { items in
                let viewController = TermsDetailViewController()
                viewController.termType = items
                viewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)
    }

    // NextButton의 상태를 업데이트
    private func updateNextButtonState() {
        if viewModel.isAllSelected {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .tintColor
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray
        }
    }

    // Allbutton을 업데이트
    private func updateAllButtonImage(isSelected: Bool) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = isSelected ? UIImage(systemName: "checkmark.circle.fill", withConfiguration: imageConfig) : UIImage(systemName: "checkmark.circle", withConfiguration: imageConfig)
        selectAllButton.setImage(image, for: .normal)
    }

    // 이전 뷰로 이동했을 때, 전체 약관값을 false로 변경
    private func resetAllTerms() {
        for index in viewModel.terms.indices {
            viewModel.terms[index].isChecked = false
        }

        updateAllButtonImage(isSelected: false) // 이미지 변경
    }

    // AllButton을 눌렀을 때 -> 모든 약관의 상태를 토글함 (이는, isAllselected의 업데이트 값에 따라 변경)
    @objc private func selectAllButtonTapped() {

        // 각각의 약관의 isChekced 상태를 업데이트 (모두 true로 변경하거나, false로 변경하거나)
        viewModel.toggleAllTerms(isSelected: !viewModel.isAllSelected)

        // 전체 선택버튼의 상태도 업데이트
        selectAllButton.isSelected = viewModel.isAllSelected

        updateAllButtonImage(isSelected: viewModel.isAllSelected)
    }

    // Navgiation Push
    @objc private func selectNextButtonTapped() {
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

extension TermsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.terms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TermsTableViewCell.identifier, for: indexPath) as? TermsTableViewCell else {
            return UITableViewCell()
        }

        let termType = viewModel.terms[indexPath.row]
        cell.configure(with: termType) // 셀을 구성하는 코드 추가
        cell.delegate = self // 이 부분을 추가해주세요.
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let termType = viewModel.terms[indexPath.row]
        viewModel.itemTapped.send(termType)
    }
}

extension TermsViewController: TermsTableViewCellDelegate {
    func termsCheckBoxStateChanged(_ termType: TermsType, isChecked: Bool) {
        viewModel.toggleTerm(for: termType)
        updateNextButtonState()
    }
}
