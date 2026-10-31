@testable import AppBundle
import Common
import XCTest

@MainActor
final class JoinWithCommandTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testMoveIn() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow.new(id: 0, parent: $0)
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        await parseCommand("join-with right").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_tiles([
            .window(0),
            .v_tiles([
                .window(1),
                .window(2),
            ]),
        ]))
    }

    func testJoinWithSpecificWindowToTheRight() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow.new(id: 0, parent: $0)
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        await parseCommand("join-with --window-id 1 --with-window-id 2 right")
            .cmdOrDie
            .run(.defaultEnv, .emptyStdin)

        assertEquals(root.layoutDescription, .h_tiles([
            .window(0),
            .h_tiles([
                .window(1),
                .window(2),
            ]),
        ]))
    }

    func testJoinWithSpecificWindowToTheLeft() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            TestWindow.new(id: 0, parent: $0)
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        await parseCommand("join-with --window-id 1 --with-window-id 2 left")
            .cmdOrDie
            .run(.defaultEnv, .emptyStdin)

        assertEquals(root.layoutDescription, .h_tiles([
            .window(0),
            .h_tiles([
                .window(2),
                .window(1),
            ]),
        ]))
    }
}
