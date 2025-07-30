import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    private let favoritesKey = "favoriteEvents"
    
    private init() {}
    
    func toggleFavorite(eventID: String) -> Bool {
        var favorites = getFavoriteEventIDs()
        
        if favorites.contains(eventID) {
            favorites.remove(eventID)
        } else {
            favorites.insert(eventID)
        }
        
        saveFavoriteEventIDs(favorites)
        
        return favorites.contains(eventID)
    }
    
    func isEventFavorite(eventID: String) -> Bool {
        let favorites = getFavoriteEventIDs()
        return favorites.contains(eventID)
    }
    
    // Nuovo metodo per ottenere tutti gli ID degli eventi preferiti
    func getAllFavoriteEventIDs() -> [String] {
        return Array(getFavoriteEventIDs())
    }
    
    private func getFavoriteEventIDs() -> Set<String> {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            return favorites
        }
        return Set<String>()
    }
    
    private func saveFavoriteEventIDs(_ favorites: Set<String>) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // Metodo per rimuovere tutti i preferiti (opzionale)
    func clearAllFavorites() {
        UserDefaults.standard.removeObject(forKey: favoritesKey)
    }
    
    // Metodo per ottenere il numero di eventi preferiti (opzionale)
    func getFavoritesCount() -> Int {
        return getFavoriteEventIDs().count
    }
}
