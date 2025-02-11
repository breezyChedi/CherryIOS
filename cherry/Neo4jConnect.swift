//
//  Neo4jConnect.swift
//  cherry
//
//  Created by Tyrone Kasi on 2025/01/22.
//

struct University {
    let name: String
    let location: String
}

struct Degree {
    let id: Int
    let name: String
    let description: String
    let subjectRequirements: [SubjectRequirement]
    let pointRequirement: Int?
    let pointCalculation: String
}

struct SubjectRequirement {
    let minPoints: Int
    let orSubject: String?
    let subject: String
}


//"neo4j+s://1172d0e4.databases.neo4j.io", port: 7687, username: "neo4j", password: "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s"
import Foundation

//import Bolt // Or the library you choose for Neo4j queries
import Theo
/*
func fetchUniversities(completion: @escaping ([University]) -> Void) {
    print("unis fetched")
    // Initialize Theo Client
    let client: BoltClient
    do {
        client = try BoltClient(
            hostname: "neo4j+s://1172d0e4.databases.neo4j.io",
            port: 7687,
            username: "neo4j",
            password: "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s",
            encrypted: true
        )
        print("Client initialized successfully.")

            try client.connect()
            print("Connection established.")
    } catch {
        print("Failed to initialize BoltClient: \(error)")
        completion([]) // Return an empty array if client initialization fails
        return
    }
    
    // Cypher Query
    let query = "MATCH (u:University) RETURN u.name AS name, u.location AS location"
    
    // Execute Cypher Query
    client.executeCypher(query) { result in
        DispatchQueue.main.async {
            switch result {
            case .success(let (_, queryResult)):
                //print("success:", result)
                var universities: [University] = []
                
                // Parse Results
                for row in queryResult.rows {
                    if let name = row["name"] as? String,
                       let location = row["location"] as? String {
                        universities.append(University(name: name, location: location))
                    }
                }
                
                // Return Universities via Completion Handler
                completion(universities)
                
            case .failure(let error):
                print("Error while executing Cypher: \(error)")
                print(result)
                completion([]) // Return an empty array if query execution fails
            }
        }
    }
}
*/

func fetchUniversitiesViaREST(completion: @escaping ([University]) -> Void) {
    // Specify the URL for the /query/v2 endpoint
    guard let url = URL(string: "https://1172d0e4.databases.neo4j.io/db/neo4j/query/v2") else {
        print("Invalid URL")
        completion([])
        return
    }

    // Basic Authentication
    let username = "neo4j"
    let password = "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s"
    let credentials = "\(username):\(password)"
    let basicAuth = Data(credentials.utf8).base64EncodedString()

    // Configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Cypher query payload with proper structure
    let queryPayload = """
    {
        "statement": "MATCH (u:University) RETURN u.name AS name, u.location AS location",
        "parameters": {}
    }
    """
    request.httpBody = queryPayload.data(using: .utf8)

    // Execute the HTTP request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed: \(error)")
            completion([])
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("No response received")
            completion([])
            return
        }

        if !(200...299).contains(httpResponse.statusCode) {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            completion([])
            return
        }

        guard let data = data else {
            print("No data received")
            completion([])
            return
        }

        // Parse the JSON response
        do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response JSON: \(json)")

                    var universities: [University] = []

                    if let dict = json as? [String: Any],
                       let dataDict = dict["data"] as? [String: Any],
                       let values = dataDict["values"] as? [[Any]] {
                        
                        for value in values {
                            if let name = value[0] as? String, let location = value[1] as? String {
                                universities.append(University(name: name, location: location))
                            }
                        }
                    }

            // Pass the parsed universities back via the completion handler
            completion(universities)
        } catch {
            print("Error parsing JSON: \(error)")
            completion([])
        }
    }.resume()
}

func fetchFacultiesForUniversity(universityId: String, completion: @escaping ([String]) -> Void) {
    // Specify the URL for the /query/v2 endpoint
    guard let url = URL(string: "https://1172d0e4.databases.neo4j.io/db/neo4j/query/v2") else {
        print("Invalid URL")
        completion([])
        return
    }

    // Basic Authentication
    let username = "neo4j"
    let password = "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s"
    let credentials = "\(username):\(password)"
    let basicAuth = Data(credentials.utf8).base64EncodedString()

    // Configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Cypher query payload to get faculties associated with a specific university
    let queryPayload = """
    {
        "statement": "MATCH (u:University)-[:HAS_FACULTY]->(f:Faculty) WHERE id(u) = $universityId RETURN f.name AS name ORDER BY f.name",
        "parameters": {
            "universityId": "\(universityId)"
        }
    }
    """
    request.httpBody = queryPayload.data(using: .utf8)

    // Execute the HTTP request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed: \(error)")
            completion([])
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("No response received")
            completion([])
            return
        }

        if !(200...299).contains(httpResponse.statusCode) {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            completion([])
            return
        }

        guard let data = data else {
            print("No data received")
            completion([])
            return
        }

        // Parse the JSON response
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Response JSON: \(json)")

            var faculties: [String] = []

            if let dict = json as? [String: Any],
               let dataDict = dict["data"] as? [[Any]] {

                for value in dataDict {
                    if let facultyName = value[0] as? String {
                        faculties.append(facultyName)
                    }
                }
            }

            // Pass the parsed faculties back via the completion handler
            completion(faculties)
        } catch {
            print("Error parsing JSON: \(error)")
            completion([])
        }
    }.resume()
}



