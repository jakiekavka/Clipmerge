import Cocoa
import Carbon

let pasteFile = "/tmp/paste"
let sep = "\n---CLIP_ENTRY---\n"
let triggerFile = "/tmp/clipmerge_sound"

func readE() -> [String] {
    guard let raw = try? String(contentsOfFile: pasteFile, encoding: .utf8) else { return [] }
    return raw.components(separatedBy: sep).map {
        $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
    }.filter { !$0.isEmpty }
}
func writeE(_ e: [String]) { try? e.prefix(15).joined(separator: sep).write(toFile: pasteFile, atomically: true, encoding: .utf8) }

var lastContent = "", merging = false
var lastMerge: Date = .distantPast

func checkCB() {
    guard !merging else { return }
    let pb = NSPasteboard.general
    guard let s = pb.string(forType: .string) else { return }
    let clean = s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
    guard !clean.isEmpty, clean != lastContent else { return }
    lastContent = clean
    var e = readE()
    guard e.first != clean else { return }
    e.insert(clean, at: 0); writeE(e)
}

func merge() {
    let now = Date()
    guard now.timeIntervalSince(lastMerge) > 0.5 else { return }
    lastMerge = now
    merging = true
    let entries = readE()
    guard entries.count >= 2 else { merging = false; return }
    var a = entries[0], b = entries[1]
    if a == b, entries.count >= 3 { b = entries[2] }
    let m = b + "\n" + a
    var updated = [m]
    for e in entries.dropFirst(2) { if e != a && e != b { updated.append(e) } }
    writeE(updated)
    NSPasteboard.general.clearContents(); NSPasteboard.general.setString(m, forType: .string)
    lastContent = m
    merging = false
    FileManager.default.createFile(atPath: triggerFile, contents: nil)
}

// Carbon hotkey
var hotkeyRefs: [EventHotKeyRef] = []
var handlerRef: EventHandlerRef?
var hotkeyID: UInt32 = 1

func startHotkey() {
    var ref: EventHotKeyRef?
    let s = RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(controlKey | optionKey),
        EventHotKeyID(signature: 0x43_4C_4D_47, id: hotkeyID), GetEventDispatcherTarget(), 0, &ref)
    guard s == noErr, let r = ref else { exit(1) }
    hotkeyRefs.append(r)
    
    var et = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
    let upp: EventHandlerUPP = { (_, event, _) -> OSStatus in
        var hid = EventHotKeyID()
        guard GetEventParameter(event, EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hid) == noErr else { return noErr }
        if hid.id == hotkeyID { DispatchQueue.main.async { merge() } }
        return noErr
    }
    InstallEventHandler(GetEventDispatcherTarget(), upp, 1, &et, nil, &handlerRef)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.accessory)
        startHotkey()
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in checkCB() }
    }
}

autoreleasepool {
    let app = NSApplication.shared
    let d = AppDelegate()
    app.delegate = d
    app.run()
}
