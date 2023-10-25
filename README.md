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
3. Далее с помощью terraform разворачиваем инфраструктуру  
```bash
terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
terraform apply
```  
P.S Создаю 4 машины. Одна машина для ansible, остальные 3 машины для k8s (node1-control-panel node, node2,node3 - worknode)

4. ansible машину необходимо сначала подготовить для разворачивания k8s на с помощью kuberspray
Выполняем следующие команнды
```bash
sudo apt update
sudo apt install git python3 python3-pip -y
sudo apt install ansible
git clone https://github.com/kubernetes-incubator/kubespray.git

```
5. Переходим в директориюю kubespray и устанавливаем зависимости
```bash
pip install -r requirements.txt
```
6. Передаем локальные IP-адреса созданных машин
```bash
declare -a IPS=(192.168.10.6 192.168.20.22 192.168.30.7) ### адреса могут быть другие, всвязи с тем что машины несколько раз пересоздавались
```
7. Копируем папку
```bash
cp -r inventory/sample inventory/mycluster
````
Создаем hosts.yml с нашими адресами. Данный файл также возможно отредактировать, исходя из ваших пожеланий к нодам
```bash
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
В директории kuberspray/inventory/mycluster/group_vars присутствуют конфигурационные файлы, которые возможно отредактировать, исходя из ваших потребностей к кластеру k8s

8. С помощью ansible подготоваливаем ноды для k8s
```bash
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo apt update"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo systemctl stop ufw.service && sudo systemctl disable ufw.service"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf"
ansible all -i inventory/mycluster/hosts.yml -m shell -a "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && sudo swapoff -a"
```
9. После выполненых всех пунктов необходимо задеплоить кластер k8s следующей командой
```bash
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
```
10. Далле необходимо подключиться к node1 и склонировать репозиторий
```bash
git clone https://github.com/Lepisok/yandex_cloud_diplom.git
```
11. Перейдём в директорию yandex_cloud_diplom/src/k8s/kube-prometheus-main и выполнить следующие команды для разворачиния кластера мониторига
```bash
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/
```
12. Grafana успешно развернута и выводит данные на dashboard http://84.201.153.173/

### img_1

13. Тестовое приложение подготовлено
https://github.com/Lepisok/test_deploy
https://hub.docker.com/repository/docker/lepisok/webserver/general

14. Используя helm создаем новый chart с указанным именем
```bash
helm create nginx
```
15. Вносим правки конфиги и выполняем установку
```bash
helm install nginx nginx
```

16. Проверям сервис и заходим на страницу приложения по порту
```bash
root@node1:~/nginx# kubectl get svc -A
NAMESPACE     NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
default       kubernetes              ClusterIP   10.233.0.1      <none>        443/TCP                        100m
kube-system   coredns                 ClusterIP   10.233.0.3      <none>        53/UDP,53/TCP,9153/TCP         97m
kube-system   kubelet                 ClusterIP   None            <none>        10250/TCP,10255/TCP,4194/TCP   69m
monitoring    alertmanager-main       ClusterIP   10.233.46.148   <none>        9093/TCP,8080/TCP              60m
monitoring    alertmanager-operated   ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP     60m
monitoring    blackbox-exporter       ClusterIP   10.233.40.31    <none>        9115/TCP,19115/TCP             60m
monitoring    grafana                 ClusterIP   10.233.59.146   <none>        3000/TCP                       60m
monitoring    kube-state-metrics      ClusterIP   None            <none>        8443/TCP,9443/TCP              60m
monitoring    node-exporter           ClusterIP   None            <none>        9100/TCP                       60m
monitoring    prometheus-adapter      ClusterIP   10.233.41.16    <none>        443/TCP                        60m
monitoring    prometheus-k8s          ClusterIP   10.233.34.172   <none>        9090/TCP,8080/TCP              60m
monitoring    prometheus-operated     ClusterIP   None            <none>        9090/TCP                       60m
monitoring    prometheus-operator     ClusterIP   None            <none>        8443/TCP                       60m
nginx         nginx-service           NodePort    10.233.24.187   <none>        80:31497/TCP                   72s
```

### img_2

17. Собираем архив и геренируем индекс файла
```bash
helm package web-application -d charts
helm repo index charts
```

18. Создаем репозиторий на https://artifacthub.io/

### img_3

19. ППерейдём в директорию в yandex_cloud_diplom/src/k8s/kube-jenkins-main для разворачиваня jenkins кластера
