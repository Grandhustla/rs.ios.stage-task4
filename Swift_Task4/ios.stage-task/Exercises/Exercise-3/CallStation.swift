import Foundation

final class CallStation {
    private var listOfUsers : [User] = []
    private var listOfCall : [Call] = []
}

extension CallStation: Station {
    func users() -> [User] {
        listOfUsers
    }
    
    func add(user: User) {
        guard !listOfUsers.contains(user) else { return }
        listOfUsers.append(user)
    }
    
    func remove(user: User) {
        listOfUsers = listOfUsers.filter { $0 != user }
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
            case .start(from: let caller, to: let callee):
            return executeStart(from: caller, to: callee)
        case .answer(from: let incomingUser):
            return executeAnswer(from: incomingUser)
        case .end(from: let user):
            return executeEnd(from: user)
        }
    }
    
    func calls() -> [Call] {
        listOfCall
    }
    
    func calls(user: User) -> [Call] {
        listOfCall.filter { $0.incomingUser.id == user.id || $0.outgoingUser.id == user.id }
    }
    
    func call(id: CallID) -> Call? {
        listOfCall.filter { $0.id == id }.first
    }
    
    func currentCall(user: User) -> Call? {
        calls(user: user).filter { $0.status == .calling || $0.status == .talk }.first
    }
    
    // MARK: suppotted func's
    private func executeStart(from caller: User, to callee: User) -> CallID? {
        if !listOfUsers.contains(caller) && !listOfUsers.contains(callee) { return nil }
        
        var callID = CallID()
        while calls().contains(where: { element in element.id == callID }) {
            callID = CallID()
        }
        
        var callStatus: CallStatus
        if !listOfUsers.contains(caller) || !listOfUsers.contains(callee) {
            callStatus = .ended(reason: .error)
        } else if calls(user: callee).filter({ $0.status == .talk || $0.status == .calling }).count > 0 {
            callStatus = .ended(reason: .userBusy)
        } else {
            callStatus = .calling
        }
        
        listOfCall.append(Call(id: callID, incomingUser: callee, outgoingUser: caller, status: callStatus))
        
        return callID
    }
    
    private func executeAnswer(from incomingUser: User) -> CallID? {
        guard let call = listOfCall.filter({ $0.incomingUser == incomingUser && $0.status == .calling }).first
        else { return nil }
        
        var someOneCrashed = false
        for user in [call.incomingUser, call.outgoingUser] {
            if !listOfUsers.contains(user) {
                abortAllCalls(for: user)
                someOneCrashed = true
            }
        }
        guard !someOneCrashed else { return nil }
        
        changeStatus(for: call, to: .talk)
        return call.id
    }
    
    private func abortAllCalls(for user: User) {
        for brokenCall in calls(user: user) {
            changeStatus(for: brokenCall, to: .ended(reason: .error))
        }
    }
    
    private func executeEnd(from user: User) -> CallID? {
        guard let call = calls(user: user).filter({ $0.status == .talk || $0.status == .calling }).first else { return nil }
        
        let endReason: CallEndReason = call.status == .talk ? .end : .cancel
        changeStatus(for: call, to: .ended(reason: endReason))
        return call.id
    }
    
    private func changeStatus(for call: Call, to status: CallStatus) {
        listOfCall = listOfCall.filter { ($0.id) != call.id }
        listOfCall.append(Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: status))
    }
}
