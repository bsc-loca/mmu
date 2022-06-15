module PTW_chisel(input clk, input reset,
    output io_requestor_1_req_ready,
    input  io_requestor_1_req_valid,
    input [26:0] io_requestor_1_req_bits_addr,
    input [1:0] io_requestor_1_req_bits_prv,
    input  io_requestor_1_req_bits_store,
    input  io_requestor_1_req_bits_fetch,
    output io_requestor_1_resp_valid,
    output io_requestor_1_resp_bits_error,
    output[19:0] io_requestor_1_resp_bits_pte_ppn,
    output[1:0] io_requestor_1_resp_bits_pte_reserved_for_software,
    output io_requestor_1_resp_bits_pte_d,
    output io_requestor_1_resp_bits_pte_a,
    output io_requestor_1_resp_bits_pte_g,
    output io_requestor_1_resp_bits_pte_u,
    output io_requestor_1_resp_bits_pte_x,
    output io_requestor_1_resp_bits_pte_w,
    output io_requestor_1_resp_bits_pte_r,
    output io_requestor_1_resp_bits_pte_v,
    output[1:0] io_requestor_1_resp_bits_level,
    output io_requestor_1_status_sd,
    output[26:0] io_requestor_1_status_zero5,
    output[1:0] io_requestor_1_status_sxl,
    output[1:0] io_requestor_1_status_uxl,
    output[8:0] io_requestor_1_status_zero4,
    output io_requestor_1_status_tsr,
    output io_requestor_1_status_tw,
    output io_requestor_1_status_tvm,
    output io_requestor_1_status_mxr,
    output io_requestor_1_status_sum,
    output io_requestor_1_status_mprv,
    output[1:0] io_requestor_1_status_xs,
    output[1:0] io_requestor_1_status_fs,
    output[1:0] io_requestor_1_status_mpp,
    output[1:0] io_requestor_1_status_zero3,
    output io_requestor_1_status_spp,
    output io_requestor_1_status_mpie,
    output io_requestor_1_status_zero2,
    output io_requestor_1_status_spie,
    output io_requestor_1_status_upie,
    output io_requestor_1_status_mie,
    output io_requestor_1_status_zero1,
    output io_requestor_1_status_sie,
    output io_requestor_1_status_uie,
    output io_requestor_1_invalidate,
    output io_requestor_0_req_ready,
    input  io_requestor_0_req_valid,
    input [26:0] io_requestor_0_req_bits_addr,
    input [1:0] io_requestor_0_req_bits_prv,
    input  io_requestor_0_req_bits_store,
    input  io_requestor_0_req_bits_fetch,
    output io_requestor_0_resp_valid,
    output io_requestor_0_resp_bits_error,
    output[19:0] io_requestor_0_resp_bits_pte_ppn,
    output[1:0] io_requestor_0_resp_bits_pte_reserved_for_software,
    output io_requestor_0_resp_bits_pte_d,
    output io_requestor_0_resp_bits_pte_a,
    output io_requestor_0_resp_bits_pte_g,
    output io_requestor_0_resp_bits_pte_u,
    output io_requestor_0_resp_bits_pte_x,
    output io_requestor_0_resp_bits_pte_w,
    output io_requestor_0_resp_bits_pte_r,
    output io_requestor_0_resp_bits_pte_v,
    output[1:0] io_requestor_0_resp_bits_level,
    output io_requestor_0_status_sd,
    output[26:0] io_requestor_0_status_zero5,
    output[1:0] io_requestor_0_status_sxl,
    output[1:0] io_requestor_0_status_uxl,
    output[8:0] io_requestor_0_status_zero4,
    output io_requestor_0_status_tsr,
    output io_requestor_0_status_tw,
    output io_requestor_0_status_tvm,
    output io_requestor_0_status_mxr,
    output io_requestor_0_status_sum,
    output io_requestor_0_status_mprv,
    output[1:0] io_requestor_0_status_xs,
    output[1:0] io_requestor_0_status_fs,
    output[1:0] io_requestor_0_status_mpp,
    output[1:0] io_requestor_0_status_zero3,
    output io_requestor_0_status_spp,
    output io_requestor_0_status_mpie,
    output io_requestor_0_status_zero2,
    output io_requestor_0_status_spie,
    output io_requestor_0_status_upie,
    output io_requestor_0_status_mie,
    output io_requestor_0_status_zero1,
    output io_requestor_0_status_sie,
    output io_requestor_0_status_uie,
    output io_requestor_0_invalidate,
    input  io_mem_req_ready,
    output io_mem_req_valid,
    output[39:0] io_mem_req_bits_addr,
    //output[7:0] io_mem_req_bits_tag
    output[4:0] io_mem_req_bits_cmd,
    output[3:0] io_mem_req_bits_typ,
    output io_mem_req_bits_kill,
    output io_mem_req_bits_phys,
    output[63:0] io_mem_req_bits_data,
    input  io_mem_resp_valid,
    input [39:0] io_mem_resp_bits_addr,
    input [7:0] io_mem_resp_bits_tag,
    input [4:0] io_mem_resp_bits_cmd,
    input [3:0] io_mem_resp_bits_typ,
    input [63:0] io_mem_resp_bits_data,
    input  io_mem_resp_bits_nack,
    input  io_mem_resp_bits_replay,
    input  io_mem_resp_bits_has_data,
    input [63:0] io_mem_resp_bits_data_subword,
    input [63:0] io_mem_resp_bits_store_data,
    input  io_mem_replay_next_valid,
    input [7:0] io_mem_replay_next_bits,
    input  io_mem_xcpt_ma_ld,
    input  io_mem_xcpt_ma_st,
    input  io_mem_xcpt_pf_ld,
    input  io_mem_xcpt_pf_st,
    //output io_mem_invalidate_lr
    input  io_mem_ordered,
    input [31:0] io_dpath_ptbr,
    input  io_dpath_invalidate,
    input  io_dpath_status_sd,
    input [26:0] io_dpath_status_zero5,
    input [1:0] io_dpath_status_sxl,
    input [1:0] io_dpath_status_uxl,
    input [8:0] io_dpath_status_zero4,
    input  io_dpath_status_tsr,
    input  io_dpath_status_tw,
    input  io_dpath_status_tvm,
    input  io_dpath_status_mxr,
    input  io_dpath_status_sum,
    input  io_dpath_status_mprv,
    input [1:0] io_dpath_status_xs,
    input [1:0] io_dpath_status_fs,
    input [1:0] io_dpath_status_mpp,
    input [1:0] io_dpath_status_zero3,
    input  io_dpath_status_spp,
    input  io_dpath_status_mpie,
    input  io_dpath_status_zero2,
    input  io_dpath_status_spie,
    input  io_dpath_status_upie,
    input  io_dpath_status_mie,
    input  io_dpath_status_zero1,
    input  io_dpath_status_sie,
    input  io_dpath_status_uie
);

  wire T0;
  reg [2:0] state;
  wire[2:0] T278;
  wire[2:0] T1;
  wire[2:0] T2;
  wire[2:0] T3_1;
  wire[2:0] T4;
  wire[2:0] T5;
  wire[2:0] T6;
  wire[2:0] T7;
  wire[2:0] T8;
  wire[2:0] T9;
  wire[2:0] T10;
  wire[2:0] T11;
  wire[2:0] T12;
  wire T13;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  reg [1:0] count;
  wire[1:0] T279;
  wire[1:0] T18;
  wire[1:0] T19;
  wire[1:0] T20;
  wire[1:0] T21;
  wire[1:0] T22;
  wire pte_cache_hit;
  wire[2:0] T23;
  wire[2:0] T24;
  wire[2:0] T25;
  wire[1:0] T26;
  reg  R27;
  wire T280;
  wire T28;
  wire T29;
  wire T30;
  wire T31;
  wire[3:0] T32;
  wire[1:0] T33;
  wire[1:0] T34;
  wire[1:0] T281;
  wire[1:0] T282;
  wire T283;
  wire[2:0] T36;
  wire T284;
  wire[1:0] T37;
  wire[2:0] T38;
  wire T39;
  wire T40;
  wire T41;
  wire[1:0] T42;
  wire[1:0] T43;
  wire T44;
  reg [2:0] R45;
  wire[2:0] T285;
  wire[2:0] T46;
  wire[2:0] T47;
  wire[2:0] T48;
  wire[2:0] T49;
  wire[5:0] T50;
  wire[1:0] T51;
  wire T52;
  wire[1:0] T286;
  wire T287;
  wire[1:0] T288;
  wire[1:0] T289;
  wire T290;
  wire T291;
  wire T54;
  wire[2:0] T55;
  wire[2:0] T56;
  wire[2:0] T57;
  wire[2:0] T58;
  wire[2:0] T59;
  wire T60;
  wire T61;
  wire[1:0] T62;
  wire T63;
  wire T64;
  wire T65;
  wire T66;
  wire T67;
  wire T68;
  wire T69;
  wire pte_r;
  wire T70;
  wire T71;
  wire T72;
  wire pte_w;
  wire T73;
  wire T74;
  wire T75;
  wire pte_x;
  wire T76;
  wire pte_v;
  wire T77;
  wire T78;
  wire T79;
  wire T80;
  wire T81;
  wire T82;
  wire[8:0] T83;
  wire[19:0] T84;
  wire T85;
  wire T86;
  wire T87;
  wire T88;
  wire T89;
  wire T90;
  wire T91;
  wire T92;
  wire T93;
  wire[8:0] T94;
  wire T95;
  wire T96;
  reg  R97;
  wire T292;
  wire T98;
  wire T99;
  wire T100;
  wire T101;
  reg  R102;
  wire T293;
  wire T103;
  wire T104;
  wire T105;
  wire T106;
  wire[2:0] T107;
  wire[2:0] T108;
  wire[1:0] T109;
  wire T110;
  wire[31:0] pte_addr;
  wire[28:0] T111;
  wire[28:0] T112;
  wire[8:0] vpn_idx;
  wire[8:0] T113;
  wire[8:0] T114;
  wire[8:0] T115;
  reg [26:0] r_req_addr;
  wire[26:0] reset_r_req_cmd_addr;
  wire[26:0] T294;
  wire[26:0] T116;
  wire T117;
  wire[8:0] T118;
  wire[17:0] T119;
  wire T120;
  wire[1:0] T121;
  wire[8:0] T122;
  wire[26:0] T123;
  wire T124;
  reg [19:0] r_pte_ppn;
  wire[19:0] reset_r_pte_cmd_ppn;
  wire[19:0] T295;
  wire[31:0] T296;
  wire[31:0] T125;
  wire[31:0] T126;
  wire[31:0] T127;
  wire[31:0] T297;
  wire[31:0] T298;
  wire[19:0] pte_ppn;
  wire T128;
  wire T129;
  wire set_dirty_bit;
  wire T130;
  wire T131;
  wire T132;
  wire pte_d;
  wire T133;
  reg  r_req_store;
  wire reset_r_req_cmd_store;
  wire T299;
  wire T134;
  wire T135;
  wire pte_a;
  wire T136;
  wire perm_ok;
  wire T137;
  wire T138;
  wire T139;
  wire T140;
  wire pte_u;
  wire T141;
  wire T142;
  wire T143;
  wire T144;
  wire T145;
  wire T146;
  wire T147;
  wire T148;
  wire T149;
  wire T150;
  wire T151;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  reg  r_req_fetch;
  wire reset_r_req_cmd_fetch;
  wire T300;
  wire T156;
  wire T157;
  wire T158;
  wire T159;
  wire T160;
  wire T161;
  wire T162;
  wire T163;
  wire T164;
  wire T165;
  wire T166;
  wire T167;
  wire T168;
  wire T169;
  wire T170;
  wire T171;
  wire T172;
  wire T173;
  wire T174;
  wire T175;
  wire[1:0] T176;
  reg [1:0] r_req_prv;
  wire[1:0] reset_r_req_cmd_prv;
  wire[1:0] T301;
  wire[1:0] T177;
  wire T178;
  wire T179;
  wire T180;
  wire T181;
  wire[31:0] T302;
  wire[19:0] pte_cache_data;
  wire[19:0] T182;
  wire[19:0] T183;
  reg [19:0] T184 [2:0];
  wire[19:0] T185;
  wire T186;
  wire T187;
  wire[1:0] T188;
  wire T189;
  wire[19:0] T190;
  wire[19:0] T191;
  wire[19:0] T192;
  wire T193;
  wire[19:0] T194;
  wire[19:0] T195;
  wire T196;
  wire[31:0] T303;
  wire[31:0] T197;
  reg [31:0] T198 [2:0];
  wire[31:0] T199;
  wire T200;
  wire T201;
  wire[1:0] T202;
  wire T203;
  wire[31:0] T204;
  wire T205;
  wire[31:0] T206;
  wire T207;
  wire T208;
  wire T209;
  wire T210;
  wire T211;
  wire T212;
  wire T213;
  wire T214;
  wire T215;
  wire T216;
  wire T217;
  wire T218;
  wire T219;
  wire T220;
  wire T221;
  wire T222;
  wire[2:0] T223;
  wire T224;
  wire T225;
  wire T226;
  wire T227;
  wire T228;
  wire T229;
  wire T230;
  wire T231;
  wire T232;
  wire T233;
  wire T234;
  wire[63:0] T304;
  wire[29:0] T235;
  wire[29:0] T236;
  wire[4:0] T237;
  wire[2:0] T238;
  wire[1:0] T239;
  wire pte_wdata_v;
  wire pte_wdata_r;
  wire pte_wdata_w;
  wire[1:0] T240;
  wire pte_wdata_x;
  wire pte_wdata_u;
  wire[24:0] T241;
  wire[2:0] T242;
  wire[1:0] T243;
  wire pte_wdata_g;
  wire pte_wdata_a;
  wire pte_wdata_d;
  wire[21:0] T244;
  wire[1:0] pte_wdata_reserved_for_software;
  wire[19:0] pte_wdata_ppn;
  wire[4:0] T245;
  wire T246;
  wire[39:0] T305;
  wire T247;
  wire T248;
  wire T249;
  wire T250;
  reg  r_pte_v;
  wire reset_r_pte_cmd_v;
  wire T306;
  wire T251;
  reg  r_pte_r;
  wire reset_r_pte_cmd_r;
  wire T307;
  wire T252;
  reg  r_pte_w;
  wire reset_r_pte_cmd_w;
  wire T308;
  wire T253;
  reg  r_pte_x;
  wire reset_r_pte_cmd_x;
  wire T309;
  wire T254;
  reg  r_pte_u;
  wire reset_r_pte_cmd_u;
  wire T310;
  wire T255;
  reg  r_pte_g;
  wire reset_r_pte_cmd_g;
  wire T311;
  wire T256;
  wire pte_g;
  wire T257;
  reg  r_pte_a;
  wire reset_r_pte_cmd_a;
  wire T312;
  wire T258;
  reg  r_pte_d;
  wire reset_r_pte_cmd_d;
  wire T313;
  wire T259;
  reg [1:0] r_pte_reserved_for_software;
  wire[1:0] reset_r_pte_cmd_reserved_for_software;
  wire[1:0] T314;
  wire[1:0] T260;
  wire[1:0] pte_reserved_for_software;
  wire[1:0] T261;
  wire[19:0] T315;
  wire[27:0] resp_ppn;
  wire[27:0] T262;
  wire[27:0] T263;
  wire[17:0] T264;
  wire[9:0] T265;
  wire[27:0] T266;
  wire[8:0] T267;
  wire[18:0] T268;
  wire T269;
  wire[1:0] T270;
  wire[27:0] r_resp_ppn;
  wire T271;
  wire resp_err;
  wire T272;
  wire T273;
  reg  r_req_dest;
  wire T316;
  wire T274;
  wire resp_val;
  wire T275;
  wire[19:0] T317;
  wire T276;
  wire T277;
  wire arb_io_in_1_ready;
  wire arb_io_in_0_ready;
  wire arb_io_out_valid;
  wire[26:0] arb_io_out_bits_addr;
  wire[1:0] arb_io_out_bits_prv;
  wire arb_io_out_bits_store;
  wire arb_io_out_bits_fetch;
  wire arb_io_chosen;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    state = {1{$random}};
    count = {1{$random}};
    R27 = {1{$random}};
    R45 = {1{$random}};
    R97 = {1{$random}};
    R102 = {1{$random}};
    r_req_addr = {1{$random}};
    r_pte_ppn = {1{$random}};
    r_req_store = {1{$random}};
    r_req_fetch = {1{$random}};
    r_req_prv = {1{$random}};
    for (initvar = 0; initvar < 3; initvar = initvar+1)
      T184[initvar] = {1{$random}};
    for (initvar = 0; initvar < 3; initvar = initvar+1)
      T198[initvar] = {1{$random}};
    r_pte_v = {1{$random}};
    r_pte_r = {1{$random}};
    r_pte_w = {1{$random}};
    r_pte_x = {1{$random}};
    r_pte_u = {1{$random}};
    r_pte_g = {1{$random}};
    r_pte_a = {1{$random}};
    r_pte_d = {1{$random}};
    r_pte_reserved_for_software = {1{$random}};
    r_req_dest = {1{$random}};
  end
