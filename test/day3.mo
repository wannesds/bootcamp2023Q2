import Map "mo:base/HashMap";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Int "mo:base/Int";

import Types "Types";

actor StudentWall {
    var messageId : Nat = 0;
    let wall = Map.HashMap<Nat,Types.Message>(0,Nat.equal, Hash.hash);

    public shared ({caller}) func writeMessage(c : Types.Content) : async Nat{
        messageId += 1;
        var m : Types.Message = Types.createMessage(0, c, caller);
        wall.put(messageId, m);
        return messageId;
    };

     public shared query func getMessage (_messageId : Nat) : async Result.Result<Types.Message, Text>{
        var m = wall.get(_messageId);
        
        switch (m){
            case (null){
                return #err("messageId not valid");
            };
            case (? something){
                return #ok(something);
            };
        };
     };

     public shared ({caller}) func updateMessage(messageId : Nat, c : Types.Content) : async Result.Result<(), Text> {
        var result = await getMessage(messageId);
        if (Result.isOk(result)){
            var message = Result.toOption(result);
            switch (message){
                case (null) { return #err("message does not exist")};
                case (? something) {
                    if (caller != something.creator){
                        return #err("caller is not the creator of this message");
                    }
                    else{
                        var m : Types.Message = Types.createMessage(something.vote, c, caller);
                        var oldM = wall.replace(messageId,m);
                        if (oldM == null){
                            return #err("not possible to update");
                        }
                        else
                            return #ok();

                        /*var r = await deleteMessage(messageId);
                        if (Result.isOk(r)){
                            wall.put(messageId,m);
                            return #ok();
                        }
                        else
                            return #err("Cannot update");
                            */
                    }
                };
            }
        };
        return #ok();
     };

    public shared func deleteMessage (messageId : Nat) : async Result.Result<(), Text>{
        //let total = wall.size();
        var message = wall.remove(messageId);
        if (message == null){
            return #err("messageId not valid");
        };
        return #ok();
    };

    
    private func voting(messageId: Nat, voting: Int) : async Result.Result<(), Text> {
        var result = await getMessage(messageId);
        if (Result.isOk(result)){
            var message = Result.toOption(result);
            switch (message){
                case (null) { return #err("message does not exist")};
                case (? something) {
                    var m = Types.createMessage(something.vote + voting, something.content, something.creator);
                    
                    var oldM = wall.replace(messageId, m);
                    if (oldM == null){
                        
                        return #err("Cannot update vote");
                    };
                    
                    return #ok();
                };
            };
        };
        return #err("messageId not correct");
    };

    public shared func upVote (messageId  : Nat) : async Result.Result<(), Text>{
       let result = await voting(messageId, 1);
       if (Result.isOk(result)){
        return #ok();
       };

       return #err("cannot upVote");
    };

    public shared func downVote (messageId  : Nat) : async Result.Result<(), Text>{
        let result = await voting(messageId, -1);
       if (Result.isOk(result)){
        return #ok();
       };

       return #err("cannot upVote");
    };

    //Get all messages
    public shared query func getAllMessages () : async [Types.Message]{
        return Iter.toArray<(Types.Message)>(wall.vals());
    };

    private func isGreaterVote(x: Types.Message, y : Types.Message) : Order.Order {
        return Int.compare(y.vote, x.vote);
    };
    public shared query func getAllMessagesRanked() : async [Types.Message]{
        var posts : Iter.Iter<Types.Message> = wall.vals();
        var post_array = Iter.toArray (posts) ;
        var sorted = Array.sort (post_array, isGreaterVote);
        return sorted;
    };
};