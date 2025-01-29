//
//  UserMetadataStorage.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-28.
//

import Foundation

public class UserMetadataStorage {
    // Bookmarks
    var bookmarkedIds: [String] = []
    
    // Annotations
    var annotations: [String: String] = [:]

    // Unread
    var unreadIds: [String] = []

    public init() {
        
    }
    
    // MARK: - General
    
    public func store() async throws {
        
    }
    
    public func load() async throws {
        
    }
    
    // MARK: - Bookmarking
    
    public func isBookmarked(txid: String) -> Bool {
        bookmarkedIds.contains(txid)
    }
    
    public func toggleBookmarkFor(txid: String) {
        if bookmarkedIds.contains(txid) {
            bookmarkedIds.removeAll { $0 == txid }
        } else {
            bookmarkedIds.append(txid)
        }
    }
    
    // MARK: - Annotations
    
    public func annotationFor(txid: String) -> String? {
        annotations[txid]
    }
    
    public func add(annotation: String, for txid: String) {
        annotations[txid] = annotation
    }
    
    public func deleteAnnotationFor(txid: String) {
        annotations.removeValue(forKey: txid)
    }
    
    // MARK: - Unread
    
    public func isUnread(txid: String) -> Bool {
        unreadIds.contains(txid)
    }
    
    public func toggleUnreadFor(txid: String) {
        if unreadIds.contains(txid) {
            unreadIds.removeAll { $0 == txid }
        } else {
            unreadIds.append(txid)
        }
    }
}
