//
//  DatabaseFilesTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 07.04.2022.
//

import XCTest
import ZcashLightClientKit
@testable import secant_testnet

extension String: Error {}

extension DatabaseFiles.DatabaseFilesError {
    var debugValue: String {
        switch self {
        case .getDocumentsURL: return "getDocumentsURL"
        case .getCacheURL: return "getCacheURL"
        case .getDataURL: return "getDataURL"
        case .getOutputParamsURL: return "getOutputParamsURL"
        case .getPendingURL: return "getPendingURL"
        case .getSpendParamsURL: return "getSpendParamsURL"
        case .nukeFiles: return "nukeFiles"
        case .filesPresentCheck: return "filesPresentCheck"
        }
    }
}

class DatabaseFilesTests: XCTestCase {
    let network = ZcashNetworkBuilder.network(for: .testnet)
    
    func testFailingDocumentsDirectory() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in throw "some error" },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            _ = try dfInteractor.documentsDirectory()
            
            XCTFail("DatabaseFiles: `testFailingDocumentsDirectory` expected to fail but passed with no error.")
        } catch {
            guard let error = error as? DatabaseFiles.DatabaseFilesError else {
                XCTFail("DatabaseFiles: the error is expected to be DatabaseFilesError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                DatabaseFiles.DatabaseFilesError.getDocumentsURL.debugValue,
                "DatabaseFiles: error must be .getDocumentsURL but it's \(error)."
            )
        }
    }
    
    func testFailingDataDbURL() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in throw "some error" },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            _ = try dfInteractor.dataDbURLFor(network)
            
            XCTFail("DatabaseFiles: `testFailingDataDbURL` expected to fail but passed with no error.")
        } catch {
            guard let error = error as? DatabaseFiles.DatabaseFilesError else {
                XCTFail("DatabaseFiles: the error is expected to be DatabaseFilesError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                DatabaseFiles.DatabaseFilesError.getDataURL.debugValue,
                "DatabaseFiles: error must be .getDataURL but it's \(error)."
            )
        }
    }
    
    func testDatabaseFilesPresent() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in URL(fileURLWithPath: "") },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            let areFilesPresent = try dfInteractor.areDbFilesPresentFor(network)
            
            XCTAssertTrue(areFilesPresent, "DatabaseFiles: `testDatabaseFilesPresent` is expected to be true but it's \(areFilesPresent)")
        } catch {
            XCTFail("DatabaseFiles: `testDatabaseFilesPresent` expected to fail but passed with no error.")
        }
    }

    func testDatabaseFilesNotPresent() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in URL(fileURLWithPath: "") },
            fileExists: { _ in return false },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            let areFilesPresent = try dfInteractor.areDbFilesPresentFor(network)
            
            XCTAssertFalse(areFilesPresent, "DatabaseFiles: `testDatabaseFilesNotPresent` is expected to be false but it's \(areFilesPresent)")
        } catch {
            XCTFail("DatabaseFiles: `testDatabaseFilesPresent` expected to fail but passed with no error.")
        }
    }

    func testDatabaseFilesPresentFailure() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in throw "some error" },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            _ = try dfInteractor.areDbFilesPresentFor(network)
            
            XCTFail("DatabaseFiles: `testDatabaseFilesPresentFailure` expected to fail but passed with no error.")
        } catch {
            guard let error = error as? DatabaseFiles.DatabaseFilesError else {
                XCTFail("DatabaseFiles: the error is expected to be DatabaseFilesError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                DatabaseFiles.DatabaseFilesError.filesPresentCheck.debugValue,
                "DatabaseFiles: error must be .filesPresentCheck but it's \(error)."
            )
        }
    }
    
    func testNukeFiles_RemoveFileFailure() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in URL(fileURLWithPath: "") },
            fileExists: { _ in return true },
            removeItem: { _ in throw "some error" }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            _ = try dfInteractor.nukeDbFilesFor(network)
            
            XCTFail("DatabaseFiles: `testNukeFiles_RemoveFileFailure` expected to fail but passed with no error.")
        } catch {
            guard let error = error as? DatabaseFiles.DatabaseFilesError else {
                XCTFail("DatabaseFiles: the error is expected to be DatabaseFilesError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                DatabaseFiles.DatabaseFilesError.nukeFiles.debugValue,
                "DatabaseFiles: error must be .nukeFiles but it's \(error)."
            )
        }
    }
    
    func testNukeFiles_URLFailure() throws {
        let mockedFileManager = WrappedFileManager(
            url: { _, _, _, _ in throw "some error" },
            fileExists: { _ in return true },
            removeItem: { _ in }
        )
        
        let dfInteractor = WrappedDatabaseFiles.live(databaseFiles: DatabaseFiles(fileManager: mockedFileManager))
        
        do {
            _ = try dfInteractor.nukeDbFilesFor(network)
            
            XCTFail("DatabaseFiles: `testNukeFiles_URLFailure` expected to fail but passed with no error.")
        } catch {
            guard let error = error as? DatabaseFiles.DatabaseFilesError else {
                XCTFail("DatabaseFiles: the error is expected to be DatabaseFilesError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                DatabaseFiles.DatabaseFilesError.nukeFiles.debugValue,
                "DatabaseFiles: error must be .nukeFiles but it's \(error)."
            )
        }
    }
}
