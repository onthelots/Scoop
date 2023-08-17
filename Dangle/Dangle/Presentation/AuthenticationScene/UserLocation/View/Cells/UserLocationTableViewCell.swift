//
//  UserLocationTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import UIKit

class UserLocationTableViewCell: UITableViewCell {

    static let identifier = "UserLocationTableViewCell"

    // 주소를 표시할 레이블
    lazy var userLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()

    // 초기화 및 UI 설정
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(userLocationLabel)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 레이아웃 설정
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            userLocationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            userLocationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userLocationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    // 셀 재사용 시 호출되는 메서드로 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        userLocationLabel.text = nil
    }

    // 셀에 주소 정보 표시
    func configure(address: Regcode) {
        userLocationLabel.text = address.name
    }
}
