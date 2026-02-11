//
//  CampfireParticleView.swift
//  SmokeCounter
//
//  美しい焚き火のパーティクルエフェクト
//  星空と炎が織りなす幻想的な映像を表現
//

import SwiftUI

/// 焚き火ビュー（炎 + 煙 + 薪 + 美しい星空）
struct CampfireParticleView: View {
    @State private var fireParticles: [CampfireFireParticle] = []
    @State private var smokeParticles: [CampfireSmokeParticle] = []
    @State private var sparkParticles: [SparkParticle] = []
    @State private var glowParticles: [GlowParticle] = []
    @State private var shootingStars: [ShootingStarParticle] = []
    @State private var animationTimer: Timer?
    @State private var time: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 美しい夜空の背景
                BeautifulNightSky(size: geometry.size, time: time)
                
                // 流れ星
                ForEach(shootingStars) { star in
                    ShootingStarShape(particle: star, time: time)
                }
                
                // 周囲の光の拡散（グロー効果）
                EnhancedAmbientGlow(size: geometry.size, time: time)
                
                // 地面の光の反射
                EnhancedGroundReflection(size: geometry.size, time: time)
                
                // 煙（後ろに配置）- カラフルに
                ForEach(smokeParticles) { particle in
                    ColorfulSmokeParticleShape(particle: particle, time: time)
                }
                
                // 薪（シルエット）
                EnhancedWoodLogsView(size: geometry.size, time: time)
                
                // 炎のグロー（背景）
                ForEach(glowParticles) { particle in
                    EnhancedGlowShape(particle: particle, time: time)
                }
                
                // 炎
                ForEach(fireParticles) { particle in
                    EnhancedFlameParticleShape(particle: particle, time: time)
                }
                
                // 火の粉
                ForEach(sparkParticles) { particle in
                    EnhancedSparkShape(particle: particle, time: time)
                }
                
                // ホタルのような光の粒
                FireflyLayer(size: geometry.size, time: time)
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
    
    // MARK: - パーティクル管理
    
    private func initializeParticles(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        
        let fireBaseY = max(150, size.height * 0.70)
        let fireBaseX = max(50, size.width / 2)
        
        // 炎パーティクル（多層）
        fireParticles = (0..<55).map { _ in
            createFireParticle(baseX: fireBaseX, baseY: fireBaseY, randomY: true)
        }
        
        // グローパーティクル
        glowParticles = (0..<10).map { _ in
            createGlowParticle(baseX: fireBaseX, baseY: fireBaseY)
        }
        
        // 煙パーティクル
        let smokeBaseY = max(50, fireBaseY - 80)
        smokeParticles = (0..<25).map { _ in
            createSmokeParticle(baseX: fireBaseX, baseY: smokeBaseY, size: size, randomY: true)
        }
        
        // 火の粉パーティクル
        sparkParticles = (0..<35).map { _ in
            createSparkParticle(baseX: fireBaseX, baseY: fireBaseY, randomY: true)
        }
        
        // 流れ星
        shootingStars = (0..<3).map { _ in
            createShootingStar(in: size)
        }
    }
    
    private func createFireParticle(baseX: CGFloat, baseY: CGFloat, randomY: Bool) -> CampfireFireParticle {
        let minY = max(0, baseY - 160)
        let maxY = max(minY + 1, baseY)
        let layer = Int.random(in: 0...2)
        let xSpread: CGFloat = CGFloat(layer + 1) * 18
        
        // 炎の色相バリエーション
        let hues: [Double] = [0.0, 0.02, 0.05, 0.08, 0.95, 0.92]
        
        return CampfireFireParticle(
            x: baseX + CGFloat.random(in: -xSpread...xSpread),
            y: randomY ? CGFloat.random(in: minY...maxY) : baseY,
            size: CGFloat.random(in: 28...75) - CGFloat(layer) * 12,
            opacity: CGFloat.random(in: 0.75...1.0),
            speed: CGFloat.random(in: 1.2...3.5),
            hue: hues.randomElement() ?? 0.05,
            swayPhase: CGFloat.random(in: 0...(.pi * 2)),
            layer: layer
        )
    }
    
