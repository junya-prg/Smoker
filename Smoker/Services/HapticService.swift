//
//  HapticService.swift
//  SmokeCounter
//
//  Core Hapticsを使用したハプティクスフィードバックサービス
//  リラックスモード突入時に「呼吸」のようなゆるやかな振動パターンを再生
//

import Foundation
import CoreHaptics

/// ハプティクスフィードバックサービス
@MainActor
@Observable
class HapticService {
    /// Core Hapticsエンジン
    private var engine: CHHapticEngine?
    
    /// デバイスがハプティクス対応かどうか
    private var supportsHaptics: Bool = false
    
    // MARK: - 初期化
    
    init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            
            // エンジン停止時の自動再起動ハンドラ
            engine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason.rawValue)")
                Task { @MainActor in
                    self?.restartEngine()
                }
            }
            
            // エンジンリセット時のハンドラ
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                Task { @MainActor in
                    self?.restartEngine()
                }
            }
        } catch {
            print("Haptic engine初期化エラー: \(error)")
            supportsHaptics = false
        }
    }
    
    // MARK: - リラックスパターン再生
    
    /// リラックスモード用の「呼吸」パターンを再生
    /// ゆるやかに3回パルスし、徐々に間隔を広げて呼吸のリズムを表現
    func playRelaxPattern() {
        guard supportsHaptics, let engine = engine else { return }
        
        do {
            try engine.start()
            
            let pattern = try createBreathingPattern()
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Hapticパターン再生エラー: \(error)")
        }
    }
    
    // MARK: - パターン定義
    
    /// 「呼吸」のようなハプティクスパターンを生成
    /// - 3回のゆるやかなパルス（フェードイン→フェードアウト）
    /// - 各パルスの間隔を少しずつ広げ、ゆっくりした呼吸を表現
    /// - 全体で約2.5秒
    private func createBreathingPattern() throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        
        // パルス設定: (開始時間, 持続時間, 最大強度)
        let pulses: [(time: TimeInterval, duration: TimeInterval, intensity: Float)] = [
            (0.0,  0.5, 0.65),  // 1回目: ふわっと（やや強め）
            (0.8,  0.6, 0.80),  // 2回目: しっかりと
            (1.7,  0.8, 0.60),  // 3回目: ゆっくりフェードアウト
        ]
        
        for pulse in pulses {
            // Continuous Event: ゆるやかな振動の本体
            let intensityParam = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: pulse.intensity
            )
            let sharpnessParam = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: 0.1  // 低いシャープネスで柔らかい感触
            )
            
            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensityParam, sharpnessParam],
                relativeTime: pulse.time,
                duration: pulse.duration
            )
            events.append(continuousEvent)
        }
        
        // パラメータカーブ: 各パルスのフェードイン→フェードアウトを定義
        var parameterCurves: [CHHapticParameterCurve] = []
        
        for pulse in pulses {
            let fadeIn = CHHapticParameterCurve.ControlPoint(
                relativeTime: pulse.time,
                value: 0.0
            )
            let peak = CHHapticParameterCurve.ControlPoint(
                relativeTime: pulse.time + pulse.duration * 0.4,
                value: pulse.intensity
            )
            let fadeOut = CHHapticParameterCurve.ControlPoint(
                relativeTime: pulse.time + pulse.duration,
                value: 0.0
            )
            
            let curve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [fadeIn, peak, fadeOut],
                relativeTime: 0
            )
            parameterCurves.append(curve)
        }
        
        return try CHHapticPattern(
            events: events,
            parameterCurves: parameterCurves
        )
    }
    
    // MARK: - エンジン管理
    
    /// エンジンを再起動
    private func restartEngine() {
        guard supportsHaptics else { return }
        
        do {
            try engine?.start()
        } catch {
            print("Haptic engine再起動エラー: \(error)")
        }
    }
}
