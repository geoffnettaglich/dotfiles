#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DIR=~/.aws

if [ -d $DIR ] ; then
  # echo "Raw: $DIR"
  AWS_CREDENTIAL_FILE="$DIR/aws_credential_file"

  # not the preferred approach but if we have a legacy creds file then try this :/
  if [ -r "$AWS_CREDENTIAL_FILE" ] ; then
    export AWS_CREDENTIAL_FILE
    export AWS_ACCESS_KEY_ID=$(grep '^AWSAccessKeyId' "$AWS_CREDENTIAL_FILE" | cut -d= -f2)
    export AWS_SECRET_ACCESS_KEY=$(grep '^AWSSecretKey'   "$AWS_CREDENTIAL_FILE" | cut -d= -f2)
  fi
fi

function aws-query-tags ()
{
    echo "[Tags[?Key==\`Name\`].Value] [0][0], [Tags[?Key==\`project\`].Value] [0][0], [Tags[?Key==\`environment\`].Value] [0][0], [Tags[?Key==\`owner\`].Value] [0][0], [Tags[?Key==\`version\`].Value] [0][0]"
}

function aws-query-tags-names ()
{
    echo -e "Name\tProject\tEnvironment\tOwner"
}

function aws-instances ()
{
    local NAME=${1:-*} STATE=${2:-*};
    echo "Using: name=$NAME and state=$STATE" 1>&2;
    echo -e -n "InstanceId\tInstanceType\tImageId\tState.Name\tLaunchTime\tPlacement.AvailabilityZone\tPrivateIpAddress\tPrivateDnsName\tPublicDnsName\t"
    aws-query-tags-names;
    aws ec2 describe-instances \
            --filters "Name=instance-state-name,Values=$STATE" "Name=tag:Name,Values=*$NAME*" \
            --query "Reservations[*].Instances[*].[InstanceId, InstanceType, ImageId, State.Name, LaunchTime, Placement.AvailabilityZone, PrivateIpAddress, PrivateDnsName, PublicDnsName, `aws-query-tags`]" \
            --output text
}

function aws-lookup ()
{
    local REGION=${1:-*} NAME=${2:-*};
    aws ec2 describe-instances \
            --region $REGION \
            --filters "Name=tag:Name,Values=*$NAME*" \
            --query='Reservations[*].Instances[*].[PublicDnsName,Tags[*].Value]' \
            --output text
}

function aws-security-groups ()
{
    local NAME=${1:-*}
    echo "Using: name=$NAME and Region=$AWS_DEFAULT_REGION" 1>&2;
    echo -e "GroupId\tGroupName\tDescription\t`aws-query-tags-names`";
    aws ec2 describe-security-groups \
            --filters "Name=group-name,Values=*$NAME*" \
            --query "SecurityGroups[*].[GroupId, GroupName, Desciption, `aws-query-tags`]" \
            --output text
}

function aws-instance-counts ()
{
    for region in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do 
        echo "Region: $region"; aws ec2 describe-instances --region "$region" --query 'Reservations[].Instances[] | length(@)'; 
    done
}

function aws-instance-tags ()
{
  REGIONS="ap-southeast-1 eu-central-1 eu-west-1 us-east-1 us-west-1 us-west-2"

  for REGION in $REGIONS ; do
    LINES=`AWS_DEFAULT_REGION=$REGION aws-instances`

    while read -r line; do
      echo "$REGION $line"
    done <<< "$LINES"

  done
}
