import Foundation

struct MeetingRoom: Identifiable, Hashable {
    let id: UUID
    var roomCode: String
    var title: String
    var hostName: String
    var startAt: Date?
    var maxDuration: TimeInterval

    init(
        id: UUID = UUID(),
        roomCode: String,
        title: String,
        hostName: String,
        startAt: Date? = nil,
        maxDuration: TimeInterval = 24 * 60 * 60
    ) {
        self.id = id
        self.roomCode = roomCode
        self.title = title
        self.hostName = hostName
        self.startAt = startAt
        self.maxDuration = maxDuration
    }

    var endAt: Date? {
        guard let startAt else { return nil }
        return startAt.addingTimeInterval(maxDuration)
    }
}
