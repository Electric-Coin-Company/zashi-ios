//
//  PartialProposalErrorStore.swift
//  
//
//  Created by Lukáš Korba on 11.03.2024.
//

import ComposableArchitecture
import MessageUI

import SupportDataGenerator

@Reducer
public struct PartialProposalError {
    @ObservableState
    public struct State: Equatable {
        public var isBackButtonHidden: Bool
        public var isExportingData: Bool
        public var message: String
        public var statuses: [String]
        public var supportData: SupportData?
        public var txIds: [String]
        
        public init(
            isBackButtonHidden: Bool = true,
            isExportingData: Bool = false,
            message: String,
            statuses: [String],
            supportData: SupportData? = nil,
            txIds: [String]
        ) {
            self.isBackButtonHidden = isBackButtonHidden
            self.isExportingData = isExportingData
            self.message = message
            self.statuses = statuses
            self.supportData = supportData
            self.txIds = txIds
        }
    }
    
    public enum Action: Equatable {
        case sendSupportMail
        case sendSupportMailFinished
        case shareFinished
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sendSupportMail:
                let supportData = SupportDataGenerator.generatePartialProposalError(txIds: state.txIds, statuses: state.statuses)
                if MFMailComposeViewController.canSendMail() {
                    state.supportData = supportData
                } else {
                    state.message = supportData.message
                    state.isExportingData = true
                }
                return .none

            case .sendSupportMailFinished:
                state.isBackButtonHidden = false
                state.supportData = nil
                return .none
                
            case .shareFinished:
                state.isBackButtonHidden = false
                state.isExportingData = false
                return .none
            }
        }
    }
}

