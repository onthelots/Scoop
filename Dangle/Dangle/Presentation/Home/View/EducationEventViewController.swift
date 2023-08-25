//
//  EducationEventViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit

class EducationEventViewController: UIViewController {

    private let educationEvent: EducationEventDTO

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    init(educationEvent: EducationEventDTO) {
        self.educationEvent = educationEvent
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
