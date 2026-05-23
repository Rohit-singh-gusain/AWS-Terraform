import boto3
import subprocess
import json
import time
import paramiko  # pip3 install paramiko

REGION = 'ap-south-1'
PARAMETER_NAME = '/quickshow/base_url'
EC2_KEY_PATH = '~/.ssh/your-key.pem'
EC2_USER = 'ubuntu'

def get_elb_dns_from_terraform():
    result = subprocess.run(
        ['terraform', 'output', '-json'],
        capture_output=True, text=True
    )
    outputs = json.loads(result.stdout)
    return outputs['elb_dns_name']['value']

def get_ec2_ip_from_terraform():
    result = subprocess.run(
        ['terraform', 'output', '-json'],
        capture_output=True, text=True
    )
    outputs = json.loads(result.stdout)
    return outputs['ec2_public_ip']['value']  # make sure this output exists in tf

def update_parameter_store(value):
    ssm = boto3.client('ssm', region_name=REGION)
    ssm.put_parameter(
        Name=PARAMETER_NAME,
        Value=f'http://{value}',
        Type='String',
        Overwrite=True
    )
    print(f'Parameter Store updated: {value}')

def restart_containers(ec2_ip):
    print(f'SSHing into {ec2_ip} to restart containers...')
    
    key = paramiko.RSAKey.from_private_key_file(EC2_KEY_PATH)
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=ec2_ip, username=EC2_USER, pkey=key)
    
    # restart all running containers
    stdin, stdout, stderr = client.exec_command('docker restart $(docker ps -q)')
    print(stdout.read().decode())
    
    client.close()
    print('Containers restarted successfully')

def run_terraform(action):
    print(f'Running terraform {action}...')
    result = subprocess.run(
        ['terraform', action, '-auto-approve'],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f'Terraform failed:\n{result.stderr}')
        exit(1)
    print(f'Terraform {action} done')

def main():
    # step 1 - build infra
    run_terraform('apply')
    
    # step 2 - wait for EC2 user data to finish
    print('Waiting for EC2 to initialize...')
    time.sleep(90)  # adjust based on how long your user data takes
    
    # step 3 - get new ELB DNS and EC2 IP from terraform outputs
    elb_dns = get_elb_dns_from_terraform()
    ec2_ip = get_ec2_ip_from_terraform()
    print(f'ELB DNS: {elb_dns}')
    print(f'EC2 IP: {ec2_ip}')
    
    # step 4 - update parameter store
    update_parameter_store(elb_dns)
    
    # step 5 - restart containers so they pick up new value
    restart_containers(ec2_ip)
    
    print(f'\n✅ QuickShow is live at: http://{elb_dns}')

if __name__ == '__main__':
    main()