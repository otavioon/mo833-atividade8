# Atividade 8: Semana 23/05

## Objetivo

O objetivo desta atividade é aprender a criar um aglomerado computacional e implamentar uma aplicação que executa de forma distribuída na nuvem computacional da AWS. 

## Descrição

Nesta atividade, você deve desenvolver um *playbook* Ansible que faça a implantação e execução da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git) em um aglomerado computacional. 
Em suma, o *playbook* Ansible desenvolvido deverá realizar as seguintes operações:

1. Instalar as aplicações necessárias para execução da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git) nas máquinas do aglomerado;
2. Montar um sistema de arquivos compartilhado EFS, nas máquinas do aglomerado;
3. Clonar repositório da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git) e realizar o *download* dos dados do CIFAR-10 (conforme as instruções do repositório). Estes elementos devem ser colocados no sistema de arquivos compartilhado; 
4. Executar a DCGAN nos nós do aglomerado computacional por 2 épocas, utilizando os dados de teste do CIFAR-10, salvando a saída (padrão) emitida pela aplicação em um arquivo de saída; e
5. Copiar os arquivos de saída das máquinas remotas para a máquina local.

Para execução do seu *playbook* Ansible uma infraestrutura básica é disponibilizada e os detalhes são descritos na seção seguinte.

## Implantação da Aplicação em uma Máquina Virtual da AWS

Esta seção descreve os requisitos e detalhes da infraestrutura para execução do seu *playbook* Ansible. 
Utilizaremos o termo "máquina local" para designar a máquina que será utilizada para realização da atividade e execução do Ansible e o termo "máquina remota" para designar a máquina virtual na nuvem computacional em que a aplicação será executada. 

### Requisitos

Para execução da atividade, você precisará:
1. Instanciar *X* máquinas virtuais de um único tipo utilizando o AWS *Web Console*, semelhantemente a atividade anterior;
2. Possuir seu identificador da chave de acesso e identificador da chave de acesso secreta (`Access Key ID` e `Secret access key`, respectivamente) consigo. Estes foram enviados por e-mail;
3. Possuir um par de chaves (publica e privada) registrados na AWS, bem como o nome deste par de chaves (`KEYPAIR_NAME`). Este par de chaves é o mesmo utilizado para acessar uma máquina virtual por SSH;
4. Possuir a aplicação Docker instalada na máquina local para execução do Ansible.

Os possíveis tipos de máquinas virtuais que podem ser instanciadas e suas respecivas configurações são listadas na abaixo. O método utilizado para a instanciação será descrito posteriormente.

```
Tipo de instancia: t2.small
Keypair: O KEYPAIR_NAME seu, mesmo do item 3
Volume: EBS de 16 Gb, montado em /dev/sda1
Imagem: Ubuntu 20.04 Server, com AMI-ID: ami-0c4f7023847b90238
```

```
Tipo de instancia: t2.medium
Keypair: O KEYPAIR_NAME seu, mesmo do item 3
Volume: EBS de 16 Gb, montado em /dev/sda1
Imagem: Ubuntu 20.04 Server, com AMI-ID: ami-0c4f7023847b90238
```

Uma vez instanciada uma máquina virtual, o IP público (`public_ip_address`) ou DNS dela deve ser anotado. Este pode ser encontrado na descrição das máquinas virtuais, no AWS *Web Console*, no campo `Auto-assigned IP address` ou `Public IPv4 DNS`. 
Note que este IP/DNS pode mudar caso a máquina virtual seja suspensa. 

### Infraestrutura para Execução do *Playbook*

O presente repositório deve ser clonado e executado apenas na máquina local. 
Este conta com os seguintes arquivos para execução do seu *playbook* Ansible:

- ``build_docker.sh``: *Script* para gerar a imagem Docker, que contém Ansible e boto (cliente da AWS). A imagem gerada é chamada `mo833-ansible`. Este arquivo não deve ser alterado;
- ``configure.yaml``: *Playbook* Ansible que deve ser preenchido com *tasks* necessárias para completar a atividade;
- ``Dockerfile``: Arquivo de descrição da imagem Docker, utilizado pelo *script* `build_docker.sh`. Este arquivo não deve ser alterado;
- ``inventory.yaml``: Arquivo de inventorio contendo o endereço da máquina remota que será gerenciada pelo Ansible;
- ``run_configure.sh``: *Script* para executar seu *playbook*. Este arquivo não deve ser alterado;
- ``vars.sh``: *Script* conténdo váriaveis globais de ambiente utilizadas para diversas finalidades. Nota: as alterações neste *script* **NÃO** devem ser submetidas ao git.

