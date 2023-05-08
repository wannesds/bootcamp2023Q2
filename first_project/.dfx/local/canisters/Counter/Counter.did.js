export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'add' : IDL.Func([IDL.Int], [IDL.Int], []),
    'div' : IDL.Func([IDL.Int], [IDL.Int], []),
    'mult' : IDL.Func([IDL.Int], [IDL.Int], []),
    'reset' : IDL.Func([], [], []),
    'show' : IDL.Func([], [IDL.Int], ['query']),
    'sub' : IDL.Func([IDL.Int], [IDL.Int], []),
  });
};
export const init = ({ IDL }) => { return []; };
