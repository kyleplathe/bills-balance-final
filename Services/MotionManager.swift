import CoreMotion
import Foundation

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    private let threshold = 2.2
    private var onShake: (() -> Void)?

    func start(onShake: @escaping () -> Void) {
        self.onShake = onShake
        guard manager.isAccelerometerAvailable else { return }

        manager.accelerometerUpdateInterval = 0.2
        manager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard
                let self,
                let acceleration = data?.acceleration
            else { return }

            let magnitude = abs(acceleration.x) + abs(acceleration.y) + abs(acceleration.z)
            if magnitude > threshold {
                self.onShake?()
            }
        }
    }

    func stop() {
        manager.stopAccelerometerUpdates()
    }
}
