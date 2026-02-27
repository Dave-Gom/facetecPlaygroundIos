//
//  ViewController.swift
//  facetecPlayground
//

import UIKit
import AVFoundation
import FaceTecSDK

class ViewController: UIViewController, FaceTecInitializeCallback {

    var facetecSDKInstance: FaceTecSDKInstance?
    var containerView: UIView?
    var faceTecVC: UIViewController?

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

        guard let sdkInstance = facetecSDKInstance else {
            print("SDK no inicializado")
            return
        }

        // Crear contenedor si no existe
        if containerView == nil {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .black

            view.addSubview(container)

            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                container.topAnchor.constraint(equalTo: view.topAnchor),
                container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            containerView = container
        }

        guard let container = containerView else { return }

        //  Crear FaceTec VC
        let faceTec = sdkInstance.start3DLiveness(with: SessionRequestProcessor())
        faceTec.title = ""
        faceTec.editButtonItem.title = "Custom text"
        var button = UIButton()
        button.titleLabel?.text = "Custom text"
        button.addTarget(self, action: #selector(StartButtonPressed(_:)), for: .touchUpInside)
        faceTec.view.addSubview(button)

        // Containment correcto
        addChild(faceTec)
        container.addSubview(faceTec.view)
        faceTec.view.frame = container.bounds
        faceTec.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        faceTec.didMove(toParent: self)

        self.faceTecVC = faceTec
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
}
