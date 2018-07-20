//
//  ModulesController.swift
//  TestEditor
//
//  Created by poisson florent on 17/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import UIKit

class ModulesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var packageRepository: PackageRepository!
    var packageDirectory: PackageDirectory! {
        didSet {
            isPackageImmutable = (packageDirectory.getInfoValue(for: .isImmutable) as? Bool) ?? false
        }
    }
    var isPackageImmutable: Bool = false
    var moduleFiles: [ModuleFile]!
    var rowCount: Int {
        return (moduleFiles?.count ?? 0)
            + (packageRepository.isImmutable || isPackageImmutable ? 0 : 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = packageDirectory.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshModules()
    }
    
    // MARK: - State management
    
    
    private func confirmModuleDeletion(forRowAt indexPath: IndexPath,
                                       completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: NSLocalizedString("Module deletion", comment: ""),
                                                message: NSLocalizedString("Do you confirm deletion?", comment: ""),
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel)  { (_) in
                                            completion(false)
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""),
                                     style: .default) { [weak self] (_) in
                                        completion(true)
                                        self?.deleteModule(forRowAt: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    private func deleteModule(forRowAt indexPath: IndexPath) {
        print("--> deleteModule")
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
    
    private func addNewModule(name: String) {
        var moduleFile = ModuleFile(packageDirectory: packageDirectory,
                                    name: name)
        do {
            try moduleFile.save(script: Script(string: ""))
        } catch let error {
            displayError(title: NSLocalizedString("Error!", comment: ""),
                         message: NSLocalizedString("New module creation failed with error: \(error.localizedDescription)",
                         comment: ""))
        }
        
        refreshModules()
    }
    
    private func refreshModules() {
        do {
            try moduleFiles = ModuleFile.getModules(of: packageDirectory)
            tableView.reloadSections([0], with: .automatic)
        } catch let error {
            displayError(title: NSLocalizedString("Error!", comment: ""),
                         message: NSLocalizedString("Modules getting failed with error: \(error.localizedDescription)", comment: ""))
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ModulesToPackageInfoSegue" {
            let navController = segue.destination as! UINavigationController
            let packageInfoController = navController.childViewControllers.first as! PackageInfoController
            packageInfoController.delegate = self
            packageInfoController.packageName = packageDirectory.name
            packageInfoController.packageTitle = packageDirectory.getInfoValue(for: .title) as? String
            packageInfoController.packageDescription = packageDirectory.getInfoValue(for: .description) as? String
            packageInfoController.packageImmutability = (packageDirectory.getInfoValue(for: .isImmutable) as? Bool) ?? false
            
        } else if segue.identifier == "ModulesToEditorSegue",
            let indexPath = sender as? IndexPath {
            let editorController = segue.destination as! EditorController
            let moduleFile = moduleFiles[indexPath.row]
            editorController.navigationItem.title = moduleFile.name
            editorController.moduleFile = moduleFile
            editorController.isImmutable = packageRepository.isImmutable || isPackageImmutable
            do {
                editorController.script = try moduleFile.getScript()
            } catch let error {
                displayError(title: NSLocalizedString("Script display error!", comment: ""),
                             message: "Script getting from module failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    private func presentModuleCreationFormController() {
        let formController = storyboard?.instantiateViewController(withIdentifier: String(describing: ModuleCreationFormController.self)) as! ModuleCreationFormController
        
        formController.delegate = self
        formController.modalPresentationStyle = .overCurrentContext
        formController.modalTransitionStyle = .crossDissolve
        
        present(formController,
                animated: true,
                completion: nil)

    }

}

// MARK: - UITableViewDataSource
extension ModulesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !(packageRepository.isImmutable || isPackageImmutable),
            indexPath.row >= rowCount - 1 {
            return tableView.dequeueReusableCell(withIdentifier: "AddModuleCell", for: indexPath)
        }
        
        let moduleFile = moduleFiles[indexPath.row]
        let moduleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ModuleViewCell.self),
                                                       for: indexPath) as! ModuleViewCell
        moduleCell.delegate = self
        moduleCell.setName(moduleFile.name + "." + ModuleFile.extension)
        moduleCell.setLock(isPackageImmutable)
        
        return moduleCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check for mutability
        if packageRepository.isImmutable || isPackageImmutable {
            return false
        }

        return true
    }
    
}

// MARK: - UITableViewDelegate
extension ModulesController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath),
            cell.reuseIdentifier == "AddModuleCell" {
            // Add new module file
            DispatchQueue.main.async {
                self.presentModuleCreationFormController()
            }
            return
        }
        
        // Access selected module script
        performSegue(withIdentifier: "ModulesToEditorSegue", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive,
                                              title: NSLocalizedString("Delete", comment: ""),
                                              handler: { [weak self] (action, sourceView, completion) in
                                                self?.confirmModuleDeletion(forRowAt: indexPath,
                                                                             completion: completion)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - PackageInfoControllerDelegate
extension ModulesController: PackageInfoControllerDelegate {
    
    func userDidUpdatePackageInfo(title: String?,
                                  description: String?,
                                  isImmutable: Bool) {
        do {
            try packageDirectory.updatePackage(title: title,
                                               description: description,
                                               isImmutable: isImmutable)
        } catch let error {
            displayError(title: NSLocalizedString("Package update error!", comment: ""),
                         message: NSLocalizedString("Package infos update failed with error: \(error.localizedDescription)", comment: ""))
        }
    }
    
}

// MARK: - ModuleCreationFormControllerDelegate
extension ModulesController: ModuleCreationFormControllerDelegate {
    
    func userDidFillModuleForm(name: String) {
        addNewModule(name: name)
    }
    
}

// MARK: - ModuleViewCellDelegate
extension ModulesController: ModuleViewCellDelegate {
    
    func userDidEditModuleName(in cell: ModuleViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        var moduleFile = moduleFiles[indexPath.row]
        
        // Get new name
        if let name = cell.nameTextField.text,
            !name.isEmpty,
            name != moduleFile.name {
            do {
                try moduleFile.rename(to: name)
                moduleFiles[indexPath.row] = moduleFile
            } catch let error {
                displayError(title: NSLocalizedString("Renaming error!", comment: ""),
                             message: NSLocalizedString("Module renaming failed with error: \(error.localizedDescription)", comment: ""))
            }
        }
        
        // Refresh name display
        cell.setName(moduleFile.name + "." + ModuleFile.extension)
    }
    
}


