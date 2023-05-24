//
//  CLGeocoder.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 31/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import CoreLocation

extension CLGeocoder {
    
    func getDepartment(from location: CLLocation, completion: @escaping (String?) -> Void) {
        self.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            guard error == nil else {
                print("􀵳 CLGeocoder error = \(error!.localizedDescription)")
                return completion(nil)
            } // No internet, retry later
            guard let code = placemarks?.first?.postalCode, placemarks?.first?.country == "France", let departmentNumber = Int(code.prefix(2)) else {
                return completion(placemarks?.first?.country ?? "?")
            }
            switch departmentNumber {
            case 1:  completion("Ain")
            case 2:  completion("Aisne")
            case 3:  completion("Allier")
            case 4:  completion("Alpes-de-Haute-Provence")
            case 5:  completion("Hautes-Alpes")
            case 6:  completion("Alpes-Maritimes")
            case 7:  completion("Ardèche")
            case 8:  completion("Ardennes")
            case 9:  completion("Ariège")
            case 10: completion("Aube")
            case 11: completion("Aude")
            case 12: completion("Aveyron")
            case 13: completion("Bouches-du-Rhône")
            case 14: completion("Calvado")
            case 15: completion("Cantal")
            case 16: completion("Charente")
            case 17: completion("Charente-Maritime")
            case 18: completion("Cher")
            case 19: completion("Corrèze")
            case 20: completion("Corse")
            case 21: completion("Côte-d'Or")
            case 22: completion("Côtes d'Armor")
            case 23: completion("Creuse")
            case 24: completion("Dordogne")
            case 25: completion("Doubs")
            case 26: completion("Drôme")
            case 27: completion("Eure")
            case 28: completion("Eure-et-Loir")
            case 29: completion("Finistère")
            case 30: completion("Gard")
            case 31: completion("Haute-Garonne")
            case 32: completion("Gers")
            case 33: completion("Gironde")
            case 34: completion("Hérault")
            case 35: completion("Ille-et-Vilaine")
            case 36: completion("Indre")
            case 37: completion("Indre-et-Loire")
            case 38: completion("Isère")
            case 39: completion("Jura")
            case 40: completion("Landes")
            case 41: completion("Loir-et-Cher")
            case 42: completion("Loire")
            case 43: completion("Haute-Loire")
            case 44: completion("Loire-Atlantique")
            case 45: completion("Loiret")
            case 46: completion("Lot")
            case 47: completion("Lot-et-Garonne")
            case 48: completion("Lozère")
            case 49: completion("Maine-et-Loire")
            case 50: completion("Manche")
            case 51: completion("Marne")
            case 52: completion("Haute-Marne")
            case 53: completion("Mayenne")
            case 54: completion("Meurthe-et-Moselle")
            case 55: completion("Meuse")
            case 56: completion("Morbihan")
            case 57: completion("Mosell")
            case 58: completion("Nièvre")
            case 59: completion("Nord")
            case 60: completion("Oise")
            case 61: completion("Orne")
            case 62: completion("Pas-de-Calais")
            case 63: completion("Puy-de-Dôme")
            case 64: completion("Pyrénées-Atlantiques")
            case 65: completion("Hautes-Pyrénées")
            case 66: completion("Pyrénées-Orientales")
            case 67: completion("Bas-Rhin")
            case 68: completion("Haut-Rhin")
            case 69: completion("Rhôn")
            case 70: completion("Haute-Saône")
            case 71: completion("Saône-et-Loire")
            case 72: completion("Sarthe")
            case 73: completion("Savoie")
            case 74: completion("Haute-Savoie")
            case 75: completion("Paris")
            case 76: completion("Seine-Maritime")
            case 77: completion("Seine-et-Marne")
            case 78: completion("Yvelines")
            case 79: completion("Deux-Sèvres")
            case 80: completion("Somme")
            case 81: completion("Tar")
            case 82: completion("Tarn-et-Garonne")
            case 83: completion("Var")
            case 84: completion("Vaucluse")
            case 85: completion("Vendée")
            case 86: completion("Vienne")
            case 87: completion("Haute-Vienne")
            case 88: completion("Vosges")
            case 89: completion("Yonne")
            case 90: completion("Terr. de Belfort")
            case 91: completion("Essonne")
            case 92: completion("Hauts-de-Seine")
            case 93: completion("Seine-St-Denis")
            case 94: completion("Val-de-Marne")
            case 95: completion("Val-D'Oise")
            default: completion("?")
            }
            
        })
    }

}

