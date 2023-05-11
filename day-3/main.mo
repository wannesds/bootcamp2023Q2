import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Array "mo:base/Array";

actor Studentwall {
    public type Content = {
        #Text: Text;
        #Image: Blob;
        #Video: Blob;
    };

    public type Message = {
        vote: Int;
        content: Content;
        creator: Principal;
    };
    
    var messageId : Nat = 0;

   

    func hashId(id : Nat) : Hash.Hash {
		Text.hash(Nat.toText(id));
	};
    let map = HashMap.HashMap<Nat, Message>(8, Nat.equal, hashId); 

    func sortByVote(x : Message, y : Message) : Order.Order {
		if (x.vote < y.vote) {
			#less;
		} else if (x.vote > y.vote) {
			#greater;
		} else {
			#equal;
		};
	};

     // Add a new message to the wall
    public shared ({caller}) func writeMessage(c : Content) : async Nat {
        let newMessage : Message= {
            vote = 0;
            content = c;
            creator = caller;
        };
        map.put(messageId, newMessage);
        //after verifying found possible mistake didnt addup msgID, not sure tbh 
        messageId += 1;
        messageId - 1
    };

    //Get a specific message by ID
    public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        let ?msg = map.get(messageId) else return #err "Couldn't find msg";

        #ok msg
    };

    // Update the content for a specific message by ID
    public shared ({caller}) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
        let ?msg = map.get(messageId) else return #err "Couldn't find msg";
        if (caller != msg.creator) return #err "You are not the creator";

        let newMessage = {
            vote = msg.vote;
            content = c;
            creator = msg.creator;
        };

        ignore map.replace(messageId, newMessage);

        #ok
    };

    //Delete a specific message by ID
    public shared func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        let ?msg = map.get(messageId) else return #err "Couldn't find msg";

        map.delete(messageId);

        #ok
    };

    // Voting
    public shared func upVote(messageId  : Nat) : async Result.Result<(), Text> {
        let ?msg = map.get(messageId) else return #err "Couldn't find msg";

        let newMessage = {
            vote = msg.vote + 1;
            content = msg.content;
            creator = msg.creator;
        };

        ignore map.replace(messageId, newMessage);

        #ok
    };

    public shared func downVote(messageId  : Nat) : async Result.Result<(), Text> {
        let ?msg = map.get(messageId) else return #err "Couldn't find msg";

        let newMessage = {
            vote = msg.vote - 1;
            content = msg.content;
            creator = msg.creator;
        };

        ignore map.replace(messageId, newMessage);

        #ok
    };

    //Get all messages
    public shared query func getAllMessages() : async [Message] {
        let buf = Buffer.Buffer<Message>(8); // Create an empty buffer
  
        for ((key, value) in map.entries()) {
            buf.add(value); // Append the entry to the buffer
        };

        Buffer.toArray(buf)
    };

    //Get all messages
    public shared query func getAllMessagesRanked() : async [Message] {
        let buf = Buffer.Buffer<Message>(8); // Create an empty buffer
  
        for ((key, value) in map.entries()) {
            buf.add(value); // Append the entry to the buffer
        };

        let arr = Buffer.toArray(buf);
        Array.sort(arr, sortByVote);
    };
};