//
//  ViewController.swift
//  Lab_7 Gps
//

//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var current_spped: UILabel!
    @IBOutlet weak var tripStatus: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var overSpeed: UILabel!
    @IBOutlet weak var avgSpeed: UILabel!
    @IBOutlet weak var maximumAcceleration: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var speeds : [Double] = []
    var manager = CLLocationManager()
    var startDate: Date?
    var time_then: Double = 0.0
    var intial_speed = 0.0
    var max_accelerate: Double = 0.0
    var calculated_distance = 0.0
    
    override func viewDidAppear(_ animated: Bool) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        mapView.delegate = self
    }
    // sets location and gets updates render function for additional zoom
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.startUpdatingLocation()
             render (location)
        }
    }
    func maxSpeed(speeds: [Double]) {
        let new_sorted_speed_array = Array(speeds.sorted().reversed())
        if new_sorted_speed_array[0] > 115 {
            overSpeed.backgroundColor = UIColor.red
        }
        maxSpeed.text = String(format: "%.2f", new_sorted_speed_array[0]) + " km/h"
    }
    func avgSpeed(speeds: [Double]){
        let total_speed_count = speeds.count
        var sum: Double = 0.0
        for speed in speeds {
            sum += speed
        }
        let avg_speed = sum/Double(total_speed_count)
        avgSpeed.text = String(format: "%.2f", avg_speed) + " km/h"
    }
    func totalDistance(speed: Double, acceleration: Double, time: Double) {
        let acc_time_sq = (acceleration * (time * time))
        calculated_distance = (0 * time) + (0.5 * acc_time_sq )
        calculated_distance = calculated_distance / 10000
        distance.text = String(format: "%.2f", calculated_distance) + " km"
    }
    // render function sets the region and pin for orginal location
    func render (_ location: CLLocation) {
        displayCurrentSpeed(location)
        let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )
        //span settings determine how much to zoom into the map - defined details
        let span = MKCoordinateSpan(latitudeDelta: 4.9, longitudeDelta: 4.9)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation ()
        
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    func displayCurrentSpeed(_ location: CLLocation) {
        if location.speed > -1 {
            let new_speed_km_hr  = location.speed * 3.6
            speeds.append(new_speed_km_hr)
            maxAcceleration(speed: location.speed)
            maxSpeed(speeds: speeds)
            avgSpeed(speeds: speeds)
            current_spped.text = String(format: "%.2f", new_speed_km_hr) + " km/h"
            tripStatus.backgroundColor = UIColor.green
        }
    }
    func maxAcceleration(speed: Double) {
        let time_now = (startDate?.timeIntervalSinceNow ?? 0.0) * 1000
        let delta_time = time_now - time_then
        time_then = time_now
        let accelerate =  speed - intial_speed / delta_time
        totalDistance(speed: speed, acceleration: accelerate, time: time_now)
        max_accelerate = abs(max_accelerate < accelerate ? accelerate : max_accelerate)
        maximumAcceleration.text = String(format: "%.2f", max_accelerate) + " m/s^2"
        intial_speed = speed
        startDate = Date()
    }
    @IBAction func startTrip(_ sender: Any) {
        overSpeed.backgroundColor = UIColor.yellow
        manager.startUpdatingLocation()
        startDate = Date()
        time_then = (startDate?.timeIntervalSinceNow ?? 0.0) * 1000
    }
    @IBAction func stopTrip(_ sender: Any) {
        manager.stopUpdatingLocation()
        tripStatus.backgroundColor = UIColor.gray
        overSpeed.backgroundColor = UIColor.yellow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

