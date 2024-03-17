import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Connecting all the logo and required labels from the main.storyboard
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    
    // Initializing the variables
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var startLocation: CLLocation?
    var tripStarted = false
    var totalDistance: Double = 0.0
    var maxSpeed: Double = 0.0
    var avgSpeed: Double = 0.0
    var maxAcceleration: Double = 0.0
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Setting userlocation true for visibility
        mapView.showsUserLocation = true
        
        // Setting the top bar background color clear when initialize
        topBar.backgroundColor = UIColor.clear
    }
    
    // Called this function when user click on starttrip button
    @IBAction func startTripButtonTapped(_ sender: Any) {
        // Took flag when trip started
        tripStarted = true
        startLocation = locationManager.location
        mapView.showsUserLocation = true
        previousLocation = startLocation
        // Location gets update at every point by start updating method
        locationManager.startUpdatingLocation()
        //Reset all label to its initial value if clicked again
        totalDistance = 0.0
        maxSpeed = 0.0
        avgSpeed = 0.0
        maxAcceleration = 0.0
        currentSpeedLabel.text = "-"
        maxSpeedLabel.text = "0.0 km/h"
        avgSpeedLabel.text = "0.0 km/h"
        distanceLabel.text = "0.0 km"
        maxAccelerationLabel.text = "0.0 m/s^2"
        
        //Trip started so change the background color of bottom bar to green and top to clear
        topBar.backgroundColor = UIColor.clear
        bottomBar.backgroundColor = UIColor.green
    }
    
    // Called this function when user click on stoptrip button
    @IBAction func stopTripButtonTapped(_ sender: Any) {
        // Set the flag to false
        tripStarted = false
        // Stop updating the location when clicked on stoptrip button
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        
        // Change the color of top bar to clear and bottom to gray
        topBar.backgroundColor = UIColor.clear
        bottomBar.backgroundColor = UIColor.gray
    }
    
    // This function called at every moment when trip started
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            self.currentLocation = currentLocation
            
            if tripStarted {
                // Called all other methods which are made below to update the values of labels
                updateSpeedLabels()
                updateDistanceLabels()
                updateAccelerationLabels()
                updateMapView()
                updateKmBeforeLimit()
            }
        }
    }
    
    // Calculate the speed and update it in the label
    func updateSpeedLabels() {
        topBar.backgroundColor = UIColor.clear
        if let currentLocation = currentLocation {
            let speed = currentLocation.speed * 3.6
            // Change the value upto 1 decimal place
            currentSpeedLabel.text = String(format: "%.1f km/h", speed)
            
            // Check of speed greater than max speed and update value of maxspeed accordingly
            if speed > maxSpeed {
                maxSpeed = speed
                maxSpeedLabel.text = String(format: "%.1f km/h", maxSpeed)
            }
            
            // Check for speed greater than 115 km/h than change top bar background color to red
            if speed > 115{
                topBar.backgroundColor = UIColor.red
            }
            
            // Calculate the average speed if total distance is greater than 0
            if totalDistance > 0 {
                avgSpeed = (avgSpeed * totalDistance + speed * currentLocation.distance(from: startLocation!)) / (totalDistance + currentLocation.distance(from: startLocation!))
            } else {
                avgSpeed = 0
            }
            
            avgSpeedLabel.text = String(format: "%.1f km/h", avgSpeed)
        }
    }
    
    // Change the distance label when trip started
    func updateDistanceLabels() {
        if let currentLocation = currentLocation {
            totalDistance += currentLocation.distance(from: previousLocation!)
            distanceLabel.text = String(format: "%.1f km", totalDistance / 1000)
        }
    }
    
    // Change the acceleration label when trip started
    func updateAccelerationLabels() {
        if let currentLocation = currentLocation, let previousLocation = previousLocation {
            // Calculate acceleration using below formula
            let acceleration = (currentLocation.speed * 3.6 - previousLocation.speed * 3.6) / 2.0
            if abs(acceleration) > maxAcceleration {
                maxAcceleration = abs(acceleration)
                maxAccelerationLabel.text = String(format: "%.1f m/s^2", maxAcceleration)
            }
        }
    }
    
    // Update the map view and get the live location accordingly
    func updateMapView() {
        if let currentLocation = currentLocation {
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Calucate the distance travelled before speed reached 115km/hr
    func updateKmBeforeLimit() {
        if let currentLocation = currentLocation {
            if currentLocation.speed * 3.6 < 115 {
                topBar.backgroundColor = UIColor.clear
                let distanceToLimit = totalDistance/1000
                let roundedVal = round(distanceToLimit * 10) / 10.0
                
                // Print the value in the log with the distance covered before reaching 115km/hr
                print("Distance travelled before exceeding speed limit of 115 km/h: \(roundedVal)")}
            else {
                topBar.backgroundColor = UIColor.red
                }
        }
    }
    
    // Called when any error occurs in the program
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
}
