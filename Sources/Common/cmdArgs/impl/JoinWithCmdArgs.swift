public struct JoinWithCmdArgs: CmdArgs {
    /*conforms*/ public var commonState: CmdArgsCommonState
    init(rawArgs: StrArrSlice) { self.commonState = .init(rawArgs) }
    public static let parser: CmdParser<Self> = .init(
        kind: .joinWith,
        help: join_with_help_generated,
        flags: [
            "--window-id": windowIdSubArgParser(),
            "--with-window-id": singleValueSubArgParser(\.joinWithWindowId, "<window-id>", parseUInt32),
        ],
        posArgs: [newMandatoryPosArgParser(\.direction, parseCardinalDirectionArg, placeholder: CardinalDirection.unionLiteral)],
    )

    public var direction: Lateinit<CardinalDirection> = .uninitialized
    public var joinWithWindowId: UInt32? = nil
}
