//
//  NewIssueCategoryView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit

protocol NewIssueCategoryViewDelegate: AnyObject {
    func categoryLabelTapped(_ gesture: UITapGestureRecognizer)
}

class NewIssueCategoryView: UIView {

    weak var delegate: NewIssueCategoryViewDelegate?
    let categories: [BlogName] = [.traffic, .safe, .house, .economy, .environment]

    var state: BlogName = .traffic

    // MARK: - Components
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let seperatedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .tintColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        addSubview(stackView)
        addSubview(seperatedLineView)
        categoryConfigure()
        update(for: state)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func categoryConfigure() {
        for category in categories {
            let categoryLabel = UILabel() // 라벨을 각각 생성
            categoryLabel.text = category.rawValue
            categoryLabel.textColor = .lightGray
            categoryLabel.textAlignment = .center
            categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            categoryLabel.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryLabelTapped(_:)))
            categoryLabel.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(categoryLabel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func update(for state: BlogName) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
            self.updateCategoryLabels()
        }
    }

    func layoutIndicator() {
         guard let selectedLabel = stackView.arrangedSubviews.first(where: { ($0 as? UILabel)?.text == state.rawValue }) else {
             return
         }

        indicatorView.removeFromSuperview() // 뷰 중복 방지
        addSubview(indicatorView) // 뷰를 새롭게 할당
        
         NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 3.5),
            indicatorView.widthAnchor.constraint(equalTo: selectedLabel.widthAnchor, multiplier: 0.5),
            indicatorView.centerXAnchor.constraint(equalTo: selectedLabel.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: selectedLabel.bottomAnchor, constant: 5.0),

            seperatedLineView.topAnchor.constraint(equalTo: selectedLabel.bottomAnchor, constant: 6.0),
            seperatedLineView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 1.0),
            seperatedLineView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)

         ])

         layoutIfNeeded()
     }

    func updateCategoryLabels() {
         for case let categoryLabel as UILabel in stackView.arrangedSubviews {
             if categoryLabel.text == state.rawValue {
                 categoryLabel.textColor = .tintColor
                 categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
             } else {
                 categoryLabel.textColor = .lightGray
             }
         }
     }

    @objc private func categoryLabelTapped(_ gesture: UITapGestureRecognizer) {
            delegate?.categoryLabelTapped(gesture)
    }
}
