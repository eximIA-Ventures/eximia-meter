import Foundation

class ProjectStore {
    private let key = "savedProjects"

    func loadProjects() -> [Project] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }

        do {
            return try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("Failed to decode projects: \(error)")
            return []
        }
    }

    func saveProjects(_ projects: [Project]) {
        do {
            let data = try JSONEncoder().encode(projects)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to encode projects: \(error)")
        }
    }
}
