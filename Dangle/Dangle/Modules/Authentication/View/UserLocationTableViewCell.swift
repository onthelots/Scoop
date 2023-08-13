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
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .darkGray
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    private let userLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
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
            userLocationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            userLocationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userLocationLabel.text = nil
    }

    // Configure (Label)
    func configure(address: UserLocationViewModel) {
        userLocationLabel.text = "\(address.sido) \(address.siGunGu) \(address.eupMyeonDong)"
    }
}
