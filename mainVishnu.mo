import Account "account";
import TrieMap "mo:base/TrieMap";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";

actor MotoCoin {

    type Subaccount = Account.Subaccount;
    type Account = Account.Account;

    let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

    // Returns the name of the token
    public query func name() : async Text {
        return "MotoCoin";
    };

    // Returns the symbol of the token
    public query func symbol() : async Text {
        return "MOC";
    };

    // Returns the the total number of tokens on all accounts
    public query func totalSupply() : async Nat {
        var netBalances = 0;
        for (amount in ledger.vals()) {
            netBalances += amount;
        };

        netBalances;

    };

    // Returns the balance of the account
    public query func balanceOf(account : Account) : async (Nat) {
        let balanceOf : Nat = switch (ledger.get(account)) {
            case (?balanceOf) { balanceOf };
            case (null) { 0 };
        };

    };

    func updateBalance(account : Account, amount : Nat) : () {
        //     let currentBalance : Nat = switch (ledger.get(account)) {
        //             case (?balanceOf) { balanceOf };
        //             case (null) { 0 };
        //         };
        // if((currentBalance >= amount)){
        // let newBalance = currentBalance - amount;
        ledger.put(account, amount);
    };

    // Transfer tokens to another account
    public func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
        // Check if the sender has sufficient balance
        let senderBalance = Option.get(ledger.get(from), 0);
        if (senderBalance < amount) {
            #err("Insufficient balance in the sender's account.");
        } else {
            // Deduct the transferred amount from the sender's account
            updateBalance(from, senderBalance - amount);

            // Add the transferred amount to the recipient's account
            let recipientBalance = Option.get(ledger.get(to), 0);
            updateBalance(to, recipientBalance + amount);

            #ok();
        };
    };
    type A = actor { getAllStudentsPrincipal : () -> async [Principal] };

    let studentActor : A = actor ("rww3b-zqaaa-aaaam-abioa-cai");

    // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.

    public func airdrop() : async Result.Result<(), Text> {
        let array = await studentActor.getAllStudentsPrincipal();
        // let bufOfAccount : Buffer.Buffer<Account> = Buffer.Buffer<Account>(100);
        for (prin in array.vals()) {
            let studentAccount : Account = {
                owner = prin;
                subaccount = null;
            };
            switch (Account.accountBelongsToPrincipal(studentAccount, prin)) {
                case (true) { return #ok(ledger.put(studentAccount, 100)) };
                case (false) { return #err "airdrop fail" };
            };

        };
        #ok;
    };

};