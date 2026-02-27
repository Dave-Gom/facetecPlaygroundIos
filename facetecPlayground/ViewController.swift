//
//  ViewController.swift
//  facetecPlayground
//

import UIKit
import AVFoundation
import FaceTecSDK

class ViewController: UIViewController, FaceTecInitializeCallback {

    var facetecSDKInstance: FaceTecSDKInstance?
    var livenessView: Custom3DLivenessView?

    override func viewDidLoad() {
        super.viewDidLoad()

        FaceTec.sdk.initializeWithSessionRequest(
            deviceKeyIdentifier: Config.DeviceKeyIdentifier,
            sessionRequestProcessor: SessionRequestProcessor(),
            completion: self
        )
    }

    // MARK: - FaceTec Init

    func onFaceTecSDKInitializeSuccess(sdkInstance: FaceTecSDKInstance) {
        print("inicializando...")
        self.facetecSDKInstance = sdkInstance
        print("inicializado!")
    }

    func onFaceTecSDKInitializeError(error: FaceTecInitializationError) {
        print(FaceTec.sdk.description(for: error))
    }

    // MARK: - Button Action

    @IBAction func StartButtonPressed(_ sender: UIButton) {

        print("✅ Botón presionado!")

        guard facetecSDKInstance != nil else {
            print("SDK no inicializado")
            return
        }

        requestCameraPermission { [weak self] granted in
            guard let self = self else { return }

            if granted {
                DispatchQueue.main.async {
                    self.showLivenessView()
                }
            } else {
                print("❌ Permiso de cámara denegado")
            }
        }
    }

    // MARK: - Camera Permission

    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {

        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .authorized:
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    // MARK: - Show Camera View

    private func showLivenessView() {

        if livenessView != nil { return }

        print("Creando Custom3DLivenessView...")

        let customView = Custom3DLivenessView()
        customView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(customView)

        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.bringSubviewToFront(customView)

        livenessView = customView

        print("✅ LivenessView agregada a pantalla")
    }
}