    private func createGlowParticle(baseX: CGFloat, baseY: CGFloat) -> GlowParticle {
        let hues: [Double] = [0.02, 0.05, 0.08, 0.95, 0.0]
        
        return GlowParticle(
            x: baseX + CGFloat.random(in: -35...35),
            y: baseY - CGFloat.random(in: 25...90),
            size: CGFloat.random(in: 70...140),
            opacity: CGFloat.random(in: 0.4...0.7),
            hue: hues.randomElement() ?? 0.05,
            pulsePhase: CGFloat.random(in: 0...(.pi * 2))
        )
    }
    
    private func createSmokeParticle(baseX: CGFloat, baseY: CGFloat, size: CGSize, randomY: Bool) -> CampfireSmokeParticle {
        let maxY = max(1, baseY)
        // 煙にも淡い色を
        let hues: [Double] = [0.0, 0.55, 0.6, 0.7, 0.85]
        
        return CampfireSmokeParticle(
            x: baseX + CGFloat.random(in: -30...30),
            y: randomY ? CGFloat.random(in: 0...maxY) : baseY,
            size: CGFloat.random(in: 70...140),
            opacity: CGFloat.random(in: 0.15...0.35),
            speed: CGFloat.random(in: 0.5...1.2),
            swayPhase: CGFloat.random(in: 0...(.pi * 2)),
            hue: hues.randomElement() ?? 0.0
        )
    }
    
    private func createSparkParticle(baseX: CGFloat, baseY: CGFloat, randomY: Bool) -> SparkParticle {
        let minY = max(0, baseY - 220)
        let maxY = max(minY + 1, baseY)
        let hues: [Double] = [0.05, 0.08, 0.12, 0.95, 0.55]
        
        return SparkParticle(
            x: baseX + CGFloat.random(in: -40...40),
            y: randomY ? CGFloat.random(in: minY...maxY) : baseY,
            size: CGFloat.random(in: 2...8),
            opacity: CGFloat.random(in: 0.7...1.0),
            speedX: CGFloat.random(in: -0.7...0.7),
            speedY: CGFloat.random(in: 2.0...5.0),
            life: 1.0,
            hue: hues.randomElement() ?? 0.05
        )
    }
    
