//
//  CulturalEventViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit

class CulturalEventViewController: UIViewController {

    private let cultuarlEvent: CultureEventDTO

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    init(cultuarlEvent: CultureEventDTO) {
        self.cultuarlEvent = cultuarlEvent
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
