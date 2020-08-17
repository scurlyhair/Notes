// MARK: - Realm

protocol Realm {
    associatedtype T
    func insert(item: T, update: Bool) throws -> Bool
    func insert(items: [T], update: Bool) throws -> Bool
    func find(condition: (T) throws -> Bool) rethrows -> [T]
    func delete(condition: (T) throws -> Bool) rethrows -> Bool
}

struct MyRealm {}

extension MyRealm: Realm {
    typealias T = Int

    func insert(item: Int, update: Bool) throws -> Bool {
        return false
    }

    func insert(items: [Int], update: Bool) throws -> Bool {
        return false
    }

    func find(condition: (Int) throws -> Bool) rethrows -> [Int] {
        return []
    }

    func delete(condition: (Int) throws -> Bool) rethrows -> Bool {
        return false
    }
}

// MARK: - DB

protocol DB {
    associatedtype T
    func insert(item: T, update: Bool) -> Bool
    func insert(items: [T], update: Bool) -> Bool
    func find(condition: (T) throws -> Bool) -> [T]
    func delete(condition: (T) throws -> Bool) -> Bool
}

struct MyDB {
    private var realm: MyRealm?
}

extension MyDB: DB {
    typealias T = Int

    func insert(item: Int, update: Bool = true) -> Bool {
        guard let realm = realm else { return false }
        do {
            let result = try realm.insert(item: item, update: update)
            return result
        } catch {
            print(error)
            return false
        }
    }

    func insert(items: [Int], update: Bool = true) -> Bool {
        guard let realm = realm else { return false }
        do {
            let result = try realm.insert(items: items, update: update)
            return result
        } catch {
            print(error)
            return false
        }
    }

    func find(condition: (Int) throws -> Bool) -> [Int] {
        guard let realm = realm else { return [] }
        do {
            let result = try realm.find(condition: condition)
            return result
        } catch {
            print(error)
            return []
        }
    }

    func delete(condition: (Int) throws -> Bool) -> Bool {
        guard let realm = realm else { return false }
        do {
            let result = try realm.delete(condition: condition)
            return result
        } catch {
            print(error)
            return false
        }
    }
}
