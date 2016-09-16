header_type OPP_t {
    fields {
        lookup_state_index : STATE_MAP_SIZE; // state map index
        update_state_index : STATE_MAP_SIZE; // state map index
        state : 16;                          // state        
		R0: 32;
		R1: 32;
		R2: 32;
		R3: 32;
		G0: 32;
		G1: 32;
		G2: 32;
		G3: 32;
		c0:1;
		c1:1;
		c2:1;
		c3:1;
    }
}

metadata OPP_t opp;

register reg_state {
    width : 16;
    instance_count : CONTEXT_TABLE_SIZE;
}

register reg_R0 {
    width : 32;
    instance_count : CONTEXT_TABLE_SIZE;
}
register reg_R1 {
    width : 32;
    instance_count : CONTEXT_TABLE_SIZE;
}
register reg_R2 {
    width : 32;
    instance_count : CONTEXT_TABLE_SIZE;
}
register reg_R3 {
    width : 32;
    instance_count : CONTEXT_TABLE_SIZE;
}
register reg_G {
    width : 32;
    instance_count : 4;
}

field_list_calculation l_hash {
    input {
        lookup_hash_field;
    }
    algorithm : crc32;
    output_width : 32;
}

field_list_calculation u_hash {
    input {
        update_hash_field;
    }
    algorithm : crc32;
    output_width : 32;
}

action lookup_context_table() {
    //store the new hash value used for the lookup
    modify_field_with_hash_based_offset(opp.lookup_state_index, 0, l_hash, CONTEXT_TABLE_SIZE);
    //Using the new hash, we perform the lookup reading the reg_state[idx]
    register_read(opp.state,reg_state, opp.lookup_state_index);
    
    register_read(opp.R0, reg_R0, opp.lookup_state_index);
    register_read(opp.R1, reg_R1, opp.lookup_state_index);
    register_read(opp.R2, reg_R2, opp.lookup_state_index);
    register_read(opp.R3, reg_R3, opp.lookup_state_index);

    register_read(opp.G0, reg_G, 0);
    register_read(opp.G1, reg_G, 1);
    register_read(opp.G2, reg_G, 2);
    register_read(opp.G3, reg_G, 3);

}

action set_cond0_true() {
    modify_field(opp.c0,1);
}

action set_cond1_true() {
    modify_field(opp.c1,1);
}

action set_cond2_true() {
    modify_field(opp.c2,1);
}

action set_cond3_true() {
    modify_field(opp.c3,1);
}

action _nop() {   
}

table context_lookup {
    actions { 
        lookup_context_table; 
        _nop;
    }
}

table set_c0_true {
    actions {
        set_cond0_true; 
    }
}

table set_c1_true {
    actions {
        set_cond1_true; 
    }
}

table set_c2_true {
    actions {
        set_cond2_true; 
    }
}

table set_c3_true {
    actions {
        set_cond3_true; 
    }
}