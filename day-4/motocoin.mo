import Account "account";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";

actor MotoCoin {
    type Account = Account.Account;

    //1
    let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

    //seb
    let bootcampCanister : actor {
        getAllStudentsPrincipal : shared () -> async Principal;
    } = actor("rww3b-zqaaa-aaaam-abioa-cai");

    public func showStudents() : async Principal {
        return await bootcampCanister.getAllStudentsPrincipal();
    };

    var supply : Nat = 0;

    //2
    public query func name() : async Text {
        return "MotoCoin";
    };

    //3
    public query func symbol() : async Text {
        return "MOC"
    };

    //4
    public query func totalSupply() : async Nat {
        for(value in ledger.vals()) {
            supply += value;
        };
        return supply;
    };

    //5
    public query func balanceOf(account: Account) : async Nat {
        switch (ledger.get(account)) {
            case(null) {
                return 0;
            };
            case(?fee) {
                return fee;
            }
        };
    };
    
    //6
    public shared ({ caller }) func transfer (
        from: Account,
        to: Account,
        amount: Nat,
    ) : async Result.Result<(), Text> {
        func balanceOf(account : Account) : Nat {
            switch(ledger.get(account)) {
                case(null) {
                    return 0;
                };
                case(?fee) {
                    return fee;
                };
            };
        };
        var balanceFrom : Nat = balanceOf(from);
        var balanceTo : Nat = balanceOf(to);

        if (balanceFrom < amount) {
            return #err("not enough tokens");
        };

        balanceFrom := balanceFrom - amount;
        balanceTo := balanceTo + amount;

        return #ok();
    };

    //7

    /* seb
    public func airdrop() : async Result.Result<(), Text> {
        try {
            let students = await bootcampCanister.getAllStudentsPrincipal();
            for (p in students.vals()) {
                let account : Account = {
                    owner = p;
                    subaccount = null;
                };
            let currentValue = Option.get(ledger.get(account), 0);
            let newValue = currentValue + 100;
            ledger.put(account, newValue)
            };
            return #ok();
        } catch (e) {
            return #err("Something went wrong when calling the bootcamp canister.")
        };
    };
    */

    public func airdrop() : async Result.Result<(), Text> {
        let bootcamp = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
            getAllStudentsPrincipal : shared () -> async [Principal];
        };

        let students = await bootcamp.getAllStudentsPrincipal();

        for (p in students.vals()) {
            let account : Account = {
                owner = p;
                subaccount = null;
            };
            
            let currentValue = Option.get(ledger.get(account), 0);
            let newValue = currentValue + 100;
            ledger.put(account, newValue);
            
            return #err("error")
        };
        return #ok();
    };

};