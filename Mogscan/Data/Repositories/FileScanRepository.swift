import Foundation

/// The local scan store: a JSON file of records, with each scan's photo beside
/// it as a JPEG.
///
/// Everything lives in Application Support, which is excluded from iCloud backup
/// by nothing in particular but is the right home for app-managed data. There is
/// no account and no sync — deleting the app deletes the history, which is what
/// the client asked for.
///
/// JSON rather than SwiftData because ``FaceScan`` is already a `Codable` value
/// type and a single user produces a handful of scans, not a table. The whole
/// file is read and written at once; at this size that is cheaper than the
/// machinery required to avoid it.
///
/// Reads are served from an in-memory copy loaded once at init, so Home does not
/// touch the disk every time it appears.
final class FileScanRepository: ScanRepositoryProtocol {

    /// Scans kept. Past this the oldest drops out, photo and all.
    ///
    /// Three, on the client's instruction — Home shows a short recent list, not
    /// an archive. It also keeps the store near 500KB, since each scan carries a
    /// photo of roughly 150KB.
    private let historyLimit = 3

    private let directory: URL
    private let recordsURL: URL
    private let photosDirectory: URL
    private var scans: [FaceScan]

    init(directory: URL? = nil) {
        let base = directory ?? FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Mogscan", isDirectory: true)

        self.directory = base
        self.recordsURL = base.appendingPathComponent("scans.json")
        self.photosDirectory = base.appendingPathComponent("Photos", isDirectory: true)
        self.scans = []

        createDirectories()
        scans = loadRecords()
    }

    // MARK: Reads

    func latestScan() -> FaceScan? {
        scans.max { $0.capturedAt < $1.capturedAt }
    }

    func scanHistory() -> [FaceScan] {
        scans.sorted { $0.capturedAt > $1.capturedAt }
    }

    func scan(withID id: UUID) -> FaceScan? {
        scans.first { $0.id == id }
    }

    func photo(for id: UUID) -> Data? {
        try? Data(contentsOf: photoURL(for: id))
    }

    // MARK: Writes

    func save(_ scan: FaceScan, photo: Data?) {
        if let photo {
            try? photo.write(to: photoURL(for: scan.id), options: .atomic)
        }

        scans.removeAll { $0.id == scan.id }
        scans.append(scan)
        pruneToLimit()
        writeRecords()
    }

    func delete(scanID: UUID) {
        scans.removeAll { $0.id == scanID }
        try? FileManager.default.removeItem(at: photoURL(for: scanID))
        writeRecords()
    }

    /// Removes the whole Photos directory rather than the files it lists.
    ///
    /// A photo whose record was lost to a bad decode would survive a per-record
    /// sweep, and this is the button that promises nothing is left — so it takes
    /// the directory, then puts it back empty for the next scan.
    func deleteAll() {
        scans = []
        try? FileManager.default.removeItem(at: photosDirectory)
        try? FileManager.default.removeItem(at: recordsURL)
        createDirectories()
    }

    /// Drops the oldest scans past ``historyLimit``, and their photos with them —
    /// an orphaned JPEG would otherwise sit on disk for the life of the install.
    private func pruneToLimit() {
        guard scans.count > historyLimit else { return }
        let ordered = scans.sorted { $0.capturedAt > $1.capturedAt }
        for dropped in ordered.dropFirst(historyLimit) {
            try? FileManager.default.removeItem(at: photoURL(for: dropped.id))
        }
        scans = Array(ordered.prefix(historyLimit))
    }

    // MARK: Disk

    private func photoURL(for id: UUID) -> URL {
        photosDirectory.appendingPathComponent("\(id.uuidString).jpg")
    }

    private func createDirectories() {
        try? FileManager.default.createDirectory(
            at: photosDirectory, withIntermediateDirectories: true
        )
    }

    /// A store that cannot be decoded is treated as empty rather than fatal: a
    /// user who loses their history to a bad write should still get a working
    /// app, and the next save overwrites it.
    private func loadRecords() -> [FaceScan] {
        guard let data = try? Data(contentsOf: recordsURL),
              let decoded = try? JSONDecoder().decode([FaceScan].self, from: data)
        else { return [] }
        return decoded
    }

    private func writeRecords() {
        guard let data = try? JSONEncoder().encode(scans) else { return }
        try? data.write(to: recordsURL, options: .atomic)
    }
}
