eksctl create cluster \
--name capstone \
--version 1.18 \
--region us-west-2 \
--nodegroup-name linux-nodes \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--ssh-access \
--ssh-public-key dmalinov-oregon \
--managed