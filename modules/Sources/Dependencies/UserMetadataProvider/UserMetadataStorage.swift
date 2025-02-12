//
//  UserMetadataStorage.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-28.
//

import Foundation
import ZcashLightClientKit

public class UserMetadataStorage {
    // General
    
    // Bookmarks
    var bookmarkedIds: [String: UMBookmark] = [:]
    
    // Annotations
    var annotations: [String: UMAnnotation] = [:]

    // Read
    var read: [String: UMRead] = [:]

    public init() { }
    
    // MARK: - General
    
    public func store() async throws {
        
    }
    
    public func load() async throws {
        
    }
    
    // MARK: - Bookmarking
    
    public func isBookmarked(txid: String) -> Bool {
        bookmarkedIds[txid] != nil
    }
    
    public func toggleBookmarkFor(txid: String) {
        if bookmarkedIds[txid] != nil {
            bookmarkedIds.removeValue(forKey: txid)
        } else {
            bookmarkedIds[txid] = UMBookmark(
                txid: txid,
                lastUpdated: Date().timeIntervalSince1970 * 1000
            )
        }
    }
    
    // MARK: - Annotations
    
    public func annotationFor(txid: String) -> String? {
        annotations[txid]?.text
    }
    
    public func add(annotation: String, for txid: String) {
        annotations[txid] = UMAnnotation(
            txid: txid,
            lastUpdated: Date().timeIntervalSince1970 * 1000,
            text: annotation
        )
    }
    
    public func deleteAnnotationFor(txid: String) {
        annotations.removeValue(forKey: txid)
    }
    
    // MARK: - Unread
    
    public func isRead(txid: String) -> Bool {
        read[txid] != nil
    }
    
    public func updateReadFor(txid: String, to value: Bool) {
        if read[txid] != nil {
            read.removeValue(forKey: txid)
        } else {
            read[txid] = UMRead(
                txid: txid,
                lastUpdated: Date().timeIntervalSince1970 * 1000,
                value: value
            )
        }
    }
}
