//
//  PackagesController.swift
//  TestEditor
//
//  Created by poisson florent on 09/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit
import SwiftyAttributes

class PackagesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var packageSections = Array(repeating: [PackageDirectory](), count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshRepositorySection(.applications)
        refreshRepositorySection(.libraries)
        refreshRepositorySection(.tutorials)
    }
    
    private func customize() {
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - State management
    
    fileprivate func addPackage(inRepository repository: PackageRepository) {
        if !repository.isImmutable {
            // Display creation form
            presentPackageCreationFormController(for: repository)
        }
    }
    
    fileprivate func createPackage(name: String,
                                   title: String?,
                                   description: String?,
                                   in repository: PackageRepository) {
        var package = PackageDirectory(name: name,
                                       repository: repository)
        do {
            try package.updatePackage(title: title,
                                      description: description,
                                      isImmutable: false)
        } catch let error {
            print("Error: package creation failed with error: \(error.localizedDescription)")
            displayError(title: "Package creation error!",
                         message: "Package creation failed with error: \(error)")
            return
        }
        
        // Refresh section display
        refreshRepositorySection(repository)        
    }
    
    private func confirmPackageDeletion(forRowAt indexPath: IndexPath,
                                        completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("Package deletion", comment: ""),
                                                message: NSLocalizedString("Do you confirm deletion?", comment: ""),
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel)  { (_) in
                                            completion(false)
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .default) { [weak self] (_) in
                                        completion(true)
                                        self?.deletePackage(forRowAt: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    private func deletePackage(forRowAt indexPath: IndexPath) {
        let package = packageSections[indexPath.section][indexPath.row]
        do {
            try PackageDirectory.delete(packageDirectory: package)
        } catch let error {
            print("Error: package deletion failed with error: \(error)")
            displayError(title: "Package deletion error!",
                         message: "Package deletion failed with error: \(error)")
            return
        }
        
        // Refresh section display
        let repository = PackageRepository(rawValue: indexPath.section)!
        refreshRepositorySection(repository)
    }

    private func refreshRepositorySection(_ repository: PackageRepository) {
        do {
            packageSections[repository.rawValue] = try PackageDirectory.getPackages(at: repository.url)
        } catch let error {
            print("Error: repository section refresh failed with error: \(error)")
            return
        }
        
        tableView.reloadSections([repository.rawValue],
                                 with: .automatic)
    }
    
    private func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .cancel,
                                     handler: nil)
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    // MARK: - Navigation

    private func presentPackageCreationFormController(for repository: PackageRepository) {
        let formController = storyboard?.instantiateViewController(withIdentifier: String(describing: PackageCreationFormController.self)) as! PackageCreationFormController
        
        formController.delegate = self
        formController.repository = repository
        formController.modalPresentationStyle = .overCurrentContext
        formController.modalTransitionStyle = .crossDissolve
        
        present(formController,
                animated: true,
                completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackagesToModulesSegue",
            let packageCell = sender as? PackageViewCell,
            let indexPath = tableView.indexPath(for: packageCell) {
            let modulesController = segue.destination as! ModulesController
            
            modulesController.packageRepository = PackageRepository(rawValue: indexPath.section)!
            modulesController.packageDirectory = packageSections[indexPath.section][indexPath.row]
        }
    }

}

// MARK: - UITableViewDataSource
extension PackagesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let repository = PackageRepository(rawValue: section) else {
            return 0
        }
        
        return packageSections[repository.rawValue].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repository = PackageRepository(rawValue: indexPath.section)!

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PackageViewCell.self),
                                                 for: indexPath) as! PackageViewCell
        
        let package = packageSections[repository.rawValue][indexPath.row]
        
        cell.setName(package.name)
        cell.setTitle(package.title)
        cell.setLock(repository.isImmutable || package.isImmutable)

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PackageRepository.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check for repository mutability
        let repository = PackageRepository(rawValue: indexPath.section)!
        
        if repository.isImmutable {
            return false
        }
        
        // Check for package mutability
        let package = packageSections[indexPath.section][indexPath.row]
        
        if let isImmutable = package.getInfoValue(for: .isImmutable) as? Bool,
            isImmutable {
            return false
        }

        return true
    }

}

// MARK: - UITableViewDelegate
extension PackagesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let repository = PackageRepository(rawValue: section) else {
            return nil
        }

        let headerView = PackagesSectionHeaderView()
        headerView.delegate = self
        headerView.repository = repository
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Access selected package detail
//        // ...
//    }
//    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive,
                                              title: NSLocalizedString("Delete", comment: ""),
                                              handler: { [weak self] (action, sourceView, completion) in
                                                self?.confirmPackageDeletion(forRowAt: indexPath,
                                                                             completion: completion)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - PackagesSectionHeaderViewDelegate
extension PackagesController: PackagesSectionHeaderViewDelegate {
    
    func addButtonTapped(for repository: PackageRepository) {
        addPackage(inRepository: repository)
    }

}

extension PackagesController: PackageCreationFormControllerDelegate {
    
    func userDidFillPackageForm(name: String,
                                title: String?,
                                description: String?,
                                in repository: PackageRepository) {
        createPackage(name: name,
                      title: title,
                      description: description,
                      in: repository)
    }
    
}
