import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Array "mo:base/Array";

import IC "ic";

actor Verifier {
    //TYPES
    public type StudentProfile = {
        name : Text;
        team : Text;
        graduate : Bool;
    };

    public type TestResult = Result.Result<(), TestError>;
    public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
    };

    public type CanisterId = IC.CanisterId;
    public type CanisterSettings = IC.CanisterSettings;
    public type ManagementCanister = IC.ManagementCanister;

    //PRIVATE FUNCS
    private func parseControllerHack(errorMessage : Text) : [Principal] {
        let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);
        while (i < words.size()) {
        controllers.add(Principal.fromText(words[i]));
        i += 1;
        };
        Buffer.toArray<Principal>(controllers);
    };

    //could remove private funcs async prob
    private func doTest(canisterId : Principal) : async TestResult {
        let calculator = actor(Principal.toText(canisterId)) : actor {
            add : shared (n : Int) -> async Int;
            sub : shared (n : Nat) -> async Int;
            reset : shared () -> async Int;
        };

        try { let addTest = await calculator.add(2) } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do add func"));
        };
        try { let subTest = await calculator.sub(1) } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do reset func"));
        };
        try { let resetTest = await calculator.reset() } catch (e) {
            return #err(#UnexpectedError("Critical Error: could not do reset func"));
        };

        let resetTest = await calculator.reset();
        if (resetTest != 0) return #err(#UnexpectedValue("Value Error: reset func should give 0"));
        let subTest = await calculator.sub(5);
        if (subTest != -5) return #err(#UnexpectedValue("Value Error: sub func gives wrong value"));
        let addTest = await calculator.add(8);
        if (addTest != 3) return #err(#UnexpectedValue("Value Error: add func gives wrong value"));
        //another reset test just to be sure
        let resetTest2 = await calculator.reset();
        if (resetTest != 0) return #err(#UnexpectedValue("Value Error: reset func should give 0"));

        #ok()
    };

    private func doVerifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
         let managementCanister = actor("aaaaa-aa") : actor {
            canister_status : ({ canister_id : CanisterId }) -> async ({
                status : { #running; #stopping; #stopped };
                settings: CanisterSettings;
                module_hash: ?Blob;
                memory_size: Nat;
                cycles: Nat;
                idle_cycles_burned_per_day: Nat;
            });
        };

        //hacky-hack
        try { 
            ignore await managementCanister.canister_status({ canister_id = canisterId });
        } catch (e) {
            let controllers : [Principal] = parseControllerHack(Error.message(e));
            if (null == Array.find<Principal>(controllers, func p = p == principalId)) return false;
        };
        return true;
    };

    

    //STABLE STORES
    stable var stableStudentProfile : [(Principal, StudentProfile)] = [];
    let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(4, Principal.equal, Principal.hash);
      
    system func preupgrade() {
		stableStudentProfile := Iter.toArray(studentProfileStore.entries());
	};

	system func postupgrade() {
		stableStudentProfile := [];
	};

    //PUBLIC FUNCS
    public shared ({caller}) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        if (null != studentProfileStore.get(caller)) return #err "principal is already in use";
        studentProfileStore.put(caller, profile);
        #ok
    };

    public shared func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
        let ?profile = studentProfileStore.get(p) else return #err "profile not found, seeAProfile";
        #ok profile
    };

    public shared ({caller}) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        let ?_ = studentProfileStore.get(caller) else return #err "profile not found, updateMyProfile";
        studentProfileStore.put(caller, profile);
        #ok
    };

    public shared ({caller}) func deleteMyProfile() : async Result.Result<(), Text> {
        let ?_ = studentProfileStore.remove(caller) else return #err "profile not found, deleteMyProfile";
        #ok
    };

    public shared func test(canisterId : Principal) : async TestResult {
        await doTest(canisterId);
    };

    public shared func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
        await doVerifyOwnership(canisterId, principalId);
    };

    public shared func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {     
        let true = await doVerifyOwnership(canisterId, principalId) else return #err "This is not your work!";
        let res : TestResult = await doTest(canisterId);
        //should change this ugly tree in let-else's
        switch(res) {
            case (#ok) {
                //should make own private function for this (should use ({caller}) principal for next check)
                let ?studentProfile = studentProfileStore.get(principalId) else return #err "profile not found, verifyWork";
                let newStudentProfile = {
                    name = studentProfile.name;
                    team = studentProfile.team;
                    graduate = true;
                };
                studentProfileStore.put(principalId, newStudentProfile);
                return #ok;
            };
            case (#err x) {
                switch (x) {
                    case (#UnexpectedError msg) {return #err msg};
                    case (#UnexpectedValue msg) {return #err msg};
                };
            };
        };
    };
}