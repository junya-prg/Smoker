//
//  FireParticleView.swift
//  SmokeCounter
//
//  幻想的な炎のパーティクルエフェクト
//  美しく鮮やかな炎の動きを表現
//

import SwiftUI

/// 炎パーティクルのデータモデル
struct FireParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var hue: Double
    var swayOffset: CGFloat
    var layer: Int
}

/// 火の粉パーティクルのデータモデル
struct EmberParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speedX: CGFloat
    var speedY: CGFloat
    var life: CGFloat
    var hue: Double
}

/// 魔法の炎パーティクル（カラフル）
struct MagicFlameParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var hue: Double
    var swayPhase: CGFloat
}

/// 幻想的な炎のパーティクルエフェクトビュー
struct FireParticleView: View {
    @State private var fireParticles: [FireParticle] = []
    @State private var emberParticles: [EmberParticle] = []
    @State private var coreGlowParticles: [CoreGlowParticle] = []
    @State private var magicFlames: [MagicFlameParticle] = []
    @State private var animationTimer: Timer?
    @State private var time: Double = 0
    
    /// 炎パーティクルの数
    var fireParticleCount: Int = 60
    
    /// 火の粉パーティクルの数
    var emberParticleCount: Int = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 深い宇宙のような背景
                MysticalBackground(time: time)
                
                // 周囲への幻想的な光の拡散
                MysticalAmbientGlow(size: geometry.size, time: time)
                
                // 炎の光の反射（床）- カラフル
                MysticalFloorReflection(size: geometry.size, time: time)
                
                // 魔法の炎（背景層）
                ForEach(magicFlames) { particle in
                    MagicFlameShape(particle: particle, time: time)
                }
                
                // コアのグロー（炎の中心）
                ForEach(coreGlowParticles) { particle in
                    EnhancedCoreGlowShape(particle: particle, time: time)
                }
                
                // メイン炎パーティクル
                ForEach(fireParticles) { particle in
                    EnhancedFireFlameShape(particle: particle, time: time)
                }
                
                // 火の粉パーティクル（カラフル）
                ForEach(emberParticles) { particle in
                    ColorfulEmberShape(particle: particle, time: time)
                }
                
