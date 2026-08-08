sudo yum update -y

sudo yum install -y wget unzip

wget https://github.com/GoogleCloudPlatform/terraformer/releases/download/0.8.24/terraformer-aws-linux-amd64 -O terraformer

chmod +x terraformer
sudo mv terraformer /usr/local/bin/

echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
