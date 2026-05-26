import AVFoundation

struct AudioRouteProvider: SegmentProvider {
    @MainActor func group() -> Group? {
        let out = AVAudioSession.sharedInstance().currentRoute.outputs.first
        let name: String
        switch out?.portType {
        case .some(.builtInSpeaker): name = "Speaker"
        case .some(.builtInReceiver): name = "Receiver"
        case .some(.headphones): name = "Wired"
        case .some(.bluetoothA2DP), .some(.bluetoothLE), .some(.bluetoothHFP):
            name = out?.portName ?? "Bluetooth"
        case .some: name = out?.portName ?? "Out"
        case .none: name = "-"
        }
        return Group(
            id: "audio",
            label: "Audio",
            segments: [Segment(id: "route", label: "Out", value: name, defaultEnabled: true)]
        )
    }
}
