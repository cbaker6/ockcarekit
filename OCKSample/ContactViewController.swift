//
//  ContactViewController.swift
//  OCKSample
//
//  Created by Corey Baker on 2/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CareKit

class ContactViewController:OCKListViewController{

    fileprivate var storeManager:OCKSynchronizedStoreManager!
    fileprivate weak var contactDelegate: OCKContactViewControllerDelegate?
    fileprivate var allContacts = [OCKAnyContact]()
    fileprivate var contactSegmentControl:UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        storeManager = appDelegate.synchronizedStoreManager
    
        contactSegmentControl = UISegmentedControl(items: ["All", "Doctors", "Daniels"])
        contactSegmentControl.selectedSegmentIndex = 0
        contactSegmentControl.addTarget(self, action: #selector(ContactViewController.queryForNewData(_:)), for: .valueChanged)
        
        self.clearAndKeepSegment()
        self.queryForNewData(contactSegmentControl)
    }
    
    @objc
    func queryForNewData(_ sender: UISegmentedControl) {
        
        self.clearAndKeepSegment()
        
        switch sender.selectedSegmentIndex {
        case 0:
            let query = OCKContactQuery()
            
            storeManager.store.fetchAnyContacts(query: query, callbackQueue: .main) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let contacts):
                    self.allContacts = contacts
                    self.displayContacts(self.allContacts)
                }
            }
        case 1:
            var query = OCKContactQuery()
            query.tags = [doctorTag]
            
            storeManager.store.fetchAnyContacts(query: query, callbackQueue: .main) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let contacts):
                    self.allContacts = contacts
                    self.displayContacts(self.allContacts)
                }
            }
        
        default:
            var query = OCKContactQuery()
            query.ids = ["jane"]
            
            storeManager.store.fetchAnyContacts(query: query, callbackQueue: .main) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let contacts):
                    self.allContacts = contacts
                    self.displayContacts(self.allContacts)
                }
            }
            
        }
    }
    
    func clearAndKeepSegment(){
        clear()
        self.appendView(contactSegmentControl, animated: false)
    }
    
    func displayContacts(_ contacts: [OCKAnyContact]){
        
        for contact in contacts {
            let contactViewController = OCKDetailedContactViewController(contact: contact, storeManager: self.storeManager)
            contactViewController.delegate = self.contactDelegate
            self.appendViewController(contactViewController, animated: false)
            guard let convertedContact = contact as? OCKContact,
                let tags = convertedContact.tags else{return}
            print("\(tags) for contact \(convertedContact)")
        }
    }
}

extension ContactViewController: OCKContactViewControllerDelegate{
    func contactViewController<C, VS>(_ viewController: OCKContactViewController<C, VS>, didEncounterError: Error) where C : OCKContactControllerProtocol, VS : OCKContactViewSynchronizerProtocol {
        
    }
    
}
