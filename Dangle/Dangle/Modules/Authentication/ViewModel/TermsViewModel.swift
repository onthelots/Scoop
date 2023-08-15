//
//  TermsViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//

import Foundation

class TermsViewModel {
    var terms: [TermsType] = TermsType.allCases

    func updateSelectAllButtonState() -> Bool {
        let allSelected = terms.allSatisfy { $0.isChecked }
        return allSelected
    }

    func updateNextButtonState() -> Bool {
        let allSelected = terms.allSatisfy { $0.isChecked }
        return allSelected
    }

    func toggleTerm(at index: Int) {
        terms[index].isChecked.toggle()
    }
}
