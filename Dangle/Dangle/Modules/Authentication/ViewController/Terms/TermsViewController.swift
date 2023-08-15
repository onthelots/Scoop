//
//  TermsViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//

import UIKit

class TermsViewController: UIViewController {

    lazy var selectAllStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var selectAllButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected) // Set selected image
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var selectAllLabel: UILabel = {
        let label = UILabel()
        label.text = "약관 전체동의"
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var tableView: UITableView = {
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

    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("동의하고 진행하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "서비스 이용약관"
        navigationItem.largeTitleDisplayMode = .always
        view.addSubview(selectAllStackView)
        selectAllStackView.addArrangedSubview(selectAllButton)
        selectAllStackView.addArrangedSubview(selectAllLabel)
        view.addSubview(separatorView)
        view.addSubview(tableView)
        view.addSubview(nextButton)
        selectAllButton.addTarget(self, action: #selector(selectAllButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(selectNextButtonTapped), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            selectAllStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectAllStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: selectAllStackView.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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

    @objc func selectAllButtonTapped() {
        let allSelected = !TermsType.allCases.contains { termType in
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.isCheckedKey(for: termType))
        }
        for termType in TermsType.allCases {
            UserDefaults.standard.set(allSelected, forKey: UserDefaultsKeys.isCheckedKey(for: termType))
        }
        tableView.reloadData()
        selectAllButton.isSelected = allSelected
        selectAllButton.setImage(allSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal) // Update the image based on selected state
        updateNextButtonState()
    }

    @objc func selectNextButtonTapped() {
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }

    // 전체 동의버튼을 눌렀을 시
    func updateSelectAllButtonState() {
        // allSeceted 는 TermsType enum의 모든 조건을 만족하는데,
        let allSelected = TermsType.allCases.allSatisfy { termType in
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.isCheckedKey(for: termType))
        }
        // allSelected 상태(toogle)에 따라 setImage를 다르게 변경함
        selectAllButton.isSelected = allSelected
        selectAllButton.setImage(allSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle"), for: .normal)
    }

    // 다음으로 넘어가는 버튼 (전체가 모두 동의되어 있어야, Tap 액션ㄴ이 활성화됨)
    func updateNextButtonState() {
        let allSelected = !TermsType.allCases.contains { !$0.isChecked }
        if allSelected {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .tintColor
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .gray // Set to gray when not all terms are checked
        }
    }}

extension TermsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TermsType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TermsTableViewCell.identifier, for: indexPath) as? TermsTableViewCell else {
            return UITableViewCell()
        }
        let termType = TermsType.allCases[indexPath.row]
        cell.configure(with: termType)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let termType = TermsType.allCases[indexPath.row]
        let termsDetailViewController = TermsDetailViewController()

        // 선택된 termType의 데이터를 넘김
        termsDetailViewController.termType = termType
        navigationController?.pushViewController(termsDetailViewController, animated: true)
    }
}

extension TermsViewController: TermsTableViewCellDelegate {
    func termsCheckBoxStateChanged(_ termType: TermsType, isChecked: Bool) {
        UserDefaults.standard.set(isChecked, forKey: UserDefaultsKeys.isCheckedKey(for: termType))
        updateNextButtonState()
        updateSelectAllButtonState()
    }
}
