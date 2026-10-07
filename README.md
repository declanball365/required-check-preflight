# Required-check Preflight

## Could a workflow filter leave your required check pending?

Run a small local check before changing selective GitHub Actions CI. Supply one workflow and the exact check names you require; get a named configuration risk and a direction to review.

**Free experimental checker — no signup, upload or telemetry.**

[Download the free checker](https://github.com/declanball365/required-check-preflight/releases/download/v0.1.0/required-check-preflight.zip) · [Read the quickstart](QUICKSTART.md)

The checker reads files locally. It does not run workflow steps or change branch protection. Tested locally on Ruby 2.6.10; other Ruby versions and operating systems are not yet verified. You need Ruby installed.

### What the evidence supports

In six frozen cases, it warned on three path-filter risks where actionlint was silent, and stayed silent on three controls. All three risks exercise the same rule. This is a narrow comparison, not an accuracy guarantee. Continue using actionlint for workflow syntax and expressions.

### Proposed team policy pack — AUD 29 once

**Not built. Not for sale. No payment or reservation is taken.**

Proposed download contents:

- An annotated unfiltered required-gate example for one static test job, with expected outcomes for changed, unchanged, failed and cancelled runs.
- A branch-protection review checklist covering exact check names and explicitly enabled merge queues.
- A small local fixture set documenting supported and unsupported patterns.

The free diagnostic stays free. The proposed pack is a fixed digital download for one team, without subscriptions, bespoke CI changes, consulting or promised ongoing updates. Matrix jobs, reusable workflows and multi-workflow fixes are excluded. Free GitHub documentation and coding assistants may already meet your needs.

[Review the exact proposed pack and interest step](PACK-INTEREST.md)

### Limits

One workflow and exact static check names only. No ruleset lookup, app identity, matrix expansion, expression evaluation or mergeability certification. Empty findings do not mean your CI is safe. Output is advisory; warnings do not produce a failing exit code. Never make this command a required gate expecting it to block risky configurations.

Experimental release v0.1.0; proposed policy pack is not for sale.
