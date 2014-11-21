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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSegue")
        if segue.identifier == "detail" {
            let docDetailVC = (segue.destinationViewController as DocDetailViewController)

            docDetailVC.currentClinic = currentSearchResult!.clinic
            docDetailVC.currentDoctor = currentSearchResult!.doctor
            docDetailVC.currentPatient = currentPatient
        }
        else {
            println("Go to another place")
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
        clinics = Array<Clinic>()
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
                    self.reloadUIData()
                })
            }
            if doctors == nil || doctors.isEmpty {
                self.reloadUIData()
            }
        })
        //searching by specialty
        search.getClinicsBySpecialityName(searchBar.text, clinics: { (clinics : [AnyObject]!) -> Void in
            //showing wait image
            self.indicator?.hidden = false
            for cl in clinics {
                self.clinics?.append(cl as Clinic)
            }
            self.reloadUIData()
        })
        //cleaning array
        var arr = Array<Clinic>()
        var existsInArray = false
        for clinic in clinics! {
            existsInArray = false
            for c in arr {
                if clinic.name == c.name {
                    existsInArray = true
                    break
                }
            }
            if !existsInArray {
                arr.append(clinic)
            }
        }
        clinics = Array<Clinic>(arr)
    }

    //MARK: - table delegated methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        for searchResult in searchResults {
            let selectedCell = searchTable.cellForRowAtIndexPath(indexPath)

            if searchResult.doctor!.name == selectedCell?.textLabel.text && searchResult.clinic!.name == selectedCell?.detailTextLabel?.text {
                currentSearchResult = searchResult

                performSegueWithIdentifier("detail", sender: self)
                break
            }
            else {
                println("Error on segue to detail appointment for table")
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as UITableViewCell
        let searchResult = searchResults[indexPath.row]
        
        cell.textLabel.textColor = UIColor.whiteColor()
        cell.textLabel.text = searchResult.doctor?.name
        cell.detailTextLabel?.text = searchResult.clinic?.name
        return cell
    }
}