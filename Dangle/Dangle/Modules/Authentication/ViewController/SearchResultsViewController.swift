//
//  SearchResultsViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

import UIKit

// delegate didTapResult
protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: Document)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultsViewControllerDelegate?

    private var searchResult: [Document] = []

    // MARK: - Components
    // result tableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UserLocationTableViewCell.self,
            forCellReuseIdentifier: UserLocationTableViewCell.identifier
        )
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - View Layout
    override func viewDidLayoutSubviews() {

        // tableview
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func update(with results: GeocodeResponse) {
        searchResult = results.documents
        print(searchResult)
        tableView.reloadData()
        tableView.isHidden = results.documents.isEmpty
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserLocationTableViewCell.identifier, for: indexPath) as? UserLocationTableViewCell else {
            return UITableViewCell()
        }
        let result = searchResult[indexPath.row]
        let viewModel: UserLocationViewModel = {
            if let bCode = result.address.bCode, !bCode.isEmpty,
               let hCode = result.address.hCode, !hCode.isEmpty {
                return UserLocationViewModel(code: bCode, name: result.addressName)
            } else if let bCode = result.address.bCode, !bCode.isEmpty {
                return UserLocationViewModel(code: bCode, name: result.addressName)
            } else if let hCode = result.address.hCode, !hCode.isEmpty {
                return UserLocationViewModel(code: hCode, name: result.addressName)
            } else {
                return UserLocationViewModel(code: "", name: result.addressName)
            }
        }()

        cell.configure(address: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    // 해당 row를 선택했을 때
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResult[indexPath.row]
        delegate?.didTapResult(result)
    }
}