// synthesis translate_on
`endif

`ifndef SYNTHESIS
// synthesis translate_off
//  assign io_mem_invalidate_lr = {1{$random}};
//  assign io_mem_req_bits_tag = {1{$random}};
// synthesis translate_on
`endif
  assign T0 = state == 3'h0;
  assign T278 = reset ? 3'h0 : T1;
  assign T1 = T234 ? 3'h0 : T2;
  assign T2 = T233 ? 3'h0 : T3_1;
  assign T3_1 = T232 ? 3'h1 : T4;
  assign T4 = T230 ? 3'h3 : T5;
  assign T5 = T228 ? 3'h4 : T6;
  assign T6 = T224 ? T223 : T7;
  assign T7 = T214 ? 3'h1 : T8;
  assign T8 = T213 ? 3'h6 : T9;
  assign T9 = T211 ? 3'h1 : T10;
  assign T10 = T208 ? 3'h2 : T11;
  assign T11 = T15 ? 3'h1 : T12;
  assign T12 = T13 ? 3'h1 : state;
  assign T13 = T14 & arb_io_out_valid;
  assign T14 = 3'h0 == state;
  assign T15 = T207 & T16;
  assign T16 = pte_cache_hit & T17;
  assign T17 = count < 2'h2;
  assign T279 = reset ? 2'h0 : T18;
  assign T18 = T214 ? T22 : T19;
  assign T19 = T15 ? T21 : T20;
  assign T20 = T14 ? 2'h0 : count;
  assign T21 = count + 2'h1;
  assign T22 = count + 2'h1;
  assign pte_cache_hit = T23 != 3'h0;
  assign T23 = T107 & T24;
  assign T24 = T25;
  assign T25 = {R102, T26};
  assign T26 = {R97, R27};
  assign T280 = reset ? 1'h0 : T28;
  assign T28 = T96 ? 1'h0 : T29;
  assign T29 = T30 ? 1'h1 : R27;
  assign T30 = T65 & T31;
  assign T31 = T32[1'h0:1'h0];
  assign T32 = 1'h1 << T33;
  assign T33 = T34;
  assign T34 = T64 ? T37 : T281;
  assign T281 = T284 ? 1'h0 : T282;
  assign T282 = T283 ? 1'h1 : 2'h2;
  assign T283 = T36[1'h1:1'h1];
  assign T36 = ~ T24;
  assign T284 = T36[1'h0:1'h0];
  assign T37 = T38[1'h1:1'h0];
  assign T38 = {T62, T39};
  assign T39 = T44 & T40;
  assign T40 = T41 - 1'h1;
  assign T41 = 1'h1 << T42;
  assign T42 = T43 + 2'h1;
  assign T43 = T62 - T62;
  assign T44 = R45 >> T62;
  assign T285 = reset ? 3'h0 : T46;
  assign T46 = T60 ? T47 : R45;
  assign T47 = T55 | T48;
  assign T48 = T54 ? 3'h0 : T49;
  assign T49 = T50[2'h2:1'h0];
  assign T50 = 3'h1 << T51;
  assign T51 = {1'h1, T52};
  assign T52 = T286[1'h1:1'h1];
  assign T286 = {T291, T287};
  assign T287 = T288[1'h1:1'h1];
  assign T288 = T290 | T289;
  assign T289 = T23[1'h1:1'h0];
  assign T290 = T23[2'h2:2'h2];
  assign T291 = T290 != 1'h0;
  assign T54 = T286[1'h0:1'h0];
  assign T55 = T57 & T56;
  assign T56 = ~ T49;
  assign T57 = T59 | T58;
  assign T58 = T52 ? 3'h0 : 3'h2;
  assign T59 = R45 & 3'h5;
  assign T60 = pte_cache_hit & T61;
  assign T61 = state == 3'h1;
  assign T62 = {1'h1, T63};
  assign T63 = R45[1'h1:1'h1];
  assign T64 = T24 == 3'h7;
  assign T65 = T67 & T66;
  assign T66 = pte_cache_hit ^ 1'h1;
  assign T67 = io_mem_resp_valid & T68;
  assign T68 = T71 & T69;
  assign T69 = pte_r ^ 1'h1;
  assign pte_r = T70;
  assign T70 = io_mem_resp_bits_data[1'h1:1'h1];
  assign T71 = T74 & T72;
  assign T72 = pte_w ^ 1'h1;
  assign pte_w = T73;
  assign T73 = io_mem_resp_bits_data[2'h2:2'h2];
  assign T74 = pte_v & T75;
  assign T75 = pte_x ^ 1'h1;
  assign pte_x = T76;
  assign T76 = io_mem_resp_bits_data[2'h3:2'h3];
  assign pte_v = T77;
  assign T77 = T91 ? 1'h0 : T78;
  assign T78 = T80 ? 1'h0 : T79;
  assign T79 = io_mem_resp_bits_data[1'h0:1'h0];
  assign T80 = T86 & T81;
  assign T81 = T85 & T82;
  assign T82 = T83 != 9'h0;
  assign T83 = T84[5'h11:4'h9];
  assign T84 = io_mem_resp_bits_data[5'h1d:4'ha];
  assign T85 = count <= 2'h0;
  assign T86 = T88 | T87;
  assign T87 = io_mem_resp_bits_data[2'h3:2'h3];
  assign T88 = T90 | T89;
  assign T89 = io_mem_resp_bits_data[2'h2:2'h2];
  assign T90 = io_mem_resp_bits_data[1'h1:1'h1];
  assign T91 = T86 & T92;
  assign T92 = T95 & T93;
  assign T93 = T94 != 9'h0;
  assign T94 = T84[4'h8:1'h0];
  assign T95 = count <= 2'h1;
  assign T96 = reset | io_dpath_invalidate;
  assign T292 = reset ? 1'h0 : T98;
  assign T98 = T96 ? 1'h0 : T99;
  assign T99 = T100 ? 1'h1 : R97;
  assign T100 = T65 & T101;
  assign T101 = T32[1'h1:1'h1];
  assign T293 = reset ? 1'h0 : T103;
  assign T103 = T96 ? 1'h0 : T104;
  assign T104 = T105 ? 1'h1 : R102;
  assign T105 = T65 & T106;
  assign T106 = T32[2'h2:2'h2];
  assign T107 = T108;
  assign T108 = {T205, T109};
  assign T109 = {T203, T110};
  assign T110 = T197 == pte_addr;
  assign pte_addr = T111 << 2'h3;
  assign T111 = T112;
  assign T112 = {r_pte_ppn, vpn_idx};
  assign vpn_idx = T124 ? T122 : T113;
  assign T113 = T120 ? T118 : T114;
  assign T114 = T115[4'h8:1'h0];
  assign T115 = r_req_addr >> 5'h12;
  assign reset_r_req_cmd_addr = 27'h0;
  assign T294 = reset ? reset_r_req_cmd_addr : T116;
  assign T116 = T117 ? arb_io_out_bits_addr : r_req_addr;
  assign T117 = T0 & arb_io_out_valid;
  assign T118 = T119[4'h8:1'h0];
  assign T119 = r_req_addr >> 4'h9;
  assign T120 = T121[1'h0:1'h0];
  assign T121 = count;
  assign T122 = T123[4'h8:1'h0];
  assign T123 = r_req_addr >> 1'h0;
  assign T124 = T121[1'h1:1'h1];
  assign reset_r_pte_cmd_ppn = 20'h0;
  assign T295 = T296[5'h13:1'h0];
  assign T296 = reset ? T303 : T125;
  assign T125 = T15 ? T302 : T126;
  assign T126 = T128 ? T298 : T127;
  assign T127 = T117 ? io_dpath_ptbr : T297;
  assign T297 = {12'h0, r_pte_ppn};
  assign T298 = {12'h0, pte_ppn};
  assign pte_ppn = T84;
  assign T128 = T180 & T129;
  assign T129 = set_dirty_bit ^ 1'h1;
  assign set_dirty_bit = perm_ok & T130;
  assign T130 = T135 | T131;
  assign T131 = r_req_store & T132;
  assign T132 = pte_d ^ 1'h1;
  assign pte_d = T133;
  assign T133 = io_mem_resp_bits_data[3'h7:3'h7];
  assign reset_r_req_cmd_store = 1'h0;
  assign T299 = reset ? reset_r_req_cmd_store : T134;
  assign T134 = T117 ? arb_io_out_bits_store : r_req_store;
  assign T135 = pte_a ^ 1'h1;
  assign pte_a = T136;
  assign T136 = io_mem_resp_bits_data[3'h6:3'h6];
  assign perm_ok = T175 ? T157 : T137;
  assign T137 = r_req_fetch ? T151 : T138;
  assign T138 = r_req_store ? T145 : T139;
  assign T139 = T140 & pte_r;
  assign T140 = T142 & pte_u;
  assign pte_u = T141;
  assign T141 = io_mem_resp_bits_data[3'h4:3'h4];
  assign T142 = pte_v & T143;
  assign T143 = T144 | pte_r;
  assign T144 = pte_x | pte_w;
  assign T145 = T146 & pte_w;
  assign T146 = T147 & pte_r;
  assign T147 = T148 & pte_u;
  assign T148 = pte_v & T149;
  assign T149 = T150 | pte_r;
  assign T150 = pte_x | pte_w;
  assign T151 = T152 & pte_x;
  assign T152 = T153 & pte_u;
  assign T153 = pte_v & T154;
  assign T154 = T155 | pte_r;
  assign T155 = pte_x | pte_w;
  assign reset_r_req_cmd_fetch = 1'h0;
  assign T300 = reset ? reset_r_req_cmd_fetch : T156;
  assign T156 = T117 ? arb_io_out_bits_fetch : r_req_fetch;
  assign T157 = r_req_fetch ? T172 : T158;
  assign T158 = r_req_store ? T165 : T159;
  assign T159 = T161 & T160;
  assign T160 = pte_u ^ 1'h1;
  assign T161 = T162 & pte_r;
  assign T162 = pte_v & T163;
  assign T163 = T164 | pte_r;
  assign T164 = pte_x | pte_w;
  assign T165 = T166 & pte_w;
  assign T166 = T168 & T167;
  assign T167 = pte_u ^ 1'h1;
  assign T168 = T169 & pte_r;
  assign T169 = pte_v & T170;
  assign T170 = T171 | pte_r;
  assign T171 = pte_x | pte_w;
  assign T172 = T174 & T173;
  assign T173 = pte_u ^ 1'h1;
  assign T174 = pte_v & pte_x;
  assign T175 = T176[1'h0:1'h0];
  assign T176 = T178 ? 2'h0 : r_req_prv;
  assign reset_r_req_cmd_prv = 2'h0;
  assign T301 = reset ? reset_r_req_cmd_prv : T177;
  assign T177 = T117 ? arb_io_out_bits_prv : r_req_prv;
  assign T178 = T179 & io_dpath_status_sum;
  assign T179 = r_req_prv == 2'h1;
  assign T180 = io_mem_resp_valid & T181;
  assign T181 = state == 3'h2;
  assign T302 = {12'h0, pte_cache_data};
  assign pte_cache_data = T190 | T182;
  assign T182 = T189 ? T183 : 20'h0;
  assign T183 = T184[2'h2];
  assign T186 = T65 & T187;
  assign T187 = T188 < 2'h3;
  assign T188 = T34[1'h1:1'h0];
  assign T189 = T23[2'h2:2'h2];
  assign T190 = T194 | T191;
  assign T191 = T193 ? T192 : 20'h0;
  assign T192 = T184[2'h1];
  assign T193 = T23[1'h1:1'h1];
  assign T194 = T196 ? T195 : 20'h0;
  assign T195 = T184[2'h0];
  assign T196 = T23[1'h0:1'h0];
  assign T303 = {12'h0, reset_r_pte_cmd_ppn};
  assign T197 = T198[2'h0];
  assign T200 = T65 & T201;
  assign T201 = T202 < 2'h3;
  assign T202 = T34[1'h1:1'h0];
  assign T203 = T204 == pte_addr;
  assign T204 = T198[2'h1];
  assign T205 = T206 == pte_addr;
  assign T206 = T198[2'h2];
  assign T207 = 3'h1 == state;
  assign T208 = T207 & T209;
  assign T209 = T210 & io_mem_req_ready;
  assign T210 = T16 ^ 1'h1;
  assign T211 = T212 & io_mem_resp_bits_nack;
  assign T212 = 3'h2 == state;
  assign T213 = T212 & io_mem_resp_valid;
  assign T214 = T213 & T215;
  assign T215 = T217 & T216;
  assign T216 = count < 2'h2;
  assign T217 = T219 & T218;
  assign T218 = pte_r ^ 1'h1;
  assign T219 = T221 & T220;
  assign T220 = pte_w ^ 1'h1;
  assign T221 = pte_v & T222;
  assign T222 = pte_x ^ 1'h1;
  assign T223 = set_dirty_bit ? 3'h3 : 3'h5;
  assign T224 = T213 & T225;
  assign T225 = pte_v & T226;
  assign T226 = T227 | pte_r;
  assign T227 = pte_x | pte_w;
  assign T228 = T229 & io_mem_req_ready;
  assign T229 = 3'h3 == state;
  assign T230 = T231 & io_mem_resp_bits_nack;
  assign T231 = 3'h4 == state;
  assign T232 = T231 & io_mem_resp_valid;
  assign T233 = 3'h5 == state;
  assign T234 = 3'h6 == state;
  assign io_mem_req_bits_data = T304;
  assign T304 = {34'h0, T235};
  assign T235 = T236;
  assign T236 = {T241, T237};
  assign T237 = {T240, T238};
  assign T238 = {pte_wdata_w, T239};
  assign T239 = {pte_wdata_r, pte_wdata_v};
  assign pte_wdata_v = 1'h0;
  assign pte_wdata_r = 1'h0;
  assign pte_wdata_w = 1'h0;
  assign T240 = {pte_wdata_u, pte_wdata_x};
  assign pte_wdata_x = 1'h0;
  assign pte_wdata_u = 1'h0;
  assign T241 = {T244, T242};
  assign T242 = {pte_wdata_d, T243};
  assign T243 = {pte_wdata_a, pte_wdata_g};
  assign pte_wdata_g = 1'h0;
  assign pte_wdata_a = 1'h1;
  assign pte_wdata_d = r_req_store;
  assign T244 = {pte_wdata_ppn, pte_wdata_reserved_for_software};
  assign pte_wdata_reserved_for_software = 2'h0;
  assign pte_wdata_ppn = 20'h0;
  assign io_mem_req_bits_phys = 1'h1;
  assign io_mem_req_bits_kill = 1'h0;
  assign io_mem_req_bits_typ = 4'h3;
  assign io_mem_req_bits_cmd = T245;
  assign T245 = T246 ? 5'ha : 5'h0;
  assign T246 = state == 3'h3;
  assign io_mem_req_bits_addr = T305;
  assign T305 = {8'h0, pte_addr};
  assign io_mem_req_valid = T247;
  assign T247 = T15 ? 1'h0 : T248;
  assign T248 = T250 | T249;
  assign T249 = state == 3'h3;
  assign T250 = state == 3'h1;
  assign io_requestor_0_invalidate = io_dpath_invalidate;
  assign io_requestor_0_status_uie = io_dpath_status_uie;
  assign io_requestor_0_status_sie = io_dpath_status_sie;
  assign io_requestor_0_status_zero1 = io_dpath_status_zero1;
  assign io_requestor_0_status_mie = io_dpath_status_mie;
  assign io_requestor_0_status_upie = io_dpath_status_upie;
  assign io_requestor_0_status_spie = io_dpath_status_spie;
  assign io_requestor_0_status_zero2 = io_dpath_status_zero2;
  assign io_requestor_0_status_mpie = io_dpath_status_mpie;
  assign io_requestor_0_status_spp = io_dpath_status_spp;
  assign io_requestor_0_status_zero3 = io_dpath_status_zero3;
  assign io_requestor_0_status_mpp = io_dpath_status_mpp;
  assign io_requestor_0_status_fs = io_dpath_status_fs;
  assign io_requestor_0_status_xs = io_dpath_status_xs;
  assign io_requestor_0_status_mprv = io_dpath_status_mprv;
  assign io_requestor_0_status_sum = io_dpath_status_sum;
  assign io_requestor_0_status_mxr = io_dpath_status_mxr;
  assign io_requestor_0_status_tvm = io_dpath_status_tvm;
  assign io_requestor_0_status_tw = io_dpath_status_tw;
  assign io_requestor_0_status_tsr = io_dpath_status_tsr;
  assign io_requestor_0_status_zero4 = io_dpath_status_zero4;
  assign io_requestor_0_status_uxl = io_dpath_status_uxl;
  assign io_requestor_0_status_sxl = io_dpath_status_sxl;
  assign io_requestor_0_status_zero5 = io_dpath_status_zero5;
  assign io_requestor_0_status_sd = io_dpath_status_sd;
  assign io_requestor_0_resp_bits_level = count;
  assign io_requestor_0_resp_bits_pte_v = r_pte_v;
  assign reset_r_pte_cmd_v = 1'h0;
  assign T306 = reset ? reset_r_pte_cmd_v : T251;
  assign T251 = T128 ? pte_v : r_pte_v;
  assign io_requestor_0_resp_bits_pte_r = r_pte_r;
  assign reset_r_pte_cmd_r = 1'h0;
  assign T307 = reset ? reset_r_pte_cmd_r : T252;
  assign T252 = T128 ? pte_r : r_pte_r;
  assign io_requestor_0_resp_bits_pte_w = r_pte_w;
  assign reset_r_pte_cmd_w = 1'h0;
  assign T308 = reset ? reset_r_pte_cmd_w : T253;
  assign T253 = T128 ? pte_w : r_pte_w;
  assign io_requestor_0_resp_bits_pte_x = r_pte_x;
  assign reset_r_pte_cmd_x = 1'h0;
  assign T309 = reset ? reset_r_pte_cmd_x : T254;
  assign T254 = T128 ? pte_x : r_pte_x;
  assign io_requestor_0_resp_bits_pte_u = r_pte_u;
  assign reset_r_pte_cmd_u = 1'h0;
  assign T310 = reset ? reset_r_pte_cmd_u : T255;
  assign T255 = T128 ? pte_u : r_pte_u;
  assign io_requestor_0_resp_bits_pte_g = r_pte_g;
  assign reset_r_pte_cmd_g = 1'h0;
  assign T311 = reset ? reset_r_pte_cmd_g : T256;
  assign T256 = T128 ? pte_g : r_pte_g;
  assign pte_g = T257;
  assign T257 = io_mem_resp_bits_data[3'h5:3'h5];
  assign io_requestor_0_resp_bits_pte_a = r_pte_a;
  assign reset_r_pte_cmd_a = 1'h0;
  assign T312 = reset ? reset_r_pte_cmd_a : T258;
  assign T258 = T128 ? pte_a : r_pte_a;
  assign io_requestor_0_resp_bits_pte_d = r_pte_d;
  assign reset_r_pte_cmd_d = 1'h0;
  assign T313 = reset ? reset_r_pte_cmd_d : T259;
  assign T259 = T128 ? pte_d : r_pte_d;
  assign io_requestor_0_resp_bits_pte_reserved_for_software = r_pte_reserved_for_software;
  assign reset_r_pte_cmd_reserved_for_software = 2'h0;
  assign T314 = reset ? reset_r_pte_cmd_reserved_for_software : T260;
  assign T260 = T128 ? pte_reserved_for_software : r_pte_reserved_for_software;
  assign pte_reserved_for_software = T261;
  assign T261 = io_mem_resp_bits_data[4'h9:4'h8];
  assign io_requestor_0_resp_bits_pte_ppn = T315;
  assign T315 = resp_ppn[5'h13:1'h0];
  assign resp_ppn = T271 ? r_resp_ppn : T262;
  assign T262 = T269 ? T266 : T263;
  assign T263 = {T265, T264};
  assign T264 = r_req_addr[5'h11:1'h0];
  assign T265 = r_resp_ppn >> 5'h12;
  assign T266 = {T268, T267};
  assign T267 = r_req_addr[4'h8:1'h0];
  assign T268 = r_resp_ppn >> 4'h9;
  assign T269 = T270[1'h0:1'h0];
  assign T270 = count;
  assign r_resp_ppn = io_mem_req_bits_addr >> 4'hc;
  assign T271 = T270[1'h1:1'h1];
  assign io_requestor_0_resp_bits_error = resp_err;
  assign resp_err = state == 3'h6;
  assign io_requestor_0_resp_valid = T272;
  assign T272 = resp_val & T273;
  assign T273 = r_req_dest == 1'h0;
  assign T316 = reset ? 1'h0 : T274;
  assign T274 = T117 ? arb_io_chosen : r_req_dest;
  assign resp_val = T275 | resp_err;
  assign T275 = state == 3'h5;
  assign io_requestor_0_req_ready = arb_io_in_0_ready;
  assign io_requestor_1_invalidate = io_dpath_invalidate;
  assign io_requestor_1_status_uie = io_dpath_status_uie;
  assign io_requestor_1_status_sie = io_dpath_status_sie;
  assign io_requestor_1_status_zero1 = io_dpath_status_zero1;
  assign io_requestor_1_status_mie = io_dpath_status_mie;
  assign io_requestor_1_status_upie = io_dpath_status_upie;
  assign io_requestor_1_status_spie = io_dpath_status_spie;
  assign io_requestor_1_status_zero2 = io_dpath_status_zero2;
  assign io_requestor_1_status_mpie = io_dpath_status_mpie;
  assign io_requestor_1_status_spp = io_dpath_status_spp;
  assign io_requestor_1_status_zero3 = io_dpath_status_zero3;
  assign io_requestor_1_status_mpp = io_dpath_status_mpp;
  assign io_requestor_1_status_fs = io_dpath_status_fs;
  assign io_requestor_1_status_xs = io_dpath_status_xs;
  assign io_requestor_1_status_mprv = io_dpath_status_mprv;
  assign io_requestor_1_status_sum = io_dpath_status_sum;
  assign io_requestor_1_status_mxr = io_dpath_status_mxr;
  assign io_requestor_1_status_tvm = io_dpath_status_tvm;
  assign io_requestor_1_status_tw = io_dpath_status_tw;
  assign io_requestor_1_status_tsr = io_dpath_status_tsr;
  assign io_requestor_1_status_zero4 = io_dpath_status_zero4;
  assign io_requestor_1_status_uxl = io_dpath_status_uxl;
  assign io_requestor_1_status_sxl = io_dpath_status_sxl;
  assign io_requestor_1_status_zero5 = io_dpath_status_zero5;
  assign io_requestor_1_status_sd = io_dpath_status_sd;
  assign io_requestor_1_resp_bits_level = count;
  assign io_requestor_1_resp_bits_pte_v = r_pte_v;
  assign io_requestor_1_resp_bits_pte_r = r_pte_r;
  assign io_requestor_1_resp_bits_pte_w = r_pte_w;
  assign io_requestor_1_resp_bits_pte_x = r_pte_x;
  assign io_requestor_1_resp_bits_pte_u = r_pte_u;
  assign io_requestor_1_resp_bits_pte_g = r_pte_g;
  assign io_requestor_1_resp_bits_pte_a = r_pte_a;
  assign io_requestor_1_resp_bits_pte_d = r_pte_d;
  assign io_requestor_1_resp_bits_pte_reserved_for_software = r_pte_reserved_for_software;
  assign io_requestor_1_resp_bits_pte_ppn = T317;
  assign T317 = resp_ppn[5'h13:1'h0];
  assign io_requestor_1_resp_bits_error = resp_err;
  assign io_requestor_1_resp_valid = T276;
  assign T276 = resp_val & T277;
  assign T277 = r_req_dest == 1'h1;
  assign io_requestor_1_req_ready = arb_io_in_1_ready;
 verilog_RRArbiter_1 arb(.clk(clk), .reset(reset),
       .io_in_1_ready( arb_io_in_1_ready ),
       .io_in_1_valid( io_requestor_1_req_valid ),
       .io_in_1_bits_addr( io_requestor_1_req_bits_addr ),
       .io_in_1_bits_prv( io_requestor_1_req_bits_prv ),
       .io_in_1_bits_store( io_requestor_1_req_bits_store ),
       .io_in_1_bits_fetch( io_requestor_1_req_bits_fetch ),
       .io_in_0_ready( arb_io_in_0_ready ),
       .io_in_0_valid( io_requestor_0_req_valid ),
       .io_in_0_bits_addr( io_requestor_0_req_bits_addr ),
       .io_in_0_bits_prv( io_requestor_0_req_bits_prv ),
       .io_in_0_bits_store( io_requestor_0_req_bits_store ),
       .io_in_0_bits_fetch( io_requestor_0_req_bits_fetch ),
       .io_out_ready( T0 ),
       .io_out_valid( arb_io_out_valid ),
       .io_out_bits_addr( arb_io_out_bits_addr ),
       .io_out_bits_prv( arb_io_out_bits_prv ),
       .io_out_bits_store( arb_io_out_bits_store ),
       .io_out_bits_fetch( arb_io_out_bits_fetch ),
       .io_chosen( arb_io_chosen )
  );

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= 3'h0;
    end else if(T234) begin
      state <= 3'h0;
    end else if(T233) begin
      state <= 3'h0;
    end else if(T232) begin
      state <= 3'h1;
    end else if(T230) begin
      state <= 3'h3;
    end else if(T228) begin
      state <= 3'h4;
    end else if(T224) begin
      state <= T223;
    end else if(T214) begin
      state <= 3'h1;
    end else if(T213) begin
      state <= 3'h6;
    end else if(T211) begin
      state <= 3'h1;
    end else if(T208) begin
      state <= 3'h2;
    end else if(T15) begin
      state <= 3'h1;
    end else if(T13) begin
      state <= 3'h1;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      count <= 2'h0;
    end else if(T214) begin
      count <= T22;
    end else if(T15) begin
      count <= T21;
    end else if(T14) begin
      count <= 2'h0;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      R27 <= 1'h0;
    end else if(T96) begin
      R27 <= 1'h0;
    end else if(T30) begin
      R27 <= 1'h1;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      R45 <= 3'h0;
    end else if(T60) begin
      R45 <= T47;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      R97 <= 1'h0;
    end else if(T96) begin
      R97 <= 1'h0;
    end else if(T100) begin
      R97 <= 1'h1;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      R102 <= 1'h0;
    end else if(T96) begin
      R102 <= 1'h0;
    end else if(T105) begin
      R102 <= 1'h1;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_addr <= reset_r_req_cmd_addr;
    end else if(T117) begin
      r_req_addr <= arb_io_out_bits_addr;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_store <= reset_r_req_cmd_store;
    end else if(T117) begin
      r_req_store <= arb_io_out_bits_store;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_fetch <= reset_r_req_cmd_fetch;
    end else if(T117) begin
      r_req_fetch <= arb_io_out_bits_fetch;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_prv <= reset_r_req_cmd_prv;
    end else if(T117) begin
      r_req_prv <= arb_io_out_bits_prv;
    end
  end
  integer T184_i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (T184_i=0; T184_i < 3; T184_i = T184_i + 1) T184[T184_i] <= 20'h0;
    end else if (T186)begin
      T184[T34] <= pte_ppn;
    end
  end
  integer T198_i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (T198_i=0; T198_i < 3; T198_i = T198_i + 1) T198[T198_i] <= 32'h0;
    end else if (T200)begin
      T198[T34] <= pte_addr;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_v <= reset_r_pte_cmd_v;
    end else if(T128) begin
      r_pte_v <= pte_v;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_r <= reset_r_pte_cmd_r;
    end else if(T128) begin
      r_pte_r <= pte_r;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_w <= reset_r_pte_cmd_w;
    end else if(T128) begin
      r_pte_w <= pte_w;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_x <= reset_r_pte_cmd_x;
    end else if(T128) begin
      r_pte_x <= pte_x;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_u <= reset_r_pte_cmd_u;
    end else if(T128) begin
      r_pte_u <= pte_u;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_g <= reset_r_pte_cmd_g;
    end else if(T128) begin
      r_pte_g <= pte_g;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_a <= reset_r_pte_cmd_a;
    end else if(T128) begin
      r_pte_a <= pte_a;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_d <= reset_r_pte_cmd_d;
    end else if(T128) begin
      r_pte_d <= pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_pte_reserved_for_software <= reset_r_pte_cmd_reserved_for_software;
    end else if(T128) begin
      r_pte_reserved_for_software <= pte_reserved_for_software;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_dest <= 1'h0;
    end else if(T117) begin
      r_req_dest <= arb_io_chosen;
    end
  end
  always @(posedge clk) begin
    r_pte_ppn <= T295;
  end
endmodule


module verilog_RRArbiter_1(input clk, input reset,
    output io_in_1_ready,
    input  io_in_1_valid,
    input [26:0] io_in_1_bits_addr,
    input [1:0] io_in_1_bits_prv,
    input  io_in_1_bits_store,
    input  io_in_1_bits_fetch,
    output io_in_0_ready,
    input  io_in_0_valid,
    input [26:0] io_in_0_bits_addr,
    input [1:0] io_in_0_bits_prv,
    input  io_in_0_bits_store,
    input  io_in_0_bits_fetch,
    input  io_out_ready,
    output io_out_valid,
    output[26:0] io_out_bits_addr,
    output[1:0] io_out_bits_prv,
    output io_out_bits_store,
    output io_out_bits_fetch,
    output io_chosen
);

  wire chosen;
  wire choose;
  wire T0;
  wire T1;
  wire T2;
  reg  last_grant;
  wire T28;
  wire T3;
  wire T4;
  wire T5;
  wire T6;
  wire T7;
  wire[1:0] T8;
  wire[26:0] T9;
  wire T10;
  wire T11;
  wire T12;
  wire T13;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  wire T18;
  wire T19;
  wire T20;
  wire T21;
  wire T22;
  wire T23;
  wire T24;
  wire T25;
  wire T26;
  wire T27;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    last_grant = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_chosen = chosen;
  assign chosen = choose;
  assign choose = T1 ? 1'h1 : T0;
  assign T0 = io_in_0_valid == 1'h0;
  assign T1 = io_in_1_valid & T2;
  assign T2 = last_grant < 1'h1;
  assign T28 = reset ? 1'h0 : T3;
  assign T3 = T4 ? chosen : last_grant;
  assign T4 = io_out_ready & io_out_valid;
  assign io_out_bits_fetch = T5;
  assign T5 = T6 ? io_in_1_bits_fetch : io_in_0_bits_fetch;
  assign T6 = chosen;
  assign io_out_bits_store = T7;
  assign T7 = T6 ? io_in_1_bits_store : io_in_0_bits_store;
  assign io_out_bits_prv = T8;
  assign T8 = T6 ? io_in_1_bits_prv : io_in_0_bits_prv;
  assign io_out_bits_addr = T9;
  assign T9 = T6 ? io_in_1_bits_addr : io_in_0_bits_addr;
  assign io_out_valid = T10;
  assign T10 = T6 ? io_in_1_valid : io_in_0_valid;
  assign io_in_0_ready = T11;
  assign T11 = T12 & io_out_ready;
  assign T12 = T19 | T13;
  assign T13 = T14 ^ 1'h1;
  assign T14 = T17 | T15;
  assign T15 = io_in_1_valid & T16;
  assign T16 = last_grant < 1'h1;
  assign T17 = io_in_0_valid & T18;
  assign T18 = last_grant < 1'h0;
  assign T19 = last_grant < 1'h0;
  assign io_in_1_ready = T20;
  assign T20 = T21 & io_out_ready;
  assign T21 = T25 | T22;
  assign T22 = T23 ^ 1'h1;
  assign T23 = T24 | io_in_0_valid;
  assign T24 = T17 | T15;
  assign T25 = T27 & T26;
  assign T26 = last_grant < 1'h1;
  assign T27 = T17 ^ 1'h1;

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      last_grant <= 1'h0;
    end else if(T4) begin
      last_grant <= chosen;
    end
  end
endmodule





