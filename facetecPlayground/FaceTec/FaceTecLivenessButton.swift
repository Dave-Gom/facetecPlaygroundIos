import UIKit
import FaceTecSDK

protocol FaceTecLivenessButtonDelegate: AnyObject {
    func faceTecLivenessDidComplete(success: Bool, result: FaceTecSessionResult?)
}

class FaceTecLivenessButton: UIButton, FaceTecInitializeCallback {

    // MARK: - Properties

    weak var delegate: FaceTecLivenessButtonDelegate?

    private var facetecSDKInstance: FaceTecSDKInstance?
    private var isSDKReady = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        setTitle("Inicializando...", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemGray
        layer.cornerRadius = 8
        isEnabled = false

        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        initializeFaceTec()
    }

    // MARK: - FaceTec Initialization

    private func initializeFaceTec() {
        FaceTec.sdk.initializeWithSessionRequest(
            deviceKeyIdentifier: Config.DeviceKeyIdentifier,
            sessionRequestProcessor: SessionRequestProcessor(),
            completion: self
        )
    }

    func onFaceTecSDKInitializeSuccess(sdkInstance: FaceTecSDKInstance) {
        self.facetecSDKInstance = sdkInstance
        self.isSDKReady = true

        DispatchQueue.main.async {
            self.setTitle("Iniciar prueba de vida", for: .normal)
            self.backgroundColor = .systemBlue
            self.isEnabled = true
        }
    }

    func onFaceTecSDKInitializeError(error: FaceTecInitializationError) {
        DispatchQueue.main.async {
            self.setTitle("Error de inicialización", for: .normal)
            self.backgroundColor = .systemRed
            self.isEnabled = false
        }
        print("FaceTec init error: \(FaceTec.sdk.description(for: error))")
    }

    // MARK: - Button Action

    @objc private func buttonPressed() {
        guard isSDKReady, let sdkInstance = facetecSDKInstance else {
            return
        }

        guard let parentVC = findParentViewController() else {
            print("No se encontró el ViewController padre")
            return
        }

        startLiveness(sdkInstance: sdkInstance, parentVC: parentVC)
    }

    private func startLiveness(sdkInstance: FaceTecSDKInstance, parentVC: UIViewController) {
        // Crear contenedor
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .black
        container.tag = 999 // Tag para identificarlo después

        parentVC.view.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
            container.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
            container.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor)
        ])

        // Crear processor con callback
        let processor = SessionRequestProcessor()
        processor.onComplete = { [weak self, weak parentVC] result in
            DispatchQueue.main.async {
                self?.handleLivenessResult(result, parentVC: parentVC)
            }
        }

        // Crear FaceTec VC
        let faceTecVC = sdkInstance.start3DLiveness(with: processor)

        // Containment
        parentVC.addChild(faceTecVC)
        container.addSubview(faceTecVC.view)
        faceTecVC.view.frame = container.bounds
        faceTecVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        faceTecVC.didMove(toParent: parentVC)
    }

    // MARK: - Handle Result

    private func handleLivenessResult(_ result: FaceTecSessionResult, parentVC: UIViewController?) {
        let success = result.sessionStatus == .sessionCompleted

        switch result.sessionStatus {
        case .sessionCompleted:
            print("Liveness completado exitosamente")
        case .userCancelledFaceScan:
            print("Usuario canceló el proceso")
        case .requestAborted:
            print("Request abortada")
        default:
            print("Otro resultado: \(result.sessionStatus)")
        }

        // Limpiar UI
        cleanup(parentVC: parentVC)

        // Notificar al delegate
        delegate?.faceTecLivenessDidComplete(success: success, result: result)
    }

    private func cleanup(parentVC: UIViewController?) {
        guard let parentVC = parentVC else { return }

        // Remover FaceTec VC
        for child in parentVC.children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Remover contenedor
        parentVC.view.viewWithTag(999)?.removeFromSuperview()
    }

    // MARK: - Helpers

    private func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
