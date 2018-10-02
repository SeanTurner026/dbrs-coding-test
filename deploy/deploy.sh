# terraform apply --auto-approve

rm output.json && terraform output --json > output.json

EC2_PUBLIC_DNS=`cat output.json | jq -r '."public-dns-address" | .value'`

ssh -oStrictHostKeyChecking=no -i "aws_terraform" ubuntu@$EC2_PUBLIC_DNS "\
git clone https://github.com/SeanTurner026/dbrs-coding-test.git;\
sudo snap install docker;\
sleep 15;\
sudo docker run -d -p 8888:8888 -v /home/ubuntu/dbrs-coding-test:/home/jovyan/dbrs-coding-test --rm --name jupyter jupyter/datascience-notebook" <<-'ENDSSH'
ENDSSH

echo "- ssh -oStrictHostKeyChecking=no -i aws_terraform ubuntu@$EC2_PUBLIC_DNS"
echo "- sudo docker exec -it <container-id> /bin/bash"
echo "- jupyter notebook list"
echo "- Copy the token to clipboard, Open a browser and navigate to $EC2_PUBLIC_DNS:8888, and enter the token"