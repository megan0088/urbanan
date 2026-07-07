import SwiftUI
@preconcurrency import AVFoundation

struct QRCodeCameraView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onCodeScanned = onCodeScanned
        controller.onPermissionDenied = onPermissionDenied
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    var onPermissionDenied: (() -> Void)?
    private let session = AVCaptureSession()
    private var hasScanned = false
    private var isConfigured = false

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraAccessIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        startSessionIfReady()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }

    /// Explicitly checks/requests authorization BEFORE touching AVCaptureDevice.
    /// Without NSCameraUsageDescription in Info.plist, this call itself won't crash,
    /// but AVFoundation will refuse to ever show the system prompt and .denied/.restricted
    /// will never resolve to .authorized — the missing Info.plist key is still required.
    private func requestCameraAccessIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.configureSession()
                        self.startSessionIfReady()
                    } else {
                        self.onPermissionDenied?()
                    }
                }
            }
        case .denied, .restricted:
            onPermissionDenied?()
        @unknown default:
            onPermissionDenied?()
        }
    }

    private func startSessionIfReady() {
        guard isConfigured, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.startRunning()
        }
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
//        previewLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.addSublayer(previewLayer)

        isConfigured = true
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = object.stringValue else { return }
        hasScanned = true
        onCodeScanned?(stringValue)
    }
}
