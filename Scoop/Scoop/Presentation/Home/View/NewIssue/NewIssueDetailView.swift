//
//  NewIssueDetailView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Kingfisher

class NewIssueDetailView: UIView {

    // MARK: - Components
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var manageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var manageDept: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dotLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "•"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var manageName: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var publishDate: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var modifyDate: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let seperatedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var postContentLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        manageStackView.addArrangedSubview(manageDept)
        manageStackView.addArrangedSubview(dotLabel)
        manageStackView.addArrangedSubview(manageName)
        dateStackView.addArrangedSubview(publishDate)
        dateStackView.addArrangedSubview(modifyDate)
        addSubview(titleLabel)
        addSubview(manageStackView)
        addSubview(dateStackView)
        addSubview(seperatedLineView)
        addSubview(postContentLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            manageStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            manageStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            dateStackView.topAnchor.constraint(equalTo: manageStackView.bottomAnchor, constant: 10),
            dateStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            seperatedLineView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 15),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 3),
            seperatedLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            postContentLabel.topAnchor.constraint(equalTo: seperatedLineView.bottomAnchor, constant: 15),
            postContentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            postContentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            postContentLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10)
        ])
    }

    func configure(newIssueDTO: NewIssueDTO) {
        self.titleLabel.text = newIssueDTO.title
        self.manageDept.text = newIssueDTO.managerDept
        self.manageName.text = newIssueDTO.managerName
        self.publishDate.text = "입력 \(newIssueDTO.publishDate)"
        self.modifyDate.text = "수정 \(newIssueDTO.modifyDate)"
        self.postContentLabel.text = newIssueDTO.attributedContent.string
    }
}