Primeiramente, para preparação do ambiente, os seguintes passos devem ser realizados:

1. Instale o Docker na máquina local e gere a imagem Docker executando o *script* `build_docker.sh`. Este passo pode ser realizado apenas uma vez.

2. Altere o arquivo `inventory.yaml` e, no campo indicado (`ansible_host`), substitua o marcador de exemplo (`XXXXX`) pelo IP público (`public_ip_address`) ou DNS de uma máquina remota, recém-anotado. Para as *X* máquinas virtuais instanciadas, *X hosts* devem ser adicionados ao inventório. O nome de cada *host* deve ser *nodeYYY*, onde *YYY* indica é um inteiro, de 0 a *X-1*, e este numero deve ser distindo para cada máquina virtual. Além disso, para cada *host*, a váriavel *node_rank: YYY* também deve ser definida, onde *YYY* deve ser o mesmo valor usado para o nome do *host* a qual esta variável lhe é atribuida. Vale ressaltar que a máquina com *node_rank: 0* agirá como mestre no aprendizado distribuído e os demais como escravos. 

3. Substitua os valores dos campos indicados no arquivo `vars.sh` com seus devidos valores. Os campos a serem substituidos são: `AWS_ACCESS_KEY_ID`, com seu respectivo *Access key ID*, enviado a si por e-mail; `AWS_SECRET_ACCESS_KEY`, com seu respectivo *Secret access key*, enviado a si por e-mail; `KEYPAIR_NAME`, com o nome do par de chaves, registrado na AWS; e `EFS_HOST` com o IP do *host* que mantém o sistema de arquivos EFS. Nota: substitua apenas os campos indicados.

4. Copie sua chave privada, utilizada para acessar as máquinas da AWS, para este diretório e renomei-a para `key.pem`.

Após realizado os passos acima, o *script* `run_configure.sh` pode ser executado. 
Este *script* executa o *playbook* Ansible `configure.yaml` nas máquinas descritas no arquivo de inventório `inventory.yaml`.

### Execução da DCGAN

Para esta atividade, você deve alterar o arquivo `configure.yaml` e, no local indicado, adicionar *tasks* para:

