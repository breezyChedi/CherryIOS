//
//  ExploreViewController.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ExploreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    @IBOutlet weak var degreeScrollView: UIScrollView!
    @IBOutlet weak var degreeView: UIView!
    
    
    let pickerView = UIPickerView()
    var faculties: [Faculty] = [] // Dynamic options for faculties
        var universities: [UniversityWithFaculties] = [] // List of universities fetched
        var selectedUniversity: UniversityWithFaculties?
    var degrees: [Degree] = []
    //let options = ["Option 1", "Option 2", "Option 3", "Option 4"]
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Assign the picker as the inputView for the text field
        pickerTextField.inputView = pickerView
        
        // Add a toolbar with a Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: true)
        pickerTextField.inputAccessoryView = toolbar
        
        /*
        fetchUniversitiesViaREST { universities in
                    DispatchQueue.main.async {
                        self.populateScrollView(with: universities)
                    }
                }*/
        
        fetchUniversitiesWithFaculties { universities in
                    DispatchQueue.main.async {
                        self.universities = universities
                        self.populateScrollView(with: universities)
                    }
                }
        

        // Do any additional setup after loading the view.
    }
    
    struct FormattedRequirement {
        let subject: String
        let minPoints: Int
        let isOrGroup: Bool
    }
    
    
    @IBAction func eligibilitySwitch(_ sender: UISwitch) {
        print("Auth? \n", Auth.auth().currentUser)
        if Auth.auth().currentUser == nil {
            // User is not signed in, prevent toggling
            sender.setOn(false, animated: true)
            
            // Show alert prompting user to sign in
            let alert = UIAlertController(title: "Sign In Required",
                                          message: "You need to sign in or sign up to use this feature.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            if let viewController = sender.window?.rootViewController {
                viewController.present(alert, animated: true)
            }
        } else {
            
            UserDefaults.standard.set(sender.isOn, forKey: "eligibilitySwitchState")
            // User is authenticated, allow toggling
            toggleEligibilityFilter(isEnabled: sender.isOn)
        }
    }

    
    func formatSubjectRequirements(_ requirements: [SubjectRequirement]) -> [FormattedRequirement] {
        var processed: [FormattedRequirement] = []
        var orGroups: [String: [String: Int]] = [:]
        
        // Process each requirement
        requirements.forEach { req in
            if let orSubject = req.orSubject {
                // Sort subjects alphabetically to create a unique key
                let subjects = [req.subject, orSubject].sorted()
                let key = subjects.joined(separator: " OR ")
                
                // Handle OR groups
                if orGroups[key] == nil {
                    orGroups[key] = [req.subject: req.minPoints]
                } else {
                    orGroups[key]?[req.subject] = req.minPoints
                }
            } else {
                // Add non-OR requirements directly
                processed.append(FormattedRequirement(
                    subject: req.subject,
                    minPoints: req.minPoints,
                    isOrGroup: false
                ))
            }
        }
        
        // Process OR groups and add them to the result
        orGroups.forEach { key, requirements in
            requirements.forEach { subject, points in
                processed.append(FormattedRequirement(
                    subject: subject,
                    minPoints: points,
                    isOrGroup: true
                ))
            }
        }
        
        return processed
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1 // Single column
        }
        /*
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return options.count
        }
        
        // MARK: - UIPickerView Delegate
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return options[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            pickerTextField.text = options[row]
        }
        */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return faculties.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return faculties[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = faculties[row].name
        let selectedFaculty = faculties[row]
        //print("selection: ", selectedFaculty)

        // Call loadDegrees with a completion handler
        loadDegrees(for: selectedFaculty.id) { degrees in
            //print("Loaded degrees: \(degrees)") // Debugging output
            // If needed, update UI or state with the fetched degrees here
        }
    }

        // MARK: - Done Button Action
        @objc func doneButtonTapped() {
            pickerTextField.resignFirstResponder()
        }
    


    func populateScrollView(with universities: [UniversityWithFaculties]) {
        let cardWidth: CGFloat = 200
        let cardHeight: CGFloat = 150
        let cardSpacing: CGFloat = 16
        var cardViews: [UIView] = []

        for (index, university) in universities.enumerated() {
            let cardView = UIView(frame: CGRect(
                x: CGFloat(index) * (cardWidth + cardSpacing),
                y: 0,
                width: cardWidth,
                height: cardHeight
            ))

            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 8
            cardView.layer.borderWidth = 2
            cardView.layer.borderColor = UIColor.black.cgColor
            cardView.isUserInteractionEnabled = true
            cardView.tag = index

            // **University Logo**
            let imageView = UIImageView(frame: CGRect(x: 75, y: 8, width: 50, height: 50))
            imageView.contentMode = .scaleAspectFit
            
            
            let imageName = (university.logoUrl as NSString).lastPathComponent // Extracts "wits_logo.png"
            let imageWithoutExtension = imageName.components(separatedBy: ".").first ?? imageName // Removes ".png"

            // Load image from Assets
            imageView.image = UIImage(named: imageWithoutExtension)
            cardView.addSubview(imageView)

            // **University Name Label**
            let nameLabel = UILabel(frame: CGRect(x: 8, y: 60, width: cardWidth - 16, height: 20))
            nameLabel.text = university.name
            nameLabel.textColor = .black
            nameLabel.textAlignment = .center
            nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
            cardView.addSubview(nameLabel)

            // **Location Label**
            let locationLabel = UILabel(frame: CGRect(x: 8, y: 85, width: cardWidth - 16, height: 20))
            locationLabel.text = "📍 \(university.location)"
            locationLabel.textColor = .gray
            locationLabel.textAlignment = .center
            locationLabel.font = UIFont.systemFont(ofSize: 12)
            cardView.addSubview(locationLabel)

            // **Application Button**
            let appButton = UIButton(frame: CGRect(x: 8, y: 110, width: cardWidth - 16, height: 30))
            appButton.setTitle("Apply Now", for: .normal)
            appButton.backgroundColor = UIColor(red: 240/255.0, green: 159/255.0, blue: 230/255.0, alpha: 1.0)
            appButton.setTitleColor(.white, for: .normal)
            appButton.layer.cornerRadius = 6
            appButton.tag = index
            appButton.addTarget(self, action: #selector(applicationButtonTapped(_:)), for: .touchUpInside)
            cardView.addSubview(appButton)

            // **Tap Gesture for Card Selection**
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            tapGesture.cancelsTouchesInView = false
            cardView.addGestureRecognizer(tapGesture)
            tapGesture.require(toFail: scrollView.panGestureRecognizer)

            contentView.addSubview(cardView)
            cardViews.append(cardView)
        }

        // **Content View & ScrollView Constraints**
        let contentWidth = CGFloat(universities.count) * (cardWidth + cardSpacing)
        let contentHeight = cardHeight

        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)

        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalToConstant: contentWidth),
            contentView.heightAnchor.constraint(equalToConstant: cardHeight)
        ])

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    @objc func applicationButtonTapped(_ sender: UIButton) {
        let university = universities[sender.tag]
        if let url = URL(string: university.appUrl) {
            UIApplication.shared.open(url)
        }
    }


    
    /*
    func loadDegrees(for facultyId: Int, completion: @escaping ([Degree]) -> Void) {
        fetchDegrees(for: facultyId) { fetchedDegrees in
            DispatchQueue.main.async {
                self.degrees = fetchedDegrees
                self.populateDegreeCards(with: fetchedDegrees)
                completion(fetchedDegrees) // Pass the degrees back via completion
            }
        }
    }
*/
    /*
    func loadDegrees(for facultyId: Int, completion: @escaping ([Degree]) -> Void) {
        fetchDegrees(for: facultyId) { [weak self] fetchedDegrees in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.degrees = fetchedDegrees
                // Check if eligibility filter is enabled
                if self.eligibilitySwitch.isOn, let uid = Auth.auth().currentUser?.uid {
                    
                    // Fetch user profile and apply filtering
                    let db = Firestore.firestore()
                    db.collection("profiles").document(uid).getDocument { document, error in
                        if let profile = document?.data(),
                           let selectedUniversity = self.selectedUniversity {
                            
                            let filteredDegrees = DegreeFilter.filterDegreesByEligibility(
                                degrees: fetchedDegrees,
                                profile: profile,
                                faculty: selectedUniversity.name
                            )
                            
                            self.populateDegreeCards(with: filteredDegrees)
                            completion(filteredDegrees)
                        }
                    }
                } else {
                    // If filter is not enabled, show all degrees
                    self.populateDegreeCards(with: fetchedDegrees)
                    completion(fetchedDegrees)
                }
            }
        }
    }
*/
    
    func loadDegrees(for facultyId: Int, completion: @escaping ([Degree]) -> Void) {
        fetchDegrees(for: facultyId) { [weak self] fetchedDegrees in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.degrees = fetchedDegrees
                
                // Get the stored switch state from UserDefaults
                let isEligibilitySwitchOn = UserDefaults.standard.bool(forKey: "eligibilitySwitchState")
                
                if isEligibilitySwitchOn, let uid = Auth.auth().currentUser?.uid {
                    
                    // Fetch user profile and apply filtering
                    let db = Firestore.firestore()
                    db.collection("profiles").document(uid).getDocument { document, error in
                        if let profile = document?.data(),
                           let selectedUniversity = self.selectedUniversity {
                            
                            let filteredDegrees = DegreeFilter.filterDegreesByEligibility(
                                degrees: fetchedDegrees,
                                profile: profile,
                                faculty: selectedUniversity.name
                            )
                            
                            self.populateDegreeCards(with: filteredDegrees)
                            completion(filteredDegrees)
                        }
                    }
                } else {
                    // If filter is not enabled, show all degrees
                    self.populateDegreeCards(with: fetchedDegrees)
                    completion(fetchedDegrees)
                }
            }
        }
    }

    
    @objc func handleCardTap(_ sender: UITapGestureRecognizer) {
        print("Tapped on: \(String(describing: sender.view))")
        guard let selectedCard = sender.view else {
            print("Error: sender.view is nil")
            return }
        let selectedIndex = selectedCard.tag
                selectedUniversity = universities[selectedIndex]
                
                // Update the faculties for the selected university
                if let selectedUniversity = selectedUniversity {
                    faculties = selectedUniversity.faculties
                } else {
                    faculties = []
                }
                
                // Refresh picker data
                pickerView.reloadAllComponents()
                pickerTextField.text = nil
        
        //print("Card tapped: \(selectedCard.tag)")
        
        // Animate enlargement
        UIView.animate(withDuration: 0.3, animations: {
            for subview in self.contentView.subviews {
                if subview == selectedCard {
                    subview.frame.size = CGSize(width: 220, height: 170) // Enlarge the selected card
                    subview.frame.origin.y = -10 // Lift the card visually
                    
                    subview.layer.zPosition = 1 // Bring the card to the front
                    subview.layer.borderWidth = 2
                    subview.layer.borderColor = UIColor.black.cgColor

                } else {
                    subview.frame.size = CGSize(width: 200, height: 150) // Reset other cards
                    subview.frame.origin.y = 0
                    subview.layer.zPosition = 0
                }
            }
        })
    }
    
    
    func populateDegreeCards(with degrees: [Degree]) {
        degreeView.subviews.forEach { $0.removeFromSuperview() }

        let cardWidth: CGFloat = degreeScrollView.frame.width - 32
        let cardHeight: CGFloat = 270
        let cardSpacing: CGFloat = 12
        
        for (index, degree) in degrees.enumerated() {
            let formattedReqs = formatSubjectRequirements(degree.subjectRequirements)
            
            let cardView = UIView(frame: CGRect(
                x: 16,
                y: CGFloat(index) * (cardHeight + cardSpacing),
                width: cardWidth,
                height: cardHeight
            ))
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 8
            cardView.layer.borderWidth = 2
            cardView.layer.borderColor = UIColor(red: 229/255, green: 184/255, blue: 232/255, alpha: 1.0).cgColor
            
            // Title Label (Centered)
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 16, width: cardWidth, height: 40))
            titleLabel.text = degree.name
            titleLabel.textColor = .black
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
            titleLabel.textAlignment = .center
            cardView.addSubview(titleLabel)
            
            // APS Label (Centered)
            let apsLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY + 4, width: cardWidth, height: 20))
            apsLabel.text = "Minimum Points: \(degree.pointRequirement ?? 0)"
            apsLabel.textColor = .black
            apsLabel.font = .systemFont(ofSize: 14)
            apsLabel.textAlignment = .center
            cardView.addSubview(apsLabel)
            
            // Subject Requirements Label (Centered)
            let requirementsLabel = UILabel(frame: CGRect(x: 0, y: apsLabel.frame.maxY + 8, width: cardWidth, height: 20))
            requirementsLabel.text = "Subject Requirements:"
            requirementsLabel.textColor = .black
            requirementsLabel.font = .systemFont(ofSize: 14, weight: .bold)
            requirementsLabel.textAlignment = .center
            cardView.addSubview(requirementsLabel)
            
            // StackView for Subject Requirements
            let stackView = UIStackView(frame: CGRect(x: 16, y: requirementsLabel.frame.maxY + 8, width: cardWidth - 32, height: 100))
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .center
            
            for requirement in formattedReqs {
                let requirementLabel = UILabel()
                requirementLabel.text = "\(requirement.subject): \(requirement.minPoints)"
                requirementLabel.textColor = .black
                requirementLabel.font = .systemFont(ofSize: 14)
                stackView.addArrangedSubview(requirementLabel)
            }
            
            cardView.addSubview(stackView)
            
            // View Details Button (Centered at Bottom)
            let detailsButton = UIButton(frame: CGRect(x: 16, y: cardHeight - 50, width: cardWidth - 32, height: 40))
            detailsButton.setTitle("View Details", for: .normal)
            detailsButton.backgroundColor = UIColor(red: 229/255, green: 184/255, blue: 232/255, alpha: 1.0)
            detailsButton.setTitleColor(.white, for: .normal)
            detailsButton.layer.cornerRadius = 5
            
            detailsButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                
                let detailsVC = DegreeDetailsViewController(degree: degree)
                
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(detailsVC, animated: true)
                } else {
                    let navController = UINavigationController(rootViewController: detailsVC)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
                }
            }), for: .touchUpInside)

            cardView.addSubview(detailsButton)
            degreeView.addSubview(cardView)
        }

        let contentHeight = CGFloat(degrees.count) * (cardHeight + cardSpacing)
        degreeView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: contentHeight)
        degreeScrollView.contentSize = CGSize(width: cardWidth, height: contentHeight)
    }
    
    

}





