# OPP.p4

How to test the P4 OPP application?

##P4 download

Download a clean Mininet 2.2.1 VM on Ubuntu 14.04 (64 bit) at [this link](https://github.com/mininet/mininet/wiki/Mininet-VM-Images).

You need to clone two p4lang Github repositories:

    cd ~
    git clone https://github.com/p4lang/behavioral-model.git bmv2
    git clone https://github.com/p4lang/p4c-bm.git p4c-bmv2

Install the following Python packages:

    sudo apt-get update && sudo apt-get install python-pip
    sudo pip install scapy thrift networkx

Each of these repositories comes with dependencies:

    cd ~/p4c-bmv2
    sudo pip install -r requirements.txt
    
    cd ~/bmv2
    ./install_deps.sh
    
Do not forget to build the code once all the dependencies have been installed:

    cd ~/bmv2
    ./autogen.sh
    ./configure
    make

###Test application

The test application mantains a packet counter for each IP_SRC,IP_DST pair in the register R0. Condition 0 is R0>=4.

The XFSM table can be found in ~/OPP.p4/OPP_test_app/p4src/test_app.p4


$ cd ~/OPP.p4/OPP_test_app

$ ./run_demo.sh

mininet> h1 ping h2

The switch should drop all the packets from the 5-th on
