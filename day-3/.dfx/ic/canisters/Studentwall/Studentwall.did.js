export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Content = IDL.Variant({
    'Text' : IDL.Text,
    'Image' : IDL.Vec(IDL.Nat8),
    'Video' : IDL.Vec(IDL.Nat8),
  });
  const Message = IDL.Record({
    'creator' : IDL.Principal,
    'content' : Content,
    'vote' : IDL.Int,
  });
  const Result_1 = IDL.Variant({ 'ok' : Message, 'err' : IDL.Text });
  return IDL.Service({
    'deleteMessage' : IDL.Func([IDL.Nat], [Result], []),
    'downVote' : IDL.Func([IDL.Nat], [Result], []),
    'getAllMessages' : IDL.Func([], [IDL.Vec(Message)], ['query']),
    'getAllMessagesRanked' : IDL.Func([], [IDL.Vec(Message)], ['query']),
    'getMessage' : IDL.Func([IDL.Nat], [Result_1], ['query']),
    'upVote' : IDL.Func([IDL.Nat], [Result], []),
    'updateMessage' : IDL.Func([IDL.Nat, Content], [Result], []),
    'writeMessage' : IDL.Func([Content], [IDL.Nat], []),
  });
};
export const init = ({ IDL }) => { return []; };
