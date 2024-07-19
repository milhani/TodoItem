import Foundation


actor Storage {
    private var revision: Int = 0

    func getRevision() -> Int {
        return revision
    }

    func updateRevision(newRevision: Int) {
        revision = newRevision
    }
}
