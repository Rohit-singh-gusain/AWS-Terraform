import boto3

ec2 = boto3.client('ec2','us-east-1')

response = ec2.describe_instances()

instnces_info = []

for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        instnces_info.append({
            'id': instance['InstanceId'],
            'instance_type': instance['InstanceType'],
            'state': instance['State'],
            'name': instance['Tags']['Name']
        })

for ec2_info in instnces_info:
    
    print(f"Id: {ec2_info['id']}")
    print(f"Instance_type: {ec2_info['instance_type']}")
    print(f"State: {ec2_info['state']['Name']}")
    print(f"Name: {ec2_info['name']}")
    print("*"*40)




