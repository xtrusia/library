chmod +x *.sh passgen passhashgen

./0.recover_tools.sh etcd/0 etcd/2 machine-2

./1.recover_charm.sh etcd/0 etcd/2 etcd-378 controller 0 machine-2 machine-4 85a15bb6-1fd0-4e6f-8e0f-680f7d66a7b1

./2.recover_systemd.sh etcd/0 etcd/2 machine-2 machine-4

./3.restart_servies.sh etcd/0 machine-2

