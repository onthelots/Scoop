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
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    // MARK: - Identifier
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    // Configure (Label)
    func configure(address: UserLocationViewModel) {
        label.text = "\(address.sido) \(address.siGunGu) \(address.eupMyeonDong) \(address.ri)"
    }
}
