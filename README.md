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
_Screenshots of the PR comment, workflow run and token usage go here._
