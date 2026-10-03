use aiken/collection/list

/// Teaching helper. This file is not a vote. It is not connected to the
/// proposal counter.
///
/// A credential is a fingerprint of who is allowed to act, not proof of a
/// token balance. The bytes are opaque. This helper does not look up $RISE,
/// balances, stake, or Midnight.
///
/// Its only job is to reject a second use of the same credential bytes.

/// Accept these bytes the first time. Return nothing if they were already used.
pub fn accept_once(
  already_used: List<ByteArray>,
  credential: ByteArray,
) -> Option<List<ByteArray>> {
  if list.has(already_used, credential) {
    None
  } else {
    Some(list.push(already_used, credential))
  }
}

test first_use_of_bytes_is_allowed() {
  let credential = #"aa11"
  expect Some(used) = accept_once([], credential)
  list.has(used, credential)
}

test second_use_of_same_bytes_is_rejected() {
  let credential = #"aa11"
  expect Some(used) = accept_once([], credential)
  accept_once(used, credential) == None
}

test different_bytes_are_still_allowed() {
  let first = #"aa11"
  let other = #"bb22"
  expect Some(used) = accept_once([], first)
  expect Some(next) = accept_once(used, other)
  list.has(next, first) && list.has(next, other)
}
