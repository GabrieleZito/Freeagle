//
//  PeopleService.swift
//  TestParthenokit
//
//  Created by mariellafarella on 20/07/25.
//

import Foundation
import ParthenoKit


struct PeopleService {
    let team = "PA0H1ABPRWQ"
    let tag = "PEOPLE"
    
    var p = ParthenoKit()
    
    
    
    public func getPerson(id: String) -> Person?{
        print("Get person by id: \(id)")
        let dic = p.readSync(team: team, tag: tag, key: id)
        print(dic)
        if let extracted = dic[id]{
            if let jsonData = extracted.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil).data(using: .utf8){
                do{
                    let savedPerson = try JSONDecoder().decode(Person.self, from: jsonData)
                    return savedPerson
                    
                } catch{
                    print("Errore nella deserializzazione: \(error)")
                }
            }
        } else {
            print("Not Found!")
        }
        return nil
    }
    
    
    public func setPerson(person: Person)-> Bool{
        let encoder = JSONEncoder()
        
        do{
            let jsonData = try encoder.encode(person)
            if let jsonString = String(data:jsonData, encoding: .utf8){
                return p.writeSync(team: team, tag: tag, key: person.id, value: jsonString)
            }
        }catch{
            print("Errore nella serializzazione: \(error)")
        }
        return false
    }
    
    public func reset(id:String) -> Bool {
        return p.writeSync(team: team, tag: tag, key: id, value: "#DEL#")
    }
}

struct Person: Identifiable, Codable{
    public var id: String
    public var firstName: String = ""
    public var lastName: String = ""
}
