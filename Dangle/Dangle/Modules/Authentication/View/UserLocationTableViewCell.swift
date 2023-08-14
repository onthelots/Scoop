//
//  UserLocationTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import UIKit

class UserLocationTableViewCell: UITableViewCell {
    static let identifier = "UserLocationTableViewCell"

    // MARK: - Components
    private let userLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()

    // MARK: - Identifier
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(userLocationLabel)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            userLocationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            userLocationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            userLocationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userLocationLabel.text = nil
    }

    // Configure (Label)
    func configure(address: UserLocationViewModel) {
        userLocationLabel.text = address.name
    }
}
