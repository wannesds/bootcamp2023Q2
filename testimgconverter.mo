    public shared(msg) func addProposalChunk(proposalId:Nat,chunks:[Nat8]){
        let result = await getProposal(proposalId);
        if(Result.isOk(result)){
            switch(Result.toOption(result)){
              case null{ };
              case (?found){
                  let arrayFromProposal:[Nat8]= await toNat8(found.content);
                  let bufferFromProposal:Buffer.Buffer<Nat8> = Buffer.Buffer<Nat8>(0);
                    for(natInArray in arrayFromProposal.vals()){
                      bufferFromProposal.add(natInArray);
                    };
                    for(chunk in chunks.vals()){
                        bufferFromProposal.add(chunk);
                    };
                  let finalConentAsNat:[Nat8] = Buffer.toArray(bufferFromProposal);
                  let finalBlob:Content = #Image(Blob.fromArray(finalConentAsNat));
                    let proposalToUpdateWithChunks:Proposal = {
                        id=found.id;
                        icp=found.icp;
                        description=found.description;
                        content=finalBlob;
                        completed=found.completed;
                        icpWallet=found.icpWallet;
                    };
                }
            };

        }
    };

public func toNat8(x : Content) : async [Nat8] {
  switch(x) {
        case (#Image(val)) { return Blob.toArray(val)};
    }; 