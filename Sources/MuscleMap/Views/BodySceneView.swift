import SwiftUI
import SceneKit

struct BodySceneView: UIViewRepresentable {
    @Binding var selectedMuscleId: String?
    var lastTrainedByMuscle: [String: Date]
    var onTap: (String) -> Void

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = BodySceneBuilder.makeScene()
        view.allowsCameraControl = true
        view.backgroundColor = UIColor.systemBackground
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard let scene = view.scene else { return }
        updateColors(in: scene)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Color Update

    private func updateColors(in scene: SCNScene) {
        let allNodeNames = MuscleNodeMap.nodeToMuscleId.keys
        for nodeName in allNodeNames {
            guard let node = scene.rootNode.childNode(withName: nodeName, recursively: true) else { continue }
            let muscleId = MuscleNodeMap.nodeToMuscleId[nodeName]!

            if muscleId == selectedMuscleId {
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemOrange
            } else {
                node.geometry?.firstMaterial?.diffuse.contents = color(for: muscleId)
            }
        }
    }

    private func color(for muscleId: String) -> UIColor {
        guard let date = lastTrainedByMuscle[muscleId] else {
            return UIColor.systemGray4
        }
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 999
        switch days {
        case 0:      return UIColor.systemGreen
        case 1...3:  return UIColor.systemBlue
        case 4...7:  return UIColor.systemYellow
        default:     return UIColor.systemRed
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject {
        var parent: BodySceneView

        init(_ parent: BodySceneView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? SCNView else { return }
            let loc = gesture.location(in: view)
            let hits = view.hitTest(loc, options: nil)
            if let name = hits.first?.node.name,
               let muscleId = MuscleNodeMap.nodeToMuscleId[name] {
                parent.onTap(muscleId)
            }
        }
    }
}

// MARK: - BodySceneBuilder

enum BodySceneBuilder {
    static func makeScene() -> SCNScene {
        let scene = SCNScene()

        // カメラ
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.position = SCNVector3(0, 0.5, 4)
        scene.rootNode.addChildNode(cam)

        // 環境光
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 400
        scene.rootNode.addChildNode(ambient)

        for node in buildBodyNodes() {
            scene.rootNode.addChildNode(node)
        }
        return scene
    }

    private static func buildBodyNodes() -> [SCNNode] {
        var nodes: [SCNNode] = []

        // 頭・首（インタラクションなし）
        nodes += [
            node(name: "head",    geo: SCNSphere(radius: 0.16),                        pos: (0, 1.72, 0),    color: .systemGray3),
            node(name: "neck",    geo: SCNCylinder(radius: 0.07, height: 0.15),        pos: (0, 1.53, 0),    color: .systemGray3),
        ]

        // 前面トルソ
        nodes += [
            node(name: "chest",  geo: SCNBox(width: 0.68, height: 0.40, length: 0.18, chamferRadius: 0.03),
                 pos: (0, 1.22, 0.02), color: .systemGray4),
            node(name: "abs",    geo: SCNBox(width: 0.58, height: 0.38, length: 0.15, chamferRadius: 0.03),
                 pos: (0, 0.82, 0.02), color: .systemGray4),
        ]

        // 後面トルソ
        nodes += [
            node(name: "traps",  geo: SCNBox(width: 0.66, height: 0.25, length: 0.16, chamferRadius: 0.03),
                 pos: (0, 1.38, -0.04), color: .systemGray4),
            node(name: "back",   geo: SCNBox(width: 0.68, height: 0.42, length: 0.16, chamferRadius: 0.03),
                 pos: (0, 1.05, -0.04), color: .systemGray4),
            node(name: "lats_l", geo: SCNBox(width: 0.14, height: 0.48, length: 0.13, chamferRadius: 0.02),
                 pos: (-0.42, 1.05, -0.03), color: .systemGray4),
            node(name: "lats_r", geo: SCNBox(width: 0.14, height: 0.48, length: 0.13, chamferRadius: 0.02),
                 pos: (0.42, 1.05, -0.03),  color: .systemGray4),
        ]

        // 肩
        nodes += [
            node(name: "shoulders_l", geo: SCNSphere(radius: 0.13), pos: (-0.47, 1.35, 0), color: .systemGray4),
            node(name: "shoulders_r", geo: SCNSphere(radius: 0.13), pos: (0.47, 1.35, 0),  color: .systemGray4),
        ]

        // 腕
        nodes += [
            node(name: "biceps_l",   geo: SCNCylinder(radius: 0.075, height: 0.35), pos: (-0.57, 0.98, 0.04), color: .systemGray4),
            node(name: "biceps_r",   geo: SCNCylinder(radius: 0.075, height: 0.35), pos: (0.57, 0.98, 0.04),  color: .systemGray4),
            node(name: "triceps_l",  geo: SCNCylinder(radius: 0.075, height: 0.35), pos: (-0.57, 0.98, -0.04), color: .systemGray4),
            node(name: "triceps_r",  geo: SCNCylinder(radius: 0.075, height: 0.35), pos: (0.57, 0.98, -0.04),  color: .systemGray4),
            node(name: "forearm_l",  geo: SCNCylinder(radius: 0.06, height: 0.30),  pos: (-0.57, 0.63, 0),    color: .systemGray3),
            node(name: "forearm_r",  geo: SCNCylinder(radius: 0.06, height: 0.30),  pos: (0.57, 0.63, 0),     color: .systemGray3),
        ]

        // 下半身
        nodes += [
            node(name: "glutes_l",      geo: SCNSphere(radius: 0.13),                      pos: (-0.17, 0.53, -0.1),  color: .systemGray4),
            node(name: "glutes_r",      geo: SCNSphere(radius: 0.13),                      pos: (0.17, 0.53, -0.1),   color: .systemGray4),
            node(name: "quads_l",       geo: SCNCylinder(radius: 0.10, height: 0.52),      pos: (-0.19, 0.14, 0.05),  color: .systemGray4),
            node(name: "quads_r",       geo: SCNCylinder(radius: 0.10, height: 0.52),      pos: (0.19, 0.14, 0.05),   color: .systemGray4),
            node(name: "hamstrings_l",  geo: SCNCylinder(radius: 0.09, height: 0.50),      pos: (-0.19, 0.14, -0.06), color: .systemGray4),
            node(name: "hamstrings_r",  geo: SCNCylinder(radius: 0.09, height: 0.50),      pos: (0.19, 0.14, -0.06),  color: .systemGray4),
            node(name: "calves_l",      geo: SCNCylinder(radius: 0.07, height: 0.42),      pos: (-0.19, -0.35, 0),    color: .systemGray4),
            node(name: "calves_r",      geo: SCNCylinder(radius: 0.07, height: 0.42),      pos: (0.19, -0.35, 0),     color: .systemGray4),
        ]

        return nodes
    }

    private static func node(name: String, geo: SCNGeometry, pos: (Float, Float, Float), color: UIColor) -> SCNNode {
        geo.firstMaterial?.diffuse.contents = color
        geo.firstMaterial?.lightingModel = .blinn
        let n = SCNNode(geometry: geo)
        n.name = name
        n.position = SCNVector3(pos.0, pos.1, pos.2)
        return n
    }
}
