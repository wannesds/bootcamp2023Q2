module Types{
    public type Message = {
        vote: Int;
        content: Content;
        creator: Principal;
    };

    public func createMessage(_vote : Int, _content : Content, _creator: Principal) : Message {
        return {
            vote = _vote;
            content = _content;
            creator = _creator;
        };
    };

    public type Content = {
        #Text: Text;
        #Image: Blob;
        #Video: Blob;
    };
}