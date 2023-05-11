import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";

actor HomeworkDiary {
    
    public type Homework = {
        title : Text;
        description : Text;
        dueDate : Time.Time;
        completed : Bool;
    };

    let homeworkDiary = Buffer.Buffer<Homework>(4);

    // Add a new homework task
    public func addHomework(homework: Homework) : async Nat {
        homeworkDiary.add(homework);
        homeworkDiary.size() - 1
    };

    // Get a specific homework task by id
    public query func getHomework(id: Nat) : async Result.Result<Homework, Text> {
        let ?entry = homeworkDiary.getOpt(id) else return #err "Can't find homework!";
        #ok entry
    };

    // Update a homework task's title, description, and/or due date
    public func updateHomework(id: Nat, homework: Homework) : async Result.Result<(), Text> {
        let ?entry = homeworkDiary.getOpt(id) else return #err "Can't find homework!";
        homeworkDiary.put(id, homework);
        #ok 
    };

    // Mark a homework task as completed 
    public func markAsCompleted(id: Nat) : async Result.Result<(), Text> {
        let ?entry = homeworkDiary.getOpt(id) else return #err "Can't find homework!";
        let newEntry : Homework = {
            title = entry.title;
            description = entry.description;
            dueDate = entry.dueDate;
            completed = true;
        };
        homeworkDiary.put(id, newEntry);
        #ok
    };

    // Delete a homework task by id
    public func deleteHomework(id: Nat) : async Result.Result<(), Text> {
        let ?entry = homeworkDiary.getOpt(id) else return #err "Can't find homework!";
        let x = homeworkDiary.remove(id);
        #ok
    };

    // Get the list of all homework tasks
    public query func getAllHomework() : async [Homework] {
        Buffer.toArray<Homework>(homeworkDiary)
    };


    // Get the list of pending (not completed) homework tasks
    public query func getPendingHomework() : async [Homework] {
        let pendingEntries = Buffer.mapFilter<Homework, Homework>(homeworkDiary, func (entry) {
            if (entry.completed) {
                null
            } else ?entry
        });
        Buffer.toArray<Homework>(pendingEntries)
    };

    // Search for homework tasks based on a search terms
   public query func searchHomework(searchTerm: Text) : async [Homework] {
        let searchedEntries = Buffer.mapFilter<Homework, Homework>(homeworkDiary, func (entry) {
            if (Text.contains(entry.title, #text searchTerm)) {
                ?entry
            } else if (Text.contains(entry.description, #text searchTerm)) {
                ?entry
            } else null
        });
        Buffer.toArray<Homework>(searchedEntries)        
   };
};