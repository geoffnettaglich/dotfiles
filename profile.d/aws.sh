#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"

complete -C '/usr/local/bin/aws_completer' aws

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
    local NAME=${1} STATE=${2:-*};
    local FILTER="Name=instance-state-name,Values=$STATE";
    echo "Using: name=$NAME and state=$STATE" 1>&2;

    if [ -n "$NAME" ] ; then
      FILTER="$FILTER Name=tag:Name,Values=*$NAME*"
    fi

    #echo -e -n "InstanceId\tInstanceType\tImageId\tState.Name\tLaunchTime\tPlacement.AvailabilityZone\tPrivateIpAddress\tPrivateDnsName\tPublicDnsName\t"
    #aws-query-tags-names;
    aws ec2 describe-instances \
            --filters $FILTER \
            --query "Reservations[*].Instances[*].{ID:InstanceId, Type:InstanceType, AMI:ImageId, State:State.Name, Launched:LaunchTime, AZ:Placement.AvailabilityZone, PrivateIP:PrivateIpAddress, PublicIP:PublicIpAddress, Name:Tags[?Key=='Name']|[0].Value}" \
            --output table
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

function aws-ad-so ()
{
  env=${1:-stg}
  aws-azure-login --profile drb${env}sec && aws-azure-login --profile drb${env}
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

function aws-images ()
{
	owner=${1:-self}
	aws ec2 describe-images --owner $owner | jq  --raw-output '
                                      # extract instances as a flat list.
     [.Images | sort_by(.CreationDate) | .[]
                                      # remove unwanted data
     | {
         created: .CreationDate,
         imageId: .ImageId,
         name: .Name,
		 description: .Description}
     ]
                                         # lowercase keys
                                         # (for predictable sorting, optional)
     |  [.[]| with_entries( .key |= ascii_downcase ) ]
         |    (.[0] |keys_unsorted | @tsv)               # print headers
            , (.[]|.|map(.) |@tsv)                       # print table
     ' | column -t
}

