import SwiftUI

struct ContentView: View {
    @StateObject private var session = CallSessionManager()

    @State private var roomTitle = "Daily Sync"
    @State private var hostName = "Host"
    @State private var roomCodeInput = ""
    @State private var displayName = "Guest"

    var body: some View {
        NavigationStack {
            Form {
                Section("创建会议") {
                    TextField("会议标题", text: $roomTitle)
                    TextField("主持人名称", text: $hostName)

                    Button("创建并加入") {
                        Task {
                            let room = session.createRoom(title: roomTitle, hostName: hostName)
                            roomCodeInput = room.roomCode
                            await session.join(room: room, displayName: hostName)
                        }
                    }
                }

                Section("加入会议") {
                    TextField("房间号", text: $roomCodeInput)
                        .textInputAutocapitalization(.characters)
                    TextField("昵称", text: $displayName)

                    Button("加入") {
                        Task {
                            let room = MeetingRoom(
                                roomCode: roomCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                                title: "24h 会议",
                                hostName: "Unknown"
                            )
                            await session.join(room: room, displayName: displayName)
                        }
                    }
                    .disabled(roomCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("会议状态") {
                    LabeledContent("状态", value: session.state.description)

                    if let room = session.currentRoom {
                        LabeledContent("会议号", value: room.roomCode)
                        LabeledContent("会议标题", value: room.title)
                        LabeledContent("已进行", value: session.elapsed.formattedTime)
                        LabeledContent("剩余", value: session.remaining.formattedTime)
                    }

                    if session.hasReached24Hours {
                        Text("已达到 24 小时，会议自动结束。")
                            .foregroundStyle(.orange)
                    }

                    Button("离开会议") {
                        Task { await session.leave() }
                    }
                    .disabled(session.currentRoom == nil)
                }
            }
            .navigationTitle("24hMeeting")
        }
        .frame(minWidth: 420, minHeight: 520)
    }
}

private extension TimeInterval {
    var formattedTime: String {
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
