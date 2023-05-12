import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

import Account "account";

actor MotoCoin {

    public type Account = Account.Account;

    let tokenName : Text= "MotoCoin";
    let tokenSymbol : Text = "MOC";

    stable var stableLedger : [(Account, Nat)] = [];
    let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

    system func preupgrade() {
		stableLedger := Iter.toArray(ledger.entries());
	};

	system func postupgrade() {
		stableLedger := [];
	};


    let bootcamp = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
    };

    // Returns the name of the token 
    public shared query func name() : async Text {
        tokenName
    };

    // Returns the symbol of the token 
    public shared query func symbol() : async Text {
        tokenSymbol
    };

    // Returns the the total number of tokens on all accounts
    public shared query func totalSupply() : async Nat {
        var total = 0;

        for (balance in ledger.vals()) {
            total += balance;
        };

        total
    };

    // Returns the balance of an account
    public shared query func balanceOf(account : Account) : async Nat {
        switch(ledger.get(account)) {
            case null 0 ;
            case (?balance) {
                balance
            };
        };
    };

    // Transfer tokens to another account
    public shared ({caller}) func transfer(from: Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
        let true = Principal.equal(from.owner, caller) else return #err "You are not the owner of this account";
        let ?fromBalance = ledger.get(from) else return #err "You don't have an account";
        let ?toBalance = ledger.get(to) else return #err "Target doesn't has an account";
        let true = (fromBalance >= amount) else return #err "You don't have enough balance";
        let ?_ = ledger.replace(from, fromBalance - amount) else return #err "Strange! Could not deduct amount from your balance";
        let ?_ = ledger.replace(to, toBalance + amount) else return #err "Strange! Could not add amount to target's balance";
        #ok
    };

    // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
    public shared func airdrop() : async Result.Result<(),Text> {
        try {
            let students : [Principal] = await bootcamp.getAllStudentsPrincipal();
                
            for (principal in students.vals()) {
                let newAccount = {
                    owner = principal;
                    subaccount = null;
                };
                ledger.put(newAccount, 100);
            };
        } catch (e) {
            return #err "An error occured when calling bootcamp canister";
        };
         
        #ok 
    };
}