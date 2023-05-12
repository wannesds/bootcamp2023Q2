import Text "mo:base/Text";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Error "mo:base/Error";
import Ic "ic";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";

actor Verifier {
  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  stable var studentProfileStableStore : [(Principal, StudentProfile)] = [];

  let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);

  public type TestResult = Result.Result<(), TestError>;
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };

  // Part 1
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let res = studentProfileStore.get(caller);
    switch (res) {
      case null {
        let studentData : StudentProfile = {
          name = profile.name;
          team = profile.team;
          graduate = profile.graduate;
        };
        studentProfileStore.put(caller, studentData);
        return #ok();
      };
      case (?data) {
        if (data.name == profile.name and data.team == profile.team) {
          return #err "The student name and team you entered was already exist!";
        } else {
          let studentData : StudentProfile = {
            name = profile.name;
            team = profile.team;
            graduate = profile.graduate;
          };
          studentProfileStore.put(caller, studentData);
          return #ok();
        };
      };
    };
  };

  public query func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let res = studentProfileStore.get(p);
    switch (res) {
      case null #err "The student data you're looking for was not found!";
      case (?data) #ok data;
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let res = studentProfileStore.get(caller);
    switch (res) {
      case null #err "The student data you're going to update was not found!";
      case (?data) {
        let newStudentData : StudentProfile = {
          name = profile.name;
          team = profile.team;
          graduate = data.graduate;
        };
        ignore studentProfileStore.replace(caller, newStudentData);
        #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let res = studentProfileStore.get(caller);
    switch (res) {
      case null #err "The student data you're going to delete was not found!";
      case (?msg) {
        ignore studentProfileStore.remove(caller);
        #ok();
      };
    };
  };

  //Part 2
  public func test(canisterId : Principal) : async TestResult {
    let calc = actor (Principal.toText(canisterId)) : actor {
      add : shared (x : Nat) -> async Int;
      sub : shared (x : Nat) -> async Int;
      reset : shared () -> async Int;
    };

    try {
      let resReset = await calc.reset();
      if (resReset != 0) {
        return #err(#UnexpectedValue("The expected result after a reset() is 0!"));
      } else {
        let resAdd1 = await calc.add(1);
        if (resAdd1 != 1) {
          return #err(#UnexpectedValue("The expected result after a reset() and followed by add(1) is 1!"));
        } else {
          let resSub1 = await calc.sub(1);
          if (resSub1 != 0) {
            return #err(#UnexpectedValue("The expected result after a reset(), add(1), and sub(1) is 0!"));
          };
        };
      };
      return #ok();
    } catch (e : Error) {
      return #err(#UnexpectedError(Error.message(e)));
    };
  };

  //Part 3
  public shared func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
    try {
      let controllers = await Ic.getCanisterControllers(canisterId);
      var isOwner : ?Principal = Array.find<Principal>(controllers, func p = p == principalId);
      if (isOwner != null) {
        return true;
      };
      return false;
    } catch (e) {
      return false;
    };
  };

  //Part 4
  public shared ({ caller }) func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {
    try {
      let isOwner = await verifyOwnership(canisterId, principalId);
      if (not isOwner) {
        return #err("The received work owner does not match with the received principal");
      } else {
        let resStudent = studentProfileStore.get(principalId);
        switch (resStudent) {
          case null #err "The student you're going to graduate was not found!";
          case (?data) {
            let resTest = await test(canisterId);
            if (resTest != #ok) {
              return #err("The work of " # data.name # " from the " # data.team # " team, hasn't passed the test yet!");
            } else {
              let newStudentData : StudentProfile = {
                data with graduate = true;
              };
              ignore studentProfileStore.replace(caller, newStudentData);
              return #ok();
            };
          };
        };
      };

    } catch (e : Error) {
      return #err(Error.message(e));
    };
  };

  // to backup the student data
  system func preupgrade() {
    studentProfileStableStore := Iter.toArray(studentProfileStore.entries());
  };

  // to restore the student data
  system func postupgrade() {
    for ((p, v) in studentProfileStableStore.vals()) {
      let studentData : StudentProfile = {
        name = v.name;
        team = v.team;
        graduate = v.graduate;
      };
      studentProfileStore.put(p, studentData);
    };
  };
};