                // 光のリング効果
                LightRingEffect(size: geometry.size, time: time)
            }
            .onAppear {
                initializeParticles(in: geometry.size)
                startAnimation(in: geometry.size)
            }
            .onDisappear {
                stopAnimation()
            }
            .onChange(of: geometry.size) { _, newSize in
                stopAnimation()
                initializeParticles(in: newSize)
                startAnimation(in: newSize)
            }
        }
        .ignoresSafeArea()
    }
    
    /// パーティクルを初期化
    private func initializeParticles(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        
        let fireBaseY = max(200, size.height * 0.72)
        let fireBaseX = max(50, size.width / 2)
        
        fireParticles = (0..<fireParticleCount).map { _ in
            createFireParticle(baseX: fireBaseX, baseY: fireBaseY, size: size, randomY: true)
        }
        
        emberParticles = (0..<emberParticleCount).map { _ in
            createEmberParticle(baseX: fireBaseX, baseY: fireBaseY, size: size, randomY: true)
        }
        
        coreGlowParticles = (0..<8).map { i in
            createCoreGlowParticle(baseX: fireBaseX, baseY: fireBaseY, index: i)
        }
        
        magicFlames = (0..<20).map { _ in
            createMagicFlame(baseX: fireBaseX, baseY: fireBaseY, randomY: true)
        }
    }
    
    /// 新しい炎パーティクルを作成
    private func createFireParticle(baseX: CGFloat, baseY: CGFloat, size: CGSize, randomY: Bool) -> FireParticle {
        let layer = Int.random(in: 0...2)
        let xSpread: CGFloat = CGFloat(layer + 1) * 22
        let minY = max(0, baseY - 200)
        let maxY = max(minY + 1, baseY)
        
        // 炎の色相（オレンジ〜ピンク〜紫のグラデーション）
        let hues: [Double] = [0.0, 0.02, 0.05, 0.08, 0.95, 0.92]
        
        return FireParticle(
            x: baseX + CGFloat.random(in: -xSpread...xSpread),
            y: randomY ? CGFloat.random(in: minY...maxY) : baseY,
            size: CGFloat.random(in: 40...100) - CGFloat(layer) * 15,
            opacity: CGFloat.random(in: 0.7...1.0),
            speed: CGFloat.random(in: 1.5...4.0),
            hue: hues.randomElement() ?? 0.05,
            swayOffset: CGFloat.random(in: -20...20),
            layer: layer
        )
    }
    
    /// 新しい火の粉パーティクルを作成
    private func createEmberParticle(baseX: CGFloat, baseY: CGFloat, size: CGSize, randomY: Bool) -> EmberParticle {
        let minY = max(0, baseY - 300)
        let maxY = max(minY + 1, baseY)
        
        // カラフルな火の粉
        let hues: [Double] = [0.05, 0.08, 0.12, 0.95, 0.85, 0.55]
        
        return EmberParticle(
            x: baseX + CGFloat.random(in: -50...50),
            y: randomY ? CGFloat.random(in: minY...maxY) : baseY,
            size: CGFloat.random(in: 3...10),
            opacity: CGFloat.random(in: 0.7...1.0),
            speedX: CGFloat.random(in: -1.2...1.2),
            speedY: CGFloat.random(in: 2.5...6.0),
            life: 1.0,
            hue: hues.randomElement() ?? 0.05
        )
    }
    
    private func createCoreGlowParticle(baseX: CGFloat, baseY: CGFloat, index: Int) -> CoreGlowParticle {
        let hues: [Double] = [0.02, 0.05, 0.08, 0.95, 0.0, 0.03, 0.06, 0.92]
        
        return CoreGlowParticle(
            x: baseX + CGFloat.random(in: -30...30),
            y: baseY - CGFloat(index * 18) - CGFloat.random(in: 15...40),
            size: CGFloat.random(in: 60...120),
            opacity: CGFloat.random(in: 0.5...0.8),
            hue: hues[index % hues.count],
            pulsePhase: CGFloat(index) * 0.5
        )
    }
    
    private func createMagicFlame(baseX: CGFloat, baseY: CGFloat, randomY: Bool) -> MagicFlameParticle {
        let minY = max(0, baseY - 180)
        let maxY = max(minY + 1, baseY)
        
        // 魔法的な色（青、紫、ピンク）
        let hues: [Double] = [0.55, 0.65, 0.75, 0.85, 0.95]
        
        return MagicFlameParticle(
            x: baseX + CGFloat.random(in: -60...60),
            y: randomY ? CGFloat.random(in: minY...maxY) : baseY,
            size: CGFloat.random(in: 30...70),
            opacity: CGFloat.random(in: 0.3...0.6),
            speed: CGFloat.random(in: 1.0...2.5),
            hue: hues.randomElement() ?? 0.75,
            swayPhase: CGFloat.random(in: 0...(CGFloat.pi * 2))
        )
    }
    
    /// アニメーションを開始
    private func startAnimation(in size: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            time += 1/60
            updateParticles(in: size)
        }
    }
    
    /// アニメーションを停止
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /// パーティクルを更新
    private func updateParticles(in size: CGSize) {
        let fireBaseY = max(200, size.height * 0.72)
        let fireBaseX = max(50, size.width / 2)
        
        // 炎パーティクルの更新
        for i in fireParticles.indices {
            fireParticles[i].y -= fireParticles[i].speed
            
            // より複雑な揺らぎ
            let sway = sin(time * 4.0 + fireParticles[i].swayOffset) * 22 * (1.0 + CGFloat(fireParticles[i].layer) * 0.3)
            let sway2 = sin(time * 2.5 + fireParticles[i].swayOffset * 0.5) * 10
            fireParticles[i].x += (sway + sway2) * 0.04
            
            // 色の変化（より鮮やか）
            let progress = (fireBaseY - fireParticles[i].y) / 200
            fireParticles[i].hue = min(0.15, fireParticles[i].hue + 0.004)
            fireParticles[i].opacity = max(0, 1.0 - progress * 0.8)
            fireParticles[i].size *= 0.993
            
            // 再生成
            if fireParticles[i].y < fireBaseY - 220 || fireParticles[i].opacity <= 0.03 {
                fireParticles[i] = createFireParticle(baseX: fireBaseX, baseY: fireBaseY, size: size, randomY: false)
            }
        }
        
        // コアグローの更新
        for i in coreGlowParticles.indices {
            let pulse = sin(time * 3.0 + coreGlowParticles[i].pulsePhase) * 0.25 + 0.75
            coreGlowParticles[i].opacity = CGFloat(pulse) * 0.7
            coreGlowParticles[i].size = 80 + CGFloat(sin(time * 2.5 + coreGlowParticles[i].pulsePhase)) * 30
        }
        
        // 魔法の炎の更新
        for i in magicFlames.indices {
            magicFlames[i].y -= magicFlames[i].speed
            
            let sway = sin(time * 2.0 + magicFlames[i].swayPhase) * 30
            magicFlames[i].x += sway * 0.03
            
            let progress = (fireBaseY - magicFlames[i].y) / 180
            magicFlames[i].opacity = max(0, 0.6 - progress * 0.65)
            magicFlames[i].size *= 0.996
            
            if magicFlames[i].y < fireBaseY - 200 || magicFlames[i].opacity <= 0.02 {
                magicFlames[i] = createMagicFlame(baseX: fireBaseX, baseY: fireBaseY, randomY: false)
            }
        }
        
        // 火の粉パーティクルの更新
        for i in emberParticles.indices {
            emberParticles[i].y -= emberParticles[i].speedY
            emberParticles[i].x += emberParticles[i].speedX
            
            // ランダムな揺らぎ
            emberParticles[i].speedX += CGFloat.random(in: -0.15...0.15)
            emberParticles[i].speedY *= 0.996
            
            // ライフ減少
            emberParticles[i].life -= 0.006
            emberParticles[i].opacity = emberParticles[i].life
            
            // 再生成
            if emberParticles[i].life <= 0 || emberParticles[i].y < fireBaseY - 350 {
                emberParticles[i] = createEmberParticle(baseX: fireBaseX, baseY: fireBaseY, size: size, randomY: false)
            }
        }
    }
}