struct Faculty {
    let id: Int
    let name: String
}

struct UniversityWithFaculties {
    let id: Int
    let name: String
    let location: String
    let logoUrl: String
    let appUrl: String
    let faculties: [Faculty]
}

func fetchUniversitiesWithFaculties(completion: @escaping ([UniversityWithFaculties]) -> Void) {
    // Specify the URL for the /query/v2 endpoint
    guard let url = URL(string: "https://1172d0e4.databases.neo4j.io/db/neo4j/query/v2") else {
        print("Invalid URL")
        completion([])
        return
    }

    // Basic Authentication
    let username = "neo4j"
    let password = "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s"
    let credentials = "\(username):\(password)"
    let basicAuth = Data(credentials.utf8).base64EncodedString()

    // Configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Cypher query to get universities and their associated faculties
    let queryPayload = """
    {
        "statement": "MATCH (u:University)-[:HAS_FACULTY]->(f:Faculty) RETURN u, collect(f) AS faculties ORDER BY u.ranking",
        "parameters": {}
    }
    """
    request.httpBody = queryPayload.data(using: .utf8)

    // Execute the HTTP request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed: \(error.localizedDescription)")
            completion([])
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Invalid HTTP response")
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            completion([])
            return
        }

        guard let data = data else {
            print("No data received")
            completion([])
            return
        }

        // Parse the JSON response
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Response JSON: \(json)")

            var universitiesWithFaculties: [UniversityWithFaculties] = []

            if let dict = json as? [String: Any],
               let dataDict = dict["data"] as? [String: Any],
               let values = dataDict["values"] as? [[Any]] { // Access "values" directly
                for value in values {
                    if let universityNode = value[0] as? [String: Any],
                       let facultiesNodes = value[1] as? [[String: Any]] {

                        if let universityProperties = universityNode["properties"] as? [String: Any] {
                            let universityId = universityNode["elementId"] as? String ?? ""
                            let universityName = universityProperties["name"] as? String ?? ""
                            let location = universityProperties["location"] as? String ?? ""
                            let logoUrl = universityProperties["logoUrl"] as? String ?? ""
                            let appUrl = universityProperties["appUrl"] as? String ?? ""

                            // Map faculties to a list of Faculty objects
                            let faculties: [Faculty] = facultiesNodes.compactMap { facultyNode in
                                if let facultyProperties = facultyNode["properties"] as? [String: Any] {
                                    //let facultyId = facultyNode["elementId"] as? String ?? ""
                                    
                                    var facultyId: Int? // Declare it outside

                                    if let elementId = facultyNode["elementId"] as? String {
                                        let parts = elementId.split(separator: ":")
                                        if let lastPart = parts.last, let id = Int(lastPart) {
                                            facultyId = id
                                        }
                                    }

                                    print(facultyId ?? "No valid facultyId found") // Output: 1038


                                    let facultyName = facultyProperties["name"] as? String ?? ""
                                    return Faculty(id:  facultyId ?? 0, name: facultyName)
                                }
                                return nil
                            }

                            let university = UniversityWithFaculties(
                                id: Int(universityId) ?? 0,
                                name: universityName,
                                location: location,
                                logoUrl: logoUrl,
                                appUrl: appUrl,
                                faculties: faculties
                            )
                            universitiesWithFaculties.append(university)
                        }
                    }
                }
            }

            // Pass the parsed universities back via the completion handler
            print(universitiesWithFaculties)
            completion(universitiesWithFaculties)
        } catch {
            print("Error parsing JSON: \(error)")
            completion([])
        }

    }.resume()
}

