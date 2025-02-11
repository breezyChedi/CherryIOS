//
//  DegreeFilter.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/02/10.
//

// DegreeFilter.swift

// DegreeFilter.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct SubjectMark {
    let subject: String
    let mark: Int
}

class DegreeFilter {
    
    static func convertSubjPoints(pcMethod: String, mark: Int, subject: String) -> Int {
        switch pcMethod {
        case "PercNSC", "UCTFPS":
            return mark
            
        case "WitsAPS":
            if subject == "English" || subject == "Mathematics" ||
               subject == "English HL" || subject == "English FAL" {
                switch mark {
                case 90...: return 10
                case 80..<90: return 9
                case 70..<80: return 8
                case 60..<70: return 7
                case 50..<60: return 4
                case 40..<50: return 3
                default: return 0
                }
            } else if subject == "Life Orientation" {
                switch mark {
                case 90...: return 4
                case 80..<90: return 3
                case 70..<80: return 2
                case 60..<70: return 1
                default: return 0
                }
            } else {
                switch mark {
                case 90...: return 8
                case 80..<90: return 7
                case 70..<80: return 6
                case 60..<70: return 5
                case 50..<60: return 4
                case 40..<50: return 3
                default: return 0
                }
            }
            
        case "APSPlus", "UWCAPS":
            switch mark {
            case 90...: return 8
            case 80..<90: return 7
            case 70..<80: return 6
            case 60..<70: return 5
            case 50..<60: return 4
            case 40..<50: return 3
            case 30..<40: return 2
            case 20..<30: return 1
            default: return 0
            }
            
        case "APS":
            switch mark {
            case 80...: return 7
            case 70..<80: return 6
            case 60..<70: return 5
            case 50..<60: return 4
            case 40..<50: return 3
            case 30..<40: return 2
            case 20..<30: return 1
            default: return 0
            }
            
        default:
            return 0
        }
    }
    
    static func calculateTotalPoints(pcMethod: String,
                                   subjectMarks: [SubjectMark],
                                   faculty: String,
                                   nbtScores: [String: Int]) -> Int {
        switch pcMethod {
        case "PercNSC", "APS", "APSPlus", "UWCAPS":
            return subjectMarks.reduce(0) { $0 + convertSubjPoints(pcMethod: pcMethod,
                                                                 mark: $1.mark,
                                                                 subject: $1.subject) }
            
        case "UCTFPS":
            if faculty == "Health Science" {
                let subjectsTotal = subjectMarks.reduce(0) { $0 + $1.mark }
                let nbtTotal = nbtScores.values.reduce(0, +)
                return subjectsTotal + nbtTotal
            } else {
                return subjectMarks.reduce(0) { $0 + convertSubjPoints(pcMethod: pcMethod,
                                                                     mark: $1.mark,
                                                                     subject: $1.subject) }
            }
            
        case "WitsAPS":
            return subjectMarks.reduce(0) { $0 + convertSubjPoints(pcMethod: pcMethod,
                                                                 mark: $1.mark,
                                                                 subject: $1.subject) }
            
        default:
            return 0
        }
    }
    
    static func filterDegreesByEligibility(degrees: [Degree],
                                         profile: [String: Any],
                                         faculty: String) -> [Degree] {
        
        let subjectMarks = combineSubjectsAndMarks(profile: profile)
        
        let nbtScores: [String: Int] = (profile["nbtScores"] as? [String: Int]) ?? [:]
        
        return degrees.filter { degree in
            // Check subject requirements
            let subjectRequirementsMet = degree.subjectRequirements.isEmpty ||
                degree.subjectRequirements.allSatisfy { requirement in
                    guard let userMark = subjectMarks.first(where: {
                        $0.subject == requirement.subject ||
                        $0.subject == requirement.orSubject
                    }) else { return false }
                    
                    return convertSubjPoints(pcMethod: degree.pointCalculation,
                                          mark: userMark.mark,
                                          subject: userMark.subject) >= requirement.minPoints
                }
            
            if !subjectRequirementsMet { return false }
            
            // Calculate and check total points
            let totalPoints = calculateTotalPoints(pcMethod: degree.pointCalculation,
                                                subjectMarks: subjectMarks,
                                                faculty: faculty,
                                                nbtScores: nbtScores)
            
            return degree.pointRequirement.map { totalPoints >= $0 } ?? true
        }
    }
    
    static func combineSubjectsAndMarks(profile: [String: Any]) -> [SubjectMark] {
        guard let subjects = profile["subjects"] as? [String: String],
              let marks = profile["marks"] as? [String: Any] else {  // <-- Ensure marks is [String: Any]
            return []
        }
        
        return subjects.compactMap { subjectKey, subjectName in
            let markKey = subjectKey.replacingOccurrences(of: "subject", with: "mark")

            guard let markString = marks[markKey] as? NSString,  // <-- Force NSString conversion
                  let mark = markString.integerValue as Int? else {  // <-- Use .integerValue to avoid ambiguity
                return nil
            }

            return SubjectMark(subject: subjectName, mark: mark)
        }
    }


}

// Extension for ExploreViewController to use the filter
extension ExploreViewController {
    func toggleEligibilityFilter(isEnabled: Bool) {
        guard isEnabled else {
            // Reset to show all degrees
            populateDegreeCards(with: degrees)
            return
        }
        
        // Fetch current user's profile
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("profiles").document(uid).getDocument { [weak self] document, error in
            guard let profile = document?.data(),
                  let self = self,
                  let selectedUniversity = self.selectedUniversity else { return }
            
            let filteredDegrees = DegreeFilter.filterDegreesByEligibility(
                degrees: self.degrees,
                profile: profile,
                faculty: selectedUniversity.name
            )
            
            self.populateDegreeCards(with: filteredDegrees)
        }
    }
}
