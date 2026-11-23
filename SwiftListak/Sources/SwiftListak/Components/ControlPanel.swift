import SwiftUI

public struct ControlPanel: View {
    public let currentStep: Int
    public let totalSteps: Int
    public let isPlaying: Bool
    public let onStepBackward: () -> Void
    public let onStepForward: () -> Void
    public let onPlayPauseToggle: () -> Void
    public let onReset: () -> Void
    
    @Binding public var speedSeconds: Double
    
    public init(
        currentStep: Int,
        totalSteps: Int,
        isPlaying: Bool,
        speedSeconds: Binding<Double>,
        onStepBackward: @escaping () -> Void,
        onStepForward: @escaping () -> Void,
        onPlayPauseToggle: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.isPlaying = isPlaying
        self._speedSeconds = speedSeconds
        self.onStepBackward = onStepBackward
        self.onStepForward = onStepForward
        self.onPlayPauseToggle = onPlayPauseToggle
        self.onReset = onReset
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Step Counters
            HStack(spacing: 4) {
                Text("STEP")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                Text("\(totalSteps > 0 ? currentStep + 1 : 0)")
                    .font(AppTheme.monoFont(size: 11))
                    .bold()
                Text("/")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("\(totalSteps)")
                    .font(AppTheme.monoFont(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(4)
            
            Divider().frame(height: 20)
            
            // Media Controls Toolbar (Unified Xcode Style)
            HStack(spacing: 8) {
                // Restart / Reset
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)
                .help("Restart visualization")
                
                // Step Back
                Button(action: onStepBackward) {
                    Image(systemName: "backward.frame")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)
                .disabled(currentStep <= 0)
                .opacity(currentStep <= 0 ? 0.4 : 1.0)
                .help("Previous step")
                
                // Play / Pause Toggle
                Button(action: onPlayPauseToggle) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help(isPlaying ? "Pause autoplay" : "Play automatically")
                
                // Step Forward
                Button(action: onStepForward) {
                    Image(systemName: "forward.frame")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.plain)
                .disabled(totalSteps == 0 || currentStep >= totalSteps - 1)
                .opacity(totalSteps == 0 || currentStep >= totalSteps - 1 ? 0.4 : 1.0)
                .help("Next step")
            }
            
            Divider().frame(height: 20)
            
            // Speed Slider
            HStack(spacing: 8) {
                Image(systemName: "gauge.medium")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                
                Slider(value: $speedSeconds, in: 0.5...3.0, step: 0.5) {
                    Text("Autoplay Delay")
                }
                .frame(width: 100)
                .controlSize(.mini)
                
                Text(String(format: "%.1fs", speedSeconds))
                    .font(AppTheme.monoFont(size: 10))
                    .foregroundColor(.secondary)
                    .frame(width: 28, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

#if !os(Windows)
#Preview {
    ControlPanel(
        currentStep: 2,
        totalSteps: 5,
        isPlaying: false,
        speedSeconds: .constant(1.5),
        onStepBackward: {},
        onStepForward: {},
        onPlayPauseToggle: {},
        onReset: {}
    )
    .padding()
}
#endif
