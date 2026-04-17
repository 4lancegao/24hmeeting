import Foundation

@MainActor
final class CallSessionManager: ObservableObject {
    enum SessionState: Equatable {
        case idle
        case connecting
        case connected(startAt: Date)
        case reconnecting
        case ended
        case failed(message: String)

        var description: String {
            switch self {
            case .idle:
                return "待机"
            case .connecting:
                return "连接中"
            case .connected:
                return "通话中"
            case .reconnecting:
                return "重连中"
            case .ended:
                return "已结束"
            case .failed(let message):
                return "连接失败：\(message)"
            }
        }
    }

    @Published private(set) var state: SessionState = .idle
    @Published private(set) var currentRoom: MeetingRoom?
    @Published private(set) var elapsed: TimeInterval = 0

    private let engine: VideoEngine
    private var tickerTask: Task<Void, Never>?

    init(engine: VideoEngine = MockVideoEngine()) {
        self.engine = engine
    }

    func createRoom(title: String, hostName: String) -> MeetingRoom {
        let code = Self.makeRoomCode()
        return MeetingRoom(roomCode: code, title: title, hostName: hostName)
    }

    func join(room: MeetingRoom, displayName: String) async {
        state = .connecting
        do {
            try await engine.join(roomCode: room.roomCode, userName: displayName)
            var runningRoom = room
            let now = Date()
            runningRoom.startAt = now
            currentRoom = runningRoom
            state = .connected(startAt: now)
            startTicker()
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    func leave() async {
        tickerTask?.cancel()
        tickerTask = nil
        await engine.leave()
        state = .ended
    }

    var remaining: TimeInterval {
        guard let room = currentRoom else { return 0 }
        return max(room.maxDuration - elapsed, 0)
    }

    var hasReached24Hours: Bool {
        remaining <= 0
    }

    private func startTicker() {
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                if case .connected(let startAt) = self.state {
                    self.elapsed = Date().timeIntervalSince(startAt)
                    if self.hasReached24Hours {
                        await self.leave()
                        break
                    }
                }

                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    static func makeRoomCode() -> String {
        let raw = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(raw.prefix(8)).uppercased()
    }
}

protocol VideoEngine {
    func join(roomCode: String, userName: String) async throws
    func leave() async
}

struct MockVideoEngine: VideoEngine {
    func join(roomCode: String, userName: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }

    func leave() async {}
}
