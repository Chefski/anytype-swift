//
//  CommonViews+Pickers+Image+UIKit.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import PhotosUI

fileprivate typealias Namespace = CommonViews.Pickers

// MARK: - FilePicker

extension Namespace {
    class Picker: UIViewController {
        var viewModel: ViewModel
        var barTintColor: UIColor?
        init(_ model: ViewModel) {
            self.viewModel = model
            super.init(nibName: nil, bundle: nil)
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Appearance
private extension Namespace.Picker {
    private func applyAppearanceForNavigationBar() {
        // Save color to reset it back later
        self.barTintColor = UINavigationBar.appearance().tintColor
        UINavigationBar.appearance().tintColor = .orange
    }
    private func resetAppearanceForNavigationBar() {
        UINavigationBar.appearance().tintColor = self.barTintColor
    }
}

// MARK: Controller
private extension Namespace.Picker {
    func createPickerController() -> UIViewController {
        var configuration: PHPickerConfiguration = .init()
        configuration.filter = self.viewModel.type.filter
        configuration.selectionLimit = 1
        let picker = PHPickerViewController.init(configuration: configuration)
        picker.delegate = self
        return picker
    }
}

// MARK: View Lifecycle
extension Namespace.Picker {
    override func viewDidLoad() {
        super.viewDidLoad()
        applyAppearanceForNavigationBar()
        embedChild(createPickerController())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyAppearanceForNavigationBar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetAppearanceForNavigationBar()
    }
}

// MARK: - ViewModel
extension Namespace.Picker {
    final class ViewModel: BaseFilePickerViewModel {
        fileprivate let type: PickerContentType
        
        init(type: PickerContentType) {
            self.type = type
        }
    }
}

// MARK: - Process
extension Namespace.Picker {
    func process(chosen itemProvider: NSItemProvider) {
        guard let identifier = itemProvider.registeredTypeIdentifiers.first else { return }
        itemProvider.loadFileRepresentation(forTypeIdentifier: identifier) { [weak self] (value, error) in
            self?.viewModel.process([value].compactMap({$0}))
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension Namespace.Picker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // do something
        /// We should load photo via item provider.
        self.dismiss(animated: true)
        if let chosen = results.first?.itemProvider {
            self.process(chosen: chosen)
        }
    }
}