func fetchDegrees(for facultyId: Int, completion: @escaping ([Degree]) -> Void) {
    // Specify the URL for the /query/v2 endpoint
    guard let url = URL(string: "https://1172d0e4.databases.neo4j.io/db/neo4j/query/v2") else {
        print("Invalid URL")
        completion([])
        return
    }

    // Basic Authentication
    let username = "neo4j"
    let password = "tvwCOzDbft2TndK1P9KgOoLLI31SJISGYmzCB3Qiq3s"
    let credentials = "\(username):\(password)"
    let basicAuth = Data(credentials.utf8).base64EncodedString()

    // Configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Cypher query to fetch degrees based on faculty ID
    let queryDict: [String: Any] = ["statement": "MATCH (f:Faculty)-[:HAS_DEGREE]->(d:Degree) MATCH (f)-[:USES_PC]->(pc:PointCalculation) WHERE id(f) = $facultyId OPTIONAL MATCH (d)-[sr:SUBJECT_REQUIREMENT]->(s:Subject) OPTIONAL MATCH (d)-[pr:POINT_REQUIREMENT]->(pc) RETURN d, collect({ minPoints: sr.minPoints, orSubject: sr.orSubject, subject: s.name }) AS subjectRequirements,pr.minPoints AS pointRequirement, pc.name as pointCalculation ORDER BY d.name",
                      "parameters": [
                          "facultyId": facultyId
                      ] ]
/*
    let queryPayload = """
    {
        "statement": "MATCH (f:Faculty)-[:HAS_DEGREE]->(d:Degree)
                      MATCH (f)-[:USES_PC]->(pc:PointCalculation)
                      WHERE id(f) = \(facultyId)
                      OPTIONAL MATCH (d)-[sr:SUBJECT_REQUIREMENT]->(s:Subject)
                      OPTIONAL MATCH (d)-[pr:POINT_REQUIREMENT]->(pc)
                      RETURN d,
                             collect({
                               minPoints: sr.minPoints,
                               orSubject: sr.orSubject,
                               subject: s.name
                             }) AS subjectRequirements,
                             pr.minPoints AS pointRequirement,
                             pc.name as pointCalculation
                      ORDER BY d.name",
        "parameters": {
            "facultyId": \(facultyId)
        }
    }
    """
    */
    guard let jsonData = try? JSONSerialization.data(withJSONObject: queryDict),
          let queryPayload = String(data: jsonData, encoding: .utf8) else { return }
    
    request.httpBody = queryPayload.data(using: .utf8)

    // Execute the HTTP request
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed: \(error.localizedDescription)")
            completion([])
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Invalid HTTP response")
            if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            completion([])
            return
        }

        guard let data = data else {
            print("No data received")
            completion([])
            return
        }

        // Parse the JSON response
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Response JSON: \(json)")

            var degrees: [Degree] = []

            if let dict = json as? [String: Any],
               let dataDict = dict["data"] as? [String: Any],
               let values = dataDict["values"] as? [[Any]] {
                for value in values {
                    if let degreeNode = value[0] as? [String: Any],
                       let subjectRequirementsRaw = value[1] as? [[String: Any]],
                       let pointRequirementRaw = value[2] as? Int?,
                       let pointCalculation = value[3] as? String? {

                        if let degreeProperties = degreeNode["properties"] as? [String: Any] {
                            let degreeId = degreeNode["elementId"] as? String ?? ""
                            let degreeName = degreeProperties["name"] as? String ?? ""
                            let description = degreeProperties["description"] as? String ?? ""

                            // Process subject requirements
                            let subjectRequirements: [SubjectRequirement] = subjectRequirementsRaw.compactMap { req in
                                guard let subject = req["subject"] as? String else { return nil }
                                let minPoints = req["minPoints"] as? Int ?? 0
                                let orSubject = req["orSubject"] as? String
                                return SubjectRequirement(minPoints: minPoints, orSubject: orSubject, subject: subject)
                            }

                            let degree = Degree(
                                id: Int(degreeId) ?? 0,
                                name: degreeName,
                                description: description,
                                subjectRequirements: subjectRequirements,
                                pointRequirement: pointRequirementRaw,
                                pointCalculation: pointCalculation ?? "APS"
                            )

                            degrees.append(degree)
                        }
                    }
                }
            }

            // Pass the parsed degrees back via the completion handler
            print(degrees)
            completion(degrees)
        } catch {
            print("Error parsing JSON: \(error)")
            completion([])
        }

    }.resume()
}




 /*
func fetchUniversities(completion: @escaping ([University]) -> Void) {
    do {
        // Initialize Theo Client
        let client = try BoltClient(
            hostname: "neo4j+s://1172d0e4.databases.neo4j.io", // Correct secure connection
            port: 7687,
            username: "neo4j",
            password: "your-password",
            encrypted: true // Ensure encryption is enabled for secure communication
        )

        // Cypher Query
        let query = "MATCH (u:University) RETURN u.name AS name, u.location AS location"

        // Execute Cypher Query
        client.executeCypher(query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let queryResult):
                    if let records = queryResult.records {
                        var universities: [University] = []
                        for record in records {
                            if let name = record["name"] as? String,
                               let location = record["location"] as? String {
                                universities.append(University(name: name, location: location))
                            }
                        }
                        completion(universities)
                    } else {
                        print("No records found.")
                        completion([])
                    }
                case .failure(let error):
                    print("Error while executing Cypher: \(error)")
                    completion([])
                }
            }
        }
    } catch {
        print("Error initializing BoltClient: \(error)")
        completion([])
    }
}
*/
