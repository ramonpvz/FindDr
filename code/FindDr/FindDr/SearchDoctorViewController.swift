//
//  SearchDoctorViewController.swift
//  FindDr
//
//  Created by eduardo milpas diaz on 11/13/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

import UIKit

class SearchDoctorViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate  {

    //MARK: - overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: quitar estos dummy
        let doc1 = Doctor()
        let doc2 = Doctor()
        let doc3 = Doctor()

        let s1 = Speciality()
        let s2 = Speciality()
        let s3 = Speciality()

        s1.name = "podologo"
        s1.name = "proctologo"
        s1.name = "oncologo"

        let specialties = [s1, s2, s3]


        doc1.name = "house"
        doc1.lastName = "britoni"
        doc1.secondLastName = "unknown"
        doc1.title = "Specialist"
        doc1.email = "house@bbc.com"
        doc1.licence = "876123"
        //doc1.specialities = specialties

        doc2.name = "Selene"
        doc2.lastName = "Milpas"
        doc2.secondLastName = "Diaz"
        doc2.title = "Oncologist"
        doc2.email = "pollo@gmail.com"
        doc2.licence = "87623423"

        doc3.name = "cachetes"
        doc3.lastName = "detras"
        doc3.secondLastName = "unknown"
        doc3.title = "proctologo"
        doc3.email = "cacheton@bbc.com"
        doc3.licence = "87sad6123"

        dummyDocDB = [doc1, doc2, doc3]
        
        //starting view
        searchMapView.hidden = false
        searchTable.hidden   = true

        searchBar.delegate = self

    }

    //MARK: - class properties
    var doctors : Array<Doctor>?
    var dummyDocDB : Array<Doctor>?

    //MARK: - view properties
    @IBOutlet var searchMapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchTable: UITableView!

    //MARK: - view actions
    @IBAction func changeView(sender: UISegmentedControl) {
        let MAP  = 0
        let LIST = 1

        if sender.selectedSegmentIndex == MAP {
            searchMapView.hidden = false
            searchTable.hidden   = true
        }
        else {
            searchMapView.hidden = true
            searchTable.hidden   = false
        }
    }

    //MARK: - SearchBar delegated methods
    func filterContentForSearchText(searchText: String?) {
        if searchText == nil || searchText!.isEmpty {
            doctors?.removeAll(keepCapacity: false)
        }
        // Filter the array using the filter method
        doctors = dummyDocDB?.filter({ (doctor : Doctor) -> Bool in
            if doctor.name.lowercaseString.rangeOfString(searchText!.lowercaseString) != nil ||
               doctor.lastName.lowercaseString.rangeOfString(searchText!.lowercaseString) != nil ||
            doctor.secondLastName.lowercaseString.rangeOfString(searchText!.lowercaseString) != nil
            {
                return true
            }

            return false
        })
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) { // called when text changes (including clear) {
        filterContentForSearchText(searchText)
        searchTable.reloadData()
    }

    //MARK: - table delegated methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors != nil ? doctors!.count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as UITableViewCell

        let doctor = doctors?[indexPath.row]

        let name = doctor?.name != nil ? doctor!.name : ""
        let lastName = doctor?.lastName != nil ? doctor!.lastName : ""
        let secondLastName = doctor?.secondLastName != nil ? doctor!.secondLastName : ""
        var specialtiesCad = "Specialties: "

//TODO: 
//        doctor?.getSpecialities({ (specialties : [AnyObject]!) -> Void in
//            var sp : Speciality?
//            var specialtiesCad = "Specialties: "
//            for specialty in specialties {
//                sp = (specialty as Speciality)
//                specialtiesCad = "\(specialtiesCad) \(sp?.name),"
//            }
//        })

        cell.textLabel.text = "\(name) \(lastName) \(secondLastName)"
        cell.detailTextLabel?.text = specialtiesCad
        return cell
    }


}
