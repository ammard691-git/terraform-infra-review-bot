# Used only in CI for an offline plan. Never commit real credentials.
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}
