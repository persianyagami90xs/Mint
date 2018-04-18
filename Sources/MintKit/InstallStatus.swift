import Foundation
import PathKit

struct InstallStatus {

    let status: Status
    let path: Path

    init(path: Path, mintPackagesPath: Path) throws {
        self.path = path
        if path.isSymlink {
            let actualPath = try path.symlinkDestination()
            if actualPath.absolute().string.contains(mintPackagesPath.absolute().string) {
                let version = actualPath.parent().lastComponent
                status = .mint(version: version)
            } else {
                status = .symlink(path: actualPath)
            }
        } else if path.exists {
            status = .file
        } else {
            status = .missing
        }
    }

    enum Status {
        case mint(version: String)
        case file
        case symlink(path: Path)
        case missing
    }

    var isSafe: Bool {
        switch status {
        case .file, .symlink: return true
        case .missing, .mint: return true
        }
    }

    var warning: String? {
        switch status {
        case .file: return "An executable that was not installed by mint already exists at \(path)."
        case let .symlink(symlink): return "An executable that was not installed by mint already exists at \(path) that is symlinked to \(symlink)."
        default: return nil
        }
    }
}
