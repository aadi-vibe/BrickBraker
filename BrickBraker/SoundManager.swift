//
//  SoundManager.swift
//  BrickBraker
//
//  Created by Upendra Sharma on 2/16/26.
//

import AVFoundation

// MARK: - Sound Manager

class SoundManager {
    private let engine = AVAudioEngine()
    private let bouncePlayer = AVAudioPlayerNode()
    private let breakPlayer = AVAudioPlayerNode()
    private let musicPlayer = AVAudioPlayerNode()
    private var bounceBuffer: AVAudioPCMBuffer?
    private var breakBuffer: AVAudioPCMBuffer?
    private var musicBuffer: AVAudioPCMBuffer?
    private var isMusicPlaying = false

    var musicEnabled = true
    var bounceEnabled = true

    init() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }

        engine.attach(bouncePlayer)
        engine.attach(breakPlayer)
        engine.attach(musicPlayer)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(bouncePlayer, to: engine.mainMixerNode, format: format)
        engine.connect(breakPlayer, to: engine.mainMixerNode, format: format)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: format)

        musicPlayer.volume = 0.18

        do { try engine.start() } catch { print("Audio engine start failed: \(error)") }

        let sr = format.sampleRate
        let ch = format.channelCount
        bounceBuffer = makeTone(frequency: 880, duration: 0.1, amplitude: 0.5,
                                decay: 25, sampleRate: sr, channels: ch)
        breakBuffer = makeBreak(duration: 0.15, amplitude: 0.6,
                                sampleRate: sr, channels: ch)
        musicBuffer = makeMusicLoop(sampleRate: sr, channels: ch)
    }

    func playBounce() {
        guard bounceEnabled, let buf = bounceBuffer else { return }
        bouncePlayer.scheduleBuffer(buf, at: nil, completionHandler: nil)
        if !bouncePlayer.isPlaying { bouncePlayer.play() }
    }

    func playBreak() {
        guard bounceEnabled, let buf = breakBuffer else { return }
        breakPlayer.scheduleBuffer(buf, at: nil, completionHandler: nil)
        if !breakPlayer.isPlaying { breakPlayer.play() }
    }

    func startMusic() {
        guard musicEnabled, let buf = musicBuffer, !isMusicPlaying else { return }
        isMusicPlaying = true
        musicPlayer.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        musicPlayer.play()
    }

    func stopMusic() {
        musicPlayer.stop()
        isMusicPlaying = false
    }

    // MARK: - Tone Generation

    private func makeTone(frequency: Double, duration: Double, amplitude: Float,
                          decay: Double, sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let count = AVAudioFrameCount(sampleRate * duration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: count) else { return nil }
        buf.frameLength = count
        for ch in 0..<Int(channels) {
            let data = buf.floatChannelData![ch]
            for i in 0..<Int(count) {
                let t = Double(i) / sampleRate
                data[i] = amplitude * Float(exp(-t * decay)) * sin(Float(2.0 * .pi * frequency * t))
            }
        }
        return buf
    }

    private func makeBreak(duration: Double, amplitude: Float,
                           sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let count = AVAudioFrameCount(sampleRate * duration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: count) else { return nil }
        buf.frameLength = count
        for ch in 0..<Int(channels) {
            let data = buf.floatChannelData![ch]
            for i in 0..<Int(count) {
                let t = Double(i) / sampleRate
                let env = Float(exp(-t * 20))
                let noise = Float.random(in: -1...1)
                let tone = sin(Float(2.0 * .pi * 300 * t)) + sin(Float(2.0 * .pi * 600 * t))
                data[i] = amplitude * env * (noise * 0.4 + tone * 0.3)
            }
        }
        return buf
    }

    private func makeMusicLoop(sampleRate: Double, channels: UInt32) -> AVAudioPCMBuffer? {
        let bpm: Double = 140
        let beatDuration = 60.0 / bpm
        let melody: [(freq: Double, beats: Double)] = [
            (523.25, 0.5), (587.33, 0.5), (659.25, 0.5), (783.99, 0.5),
            (659.25, 1.0), (523.25, 0.5), (587.33, 0.5),
            (783.99, 0.5), (659.25, 0.5), (523.25, 1.0),
            (0, 0.5),
            (392.00, 0.5), (440.00, 0.5), (523.25, 0.5), (659.25, 0.5),
            (523.25, 1.0), (440.00, 0.5), (392.00, 0.5),
            (523.25, 0.5), (440.00, 0.5), (392.00, 1.0),
            (0, 0.5),
            (783.99, 0.5), (659.25, 0.5), (783.99, 0.5), (880.00, 0.5),
            (783.99, 1.0), (659.25, 0.5), (523.25, 0.5),
            (587.33, 0.5), (523.25, 0.5), (440.00, 1.0),
            (0, 0.5),
            (523.25, 0.5), (587.33, 0.5), (659.25, 0.5), (523.25, 0.5),
            (440.00, 0.5), (392.00, 0.5), (440.00, 0.5), (523.25, 0.5),
            (523.25, 1.5), (0, 0.5),
        ]
        var totalBeats: Double = 0
        for note in melody { totalBeats += note.beats }
        let totalDuration = totalBeats * beatDuration
        let totalSamples = AVAudioFrameCount(sampleRate * totalDuration)
        guard let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels),
              let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: totalSamples) else { return nil }
        buf.frameLength = totalSamples
        var sampleOffset = 0
        let amplitude: Float = 0.35
        for note in melody {
            let noteSamples = Int(note.beats * beatDuration * sampleRate)
            let freq = note.freq
            for ch in 0..<Int(channels) {
                let data = buf.floatChannelData![ch]
                for i in 0..<noteSamples {
                    let idx = sampleOffset + i
                    guard idx < Int(totalSamples) else { break }
                    if freq == 0 {
                        data[idx] = 0
                    } else {
                        let t = Double(i) / sampleRate
                        let noteDur = note.beats * beatDuration
                        let attack = min(Float(t / 0.01), 1.0)
                        let release = Float(max(0, min(1, (noteDur - t) / 0.05)))
                        let env = attack * release
                        let fundamental = sin(Float(2.0 * .pi * freq * t))
                        let third = sin(Float(2.0 * .pi * freq * 3.0 * t)) * 0.33
                        let fifth = sin(Float(2.0 * .pi * freq * 5.0 * t)) * 0.2
                        data[idx] = amplitude * env * (fundamental + third + fifth)
                    }
                }
            }
            sampleOffset += noteSamples
        }
        return buf
    }
}
