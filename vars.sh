# Script contendo as váriaveis de ambiente necessárias para execução do Playbook
# Nota: As atualizações neste script não devem ser colocadas no seu git!
# Nota: Altere apenas os campos exigidos.

CONTAINER_CMD="docker"                      # Aplicação de container a ser utilizada
CONTAINER_IMAGE="mo833-ansible"             # Nome da imagem
AWS_ACCESS_KEY_ID="AKIXXXXXXXXXXXXXXXX"     # Access key ID <SUBSTITUA COM O SEU, ENVIADO POR E-MAIL>
AWS_SECRET_ACCESS_KEY="XXXXX"               # Secret access key <SUBSTITUA COM O SEU, ENVIADO POR E-MAIL>
AWS_REGION="us-east-1"                      # Região do provedor de nuvem
KEYPAIR_NAME="XXXXXXXXX"                    # Nome do Key Pair <SUBSTITUA COM O SEU, CRIADO NO AWS WEB CONSOLE>
WORK_DIR="$(realpath $(pwd))"               # Diretório
KEYPAIR_PEM_FILE="$WORK_DIR/key.pem"        # Arquivo com a chave privada, utilizado para realizar SSH
ANSIBLE_PRIVATE_KEY_FILE=$KEYPAIR_PEM_FILE  # Alias para KEYPAIR_PEM_FILE, utilizado pelo Ansible
EFS_HOST="XXXX"                             # Endereço IP do EFS <SUBSTITUA COM O SEU IP DO EFS>
EFS_MOUNT_POINT="/home/ubuntu/efs"          # Local de montagem do sistema 
ANSIBLE_HOST_KEY_CHECKING=0                 # Remover o prompt de 'yes' ao conectar por SSH na máquina remota
