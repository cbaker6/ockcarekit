//
//  PatientViewController.swift
//  OCKSample
//
//  Created by Corey Baker on 2/21/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CareKit

class PatientViewController:UITableViewController{

    fileprivate var storeManager:OCKSynchronizedStoreManager!
    fileprivate var allPatients = [OCKAnyPatient]()
    fileprivate var modified = false
    fileprivate var patientSegmentControl:UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        storeManager = appDelegate.synchronizedStoreManager
    
        patientSegmentControl = UISegmentedControl(items: ["All Patients", "Latest Patient"])
        patientSegmentControl.selectedSegmentIndex = 1
        patientSegmentControl.addTarget(self, action: #selector(PatientViewController.queryForNewData(_:)), for: .valueChanged)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "patientCell")
        self.queryForNewData(patientSegmentControl)

    }
    
    @objc
    func queryForNewData(_ sender: UISegmentedControl) {
        
        //self.clearAndKeepSegment()
        var query = OCKPatientQuery()
        
        switch sender.selectedSegmentIndex {
        case 0:
            print("Get all patients...")
        case 1:
            query = OCKPatientQuery(for: Date())
            query.ids = [patientId]
        default:
            print("Not implemented")
            
        }

        storeManager.store.fetchAnyPatients(query: query, callbackQueue: .main) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let patients):
                self.allPatients = patients
                self.tableView.reloadData()
                //self.displayPatients(self.allPatients)
            }
        }
    }
    
    func updatePatient(_ patient: OCKPatient){
        
        //Only make 1 modification to prevent infinite loop
        if modified{
            return
        }else{
            modified = true
        }
        
        var mutablePatient = patient
        mutablePatient.name.givenName!.append("s")
        
        storeManager.store.updateAnyPatient(mutablePatient, callbackQueue: .main){
            result in
            
            switch result{
                
            case .success(_):
                self.tableView.reloadData()
            case .failure(let error):
                print("Couldn't update \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPatients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "patientCell")
        
        let patient = self.allPatients[indexPath.row]
        updatePatient(patient as! OCKPatient)
        cell.textLabel?.text = patient.name.givenName
        cell.detailTextLabel?.text = patient.name.familyName
        
        return cell
    }

}


