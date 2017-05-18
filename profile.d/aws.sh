#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DIR=~/.aws
export AWS_CREDENTIAL_FILE="$DIR/aws_credential_file"
export AWS_ACCESS_KEY_ID=$(grep '^AWSAccessKeyId' "$AWS_CREDENTIAL_FILE" | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep '^AWSSecretKey'   "$AWS_CREDENTIAL_FILE" | cut -d= -f2)

function aws-lookup() {
  aws ec2 describe-instances --region $1 --filters "Name=tag:Name,Values=*$2*" --query='Reservations[*].Instances[*].[PublicDnsName,Tags[*].Value]' --output text
}
