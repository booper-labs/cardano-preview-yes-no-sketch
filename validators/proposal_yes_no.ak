use cardano/address.{Script}
use cardano/transaction.{
  InlineDatum, OutputReference, Transaction, find_input, find_script_outputs,
}

/// Teaching datum for one proposal output.
///
/// `title_hash` is an opaque byte string stored by whoever created the output.
/// This script does not hash a title, does not check the length, and does not
/// look up a proposal registry.
///
/// `yes_count` and `no_count` are plain integers. They are not token balances
/// and they are not tied to $RISE or to ADA.
pub type ProposalDatum {
  title_hash: ByteArray,
  yes_count: Int,
  no_count: Int,
}

/// Redeemer for this sketch: yes or no.
///
/// This is not `cardano/governance.Vote`. That standard-library type is the
/// CIP-1694 vote (yes, no, or abstain) attached to a governance action.
/// This validator does not implement the `vote` script purpose at all.
pub type Choice {
  Yes
  No
}

/// Next datum after one spend. The title hash is copied. One counter goes up by 1.
pub fn next_datum(current: ProposalDatum, choice: Choice) -> ProposalDatum {
  when choice is {
    Yes -> ProposalDatum { ..current, yes_count: current.yes_count + 1 }
    No -> ProposalDatum { ..current, no_count: current.no_count + 1 }
  }
}

/// Spend validator. Success means: read the current datum, add one yes or one no,
/// and pay the same value back to this same script with that new inline datum.
///
/// It does not check who signed. Any transaction that can spend the output can
/// increment a counter. See the README for the limits.
validator proposal_yes_no {
  spend(
    datum: Option<ProposalDatum>,
    redeemer: Choice,
    own_ref: OutputReference,
    self: Transaction,
  ) {
    expect Some(current) = datum

    expect Some(own_input) = find_input(self.inputs, own_ref)

    expect Script(own_hash) = own_input.output.address.payment_credential

    let expected = next_datum(current, redeemer)

    // One continuing output at this script. Zero or many fails the spend.
    expect [output] = find_script_outputs(self.outputs, own_hash)

    let same_value = output.value == own_input.output.value

    let same_stake =
      output.address.stake_credential == own_input.output.address.stake_credential

    let datum_ok =
      when output.datum is {
        InlineDatum(data) -> {
          expect updated: ProposalDatum = data
          updated == expected
        }
        _ -> False
      }

    and {
      same_value,
      same_stake,
      datum_ok,
    }
  }

  // Mint, withdraw, publish, CIP-1694 vote, and propose are rejected.
  else(_ctx) {
    False
  }
}

test yes_adds_one_and_keeps_title() {
  let start =
    ProposalDatum { title_hash: #"aabb", yes_count: 2, no_count: 5 }
  let next = next_datum(start, Yes)
  next.title_hash == #"aabb" && next.yes_count == 3 && next.no_count == 5
}

test no_adds_one_and_keeps_title() {
  let start =
    ProposalDatum { title_hash: #"cc", yes_count: 2, no_count: 5 }
  let next = next_datum(start, No)
  next.title_hash == #"cc" && next.yes_count == 2 && next.no_count == 6
}
