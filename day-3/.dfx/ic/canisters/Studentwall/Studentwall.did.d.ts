import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type Content = { 'Text' : string } |
  { 'Image' : Uint8Array | number[] } |
  { 'Video' : Uint8Array | number[] };
export interface Message {
  'creator' : Principal,
  'content' : Content,
  'vote' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Message } |
  { 'err' : string };
export interface _SERVICE {
  'deleteMessage' : ActorMethod<[bigint], Result>,
  'downVote' : ActorMethod<[bigint], Result>,
  'getAllMessages' : ActorMethod<[], Array<Message>>,
  'getAllMessagesRanked' : ActorMethod<[], Array<Message>>,
  'getMessage' : ActorMethod<[bigint], Result_1>,
  'upVote' : ActorMethod<[bigint], Result>,
  'updateMessage' : ActorMethod<[bigint, Content], Result>,
  'writeMessage' : ActorMethod<[Content], bigint>,
}
