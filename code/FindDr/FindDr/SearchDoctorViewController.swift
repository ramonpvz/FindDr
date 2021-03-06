//
//  SearchDoctorViewController.swift
//  FindDr
//
//  Created by eduardo milpas diaz on 11/13/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

import UIKit

class SearchDoctorViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate, CLLocationManagerDelegate  {

    //MARK: - overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //starting variables
        locationManager = CLLocationManager()
        //spinner to indicate waiting
        self.indicator?.startAnimating()
        self.indicator?.hidden = true
        //starting view
        searchMapView.hidden = false
        searchTable.hidden   = true
        searchBar.delegate = self
        locationManager?.delegate = self
        //locate user's position
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        //set pacient logged
        Patient.getPatientByUser(PFUser.currentUser(), pat: { (patient : Patient!) -> Void in
            self.currentPatient = patient
        })

        let imageLogout = UIImage(named: "Logout-32")
        let logoutButton = UIBarButtonItem(image: imageLogout, style: .Plain, target: self, action: "doLogout")
        self.navigationItem.rightBarButtonItem = logoutButton;
        self.navigationItem.hidesBackButton = true;
    }

    func doLogout() {
        performSegueWithIdentifier("logout", sender:nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSegue")
        if segue.identifier == "detail" {
            let docDetailVC = (segue.destinationViewController as DocDetailViewController)

            docDetailVC.currentClinic = currentSearchResult!.clinic
            docDetailVC.currentDoctor = currentSearchResult!.doctor
            docDetailVC.currentPatient = currentPatient
        }
        else if segue.identifier == "tableDetailSegue" {

            for searchResult in searchResults {
                let selectedCell = searchTable.cellForRowAtIndexPath(searchTable.indexPathForSelectedRow()!)
                println("\(searchResult.doctor!.name) == \(selectedCell?.textLabel.text) && \(searchResult.clinic!.name) == \(selectedCell?.detailTextLabel?.text)")
                if searchResult.doctor!.name == selectedCell?.textLabel.text && searchResult.clinic!.name == selectedCell?.detailTextLabel?.text {
                    currentSearchResult = searchResult
                    let docDetailVC = (segue.destinationViewController as DocDetailViewController)

                    docDetailVC.currentClinic = searchResult.clinic
                    docDetailVC.currentDoctor = searchResult.doctor
                    docDetailVC.currentPatient = currentPatient

                    break
                }
                else {
                    println("Error on segue to detail appointment for table")
                }
            }
        }
        else {
            println("Go to another place: \(segue.identifier)")
        }
    }



    //MARK: - class properties
    var doctors : Array<Doctor>?
    var clinics : Array<Clinic>?
    var locationManager : CLLocationManager?
    var searchResults = Array<SearchResult>()
    var currentDoctor : Doctor?
    var currentClinic : Clinic?
    var currentPatient : Patient?
    var currentSearchResult : SearchResult?
    //MARK: - view properties
    @IBOutlet var searchMapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchTable: UITableView!
    @IBOutlet var indicator: UIActivityIndicatorView!
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

    //MARK: - class methods

    func centerMapOnMyPosition(latitude : CDouble, longitude : CDouble) {
        //center pin
        let SPAN = 0.1
        let span = MKCoordinateSpan(latitudeDelta: SPAN, longitudeDelta: SPAN)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)

        searchMapView.setRegion(region, animated: true)
        //adding pin on my position
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()

        annotation.coordinate = location;
        annotation.title = "Me"
        annotation.subtitle = "This is where I am located"

        searchMapView.addAnnotation(annotation)
    }

    func markMap() {
        for searchResult in searchResults {
            let latitude = (searchResult.clinic!.latitude as NSString).doubleValue
            let longitude = (searchResult.clinic!.longitude as NSString).doubleValue

            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()

            annotation.coordinate = location;
            annotation.title = searchResult.doctor!.name
            annotation.subtitle = searchResult.clinic!.name

            searchMapView.addAnnotation(annotation)
        }
    }

    func reloadUIData() {
        //cleaning array
        var arr = Array<SearchResult>()
        var existsInArray = false
        for searchResult in searchResults {
            existsInArray = false
            for c in arr {
                if searchResult.clinic?.name == c.clinic?.name && searchResult.doctor?.name == c.doctor?.name {
                    existsInArray = true
                    break
                }
            }
            if !existsInArray {
                arr.append(searchResult)
            }
        }
        searchResults = Array<SearchResult>(arr)
        //hidding wait image and cleaning table results
        self.indicator?.hidden = true
        self.searchTable.reloadData()//printing results in table view
        self.markMap()
    }

    //MARK: - MAP delegated methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
        //adding properties
        pin.canShowCallout = true
        pin.highlighted = true
        pin.pinColor = MKPinAnnotationColor.Red

        if annotation.title == "Me" {
            pin.pinColor = MKPinAnnotationColor.Purple
        }
        else {
            pin.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
        }
        return pin
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        for searchResult in searchResults {
            //            println("\(searchResult.doctor!.name) == \(view.annotation.title) && \(searchResult.clinic!.name) == \(view.annotation.subtitle)")
            if searchResult.doctor!.name == view.annotation.title && searchResult.clinic!.name == view.annotation.subtitle {
                currentSearchResult = searchResult

                performSegueWithIdentifier("detail", sender: self)
                break
            }
            else {
                println("Error on segue to detail appointment")
            }
        }
    }

    //MARK: - Location delegated methods
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location: " + error.localizedDescription)
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.locationManager?.stopUpdatingLocation()
                self.centerMapOnMyPosition(pm.location.coordinate.latitude, longitude: pm.location.coordinate.longitude)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }

    //MARK: - search Bar delegated methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { // called when keyboard search button pressed
        let search = Search()
        //cleaning map and table
        searchResults = Array<SearchResult>()
        searchMapView.removeAnnotations(searchMapView.annotations)
        locationManager?.startUpdatingLocation()
        //searching by doctor name
        search.getDoctorsByName(searchBar.text, apps: { (doctors : [AnyObject]!) -> Void in
            //showing wait image
            self.indicator?.hidden = false
            for doc in doctors {
                search.loadClinics(doc as Doctor, results: { (clinicas : [AnyObject]!) -> Void in
                    self.clinics = Array<Clinic>()
                    for clinic in clinicas {
                        var searchResult = SearchResult()
                        searchResult.clinic = (clinic as Clinic)
                        searchResult.doctor = (doc as Doctor)

                        self.searchResults.append(searchResult)
                    }
                })
            }
            //searching by specialty
            search.getClinicsBySpecialityName(searchBar.text, clinics: { (clinics : [AnyObject]!) -> Void in
                for cl in clinics {
                    search.getDoctorsByClinicId((cl as Clinic).objectId, apps: { (doctors : [AnyObject]!) -> Void in
                        if !doctors.isEmpty {
                            var searchResult = SearchResult()
                            searchResult.clinic = (cl as Clinic)
                            searchResult.doctor = (doctors[0] as Doctor)//correct this for multiple doctors in 1 clinic
                            self.searchResults.append(searchResult)

                            self.reloadUIData()
                        }
                        else {
                            self.reloadUIData()
                        }
                    })
                }
                if(clinics == nil || clinics.isEmpty) {
                    self.reloadUIData()
                }
            })
        })
    }

    //MARK: - table delegated methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as UITableViewCell
        let searchResult = searchResults[indexPath.row]

        cell.textLabel.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        cell.textLabel.text = searchResult.doctor?.name
        cell.detailTextLabel?.text = searchResult.clinic?.name
        return cell
    }
}