// MARK: - サブビュー

/// 神秘的な背景
struct MysticalBackground: View {
    let time: Double
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.01, green: 0.01, blue: 0.05),
                    Color(red: 0.03, green: 0.02, blue: 0.10),
                    Color(red: 0.06, green: 0.03, blue: 0.15),
                    Color(red: 0.10, green: 0.04, blue: 0.08)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 星の輝き
            GeometryReader { geometry in
                Canvas { context, size in
                    for i in 0..<60 {
                        let x = CGFloat((i * 67 + 19) % Int(max(1, size.width)))
                        let y = CGFloat((i * 43 + 11) % Int(max(1, size.height * 0.6)))
                        let starSize = CGFloat.random(in: 0.5...2.5)
                        let twinkle = sin(time * 3 + Double(i) * 0.4) * 0.4 + 0.6
                        
                        let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(Color.white.opacity(twinkle * 0.7))
                        )
                    }
                }
            }
        }
    }
}

/// 神秘的な環境グロー
struct MysticalAmbientGlow: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let pulse = 0.85 + sin(time * 1.5) * 0.15
        let centerX = size.width / 2
        let baseY = size.height * 0.72
        
        ZStack {
            // オレンジのグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.18 * pulse),
                            Color(hue: 0.08, saturation: 0.9, brightness: 0.7).opacity(0.08 * pulse),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.7
                    )
                )
                .frame(width: size.width * 1.5, height: size.height * 0.9)
                .position(x: centerX, y: baseY - 80)
            
            // 紫のアクセントグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0.8, saturation: 0.7, brightness: 1.0).opacity(0.08 * pulse),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.4
                    )
                )
                .frame(width: size.width * 0.8, height: size.height * 0.5)
                .position(x: centerX + 50, y: baseY - 150)
        }
    }
}

/// 神秘的な床の反射
struct MysticalFloorReflection: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let pulse = 0.8 + sin(time * 2.5) * 0.2
        
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.45 * pulse),
                            Color(hue: 0.05, saturation: 0.95, brightness: 0.8).opacity(0.2 * pulse),
                            Color(hue: 0.85, saturation: 0.6, brightness: 0.6).opacity(0.08 * pulse),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.55
                    )
                )
                .frame(width: size.width * 1.1, height: 180)
                .position(x: size.width / 2, y: size.height - 25)
        }
    }
}

/// 強化されたコアグロー形状
struct EnhancedCoreGlowShape: View {
    let particle: CoreGlowParticle
    let time: Double
    