    private func createShootingStar(in size: CGSize) -> ShootingStarParticle {
        ShootingStarParticle(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height * 0.4),
            length: CGFloat.random(in: 50...150),
            speed: CGFloat.random(in: 3...8),
            opacity: 0,
            angle: Double.random(in: 0.3...0.8),
            delay: Double.random(in: 0...15),
            hue: Double.random(in: 0...1)
        )
    }
    
    private func startAnimation(in size: CGSize) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            time += 1/60
            updateParticles(in: size)
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateParticles(in size: CGSize) {
        let fireBaseY = max(150, size.height * 0.70)
        let fireBaseX = max(50, size.width / 2)
        
        // 炎の更新
        for i in fireParticles.indices {
            fireParticles[i].y -= fireParticles[i].speed
            
            let sway = sin(time * 3.5 + fireParticles[i].swayPhase) * 18 * (1.0 + CGFloat(fireParticles[i].layer) * 0.35)
            let sway2 = sin(time * 2.0 + fireParticles[i].swayPhase * 0.5) * 8
            fireParticles[i].x += (sway + sway2) * 0.045
            
            let progress = (fireBaseY - fireParticles[i].y) / 160
            fireParticles[i].hue = min(0.14, fireParticles[i].hue + 0.003)
            fireParticles[i].opacity = max(0, 1.0 - progress * 0.85)
            fireParticles[i].size *= 0.994
            
            if fireParticles[i].y < fireBaseY - 175 || fireParticles[i].opacity <= 0.04 {
                fireParticles[i] = createFireParticle(baseX: fireBaseX, baseY: fireBaseY, randomY: false)
            }
        }
        
        // グローの更新（脈動）
        for i in glowParticles.indices {
            let pulse = sin(time * 2.5 + glowParticles[i].pulsePhase) * 0.2 + 0.8
            glowParticles[i].opacity = CGFloat(pulse) * 0.6
            glowParticles[i].size = 90 + CGFloat(sin(time * 1.8 + glowParticles[i].pulsePhase)) * 25
        }
        
        // 煙の更新
        for i in smokeParticles.indices {
            smokeParticles[i].y -= smokeParticles[i].speed
            
            let sway = sin(time * 0.9 + smokeParticles[i].swayPhase) * 55
            smokeParticles[i].x += sway * 0.018
            
            let progress = 1 - (smokeParticles[i].y / size.height)
            smokeParticles[i].opacity = max(0, 0.35 - progress * 0.4)
            smokeParticles[i].size += 0.35
            
            if smokeParticles[i].y < -120 || smokeParticles[i].opacity <= 0.02 {
                smokeParticles[i] = createSmokeParticle(baseX: fireBaseX, baseY: fireBaseY - 80, size: size, randomY: false)
            }
        }
        
        // 火の粉の更新
        for i in sparkParticles.indices {
            sparkParticles[i].y -= sparkParticles[i].speedY
            sparkParticles[i].x += sparkParticles[i].speedX
            sparkParticles[i].speedX += CGFloat.random(in: -0.1...0.1)
            sparkParticles[i].speedY *= 0.994
            sparkParticles[i].life -= 0.007
            sparkParticles[i].opacity = sparkParticles[i].life * (0.75 + CGFloat(sin(time * 18)) * 0.25)
            
            if sparkParticles[i].life <= 0 {
                sparkParticles[i] = createSparkParticle(baseX: fireBaseX, baseY: fireBaseY, randomY: false)
            }
        }
        
        // 流れ星の更新
        for i in shootingStars.indices {
            if time > shootingStars[i].delay {
                let activeTime = time - shootingStars[i].delay
                if activeTime < 2.0 {
                    shootingStars[i].opacity = min(1.0, activeTime * 2)
                    shootingStars[i].x += shootingStars[i].speed * CGFloat(cos(shootingStars[i].angle))
                    shootingStars[i].y += shootingStars[i].speed * CGFloat(sin(shootingStars[i].angle))
                } else {
                    shootingStars[i].opacity = max(0, 1.0 - (activeTime - 2.0) * 2)
                }
                
                if shootingStars[i].x > size.width + 100 || shootingStars[i].y > size.height * 0.5 || activeTime > 3.0 {
                    shootingStars[i] = createShootingStar(in: size)
                    shootingStars[i].delay = time + Double.random(in: 5...20)
                }
            }
        }
    }
}

// MARK: - パーティクルモデル

struct CampfireFireParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var hue: Double
    var swayPhase: CGFloat
    var layer: Int
}

struct CampfireSmokeParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speed: CGFloat
    var swayPhase: CGFloat
    var hue: Double = 0.0
}

struct SparkParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var speedX: CGFloat
    var speedY: CGFloat
    var life: CGFloat
    var hue: Double = 0.05
}

struct GlowParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var hue: Double
    var pulsePhase: CGFloat
}

struct ShootingStarParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var length: CGFloat
    var speed: CGFloat
    var opacity: CGFloat
    var angle: Double
    var delay: Double
    var hue: Double
}

// MARK: - サブビュー

/// 美しい夜空の背景
struct BeautifulNightSky: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        ZStack {
            // 深い夜空のグラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.01, green: 0.02, blue: 0.08),
                    Color(red: 0.02, green: 0.03, blue: 0.12),
                    Color(red: 0.04, green: 0.04, blue: 0.18),
                    Color(red: 0.06, green: 0.05, blue: 0.20)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 天の川風の効果
            MilkyWayEffect(size: size, time: time)
            
