
import TrieMap "mo:base/TrieMap";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";


actor MotoCoin {

  public type Account = Account.Account;

  var ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);  
  let bootcamp = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal() : shared () -> async [Principal];
  };

  // Returns the name of the token
  
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    return 123456789;
  };
   // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
      let balance : ?Nat = ledger.get(account);
        switch (balance){
            case (null) return 0;
            case (?balance)  return balance;
        };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
        let balFrom = await balanceOf(from);
        if (balFrom < amount) return #err("Insuficient founds");
          let balTo = await balanceOf(to);
        ledger.put(from, balFrom - amount);
        ledger.put(to, balTo + amount);
        return #ok ();
    };
      // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public shared func airdrop() : async Result.Result<(), Text> {
    try {
      let students : [Principal] = await bootcamp.getAllStudentsPrincipal();
      for (principal in students.vals()) {
        let newAccount = {
          owner = principal;
          subaccount = null;
        };
        ledger.put(newAccount,100);
      };
    } catch(e) {
      return #err "Error calling bootcamp canister"
    };
    #ok
  };
};