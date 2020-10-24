//
//  ShowAttractionViewController.swift
//  KodeTest
//
//  Created by Кирилл Крамар on 20.10.2020.
//  Copyright © 2020 Кирилл Крамар. All rights reserved.
//

import UIKit
import MapKit

class ShowAttractionViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var readMoreButton: UIButton!
    
    //MARK: - Public Property
    var viewModel: ShowAttractionViewModelProtocol!
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentInViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInMap" {
            guard let mapVC = segue.destination as? AttractionInMapViewController else { return }
            guard let location = sender as? LocationMap else { return }
            mapVC.location = location
        }
    }
    
    
    //MARL: - Private Methods
    private func setupContentInViews() {
        customizeBackButton()
        imageView.fetchImage(from: viewModel.getImageURLString())
        nameLabel.text = viewModel.getAttractiveName()
        descriptionLabel.text = viewModel.getDescription()
        title = viewModel.getAttractiveName()
        viewModel.nameForReadMoreButton.bind {[unowned self] (name) in
            self.readMoreButton.setTitle(name, for: .normal)
        }
        setRegion()
        createAnnotation()
    }
    
    
    private func setRegion() {
        let distanceSpan: CLLocationDistance = 1000
        let location = viewModel.getLocation()
        let locationLatLon = CLLocation(latitude: location.lat, longitude: location.lng)
        let mapCoordinates = MKCoordinateRegion(center: locationLatLon.coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
        mapView.setRegion(mapCoordinates, animated: true)
    }
    
    private func createAnnotation() {
        let annotation = MKPointAnnotation()
        let location = viewModel.getLocation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
        mapView.addAnnotation(annotation)
    }
    
    
    
    //MARK: - Selectors
    @IBAction func readMore(_ sender: Any) {
        let desc = viewModel.getDescription()
        self.descriptionLabel.text = desc
        let oldheight = descriptionLabel.frame.height
        let oldheightContentView = contentViewHeightConstraint.constant
        view.layoutIfNeeded()
        let newHeight = descriptionLabel.frame.height
        contentViewHeightConstraint.constant = oldheightContentView + newHeight - oldheight
    }
    @IBAction func showInMap(_ sender: Any) {
        let location = viewModel.getLocation()
        performSegue(withIdentifier: SegueIdentifiers.showInMap.rawValue, sender: location)
    }
    
}


