import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface _SERVICE {
  'add' : ActorMethod<[bigint], bigint>,
  'div' : ActorMethod<[bigint], bigint>,
  'mult' : ActorMethod<[bigint], bigint>,
  'reset' : ActorMethod<[], undefined>,
  'show' : ActorMethod<[], bigint>,
  'sub' : ActorMethod<[bigint], bigint>,
}
