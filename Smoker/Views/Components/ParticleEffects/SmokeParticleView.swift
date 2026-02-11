//
//  SmokeParticleView.swift
//  SmokeCounter
//
//  オーロラ風のカラフルな煙パーティクルエフェクト
//  幻想的で癒される美しい映像を表現
//

import SwiftUI

/// オーロラ煙パーティクルのデータモデル
struct AuroraSmokeParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var swayOffset: Double
    var swaySpeed: Double
    var rotation: Double
    var rotationSpeed: Double
    var hue: Double
    var hueSpeed: Double  // 色相の変化速度
}

/// 光の筋パーティクル
struct LightStreamParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var length: CGFloat
    var width: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var hue: Double
    var angle: Double
}

/// 輝く粒子パーティクル
struct GlitterParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var twinklePhase: Double
    var hue: Double
}

/// オーロラ風カラフル煙のパーティクルエフェクトビュー
struct SmokeParticleView: View {
    @State private var particles: [AuroraSmokeParticle] = []
    @State private var lightStreams: [LightStreamParticle] = []
    @State private var glitters: [GlitterParticle] = []
    @State private var animationTimer: Timer?
    @State private var time: Double = 0
    
    /// パーティクルの数
    var particleCount: Int = 40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 深い宇宙のような背景
                CosmicBackground(time: time)
                
                // 背景のオーロラ波
                AuroraWaveLayer(size: geometry.size, time: time)
                
                // 光の筋（流れ星のような）
                ForEach(lightStreams) { stream in
                    LightStreamShape(particle: stream, time: time)
                }
                
                // メインのオーロラ煙パーティクル
                ForEach(particles) { particle in
                    AuroraSmokeShape(particle: particle, time: time)
                }
                
                // 輝く粒子（キラキラ）
                ForEach(glitters) { glitter in
                    GlitterShape(particle: glitter, time: time)
                }
                
                // 前景のグロー効果
                ForegroundGlow(size: geometry.size, time: time)
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
        
        particles = (0..<particleCount).map { _ in
            createParticle(in: size, randomY: true)
        }
        
        lightStreams = (0..<12).map { _ in
            createLightStream(in: size, randomY: true)
        }
        
        glitters = (0..<60).map { _ in
            createGlitter(in: size)
        }
    }
    
    /// 新しいオーロラ煙パーティクルを作成
    private func createParticle(in size: CGSize, randomY: Bool) -> AuroraSmokeParticle {
        let hues: [Double] = [
            0.5,   // シアン
            0.55,  // ターコイズ
            0.6,   // 青
            0.75,  // 紫
            0.85,  // マゼンタ
            0.95,  // ピンク
            0.3,   // 緑
        ]
        
        return AuroraSmokeParticle(
            x: CGFloat.random(in: 0...size.width),
            y: randomY ? CGFloat.random(in: 0...size.height) : size.height + 80,
            size: CGFloat.random(in: 100...220),
            opacity: CGFloat.random(in: 0.3...0.6),
            speed: CGFloat.random(in: 0.4...1.0),
            swayOffset: Double.random(in: -80...80),
            swaySpeed: Double.random(in: 0.2...0.8),
            rotation: Double.random(in: 0...360),
            rotationSpeed: Double.random(in: -0.2...0.2),
            hue: hues.randomElement() ?? 0.5,
            hueSpeed: Double.random(in: 0.01...0.03)
        )
    }
    
    /// 光の筋パーティクルを作成
    private func createLightStream(in size: CGSize, randomY: Bool) -> LightStreamParticle {
        LightStreamParticle(
            x: CGFloat.random(in: 0...size.width),
            y: randomY ? CGFloat.random(in: 0...size.height) : size.height + 50,
            length: CGFloat.random(in: 100...300),
            width: CGFloat.random(in: 2...8),
            opacity: CGFloat.random(in: 0.2...0.5),
            speed: CGFloat.random(in: 0.8...2.0),
            hue: Double.random(in: 0.4...0.9),
            angle: Double.random(in: -0.3...0.3)
        )
    }
    
    /// 輝く粒子を作成
    private func createGlitter(in size: CGSize) -> GlitterParticle {
        GlitterParticle(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height),
            size: CGFloat.random(in: 2...6),
            opacity: CGFloat.random(in: 0.3...0.9),
            twinklePhase: Double.random(in: 0...(Double.pi * 2)),
            hue: Double.random(in: 0...1)
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
        // オーロラ煙パーティクルの更新
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            
            // 複雑な揺らぎ
            let swayValue = sin(time * particles[i].swaySpeed + particles[i].swayOffset) * 40
            let swayValue2 = sin(time * particles[i].swaySpeed * 0.7 + particles[i].swayOffset * 1.5) * 20
            particles[i].x += CGFloat(swayValue + swayValue2) * 0.012
            
            // 回転
            particles[i].rotation += particles[i].rotationSpeed
            
            // 色相の変化（ゆっくり）
            particles[i].hue += particles[i].hueSpeed * 0.01
            if particles[i].hue > 1 { particles[i].hue -= 1 }
            
            // 上に行くほど透明に & サイズ拡大
            let progress = 1 - (particles[i].y / size.height)
            particles[i].opacity = max(0, 0.6 - progress * 0.65)
            particles[i].size += 0.15
            
            // 画面外に出たら再生成
            if particles[i].y < -180 || particles[i].opacity <= 0.02 {
                particles[i] = createParticle(in: size, randomY: false)
            }
        }
        
        // 光の筋の更新
        for i in lightStreams.indices {
            lightStreams[i].y -= lightStreams[i].speed
            lightStreams[i].x += CGFloat(sin(time * 0.5 + Double(i))) * 0.3
            
            let progress = 1 - (lightStreams[i].y / size.height)
            lightStreams[i].opacity = max(0, 0.5 - progress * 0.55)
            
            if lightStreams[i].y < -lightStreams[i].length {
                lightStreams[i] = createLightStream(in: size, randomY: false)
            }
        }
        
        // 輝く粒子の更新（位置は固定、明滅のみ）
        for i in glitters.indices {
            glitters[i].twinklePhase += 0.05
        }
    }
}

