Task

Monitor two server logs using Grafana,Prometheus, Loki and Promtail

On Master node:

Install Docker and docker compose

git clone the repo

cd Monitoring-stack
delete worker, nginx and apache

then,

cd Master

nano prometheus.yml
  edit the targets - save and close
then
  docker compose up -d --build
verify
  docker ps or docker ps -a

  grafana
  prometheus
  loki 
  should be up and running

On Worker node1
    Install docker and docker compose
  git clone the repo 
    delete master and apache
  cd Worker
    nano promtail-config.yml
      change client url - ipaddress and name of the host
    docker compose up -d
  verify
    docker ps or docker ps -a

After this configure prometheus and loki to grafana

and then run nginx on one worker and apache on other server
    