            // 星空
            EnhancedStarsOverlay(size: size, time: time)
        }
    }
}

/// 天の川効果
struct MilkyWayEffect: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            // 天の川の帯を描画
            let path = Path { p in
                p.move(to: CGPoint(x: 0, y: canvasSize.height * 0.1))
                p.addQuadCurve(
                    to: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.35),
                    control: CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.15)
                )
                p.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.45))
                p.addQuadCurve(
                    to: CGPoint(x: 0, y: canvasSize.height * 0.2),
                    control: CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.25)
                )
                p.closeSubpath()
            }
            
            let gradient = Gradient(colors: [
                Color(hue: 0.7, saturation: 0.3, brightness: 0.4).opacity(0.08),
                Color(hue: 0.6, saturation: 0.2, brightness: 0.5).opacity(0.12),
                Color(hue: 0.55, saturation: 0.3, brightness: 0.4).opacity(0.08)
            ])
            
            context.fill(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: canvasSize.width, y: canvasSize.height * 0.4)
                )
            )
        }
        .blur(radius: 30)
    }
}

/// 強化された星のオーバーレイ
struct EnhancedStarsOverlay: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            guard canvasSize.width > 1 && canvasSize.height > 1 else { return }
            
            // 通常の星
            for i in 0..<80 {
                let x = CGFloat((i * 53 + 17) % Int(canvasSize.width))
                let y = CGFloat((i * 37 + 11) % Int(canvasSize.height * 0.55))
                let starSize = CGFloat.random(in: 0.8...2.5)
                let twinkle = sin(time * 2.5 + Double(i) * 0.4) * 0.35 + 0.65
                
                let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                context.fill(Circle().path(in: rect), with: .color(Color.white.opacity(twinkle * 0.9)))
            }
            
            // 明るい星（カラフル）
            let brightStarColors: [(hue: Double, x: CGFloat, y: CGFloat)] = [
                (0.6, canvasSize.width * 0.15, canvasSize.height * 0.08),
                (0.55, canvasSize.width * 0.75, canvasSize.height * 0.12),
                (0.95, canvasSize.width * 0.45, canvasSize.height * 0.05),
                (0.08, canvasSize.width * 0.85, canvasSize.height * 0.25),
                (0.7, canvasSize.width * 0.25, canvasSize.height * 0.22),
            ]
            
            for (index, star) in brightStarColors.enumerated() {
                let twinkle = sin(time * 1.5 + Double(index) * 0.7) * 0.3 + 0.7
                let starSize: CGFloat = 4
                
                // 星の光芒
                let glowRect = CGRect(x: star.x - 8, y: star.y - 8, width: 16, height: 16)
                context.fill(
                    Circle().path(in: glowRect),
                    with: .color(Color(hue: star.hue, saturation: 0.5, brightness: 1.0).opacity(twinkle * 0.3))
                )
                
                // 星本体
                let rect = CGRect(x: star.x - starSize/2, y: star.y - starSize/2, width: starSize, height: starSize)
                context.fill(
                    Circle().path(in: rect),
                    with: .color(Color(hue: star.hue, saturation: 0.3, brightness: 1.0).opacity(twinkle))
                )
            }
        }
    }
}

/// 流れ星の形状
struct ShootingStarShape: View {
    let particle: ShootingStarParticle
    let time: Double
    
    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color(hue: particle.hue, saturation: 0.3, brightness: 1.0).opacity(particle.opacity * 0.5),
                        Color.white.opacity(particle.opacity)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: particle.length, height: 2)
            .rotationEffect(.radians(particle.angle))
            .position(x: particle.x, y: particle.y)
            .blur(radius: 1)
    }
}