1. Instalar as aplicações necessárias para execução da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git), como os pacotes `docker.io`, `python3-docker` e `nfs-common`;
2. Montar o sistema de arquivos compartilhado EFS nas máquinas do aglomerado. O ponto de montagem a ser utilizado é definido pela variável `efs_mount_point` incluida no *playbook* Ansible e o endereço do *host* que contém o sistema de arquivos EFS é definido pela váriavel `efs_host`;
3. Clonar o repositório da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git) na raíz do sistema de arquivos compartilhado (em `efs_mount_point`). Note que esta operação deve ser executada por apenas uma máquina do aglomerado;
4. Fazer o *download* do conjunto de dados do CIFAR-10 e extraí-lo no sistema de arquivos compartilhado (conforme descrito no repositṕrio da [DCGAN](https://github.com/otavioon/Distributed-DCGAN.git). O caminho, no sistema de arquivos compartilhado, onde os dados devem residir é definido pela váriavel `cifar_data_dir`. Note que esta operação deve ser executada por apenas uma máquina do aglomerado;
5. Criar a imagem Docker da DCGAN (`dist_dcgan`), conforme o manual de uso da mesma (`docker build`);
6. Executar o aprendizado distribuído da DCGAN por 2 épocas, utilizando todos os nós do aglomerado e utilizando como entrada os dados de teste do CIFAR-10. Note que cada nó deve executar a aplicação com parametros diferentes em sua execução. Cada nó deve utilizar seu respectivo valor `node_rank`, definido no inventório, para o parâmetro `--node_rank` da aplicação e o parametro `master_addr` da aplicação deve ser preenchido com o endereço do *host* com nome *node0*.  Além disso, a saída da aplicação deve ser redirecionada e guardada um arquivo `output-XXX.txt`, onde `XXX` corresponde ao `node_rank` do *host* que está executando a aplicação. 
A linha de comando utilizada para execução da aplicação e para realizar o redirecionamento da saída para o arquivo `output.txt` é mostrada a seguir (pode ser alterada caso deseje) e os valores entre '<' e  '>' devem ser subistituidos adequadamente:
```
docker run --network=host --rm -e HOMEDIR=$(pwd) -w $(pwd) -v={{ cifar_data_dir }}:{{ cifar_data_dir }} -v=$(pwd):$(pwd) dist_dcgan:latest python -m torch.distributed.launch --nproc_per_node=1 --nnodes={{ <NUMERO TOTAL DE HOSTS NO AGLOMERADO> }} --node_rank={{ <VARIAVEL NODE RANK DO HOST> }} --master_addr="{{ <ENDEREÇO DO HOST COM NOME node0> }}" --master_port=1234 dist_dcgan.py --dataset cifar10 --dataroot {{ cifar_data_dir }} --image_size 64 --batch_size 128 --out_folder output --test_data --num_epochs 2 --max_workers 1 > output-{{ <VARIAVEL NODE RANK DO HOST> }}.txt
```
7. Copiar o arquivo de saída produzido nas máquinas remotas para a máquina local, em um direrório chamado `resultados` (podem haver mais subdiretórios dentro deste, caso deseje).

Uma vez confeccionado o arquivo `configure.yaml`, o *script* `run_configure.sh` deve ser executado para realizar os testes.

Ao finalizar os testes e submissão, você deve terminar a máquina virtual que foi instânciada.

### Observações do Ansible durante a execução

Vale ressaltar que uma *task* Ansible é executada em todos os nós simulataneamente. Entretando, na execução de um tarefa em um *host*, as variáveis e valores definidos para aquele *host* são passados a ele.

Além disso, variaveis podem ser accessadas utilizando [chaves duplas (`{{ variável }}`), a sintaxe Jinja2](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#using-variables). As váriaveis podem definir valores numéricos, literais, listas e dicionários. Além disso, as váriaveis podem ser [manipuladas utilizando filtros](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html). Por exemplo, supondo que a váriavel `x` corresponda a uma lista de números inteiros, podemos obter o tamanho desta lista (quantidade de elementos) utilizando o filtro `length`, como no exemplo do *playbook* abaixo.

```
- name: "Exemplo de Play que imprime o tamanho da lista, definida pela váriavel x, na tela"
  hosts: localhost
  vars:
    x:
    - 1
    - 2
    - 3
  tasks:
  - name: "Imprime o tamanho da lista X"
    debug:
      msg: "O tamanho da lista é: {{ x | length }}"

```

### Condução de Experimentos

Para esta atividade, você deve executar o seu *playbook* e coletar os resultados da execução da aplicação nos seguintes abaixo, onde o tipo das máquinas e suas respectivas configurações devem ser instânciado conforme descrito préviamente:
- Aglomerado com 1 máquina do tipo `t2.small` (aglomerado 1)
- Aglomerado com 2 máquinas do tipo `t2.small` (aglomerado 2)
- Aglomerado com 4 máquinas do tipo `t2.small` (aglomerado 3)
- Aglomerado com 1 máquina do tipo `t2.medium` (aglomerado 4)
- Aglomerado com 2 máquinas do tipo `t2.medium` (aglomerado 5)
- Aglomerado com 4 máquinas do tipo `t2.medium` (aglomerado 6)

O tempo médio total de execução da aplicação (média dos tempos totais da execução da aplicação em cada uma das máquinas) para cada aglomerado descrito acima, deve ser colocado em um arquivo de texto chamado `tempos.txt`, com o seguinte formato:

```
aglomerado 1: XXXX segundos
aglomerado 2: XXXX segundos
aglomerado 3: XXXX segundos
aglomerado 4: XXXX segundos
aglomerado 5: XXXX segundos
aglomerado 6: XXXX segundos
```

## Entrega e Avaliação

Para entrega, os arquivos `configure.yaml` e `tempos.txt` devem ser submetidos.
A submissão deve ser realizada até o dia 31/05/2021 às 13h59min, horário de Brasilia.

## Dicas e Observações
- **NÃO** submeta nenhum arquivo adicional, apenas os arquivos `configure.yaml` e `tempos.txt`.

- Altere apenas os campos indicados nos arquivos, uma vez que a avaliação será realizada re-executando os passos descritos nas seções anteriores, entretanto, com o seu arquvo `configure.yaml`. Além disso, é essencial que seus arquivos não dependa de nenhum outro arquivo externo.

- Todas as *tasks* devem ser nomeadas.

- As máquinas virtuais da sua conta na AWS são suspensas todos os dias, a meia-noite. Você pode reativá-las normalmente, através do AWS *Web Console*. Note que o IP e DNS pode mudar, o que exige a atualização das informações no arquivo de inventório.

- Você pode ir montando e executando seu *playbook* aos poucos e testar, sempre que possível.

- É mais facil iniciar com um aglomerado pequeno, ao invés dele grande

- A váriavel `ansible_play_hosts`, definida pelo próprio Ansible, contém uma lista de *hosts* que executam a *Play* em questão.

- A váriavle `hostvars`, definida pelo Ansible, é um dicionário onde a chave é o nome do nó e os valores são diversas informações sobre aquele nó, como, por exemplo, o IP ou DNS, *e.g.*, `ansible_host`.

- Váriaveis especiais adicionais podem ser consultadas na [documentação do Ansible](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html).

- Utilize o módulo [`debug`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html) para auxiliar a depurar seu *playbook* e observar o valor de variáveis.

- Não esqueça de testar antes de submeter, executando o *script* `run_configure.sh`!

- Você pode, paralelamente, efetuar *login* na máquina remota para observar os efeitos realizados pelas *tasks* executadas.

- Você pode utilizar qualquer módulo embutido na instalação do Ansible, mas não deve instalar nenhum módulo adicional.

- Alguns modulos do Ansible úteis para esta atividade podem ser: 
    - [Módulo `apt`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html) para instalação e atualização de pacotes.
    - [Módulo `git`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html) para utilizar git.
    - [Módulo `docker_image`](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_image_module.html) para construção de imagens Docker.
    - [Módulo `shell`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html) para execução de comandos shell.
    - [Módulo `fetch`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html) para copia de arquivos da máquna remota para a máquina local.
    - [Módulo `mount`](https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html) para montar sistema de aquivos. Para EFS, algumas opções úteis são: `fstype: nfs4`, `src: "{{ efs_host }}:/"` e `opts: nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport`.
    - [Módulo `file`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html) para criar e excluir arquivos e diretórios, bem como mudar permissões.
    - [Módulo `unarchive`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html) para extraír arquivos. Nota: este módulo permite fazer o *download* do arquivo que será extraído.

- Lembre-se de criar o direrório onde será montado o sistema de arquivos compartilhado EFS (`efs_mount_point`) antes de monta-lo. Talvez valha alterar as permissões do diretório, após montado para aberto (0777), utilizando o módulo `file` (com `recurse: True`).

- Antes de instalar pacotes, lembre-se de atualizar a lista de pacotes (veja a opção `update_cache` do módulo `apt`).

- A chave `become` com valor `true` (*e.g.* `become: true`) pode ser adicionada a uma *task* (ou *play*) para ela seja executada como super usuário (*e.g.* *root*). Isto é util para *tasks* que necessitam de permissões elevadas (como instalação de pacotes, por exemplo).

- A chave `run_once` com valor `true` (*e.g.* `run_once: true`) pode ser adicionada a uma *task* para ela seja executada apenas um único *host* qualquer.

- Para longas tarefas (execução da aplicação ou construção da imagem Docker, por exemplo), o Ansible fornece as chaves [`pool`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html#asynchronous-playbook-tasks) e [`async`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_async.html#asynchronous-playbook-tasks) para evitar desconexões SSH ao executar as tarefas. Valores como `pool: 30` e `async: 1200` podem ser razoáveis para as tarefas de execução daaplicação e criação da imagem Docker, caso necessite.