    var body: some View {
        let shimmer = 0.8 + sin(time * 4 + particle.pulsePhase) * 0.2
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 1.0, brightness: 1.0).opacity(particle.opacity * shimmer),
                        Color(hue: particle.hue + 0.03, saturation: 0.9, brightness: 0.95).opacity(particle.opacity * 0.6 * shimmer),
                        Color(hue: particle.hue + 0.06, saturation: 0.7, brightness: 0.8).opacity(particle.opacity * 0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .position(x: particle.x, y: particle.y)
            .blur(radius: particle.size / 3)
    }
}

/// 強化された炎の形状
struct EnhancedFireFlameShape: View {
    let particle: FireParticle
    let time: Double
    
    var body: some View {
        let flicker = 0.85 + sin(time * 8 + Double(particle.swayOffset)) * 0.15
        
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 1.0, brightness: 1.0),
                        Color(hue: particle.hue + 0.02, saturation: 0.98, brightness: 0.98).opacity(0.9),
                        Color(hue: particle.hue + 0.05, saturation: 0.85, brightness: 0.8).opacity(0.5),
                        Color(hue: particle.hue + 0.1, saturation: 0.7, brightness: 0.6).opacity(0.2),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size * 1.8)
            .position(x: particle.x, y: particle.y)
            .opacity(particle.opacity * flicker)
            .blur(radius: particle.size / 12)
    }
}

/// 魔法の炎の形状
struct MagicFlameShape: View {
    let particle: MagicFlameParticle
    let time: Double
    
    var body: some View {
        let shimmer = 0.7 + sin(time * 3 + particle.swayPhase) * 0.3
        
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 0.8, brightness: 1.0).opacity(particle.opacity * shimmer),
                        Color(hue: particle.hue + 0.05, saturation: 0.6, brightness: 0.9).opacity(particle.opacity * 0.5 * shimmer),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size * 1.5)
            .position(x: particle.x, y: particle.y)
            .blur(radius: particle.size / 6)
    }
}

/// カラフルな火の粉の形状
struct ColorfulEmberShape: View {
    let particle: EmberParticle
    let time: Double
    
    var body: some View {
        let flicker = 0.6 + sin(time * 25 + Double(particle.id.hashValue % 100)) * 0.4
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 1.0, brightness: 1.0),
                        Color(hue: particle.hue + 0.02, saturation: 1.0, brightness: 0.9)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .opacity(particle.opacity * flicker)
            .shadow(color: Color(hue: particle.hue, saturation: 0.8, brightness: 1.0).opacity(particle.opacity * 0.8), radius: 5)
    }
}

/// 光のリング効果
struct LightRingEffect: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let centerX = size.width / 2
        let baseY = size.height * 0.72
        
        ForEach(0..<3, id: \.self) { i in
            let ringTime = time + Double(i) * 2
            let scale = (ringTime.truncatingRemainder(dividingBy: 6)) / 6
            let opacity = max(0, 0.3 - scale * 0.35)
            
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(opacity),
                            Color(hue: 0.08, saturation: 0.9, brightness: 1.0).opacity(opacity * 0.7),
                            Color(hue: 0.85, saturation: 0.6, brightness: 1.0).opacity(opacity * 0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 100 + CGFloat(scale) * 200, height: 40 + CGFloat(scale) * 80)
                .position(x: centerX, y: baseY)
                .blur(radius: 5)
        }
    }
}

// MARK: - パーティクルモデル

struct CoreGlowParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var hue: Double
    var pulsePhase: CGFloat
}

// MARK: - 後方互換性のためのサブビュー

struct DarkBackground: View {
    var body: some View {
        MysticalBackground(time: 0)
    }
}

struct AmbientFireGlow: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        MysticalAmbientGlow(size: size, time: time)
    }
}

struct FloorReflection: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        MysticalFloorReflection(size: size, time: time)
    }
}

struct CoreGlowShape: View {
    let particle: CoreGlowParticle
    
    var body: some View {
        EnhancedCoreGlowShape(particle: particle, time: 0)
    }
}

struct FireFlameShape: View {
    let particle: FireParticle
    
    var body: some View {
        EnhancedFireFlameShape(particle: particle, time: 0)
    }
}

struct EmberShape: View {
    let particle: EmberParticle
    let time: Double
    
    var body: some View {
        ColorfulEmberShape(particle: particle, time: time)
    }
}

#Preview {
    FireParticleView()
}