/// 強化された環境グロー
struct EnhancedAmbientGlow: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let centerX = size.width / 2
        let baseY = size.height * 0.70
        let pulse = 0.88 + sin(time * 1.8) * 0.12
        
        ZStack {
            // メインのオレンジグロー
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.18 * pulse),
                            Color(hue: 0.08, saturation: 0.8, brightness: 0.7).opacity(0.08 * pulse),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.65
                    )
                )
                .frame(width: size.width * 1.3, height: size.height * 0.85)
                .position(x: centerX, y: baseY - 40)
            
            // 紫のアクセント
            Ellipse()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0.8, saturation: 0.5, brightness: 0.8).opacity(0.06 * pulse),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.3
                    )
                )
                .frame(width: size.width * 0.6, height: size.height * 0.4)
                .position(x: centerX + 60, y: baseY - 120)
        }
    }
}

/// 強化された地面の反射
struct EnhancedGroundReflection: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let pulse = 0.82 + sin(time * 2.2) * 0.18
        
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.4 * pulse),
                        Color(hue: 0.05, saturation: 0.85, brightness: 0.7).opacity(0.18 * pulse),
                        Color(hue: 0.85, saturation: 0.4, brightness: 0.5).opacity(0.05 * pulse),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.5
                )
            )
            .frame(width: size.width * 0.95, height: 160)
            .position(x: size.width / 2, y: size.height - 30)
    }
}

/// カラフルな煙の形状
struct ColorfulSmokeParticleShape: View {
    let particle: CampfireSmokeParticle
    let time: Double
    
    var body: some View {
        let shimmer = 0.85 + sin(time * 0.8 + particle.swayPhase) * 0.15
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 0.2, brightness: 0.9).opacity(particle.opacity * shimmer * 0.6),
                        Color(hue: particle.hue, saturation: 0.15, brightness: 0.8).opacity(particle.opacity * shimmer * 0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.x, y: particle.y)
            .blur(radius: particle.size / 3.5)
    }
}

/// 強化されたグローの形状
struct EnhancedGlowShape: View {
    let particle: GlowParticle
    let time: Double
    
    var body: some View {
        let shimmer = 0.75 + sin(time * 3 + particle.pulsePhase) * 0.25
        
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 0.85, brightness: 1.0).opacity(particle.opacity * shimmer * 0.5),
                        Color(hue: particle.hue + 0.03, saturation: 0.65, brightness: 0.85).opacity(particle.opacity * shimmer * 0.25),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size
                )
            )
            .frame(width: particle.size * 2, height: particle.size * 2)
            .position(x: particle.x, y: particle.y)
            .blur(radius: particle.size / 2.5)
    }
}

/// 強化された炎の形状
struct EnhancedFlameParticleShape: View {
    let particle: CampfireFireParticle
    let time: Double
    
    var body: some View {
        let flicker = 0.85 + sin(time * 7 + particle.swayPhase) * 0.15
        
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hue: particle.hue, saturation: 1.0, brightness: 1.0),
                        Color(hue: particle.hue + 0.02, saturation: 0.95, brightness: 0.97).opacity(0.92),
                        Color(hue: particle.hue + 0.05, saturation: 0.82, brightness: 0.75).opacity(0.55),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: particle.size / 2
                )
            )
            .frame(width: particle.size, height: particle.size * 1.7)
            .position(x: particle.x, y: particle.y)
            .opacity(particle.opacity * flicker)
            .blur(radius: particle.size / 10)
    }
}

/// 強化された火の粉の形状
struct EnhancedSparkShape: View {
    let particle: SparkParticle
    let time: Double
    
    var body: some View {
        let flicker = 0.6 + sin(time * 20 + Double(particle.id.hashValue % 100)) * 0.4
        
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
            .shadow(color: Color(hue: particle.hue, saturation: 0.9, brightness: 1.0).opacity(particle.opacity * 0.85), radius: 4)
    }
}

