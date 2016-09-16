#include "includes/parser.p4"
#include "includes/headers.p4"
#include "includes/intrinsic.p4"

#define STATE_MAP_SIZE 13    // 13 bits = 8192 state entries
#define CONTEXT_TABLE_SIZE 8192
#include "../../OPP.p4"


/*

eth_type | state | c0 | c1 | c2 | c3 | in_port || actions
------------------------------------------------------------------------
  IP     |   *   |  0 |  * |  * |  * |    1    ||  count_and_forward(2)
  IP     |   *   |  1 |  * |  * |  * |    1    ||  drop()
  IP     |   *   |  * |  * |  * |  * |    2    ||  forward(2)
  ARP    |   *   |  * |  * |  * |  * |    *    ||  broadcast()


$ cd ~/OPP.p4/OPP_test_app
~/OPP.p4/OPP_test_app$ ./run_demo.sh
mininet> h1 ping h2
It should drop all the packets from the 5-th

DEBUG:
mininet@mininet-vm:~$ cd ~/bmv2/tools
mininet@mininet-vm:~/bmv2/tools$ sudo ./nanomsg_client.py --json ~/OPP.p4/OPP_test_app/test_app.json --socket ipc:///tmp/bm-0-log.ipc

*/

metadata routing_metadata_t routing_metadata;

field_list lookup_hash_field {
    ipv4.srcAddr;
    ipv4.dstAddr;
}

field_list update_hash_field {
    ipv4.srcAddr;
    ipv4.dstAddr;
}

action count_and_forward(port) {
    // R0 = R0 + 1
    add_to_field(opp.R0, 1);
    modify_field(standard_metadata.egress_spec, port);

    //update context table
    modify_field_with_hash_based_offset(opp.update_state_index, 0, u_hash, CONTEXT_TABLE_SIZE);
    register_write(reg_R0, opp.update_state_index, opp.R0);
}

action forward(port) {
    modify_field(standard_metadata.egress_spec, port);
}

action _drop() {
    drop();
}

action broadcast() {
    modify_field(intrinsic_metadata.mcast_grp, standard_metadata.ingress_port);
}


/*********** TABLES *************/

table flow_table {
    reads {
        opp.state : ternary;
        opp.c0 : ternary;
        opp.c1 : ternary;
        opp.c2 : ternary;
        opp.c3 : ternary;
        standard_metadata.ingress_port: exact;
    }
    actions {
        count_and_forward;
        forward;
        _drop;
    }
}

table arp_manager {
    actions { 
        broadcast;
    }
}

control ingress {
    if(valid(ethernet) and ethernet.etherType == ETHERTYPE_IPV4 and valid(ipv4))
    {
        /* Context lookup */
        apply(context_lookup);

    	/* Conditions evaluation */
    	if (opp.R0>=4)
    	{
    	    apply(set_c0_true);
    	}

        /* XFSM evolution */
        apply(flow_table);

    }

    if(valid(ethernet) and ethernet.etherType == ETHERTYPE_ARP)
    {
        apply(arp_manager);
    }
}
