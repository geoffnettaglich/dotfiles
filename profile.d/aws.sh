#DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
DIR=~/.aws

if [ -d $DIR ] ; then
  echo "Raw: $DIR"
  export AWS_CREDENTIAL_FILE="$DIR/aws_credential_file"
  export AWS_ACCESS_KEY_ID=$(grep '^AWSAccessKeyId' "$AWS_CREDENTIAL_FILE" | cut -d= -f2)
  export AWS_SECRET_ACCESS_KEY=$(grep '^AWSSecretKey'   "$AWS_CREDENTIAL_FILE" | cut -d= -f2)
fi

function aws-lookup() {
  aws ec2 describe-instances --region $1 --filters "Name=tag:Name,Values=*$2*" --query='Reservations[*].Instances[*].[PublicDnsName,Tags[*].Value]' --output text
}

function aws-filter-args ()
{
    NAME="";
    STATE="*";
    for i in "$@";
    do
        echo "I is $i";
        case $i in
            -n=* | --name=*)
                NAME="${i#*=}"
            ;;
            -s=* | --state=*)
                STATE="${i#*=}"
            ;;
        esac;
    done
}

function aws-instances ()
{
    aws-filter-args $@;
    echo "Using: name=$NAME and state=$STATE" 1>&2;
    aws-query-tags-names;
    aws ec2 describe-instances --filters "Name=instance-state-name,Values=$STATE" "Name=tag:Name,Values=*$NAME*" --output text --query "Reservations[*].Instances[*].[InstanceId, InstanceType, ImageId, State.Name, LaunchTime, Placement.AvailabilityZone, Placement.Tenancy, PrivateIpAddress, PrivateDnsName, PublicDnsName, `aws-query-tags`]"
}

function aws-lookup ()
{
    aws ec2 describe-instances --region $1 --filters "Name=tag:Name,Values=*$2*" --query='Reservations[*].Instances[*].[PublicDnsName,Tags[*].Value]' --output text
}

function aws-query-tags ()
{
    echo "[Tags[?Key==\`Name\`].Value] [0][0], [Tags[?Key==\`project\`].Value] [0][0], [Tags[?Key==\`environment\`].Value] [0][0], [Tags[?Key==\`owner\`].Value] [0][0]"
}

function aws-query-tags-names ()
{
    echo -e "Name\tProject\tEnvironment\tOwner"
}

function aws-security-groups ()
{
    local NAME=${1:-*} STATE=${2:-*};
    echo "Using: name=$NAME and Region=$AWS_DEFAULT_REGION" 1>&2;
    echo -e "GroupId\tGroupName\tDescription\t`aws-query-tags-names`";
    aws ec2 describe-security-groups --filters "Name=group-name,Values=*$NAME*" --output text --query "SecurityGroups[*].[GroupId, GroupName, Desciption, `aws-query-tags`]"
}
