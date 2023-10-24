1. Необходимо сначала устнаовить s3 bucket для этого в директории /src/k8s/terraform/s3 выоплняем команду
```bash
terraform init
terraform apply
```  
2. Далее разворачиваем VM в yandexcloud. 
Дня этого сначала необходимо передать переменные из ранее созданного s3 bucket. Ключи находятся в terraform.tfstate в директории где создавался s3 bucket
```bash
export ACCESS_KEY=******
export SECRET_KEY=******
```  
Далее с помощью terraform разворачиваем инфраструктуру  
```bash
terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
terraform apply
```  
P.S Создаю 4 машины. Одна машина для ansible, остальные 3 машины для k8s (node1-control-panel node, node2,node3 - worknode)

3. ansible машину необходимо сначала подготовить для разворачивания k8s на с помощью kuberspray
Выполняем следующие команнды
```bash
sudo apt update
sudo apt install git python3 python3-pip -y
sudo apt install ansible
git clone https://github.com/kubernetes-incubator/kubespray.git

```
4. Переходим в директориюю kubespray и устанавливаем зависимости
```bash
pip install -r requirements.txt
```
Передаем локальные IP-адреса созданных машин
```bash
declare -a IPS=(192.168.10.6 192.168.20.22 192.168.30.7) ### адреса могут быть другие, всвязи с тем что машины несколько раз пересоздавались
```
Копируем папку
```bash
cp -r inventory/sample inventory/mycluster
````
Создаем hosts.yml с нашими адресами. Данный файл также возможно отредактировать, исходя из ваших пожеланий к нодам
```bash
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
В директории kuberspray/inventory/mycluster/group_vars присутствуют конфигурационные файлы, которые возможно отредактировать, исходя из ваших потребностей к кластеру k8s

С помощью ansible подготоваливаем ноды для k8s
```bash
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo apt update"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo systemctl stop ufw.service && sudo systemctl disable ufw.service"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && sudo swapoff -a"
```
После выполненых всех пунктов необходимо задеплоить кластер k8s следующей командой
```bash
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
```
Далле необходимо подключиться к node1 и склонировать репозиторий
```bash
git clone https://github.com/Lepisok/yandex_cloud_diplom.git
```
Перейти в директорию kube-prometheus-main\ и выполнить следующие команды для разворачиния кластера мониторига
```bash
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
````