/// ホタルのような光の粒レイヤー
struct FireflyLayer: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        Canvas { context, canvasSize in
            for i in 0..<15 {
                let baseX = CGFloat((i * 67 + 23) % Int(max(1, canvasSize.width)))
                let baseY = CGFloat((i * 41 + 17) % Int(max(1, canvasSize.height * 0.6))) + canvasSize.height * 0.3
                
                let offsetX = sin(time * 0.5 + Double(i) * 0.8) * 20
                let offsetY = cos(time * 0.4 + Double(i) * 0.6) * 15
                
                let x = baseX + CGFloat(offsetX)
                let y = baseY + CGFloat(offsetY)
                
                let twinkle = max(0, sin(time * 2 + Double(i) * 1.2))
                let opacity = twinkle * 0.6
                
                if opacity > 0.1 {
                    let hue = Double(i % 3) * 0.3 + 0.1  // 暖色系
                    let glowSize: CGFloat = 12
                    
                    let glowRect = CGRect(x: x - glowSize/2, y: y - glowSize/2, width: glowSize, height: glowSize)
                    context.fill(
                        Circle().path(in: glowRect),
                        with: .color(Color(hue: hue, saturation: 0.6, brightness: 1.0).opacity(opacity * 0.4))
                    )
                    
                    let coreRect = CGRect(x: x - 2, y: y - 2, width: 4, height: 4)
                    context.fill(
                        Circle().path(in: coreRect),
                        with: .color(Color(hue: hue, saturation: 0.4, brightness: 1.0).opacity(opacity))
                    )
                }
            }
        }
    }
}

/// 強化された薪のシルエット
struct EnhancedWoodLogsView: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        let centerX = size.width / 2
        let baseY = size.height * 0.76
        let glowPulse = 0.65 + sin(time * 2.8) * 0.35
        
        ZStack {
            // 薪の光の縁取り
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.5 * glowPulse),
                            Color(hue: 0.05, saturation: 0.9, brightness: 1.0).opacity(0.3 * glowPulse)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
                .frame(width: 110, height: 24)
                .rotationEffect(.degrees(-12))
                .position(x: centerX - 20, y: baseY)
                .blur(radius: 3)
            
            // 横の薪
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.12, blue: 0.06),
                            Color(red: 0.14, green: 0.08, blue: 0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 105, height: 22)
                .rotationEffect(.degrees(-12))
                .position(x: centerX - 20, y: baseY)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.17, green: 0.10, blue: 0.04),
                            Color(red: 0.12, green: 0.06, blue: 0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 95, height: 20)
                .rotationEffect(.degrees(15))
                .position(x: centerX + 15, y: baseY + 8)
            
            // 立てかけた薪
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(red: 0.14, green: 0.08, blue: 0.03))
                .frame(width: 18, height: 80)
                .rotationEffect(.degrees(28))
                .position(x: centerX - 40, y: baseY - 30)
            
            RoundedRectangle(cornerRadius: 7)
                .fill(Color(red: 0.16, green: 0.09, blue: 0.04))
                .frame(width: 18, height: 75)
                .rotationEffect(.degrees(-22))
                .position(x: centerX + 35, y: baseY - 25)
        }
    }
}

// MARK: - 後方互換性のためのサブビュー

struct NightSkyBackground: View {
    var body: some View {
        BeautifulNightSky(size: CGSize(width: 400, height: 800), time: 0)
    }
}

struct StarsOverlay: View {
    var body: some View {
        EnhancedStarsOverlay(size: CGSize(width: 400, height: 800), time: 0)
    }
}

struct AmbientGlow: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        EnhancedAmbientGlow(size: size, time: time)
    }
}

struct GroundReflection: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        EnhancedGroundReflection(size: size, time: time)
    }
}

struct SmokeParticleShape: View {
    let particle: CampfireSmokeParticle
    
    var body: some View {
        ColorfulSmokeParticleShape(particle: particle, time: 0)
    }
}

struct WoodLogsView: View {
    let size: CGSize
    let time: Double
    
    var body: some View {
        EnhancedWoodLogsView(size: size, time: time)
    }
}

struct FlameParticleShape: View {
    let particle: CampfireFireParticle
    
    var body: some View {
        EnhancedFlameParticleShape(particle: particle, time: 0)
    }
}

#Preview {
    CampfireParticleView()
}