// MARK: - サブビュー

/// 宇宙のような深い背景
struct CosmicBackground: View {
    let time: Double
    
    var body: some View {
        ZStack {
            // ベースグラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.04, green: 0.02, blue: 0.12),
                    Color(red: 0.06, green: 0.03, blue: 0.15),
                    Color(red: 0.03, green: 0.02, blue: 0.10)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 動く星雲効果
            GeometryReader { geometry in
                Canvas { context, size in
                    // 星を描画
                    for i in 0..<100 {
                        let x = CGFloat((i * 73 + 17) % Int(max(1, size.width)))
                        let y = CGFloat((i * 41 + 23) % Int(max(1, size.height)))
                        let starSize = CGFloat.random(in: 0.5...2.0)
                        let twinkle = sin(time * 2 + Double(i) * 0.3) * 0.3 + 0.7
                        
                        let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(Color.white.opacity(twinkle * 0.8))
                        )
                    }
                }
            }
        }
    }
}

/// オーロラ波のデータ
struct AuroraWaveData {
    let hue: Double
    let yOffset: Double
    let amplitude: Double
    let speed: Double
}

/// オーロラの波レイヤー
struct AuroraWaveLayer: View {
    let size: CGSize
    let time: Double
    
    // 波のデータを事前に定義
    private let waves: [AuroraWaveData] = [
        AuroraWaveData(hue: 0.5, yOffset: 0.3, amplitude: 60.0, speed: 0.3),
        AuroraWaveData(hue: 0.6, yOffset: 0.45, amplitude: 80.0, speed: 0.25),
        AuroraWaveData(hue: 0.75, yOffset: 0.55, amplitude: 50.0, speed: 0.35),
        AuroraWaveData(hue: 0.85, yOffset: 0.65, amplitude: 70.0, speed: 0.2)
    ]
    
    var body: some View {
        Canvas { context, canvasSize in
            drawWaves(context: context, canvasSize: canvasSize)
        }
        .blur(radius: 30)
    }
    
