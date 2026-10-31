import AppKit
import Common

struct JoinWithCommand: Command {
    let args: JoinWithCmdArgs
    /*conforms*/ let shouldResetClosedWindowsCache = true

    func run(_ env: CmdEnv, _ io: CmdIo) -> BinaryExitCode {
        let direction = args.direction.val
        guard let target = args.resolveTargetOrReportError(env, io) else { return .fail }
        guard let currentWindow = target.windowOrNil else {
            return .fail(io.err(noWindowIsFocused))
        }

        if let joinWithWindowId = args.joinWithWindowId {
            guard let joinWithWindow = Window.get(byId: joinWithWindowId) else {
                return .fail(io.err("Can't find window with ID \(joinWithWindowId)"))
            }
            guard currentWindow != joinWithWindow else {
                return .fail(io.err("Can't join a window with itself"))
            }
            guard currentWindow.nodeWorkspace === joinWithWindow.nodeWorkspace else {
                return .fail(io.err("Windows must belong to the same workspace"))
            }
            guard case .tilingContainer = currentWindow.windowParentCases,
                  case .tilingContainer = joinWithWindow.windowParentCases
            else {
                return .fail(io.err("Both windows must be tiling windows"))
            }

            let joinWithBinding = joinWithWindow.unbindFromParent()
            let newParent = TilingContainer(
                parent: joinWithBinding.parent,
                adaptiveWeight: joinWithBinding.adaptiveWeight,
                direction.orientation,
                .tiles,
                index: joinWithBinding.index,
            )
            currentWindow.unbindFromParent()

            joinWithWindow.bind(
                to: newParent,
                adaptiveWeight: WEIGHT_AUTO,
                index: direction.isPositive ? INDEX_BIND_LAST : 0,
            )
            currentWindow.bind(
                to: newParent,
                adaptiveWeight: WEIGHT_AUTO,
                index: direction.isPositive ? 0 : INDEX_BIND_LAST,
            )
            _ = currentWindow.focusWindow()
            return .succ
        }

        guard let (parent, ownIndex) = currentWindow.closestParent(hasChildrenInDirection: direction, withLayout: nil) else {
            return .fail(io.err("No windows in the specified direction"))
        }
        let joinWithTarget = parent.children[ownIndex + direction.focusOffset]
        let prevBinding = joinWithTarget.unbindFromParent()
        let newParent = TilingContainer(
            parent: parent,
            adaptiveWeight: prevBinding.adaptiveWeight,
            parent.orientation.opposite,
            .tiles,
            index: prevBinding.index,
        )
        currentWindow.unbindFromParent()

        joinWithTarget.bind(to: newParent, adaptiveWeight: WEIGHT_AUTO, index: 0)
        currentWindow.bind(to: newParent, adaptiveWeight: WEIGHT_AUTO, index: direction.isPositive ? 0 : INDEX_BIND_LAST)
        return .succ
    }
}
