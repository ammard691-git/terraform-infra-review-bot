# Terraform Infra Review Bot

An AI-assisted pull request reviewer for Terraform. On every PR that changes `infra/`,
GitHub Actions runs deterministic checks and asks Claude (Haiku 5.5) to explain and
prioritise the security and cost risks, then posts one auto-updating PR comment.

## How it works
PR opened or updated -> GitHub Actions -> `terraform fmt` / `validate` -> TFLint -> Checkov
-> offline `terraform plan` (mock credentials, nothing is created) -> `scripts/review.py`
calls Claude -> one sticky PR comment with a findings table and suggested fixes.

## Cost
- GitHub Actions: free (public repository, standard runner).
- AWS: $0. No AWS resources are created and no AWS credentials are used.
- Claude Haiku 5.5: about $0.002 per review.

## Security
- No `terraform apply` anywhere; the plan runs offline with mock credentials.
- The Anthropic key is a GitHub Actions secret, capped by a Claude Console workspace spend limit.
- Workflow runs only on `pull_request` (never `pull_request_target`) and skips fork PRs.
- PR content is treated as untrusted data in the prompt; secrets are redacted before sending.
- Claude's review is advisory; Checkov and Terraform provide the deterministic findings.

## Evidence
Live example: [PR #1](https://github.com/ammard691-git/terraform-infra-review-bot/pull/1). Click "edited" on the bot's comment to see the first version.

| | Risky PR (before) | Fixed PR (after) |
|---|---|---|
| Verdict | Not safe to merge | Safe to merge (plan-only demo) |
| High-severity issues | 4 | 0 |
| Checkov failed checks | 27 | 10 |
| Offline plan | 7 to add | 5 to add |
| Claude tokens in / out | 5,769 / 3,215 | 4,217 / 3,994 |
| Claude cost | $0.0022 | $0.0024 |

Planted risks caught: public S3 bucket, SSH open to 0.0.0.0/0, wildcard IAM policy, p4d.24xlarge GPU instance (about $24k a month, Claude's estimate), NAT gateway.

Total project spend: $0.01 in Claude usage. AWS: $0. GitHub Actions: $0.
