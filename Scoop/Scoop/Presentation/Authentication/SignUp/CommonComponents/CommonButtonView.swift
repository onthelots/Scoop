//
//  CommonButtonView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import UIKit

class CommonButtonView: UIView {

    // 타이틀
    lazy var nextButton: UIButton = {
        let button = UIButton()
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        addSubview(nextButton)

        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: self.topAnchor),
            nextButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