    /// 波を描画
    private func drawWaves(context: GraphicsContext, canvasSize: CGSize) {
        for wave in waves {
            let path = createWavePath(wave: wave, canvasSize: canvasSize)
            let gradient = createWaveGradient(hue: wave.hue)
            let baseY = canvasSize.height * wave.yOffset
            
            context.fill(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: canvasSize.width / 2, y: baseY - 50),
                    endPoint: CGPoint(x: canvasSize.width / 2, y: canvasSize.height)
                )
            )
        }
    }
    
    /// 波のパスを作成
    private func createWavePath(wave: AuroraWaveData, canvasSize: CGSize) -> Path {
        var path = Path()
        let baseY = canvasSize.height * wave.yOffset
        
        path.move(to: CGPoint(x: 0, y: baseY))
        
        for x in stride(from: CGFloat(0), to: canvasSize.width, by: 5) {
            let normalizedX = x / canvasSize.width
            let waveY = calculateWaveY(
                baseY: baseY,
                normalizedX: normalizedX,
                amplitude: wave.amplitude,
                speed: wave.speed
            )
            path.addLine(to: CGPoint(x: x, y: waveY))
        }
        
        path.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height))
        path.addLine(to: CGPoint(x: 0, y: canvasSize.height))
        path.closeSubpath()
        
        return path
    }
    
    /// 波のY座標を計算
    private func calculateWaveY(baseY: CGFloat, normalizedX: CGFloat, amplitude: Double, speed: Double) -> CGFloat {
        let wave1 = sin(Double(normalizedX) * 4 * .pi + time * speed) * amplitude
        let wave2 = sin(Double(normalizedX) * 2 * .pi + time * speed * 0.7) * amplitude * 0.5
        return baseY + CGFloat(wave1 + wave2)
    }
    
    /// 波のグラデーションを作成
    private func createWaveGradient(hue: Double) -> Gradient {
        let color1 = Color(hue: hue, saturation: 0.8, brightness: 1.0).opacity(0.15)
        let color2 = Color(hue: hue + 0.1, saturation: 0.6, brightness: 0.8).opacity(0.08)
        return Gradient(colors: [color1, color2, Color.clear])
    }
}

/// オーロラ煙の形状
struct AuroraSmokeShape: View {
    let particle: AuroraSmokeParticle
    let time: Double
    
    var body: some View {
        let pulsingOpacity = particle.opacity * (0.8 + sin(time * 1.5 + particle.swayOffset) * 0.2)
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 0.9, brightness: 1.0).opacity(pulsingOpacity),
                        Color(hue: particle.hue + 0.05, saturation: 0.7, brightness: 0.9).opacity(pulsingOpacity * 0.6),
                        Color(hue: particle.hue + 0.1, saturation: 0.5, brightness: 0.8).opacity(pulsingOpacity * 0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(particle.rotation))
            .position(x: particle.x, y: particle.y)
            .blur(radius: particle.size / 6)
    }
}

/// 光の筋の形状
struct LightStreamShape: View {
    let particle: LightStreamParticle
    let time: Double
    
    var body: some View {
        let shimmer = 0.7 + sin(time * 3 + particle.hue * 10) * 0.3
        
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color(hue: particle.hue, saturation: 0.8, brightness: 1.0).opacity(particle.opacity * shimmer),
                        Color(hue: particle.hue, saturation: 0.9, brightness: 1.0).opacity(particle.opacity * shimmer * 0.8),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: particle.width, height: particle.length)
            .rotationEffect(.degrees(particle.angle * 180 / .pi))
            .position(x: particle.x, y: particle.y)
            .blur(radius: 3)
    }
}

/// 輝く粒子の形状
struct GlitterShape: View {
    let particle: GlitterParticle
    let time: Double
    
    var body: some View {
        let twinkle = max(0, sin(time * 4 + particle.twinklePhase))
        let brightness = twinkle * particle.opacity
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 0.3, brightness: 1.0).opacity(brightness),
                        Color(hue: particle.hue, saturation: 0.5, brightness: 0.9).opacity(brightness * 0.5),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 3, height: particle.size * 3)
            .position(x: particle.x, y: particle.y)
    }
}

/// 前景のグロー効果
struct ForegroundGlow: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        ZStack {
            // 下部のカラフルなグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0.55 + sin(time * 0.2) * 0.1, saturation: 0.7, brightness: 1.0).opacity(0.15),
                            Color(hue: 0.75 + sin(time * 0.15) * 0.1, saturation: 0.5, brightness: 0.8).opacity(0.08),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.6
                    )
                )
                .frame(width: size.width * 1.2, height: size.height * 0.5)
                .position(x: size.width / 2, y: size.height * 0.85)
            
            // 上部のアクセントグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0.85 + sin(time * 0.25) * 0.1, saturation: 0.6, brightness: 1.0).opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.4
                    )
                )
                .frame(width: size.width * 0.8, height: size.height * 0.3)
                .position(x: size.width * 0.3, y: size.height * 0.2)
        }
    }
}

// MARK: - 後方互換性のための構造体

/// 後方互換性のためのColorSmokeParticle
struct ColorSmokeParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var swayPhase: Double
    var hue: Double
}

#Preview {
    SmokeParticleView()
}
