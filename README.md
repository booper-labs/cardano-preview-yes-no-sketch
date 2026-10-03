This is NOT CIP-1694 governance (CIP means Cardano Improvement Proposal; CIP-1694 is Cardano's on-chain governance system with DReps, stake pool operators, and the treasury).

This does NOT move the Cardano treasury and is NOT a delegated-representative (DRep) vote.

$RISE voting weight is Unknown: who holds it, on which chain, and what a script could prove. Those three are not filled in here.

No transaction was submitted. No mainnet. No browser-wallet (CIP-30) spend. CIP-30 is the Cardano standard for a web page to ask a browser wallet to build or sign a transaction. This folder does not do that.

**Audience:** Community learners and reviewers.
**Status:** teaching sketch. Not a live vote. No transaction was submitted.
**Checked:** 2026-10-02 (evening PT).

UTxO means unspent transaction output (a coin output that has not been spent yet). The validator below is a spend validator: it runs only when a transaction tries to spend one of those outputs.

## What you are looking at

A teaching sketch of a "proposal plus yes/no" counter. The datum (the data stored on the output) has three fields:

- a title hash (an opaque string of bytes the locker chose)
- a yes count (a plain integer)
- a no count (a plain integer)

The redeemer (the argument supplied when spending) is yes or no. In the code the type is named `Choice`, with constructors `Yes` and `No`, so it is not the standard library's CIP-1694 vote type. That library type is `cardano/governance.Vote`, and the library's own comment describes it as yes, no, or abstain on a governance action. This validator does not implement the `vote` script purpose. Its fallback handler returns false, so minting, withdrawing, publishing a certificate, a CIP-1694 vote, and proposing a governance action are rejected.

On a successful spend the script asks for exactly one new output back to the same script, carrying the same value (the same coins and tokens that were locked), and an inline datum whose title hash is unchanged and whose matching counter is one higher.

The file is `validators/proposal_yes_no.ak`.

## Obvious limits

Read these before anyone treats a counter as a vote.

- Anyone can vote. The script never checks a signature. Whoever can build the spend can add one yes or one no.
- The same person can do it again. Each spend creates a new output, and that output can be spent again. There is no "already voted" mark.
- The counters are not tied to a token. They are not $RISE, not ADA, and not a snapshot of any balance.
- There is no identity. Nothing in the datum records who voted.
- This is not a snapshot. There is no block height, no time, and no list of holders.
- The title hash is not checked. The script does not hash a title string, does not require 32 bytes, and does not look up a proposal list. The locker picks the starting datum, including the starting counts.
- The two tests only check the helper that adds one to a counter. They do not build a transaction and they do not run the spend rule. The spend rule typechecked. It was not executed.

## What was compiled

Command used for the pass below: `aiken v1.1.23+8949565`.

`aiken.toml` pins:

- `compiler = "v1.1.23"`
- `plutus = "v3"` (Plutus V3 is the script language this compiler is set to emit; this was not a live Preview node query)
- `aiken-lang/stdlib` version `v3.1.0`

The hello-world practice project at `preview-practice-spike/aiken-hello` pins the same compiler and `plutus = "v3"`, but its stdlib line is the floating tag `version = "v3"`, not `v3.1.0`. No transaction hash was copied from that repo.

Stdlib v4 matters, and this sketch does **not** use it. The GitHub releases page for `aiken-lang/stdlib`, fetched 2026-10-02, lists `v4.0.0` (commit `dfdf5ff`) above `v3.1.0`. v4 renames the old `Value` type to `Assets` and adds a builtin value syntax. On this compiler, `aiken check` against `v4.0.0` failed while parsing the library itself (`cardano/value.ak` and `cardano/value.test.ak`). The summary line was `Summary 2 errors, 0 warnings` and the process exited 1. That pin was reverted. `aiken new` on this machine had written stdlib `1.5.0`, which is older than the v3 API this compiler expects; that default was replaced with `v3.1.0` before the passing check. A newer compiler was not installed. The box already had Aiken.

The `repository` table in `aiken.toml` is only the project name Aiken requires, not a claim that this GitHub repo does not exist.

## Honesty

| Claim | Rating |
|-------|--------|
| `aiken check` in this folder exited 0 on 2026-10-02 against stdlib v3.1.0, and the two counter tests passed | **Solid** (output quoted below) |
| The spend rule typechecks as part of that same check | **Solid** (the project compiled; exit 0) |
| The spend rule was run on a sample transaction | **Not run.** Do not read the unit tests as covering it. Call that behavior **Shaky** until a transaction test exists |
| This sketch is CIP-1694 governance, a DRep vote, or a treasury move | **Solid** that it is none of those. The code never touches treasury fields and rejects the governance script purposes |
| Live Preview parameters match this local Plutus V3 setting | **Unknown** (no node query, no submission) |
| Who holds $RISE, on which chain, and what a Preview script could prove | **Unknown** |
| Stdlib v4.0.0 typechecks on Aiken v1.1.23 | **Solid** that it did **not**, on the attempt above |

## NOTE — `aiken check`

Command (this shell was not a terminal, so Aiken printed JSON, which is what it documents for non-TTY output). The command was run in this project folder:

```
aiken check
```

Process exit code observed: 0.

Output captured from that command:

```
    Compiling preview-practice/yes-no-sketch 0.0.0 (.)
    Resolving dependencies
    Resolving preview-practice/yes-no-sketch
      Fetched 1 package in 0.05s from cache
    Compiling aiken-lang/stdlib v3.1.0 (./build/packages/aiken-lang-stdlib)
   Collecting all tests scenarios across all modules
      Testing ...
{
  "seed": 3817836258,
  "summary": {
    "total": 2,
    "passed": 2,
    "failed": 0,
    "kind": {
      "unit": 2,
      "property": 0
    }
  },
  "modules": [
    {
      "name": "proposal_yes_no",
      "summary": {
        "total": 2,
        "passed": 2,
        "failed": 0,
        "kind": {
          "unit": 2,
          "property": 0
        }
      },
      "tests": [
        {
          "title": "yes_adds_one_and_keeps_title",
          "status": "pass",
          "on_failure": "fail_immediately",
          "execution_units": {
            "mem": 16401,
            "cpu": 5132943
          }
        },
        {
          "title": "no_adds_one_and_keeps_title",
          "status": "pass",
          "on_failure": "fail_immediately",
          "execution_units": {
            "mem": 17065,
            "cpu": 5384455
          }
        }
      ]
    }
  ]
}
```

The earlier v4 attempt is not this result. Its captured summary was `Summary 2 errors, 0 warnings` (exit 1).

This repository is a teaching sketch, not a live vote, and no transaction was submitted.
