//
//  CommonTextFieldView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/19.
//

import UIKit

class CommonTextFieldView: UIView {

    // 라벨
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 텍스트필드
    let textField: UnderLineTextField = {
        let textField = UnderLineTextField()
        textField.frame.size.height = 40
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.clearButtonMode = .always
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        addSubview(textLabel)
        addSubview(textField)

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            textField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
