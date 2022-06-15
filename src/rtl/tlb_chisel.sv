module TLB_chisel(input clk, input reset,
    output io_req_ready,
    input  io_req_valid,
    input [6:0] io_req_bits_asid,
    input [27:0] io_req_bits_vpn,
    input  io_req_bits_passthrough,
    input  io_req_bits_instruction,
    input  io_req_bits_store,
    output io_resp_miss,
    output[19:0] io_resp_ppn,
    output io_resp_xcpt_ld,
    output io_resp_xcpt_st,
    output io_resp_xcpt_if,
    output[7:0] io_resp_hit_idx,
    input  io_ptw_req_ready,
    output io_ptw_req_valid,
    output[26:0] io_ptw_req_bits_addr,
    output[1:0] io_ptw_req_bits_prv,
    output io_ptw_req_bits_store,
    output io_ptw_req_bits_fetch,
    input  io_ptw_resp_valid,
    input  io_ptw_resp_bits_error,
    input [19:0] io_ptw_resp_bits_pte_ppn,
    input [1:0] io_ptw_resp_bits_pte_reserved_for_software,
    input  io_ptw_resp_bits_pte_d,
    input  io_ptw_resp_bits_pte_a,
    input  io_ptw_resp_bits_pte_g,
    input  io_ptw_resp_bits_pte_u,
    input  io_ptw_resp_bits_pte_x,
    input  io_ptw_resp_bits_pte_w,
    input  io_ptw_resp_bits_pte_r,
    input  io_ptw_resp_bits_pte_v,
    input [1:0] io_ptw_resp_bits_level,
    input  io_ptw_status_sd,
    input [26:0] io_ptw_status_zero5,
    input [1:0] io_ptw_status_sxl,
    input [1:0] io_ptw_status_uxl,
    input [8:0] io_ptw_status_zero4,
    input  io_ptw_status_tsr,
    input  io_ptw_status_tw,
    input  io_ptw_status_tvm,
    input  io_ptw_status_mxr,
    input  io_ptw_status_sum,
    input  io_ptw_status_mprv,
    input [1:0] io_ptw_status_xs,
    input [1:0] io_ptw_status_fs,
    input [1:0] io_ptw_status_mpp,
    input [1:0] io_ptw_status_zero3,
    input  io_ptw_status_spp,
    input  io_ptw_status_mpie,
    input  io_ptw_status_zero2,
    input  io_ptw_status_spie,
    input  io_ptw_status_upie,
    input  io_ptw_status_mie,
    input  io_ptw_status_zero1,
    input  io_ptw_status_sie,
    input  io_ptw_status_uie,
    input  io_ptw_invalidate,
    input [1:0] io_priv_lvl,
    input  io_en_translation
);

  reg [2:0] r_refill_waddr;
  wire[2:0] T646;
  wire[2:0] T0;
  wire[2:0] repl_waddr;
  wire[2:0] T1;
  wire[3:0] T2;
  wire T3;
  wire T4;
  wire T5;
  wire[2:0] T6;
  wire[2:0] T7;
  wire T8;
  reg [7:0] R9;
  wire[7:0] T647;
  wire[7:0] T10;
  wire[7:0] T11;
  wire[7:0] T12;
  wire[7:0] T13;
  wire[14:0] T14;
  wire[2:0] T15;
  wire T16;
  wire[2:0] T648;
  wire[1:0] T649;
  wire T650;
  wire[1:0] T651;
  wire[1:0] T652;
  wire[3:0] T653;
  wire[3:0] T654;
  wire[7:0] tag_hit_lvl;
  wire[7:0] T18;
  wire[7:0] T19;
  wire[7:0] T20;
  wire[3:0] T21;
  wire[1:0] T22;
  reg  lvl_k_array_0;
  wire T655;
  wire T23;
  wire T24;
  wire T25;
  wire T26;
  wire[7:0] T27;
  wire[2:0] T28;
  reg  lvl_k_array_1;
  wire T656;
  wire T29;
  wire T30;
  wire T31;
  wire[1:0] T32;
  reg  lvl_k_array_2;
  wire T657;
  wire T33;
  wire T34;
  wire T35;
  reg  lvl_k_array_3;
  wire T658;
  wire T36;
  wire T37;
  wire T38;
  wire[3:0] T39;
  wire[1:0] T40;
  reg  lvl_k_array_4;
  wire T659;
  wire T41;
  wire T42;
  wire T43;
  reg  lvl_k_array_5;
  wire T660;
  wire T44;
  wire T45;
  wire T46;
  wire[1:0] T47;
  reg  lvl_k_array_6;
  wire T661;
  wire T48;
  wire T49;
  wire T50;
  reg  lvl_k_array_7;
  wire T662;
  wire T51;
  wire T52;
  wire T53;
  wire[7:0] T54;
  wire[7:0] T55;
  wire[7:0] T56;
  wire[7:0] T57;
  wire[3:0] T58;
  wire[1:0] T59;
  reg  lvl_m_array_0;
  wire T663;
  wire T60;
  wire T61;
  wire T62;
  wire T63;
  wire[7:0] T64;
  wire[2:0] T65;
  reg  lvl_m_array_1;
  wire T664;
  wire T66;
  wire T67;
  wire T68;
  wire[1:0] T69;
  reg  lvl_m_array_2;
  wire T665;
  wire T70;
  wire T71;
  wire T72;
  reg  lvl_m_array_3;
  wire T666;
  wire T73;
  wire T74;
  wire T75;
  wire[3:0] T76;
  wire[1:0] T77;
  reg  lvl_m_array_4;
  wire T667;
  wire T78;
  wire T79;
  wire T80;
  reg  lvl_m_array_5;
  wire T668;
  wire T81;
  wire T82;
  wire T83;
  wire[1:0] T84;
  reg  lvl_m_array_6;
  wire T669;
  wire T85;
  wire T86;
  wire T87;
  reg  lvl_m_array_7;
  wire T670;
  wire T88;
  wire T89;
  wire T90;
  wire[7:0] T91;
  wire[7:0] T92;
  wire[7:0] T93;
  wire[3:0] T94;
  wire[1:0] T95;
  reg  lvl_g_array_0;
  wire T671;
  wire T96;
  wire T97;
  wire T98;
  wire T99;
  wire[7:0] T100;
  wire[2:0] T101;
  reg  lvl_g_array_1;
  wire T672;
  wire T102;
  wire T103;
  wire T104;
  wire[1:0] T105;
  reg  lvl_g_array_2;
  wire T673;
  wire T106;
  wire T107;
  wire T108;
  reg  lvl_g_array_3;
  wire T674;
  wire T109;
  wire T110;
  wire T111;
  wire[3:0] T112;
  wire[1:0] T113;
  reg  lvl_g_array_4;
  wire T675;
  wire T114;
  wire T115;
  wire T116;
  reg  lvl_g_array_5;
  wire T676;
  wire T117;
  wire T118;
  wire T119;
  wire[1:0] T120;
  reg  lvl_g_array_6;
  wire T677;
  wire T121;
  wire T122;
  wire T123;
  reg  lvl_g_array_7;
  wire T678;
  wire T124;
  wire T125;
  wire T126;
  wire[3:0] T679;
  wire[1:0] T680;
  wire T681;
  wire T682;
  wire[1:0] T127;
  wire T128;
  wire T129;
  wire[7:0] T130;
  wire[7:0] T131;
  wire[7:0] T132;
  wire[7:0] T133;
  wire[7:0] T134;
  wire[10:0] T135;
  wire[7:0] T136;
  wire[7:0] T137;
  wire[7:0] T138;
  wire[7:0] T139;
  wire[7:0] T140;
  wire T141;
  wire tlb_hit;
  wire tag_hit;
  wire[7:0] tag_hits;
  wire[7:0] T142;
  wire[7:0] T143;
  wire[7:0] T144;
  wire[7:0] w_array;
  wire[7:0] T145;
  wire[7:0] T146;
  wire[3:0] T147;
  wire[1:0] T148;
  reg  uw_array_0;
  wire T683;
  wire T149;
  wire T150;
  wire T151;
  wire T152;
  wire T153;
  wire T154;
  wire T155;
  wire T156;
  wire T157;
  wire T158;
  wire T159;
  wire[7:0] T160;
  wire[2:0] T161;
  reg  uw_array_1;
  wire T684;
  wire T162;
  wire T163;
  wire T164;
  wire[1:0] T165;
  reg  uw_array_2;
  wire T685;
  wire T166;
  wire T167;
  wire T168;
  reg  uw_array_3;
  wire T686;
  wire T169;
  wire T170;
  wire T171;
  wire[3:0] T172;
  wire[1:0] T173;
  reg  uw_array_4;
  wire T687;
  wire T174;
  wire T175;
  wire T176;
  reg  uw_array_5;
  wire T688;
  wire T177;
  wire T178;
  wire T179;
  wire[1:0] T180;
  reg  uw_array_6;
  wire T689;
  wire T181;
  wire T182;
  wire T183;
  reg  uw_array_7;
  wire T690;
  wire T184;
  wire T185;
  wire T186;
  wire[7:0] T187;
  wire[7:0] T188;
  wire[7:0] T189;
  wire[7:0] T190;
  wire[7:0] T191;
  wire[3:0] T192;
  wire[1:0] T193;
  reg  sw_array_0;
  wire T691;
  wire T194;
  wire T195;
  wire T196;
  wire T197;
  wire T198;
  wire T199;
  wire T200;
  wire T201;
  wire T202;
  wire T203;
  wire T204;
  wire T205;
  wire[7:0] T206;
  wire[2:0] T207;
  reg  sw_array_1;
  wire T692;
  wire T208;
  wire T209;
  wire T210;
  wire[1:0] T211;
  reg  sw_array_2;
  wire T693;
  wire T212;
  wire T213;
  wire T214;
  reg  sw_array_3;
  wire T694;
  wire T215;
  wire T216;
  wire T217;
  wire[3:0] T218;
  wire[1:0] T219;
  reg  sw_array_4;
  wire T695;
  wire T220;
  wire T221;
  wire T222;
  reg  sw_array_5;
  wire T696;
  wire T223;
  wire T224;
  wire T225;
  wire[1:0] T226;
  reg  sw_array_6;
  wire T697;
  wire T227;
  wire T228;
  wire T229;
  reg  sw_array_7;
  wire T698;
  wire T230;
  wire T231;
  wire T232;
  wire[7:0] T233;
  wire T234;
  wire priv_s;
  wire[7:0] T235;
  wire[7:0] T236;
  wire[3:0] T237;
  wire[1:0] T238;
  reg  dirty_array_0;
  wire T699;
  wire T239;
  wire T240;
  wire T241;
  wire[7:0] T242;
  wire[2:0] T243;
  reg  dirty_array_1;
  wire T700;
  wire T244;
  wire T245;
  wire T246;
  wire[1:0] T247;
  reg  dirty_array_2;
  wire T701;
  wire T248;
  wire T249;
  wire T250;
  reg  dirty_array_3;
  wire T702;
  wire T251;
  wire T252;
  wire T253;
  wire[3:0] T254;
  wire[1:0] T255;
  reg  dirty_array_4;
  wire T703;
  wire T256;
  wire T257;
  wire T258;
  reg  dirty_array_5;
  wire T704;
  wire T259;
  wire T260;
  wire T261;
  wire[1:0] T262;
  reg  dirty_array_6;
  wire T705;
  wire T263;
  wire T264;
  wire T265;
  reg  dirty_array_7;
  wire T706;
  wire T266;
  wire T267;
  wire T268;
  wire[2:0] T269;
  wire T270;
  wire T271;
  wire T272;
  wire[1:0] T273;
  wire[1:0] T274;
  wire T275;
  wire[1:0] T276;
  wire T277;
  wire[2:0] T707;
  wire[2:0] T708;
  wire[2:0] T709;
  wire[2:0] T710;
  wire[2:0] T711;
  wire[2:0] T712;
  wire[2:0] T713;
  wire T714;
  wire[7:0] T278;
  wire T715;
  wire T716;
  wire T717;
  wire T718;
  wire T719;
  wire T720;
  wire has_invalid_entry;
  wire T279;
  wire T280;
  wire tlb_miss;
  wire T281;
  wire bad_va;
  wire T282;
  wire T283;
  wire T284;
  wire T285;
  wire T286;
  wire[33:0] T721;
  reg [34:0] r_refill_tag;
  wire[34:0] T722;
  wire[34:0] T287;
  wire[34:0] lookup_tag;
  wire[34:0] T288;
  wire T289;
  wire T290;
  reg [1:0] state;
  wire[1:0] T723;
  wire[1:0] T291;
  wire[1:0] T292;
  wire[1:0] T293;
  wire[1:0] T294;
  wire[1:0] T295;
  wire[1:0] T296;
  wire T297;
  wire T298;
  wire T299;
  wire T300;
  wire T301;
  wire T302;
  wire[33:0] T724;
  wire[7:0] T303;
  wire[7:0] T304;
  wire[7:0] T305;
  wire[7:0] T306;
  wire[7:0] T307;
  wire[7:0] T308;
  wire[7:0] T309;
  wire[3:0] T310;
  wire[1:0] T311;
  reg  valid_array_0;
  wire T725;
  wire T312;
  wire T313;
  wire T314;
  wire T315;
  wire[7:0] T316;
  wire[2:0] T317;
  reg  valid_array_1;
  wire T726;
  wire T318;
  wire T319;
  wire T320;
  wire[1:0] T321;
  reg  valid_array_2;
  wire T727;
  wire T322;
  wire T323;
  wire T324;
  reg  valid_array_3;
  wire T728;
  wire T325;
  wire T326;
  wire T327;
  wire[3:0] T328;
  wire[1:0] T329;
  reg  valid_array_4;
  wire T729;
  wire T330;
  wire T331;
  wire T332;
  reg  valid_array_5;
  wire T730;
  wire T333;
  wire T334;
  wire T335;
  wire[1:0] T336;
  reg  valid_array_6;
  wire T731;
  wire T337;
  wire T338;
  wire T339;
  reg  valid_array_7;
  wire T732;
  wire T340;
  wire T341;
  wire T342;
  wire T343;
  wire T344;
  reg  r_req_instruction;
  wire reset_r_req_cmd_instruction;
  wire T733;
  wire T345;
  reg  r_req_store;
  wire reset_r_req_cmd_store;
  wire T734;
  wire T346;
  wire[26:0] T735;
  wire T347;
  wire T348;
  wire T349;
  wire T350;
  wire T351;
  wire[7:0] T352;
  wire[7:0] x_array;
  wire[7:0] T353;
  wire[7:0] T354;
  wire[3:0] T355;
  wire[1:0] T356;
  reg  ux_array_0;
  wire T736;
  wire T357;
  wire T358;
  wire T359;
  wire T360;
  wire T361;
  wire T362;
  wire T363;
  wire T364;
  wire T365;
  wire T366;
  wire[7:0] T367;
  wire[2:0] T368;
  reg  ux_array_1;
  wire T737;
  wire T369;
  wire T370;
  wire T371;
  wire[1:0] T372;
  reg  ux_array_2;
  wire T738;
  wire T373;
  wire T374;
  wire T375;
  reg  ux_array_3;
  wire T739;
  wire T376;
  wire T377;
  wire T378;
  wire[3:0] T379;
  wire[1:0] T380;
  reg  ux_array_4;
  wire T740;
  wire T381;
  wire T382;
  wire T383;
  reg  ux_array_5;
  wire T741;
  wire T384;
  wire T385;
  wire T386;
  wire[1:0] T387;
  reg  ux_array_6;
  wire T742;
  wire T388;
  wire T389;
  wire T390;
  reg  ux_array_7;
  wire T743;
  wire T391;
  wire T392;
  wire T393;
  wire[7:0] T394;
  wire[7:0] T395;
  wire[3:0] T396;
  wire[1:0] T397;
  reg  sx_array_0;
  wire T744;
  wire T398;
  wire T399;
  wire T400;
  wire T401;
  wire T402;
  wire T403;
  wire T404;
  wire T405;
  wire[7:0] T406;
  wire[2:0] T407;
  reg  sx_array_1;
  wire T745;
  wire T408;
  wire T409;
  wire T410;
  wire[1:0] T411;
  reg  sx_array_2;
  wire T746;
  wire T412;
  wire T413;
  wire T414;
  reg  sx_array_3;
  wire T747;
  wire T415;
  wire T416;
  wire T417;
  wire[3:0] T418;
  wire[1:0] T419;
  reg  sx_array_4;
  wire T748;
  wire T420;
  wire T421;
  wire T422;
  reg  sx_array_5;
  wire T749;
  wire T423;
  wire T424;
  wire T425;
  wire[1:0] T426;
  reg  sx_array_6;
  wire T750;
  wire T427;
  wire T428;
  wire T429;
  reg  sx_array_7;
  wire T751;
  wire T430;
  wire T431;
  wire T432;
  wire T433;
  wire T434;
  wire T435;
  wire T436;
  wire[7:0] T437;
  wire T438;
  wire T439;
  wire T440;
  wire T441;
  wire[7:0] T442;
  wire[7:0] r_array;
  wire[7:0] r_array_pre;
  wire[7:0] T443;
  wire[7:0] T444;
  wire[3:0] T445;
  wire[1:0] T446;
  reg  ur_array_0;
  wire T752;
  wire T447;
  wire T448;
  wire T449;
  wire T450;
  wire T451;
  wire T452;
  wire T453;
  wire T454;
  wire T455;
  wire T456;
  wire[7:0] T457;
  wire[2:0] T458;
  reg  ur_array_1;
  wire T753;
  wire T459;
  wire T460;
  wire T461;
  wire[1:0] T462;
  reg  ur_array_2;
  wire T754;
  wire T463;
  wire T464;
  wire T465;
  reg  ur_array_3;
  wire T755;
  wire T466;
  wire T467;
  wire T468;
  wire[3:0] T469;
  wire[1:0] T470;
  reg  ur_array_4;
  wire T756;
  wire T471;
  wire T472;
  wire T473;
  reg  ur_array_5;
  wire T757;
  wire T474;
  wire T475;
  wire T476;
  wire[1:0] T477;
  reg  ur_array_6;
  wire T758;
  wire T478;
  wire T479;
  wire T480;
  reg  ur_array_7;
  wire T759;
  wire T481;
  wire T482;
  wire T483;
  wire[7:0] T484;
  wire[7:0] T485;
  wire[7:0] T486;
  wire[7:0] T487;
  wire[7:0] T488;
  wire[3:0] T489;
  wire[1:0] T490;
  reg  sr_array_0;
  wire T760;
  wire T491;
  wire T492;
  wire T493;
  wire T494;
  wire T495;
  wire T496;
  wire T497;
  wire T498;
  wire T499;
  wire T500;
  wire T501;
  wire[7:0] T502;
  wire[2:0] T503;
  reg  sr_array_1;
  wire T761;
  wire T504;
  wire T505;
  wire T506;
  wire[1:0] T507;
  reg  sr_array_2;
  wire T762;
  wire T508;
  wire T509;
  wire T510;
  reg  sr_array_3;
  wire T763;
  wire T511;
  wire T512;
  wire T513;
  wire[3:0] T514;
  wire[1:0] T515;
  reg  sr_array_4;
  wire T764;
  wire T516;
  wire T517;
  wire T518;
  reg  sr_array_5;
  wire T765;
  wire T519;
  wire T520;
  wire T521;
  wire[1:0] T522;
  reg  sr_array_6;
  wire T766;
  wire T523;
  wire T524;
  wire T525;
  reg  sr_array_7;
  wire T767;
  wire T526;
  wire T527;
  wire T528;
  wire[7:0] T529;
  wire T530;
  wire[7:0] T531;
  wire[19:0] T532;
  wire[19:0] T533;
  wire[19:0] T534;
  wire[19:0] T535;
  wire[19:0] ppn_k;
  wire[19:0] T536;
  wire[19:0] T537;
  reg [19:0] tag_ram [7:0];
  wire[19:0] T538;
  wire T539;
  wire[7:0] T540;
  wire[7:0] T541;
  wire[19:0] T542;
  wire[19:0] T543;
  wire[19:0] T544;
  wire T545;
  wire[19:0] T546;
  wire[19:0] T547;
  wire[19:0] T548;
  wire T549;
  wire[19:0] T550;
  wire[19:0] T551;
  wire[19:0] T552;
  wire T553;
  wire[19:0] T554;
  wire[19:0] T555;
  wire[19:0] T556;
  wire T557;
  wire[19:0] T558;
  wire[19:0] T559;
  wire[19:0] T560;
  wire T561;
  wire[19:0] T562;
  wire[19:0] T563;
  wire[19:0] T564;
  wire T565;
  wire[19:0] T566;
  wire[19:0] T567;
  wire T568;
  wire[19:0] ppn_m;
  wire[8:0] T569;
  wire[10:0] T570;
  wire[19:0] T571;
  wire[19:0] T572;
  wire[19:0] T573;
  wire T574;
  wire[7:0] T575;
  wire[7:0] T576;
  wire[19:0] T577;
  wire[19:0] T578;
  wire[19:0] T579;
  wire T580;
  wire[19:0] T581;
  wire[19:0] T582;
  wire[19:0] T583;
  wire T584;
  wire[19:0] T585;
  wire[19:0] T586;
  wire[19:0] T587;
  wire T588;
  wire[19:0] T589;
  wire[19:0] T590;
  wire[19:0] T591;
  wire T592;
  wire[19:0] T593;
  wire[19:0] T594;
  wire[19:0] T595;
  wire T596;
  wire[19:0] T597;
  wire[19:0] T598;
  wire[19:0] T599;
  wire T600;
  wire[19:0] T601;
  wire[19:0] T602;
  wire T603;
  wire tag_hits_m;
  wire[7:0] T604;
  wire[7:0] T605;
  wire[19:0] ppn_g;
  wire[17:0] T606;
  wire[1:0] T607;
  wire[19:0] T608;
  wire[19:0] T609;
  wire[19:0] T610;
  wire T611;
  wire[7:0] T612;
  wire[7:0] T613;
  wire[19:0] T614;
  wire[19:0] T615;
  wire[19:0] T616;
  wire T617;
  wire[19:0] T618;
  wire[19:0] T619;
  wire[19:0] T620;
  wire T621;
  wire[19:0] T622;
  wire[19:0] T623;
  wire[19:0] T624;
  wire T625;
  wire[19:0] T626;
  wire[19:0] T627;
  wire[19:0] T628;
  wire T629;
  wire[19:0] T630;
  wire[19:0] T631;
  wire[19:0] T632;
  wire T633;
  wire[19:0] T634;
  wire[19:0] T635;
  wire[19:0] T636;
  wire T637;
  wire[19:0] T638;
  wire[19:0] T639;
  wire T640;
  wire tag_hits_g;
  wire[7:0] T641;
  wire[7:0] T642;
  wire T643;
  wire T644;
  wire T645;
  wire[7:0] tag_cam_io_hits_g;
  wire[7:0] tag_cam_io_hits_m;
  wire[7:0] tag_cam_io_hits_k;
  wire[7:0] tag_cam_io_valid_bits;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    r_refill_waddr = {1{$random}};
    R9 = {1{$random}};
    lvl_k_array_0 = {1{$random}};
    lvl_k_array_1 = {1{$random}};
    lvl_k_array_2 = {1{$random}};
    lvl_k_array_3 = {1{$random}};
    lvl_k_array_4 = {1{$random}};
    lvl_k_array_5 = {1{$random}};
    lvl_k_array_6 = {1{$random}};
    lvl_k_array_7 = {1{$random}};
    lvl_m_array_0 = {1{$random}};
    lvl_m_array_1 = {1{$random}};
    lvl_m_array_2 = {1{$random}};
    lvl_m_array_3 = {1{$random}};
    lvl_m_array_4 = {1{$random}};
    lvl_m_array_5 = {1{$random}};
    lvl_m_array_6 = {1{$random}};
    lvl_m_array_7 = {1{$random}};
    lvl_g_array_0 = {1{$random}};
    lvl_g_array_1 = {1{$random}};
    lvl_g_array_2 = {1{$random}};
    lvl_g_array_3 = {1{$random}};
    lvl_g_array_4 = {1{$random}};
    lvl_g_array_5 = {1{$random}};
    lvl_g_array_6 = {1{$random}};
    lvl_g_array_7 = {1{$random}};
    uw_array_0 = {1{$random}};
    uw_array_1 = {1{$random}};
    uw_array_2 = {1{$random}};
    uw_array_3 = {1{$random}};
    uw_array_4 = {1{$random}};
    uw_array_5 = {1{$random}};
    uw_array_6 = {1{$random}};
    uw_array_7 = {1{$random}};
    sw_array_0 = {1{$random}};
    sw_array_1 = {1{$random}};
    sw_array_2 = {1{$random}};
    sw_array_3 = {1{$random}};
    sw_array_4 = {1{$random}};
    sw_array_5 = {1{$random}};
    sw_array_6 = {1{$random}};
    sw_array_7 = {1{$random}};
    dirty_array_0 = {1{$random}};
    dirty_array_1 = {1{$random}};
    dirty_array_2 = {1{$random}};
    dirty_array_3 = {1{$random}};
    dirty_array_4 = {1{$random}};
    dirty_array_5 = {1{$random}};
    dirty_array_6 = {1{$random}};
    dirty_array_7 = {1{$random}};
    r_refill_tag = {2{$random}};
    state = {1{$random}};
    valid_array_0 = {1{$random}};
    valid_array_1 = {1{$random}};
    valid_array_2 = {1{$random}};
    valid_array_3 = {1{$random}};
    valid_array_4 = {1{$random}};
    valid_array_5 = {1{$random}};
    valid_array_6 = {1{$random}};
    valid_array_7 = {1{$random}};
    r_req_instruction = {1{$random}};
    r_req_store = {1{$random}};
    ux_array_0 = {1{$random}};
    ux_array_1 = {1{$random}};
    ux_array_2 = {1{$random}};
    ux_array_3 = {1{$random}};
    ux_array_4 = {1{$random}};
    ux_array_5 = {1{$random}};
    ux_array_6 = {1{$random}};
    ux_array_7 = {1{$random}};
    sx_array_0 = {1{$random}};
    sx_array_1 = {1{$random}};
    sx_array_2 = {1{$random}};
    sx_array_3 = {1{$random}};
    sx_array_4 = {1{$random}};
    sx_array_5 = {1{$random}};
    sx_array_6 = {1{$random}};
    sx_array_7 = {1{$random}};
    ur_array_0 = {1{$random}};
    ur_array_1 = {1{$random}};
    ur_array_2 = {1{$random}};
    ur_array_3 = {1{$random}};
    ur_array_4 = {1{$random}};
    ur_array_5 = {1{$random}};
    ur_array_6 = {1{$random}};
    ur_array_7 = {1{$random}};
    sr_array_0 = {1{$random}};
    sr_array_1 = {1{$random}};
    sr_array_2 = {1{$random}};
    sr_array_3 = {1{$random}};
    sr_array_4 = {1{$random}};
    sr_array_5 = {1{$random}};
    sr_array_6 = {1{$random}};
    sr_array_7 = {1{$random}};
    for (initvar = 0; initvar < 8; initvar = initvar+1)
      tag_ram[initvar] = {1{$random}};
  end
// synthesis translate_on
`endif

  assign T646 = reset ? 3'h0 : T0;
  assign T0 = T280 ? repl_waddr : r_refill_waddr;
  assign repl_waddr = has_invalid_entry ? T707 : T1;
  assign T1 = T2[2'h2:1'h0];
  assign T2 = {T269, T3};
  assign T3 = T8 & T4;
  assign T4 = T5 - 1'h1;
  assign T5 = 1'h1 << T6;
  assign T6 = T7 + 3'h1;
  assign T7 = T269 - T269;
  assign T8 = R9 >> T269;
  assign T647 = reset ? 8'h0 : T10;
  assign T10 = T141 ? T11 : R9;
  assign T11 = T130 | T12;
  assign T12 = T129 ? 8'h0 : T13;
  assign T13 = T14[3'h7:1'h0];
  assign T14 = 8'h1 << T15;
  assign T15 = {T127, T16};
  assign T16 = T648[1'h1:1'h1];
  assign T648 = {T682, T649};
  assign T649 = {T681, T650};
  assign T650 = T651[1'h1:1'h1];
  assign T651 = T680 | T652;
  assign T652 = T653[1'h1:1'h0];
  assign T653 = T679 | T654;
  assign T654 = tag_hit_lvl[2'h3:1'h0];
  assign tag_hit_lvl = T54 | T18;
  assign T18 = T19 & tag_cam_io_hits_k;
  assign T19 = T20;
  assign T20 = {T39, T21};
  assign T21 = {T32, T22};
  assign T22 = {lvl_k_array_1, lvl_k_array_0};
  assign T655 = reset ? 1'h0 : T23;
  assign T23 = T25 ? T24 : lvl_k_array_0;
  assign T24 = io_ptw_resp_bits_level == 2'h2;
  assign T25 = io_ptw_resp_valid & T26;
  assign T26 = T27[1'h0:1'h0];
  assign T27 = 1'h1 << T28;
  assign T28 = r_refill_waddr;
  assign T656 = reset ? 1'h0 : T29;
  assign T29 = T30 ? T24 : lvl_k_array_1;
  assign T30 = io_ptw_resp_valid & T31;
  assign T31 = T27[1'h1:1'h1];
  assign T32 = {lvl_k_array_3, lvl_k_array_2};
  assign T657 = reset ? 1'h0 : T33;
  assign T33 = T34 ? T24 : lvl_k_array_2;
  assign T34 = io_ptw_resp_valid & T35;
  assign T35 = T27[2'h2:2'h2];
  assign T658 = reset ? 1'h0 : T36;
  assign T36 = T37 ? T24 : lvl_k_array_3;
  assign T37 = io_ptw_resp_valid & T38;
  assign T38 = T27[2'h3:2'h3];
  assign T39 = {T47, T40};
  assign T40 = {lvl_k_array_5, lvl_k_array_4};
  assign T659 = reset ? 1'h0 : T41;
  assign T41 = T42 ? T24 : lvl_k_array_4;
  assign T42 = io_ptw_resp_valid & T43;
  assign T43 = T27[3'h4:3'h4];
  assign T660 = reset ? 1'h0 : T44;
  assign T44 = T45 ? T24 : lvl_k_array_5;
  assign T45 = io_ptw_resp_valid & T46;
  assign T46 = T27[3'h5:3'h5];
  assign T47 = {lvl_k_array_7, lvl_k_array_6};
  assign T661 = reset ? 1'h0 : T48;
  assign T48 = T49 ? T24 : lvl_k_array_6;
  assign T49 = io_ptw_resp_valid & T50;
  assign T50 = T27[3'h6:3'h6];
  assign T662 = reset ? 1'h0 : T51;
  assign T51 = T52 ? T24 : lvl_k_array_7;
  assign T52 = io_ptw_resp_valid & T53;
  assign T53 = T27[3'h7:3'h7];
  assign T54 = T91 | T55;
  assign T55 = T56 & tag_cam_io_hits_m;
  assign T56 = T57;
  assign T57 = {T76, T58};
  assign T58 = {T69, T59};
  assign T59 = {lvl_m_array_1, lvl_m_array_0};
  assign T663 = reset ? 1'h0 : T60;
  assign T60 = T62 ? T61 : lvl_m_array_0;
  assign T61 = io_ptw_resp_bits_level == 2'h1;
  assign T62 = io_ptw_resp_valid & T63;
  assign T63 = T64[1'h0:1'h0];
  assign T64 = 1'h1 << T65;
  assign T65 = r_refill_waddr;
  assign T664 = reset ? 1'h0 : T66;
  assign T66 = T67 ? T61 : lvl_m_array_1;
  assign T67 = io_ptw_resp_valid & T68;
  assign T68 = T64[1'h1:1'h1];
  assign T69 = {lvl_m_array_3, lvl_m_array_2};
  assign T665 = reset ? 1'h0 : T70;
  assign T70 = T71 ? T61 : lvl_m_array_2;
  assign T71 = io_ptw_resp_valid & T72;
  assign T72 = T64[2'h2:2'h2];
  assign T666 = reset ? 1'h0 : T73;
  assign T73 = T74 ? T61 : lvl_m_array_3;
  assign T74 = io_ptw_resp_valid & T75;
  assign T75 = T64[2'h3:2'h3];
  assign T76 = {T84, T77};
  assign T77 = {lvl_m_array_5, lvl_m_array_4};
  assign T667 = reset ? 1'h0 : T78;
  assign T78 = T79 ? T61 : lvl_m_array_4;
  assign T79 = io_ptw_resp_valid & T80;
  assign T80 = T64[3'h4:3'h4];
  assign T668 = reset ? 1'h0 : T81;
  assign T81 = T82 ? T61 : lvl_m_array_5;
  assign T82 = io_ptw_resp_valid & T83;
  assign T83 = T64[3'h5:3'h5];
  assign T84 = {lvl_m_array_7, lvl_m_array_6};
  assign T669 = reset ? 1'h0 : T85;
  assign T85 = T86 ? T61 : lvl_m_array_6;
  assign T86 = io_ptw_resp_valid & T87;
  assign T87 = T64[3'h6:3'h6];
  assign T670 = reset ? 1'h0 : T88;
  assign T88 = T89 ? T61 : lvl_m_array_7;
  assign T89 = io_ptw_resp_valid & T90;
  assign T90 = T64[3'h7:3'h7];
  assign T91 = T92 & tag_cam_io_hits_g;
  assign T92 = T93;
  assign T93 = {T112, T94};
  assign T94 = {T105, T95};
  assign T95 = {lvl_g_array_1, lvl_g_array_0};
  assign T671 = reset ? 1'h0 : T96;
  assign T96 = T98 ? T97 : lvl_g_array_0;
  assign T97 = io_ptw_resp_bits_level == 2'h0;
  assign T98 = io_ptw_resp_valid & T99;
  assign T99 = T100[1'h0:1'h0];
  assign T100 = 1'h1 << T101;
  assign T101 = r_refill_waddr;
  assign T672 = reset ? 1'h0 : T102;
  assign T102 = T103 ? T97 : lvl_g_array_1;
  assign T103 = io_ptw_resp_valid & T104;
  assign T104 = T100[1'h1:1'h1];
  assign T105 = {lvl_g_array_3, lvl_g_array_2};
  assign T673 = reset ? 1'h0 : T106;
  assign T106 = T107 ? T97 : lvl_g_array_2;
  assign T107 = io_ptw_resp_valid & T108;
  assign T108 = T100[2'h2:2'h2];
  assign T674 = reset ? 1'h0 : T109;
  assign T109 = T110 ? T97 : lvl_g_array_3;
  assign T110 = io_ptw_resp_valid & T111;
  assign T111 = T100[2'h3:2'h3];
  assign T112 = {T120, T113};
  assign T113 = {lvl_g_array_5, lvl_g_array_4};
  assign T675 = reset ? 1'h0 : T114;
  assign T114 = T115 ? T97 : lvl_g_array_4;
  assign T115 = io_ptw_resp_valid & T116;
  assign T116 = T100[3'h4:3'h4];
  assign T676 = reset ? 1'h0 : T117;
  assign T117 = T118 ? T97 : lvl_g_array_5;
  assign T118 = io_ptw_resp_valid & T119;
  assign T119 = T100[3'h5:3'h5];
  assign T120 = {lvl_g_array_7, lvl_g_array_6};
  assign T677 = reset ? 1'h0 : T121;
  assign T121 = T122 ? T97 : lvl_g_array_6;
  assign T122 = io_ptw_resp_valid & T123;
  assign T123 = T100[3'h6:3'h6];
  assign T678 = reset ? 1'h0 : T124;
  assign T124 = T125 ? T97 : lvl_g_array_7;
  assign T125 = io_ptw_resp_valid & T126;
  assign T126 = T100[3'h7:3'h7];
  assign T679 = tag_hit_lvl[3'h7:3'h4];
  assign T680 = T653[2'h3:2'h2];
  assign T681 = T680 != 2'h0;
  assign T682 = T679 != 4'h0;
  assign T127 = {1'h1, T128};
  assign T128 = T648[2'h2:2'h2];
  assign T129 = T648[1'h0:1'h0];
  assign T130 = T132 & T131;
  assign T131 = ~ T13;
  assign T132 = T136 | T133;
  assign T133 = T16 ? 8'h0 : T134;
  assign T134 = T135[3'h7:1'h0];
  assign T135 = 8'h1 << T127;
  assign T136 = T138 & T137;
  assign T137 = ~ T134;
  assign T138 = T140 | T139;
  assign T139 = T128 ? 8'h0 : 8'h2;
  assign T140 = R9 & 8'hfd;
  assign T141 = io_req_valid & tlb_hit;
  assign tlb_hit = io_en_translation & tag_hit;
  assign tag_hit = tag_hits != 8'h0;
  assign tag_hits = tag_hit_lvl & T142;
  assign T142 = T235 | T143;
  assign T143 = ~ T144;
  assign T144 = io_req_bits_store ? w_array : 8'h0;
  assign w_array = priv_s ? T187 : T145;
  assign T145 = T146;
  assign T146 = {T172, T147};
  assign T147 = {T165, T148};
  assign T148 = {uw_array_1, uw_array_0};
  assign T683 = reset ? 1'h0 : T149;
  assign T149 = T158 ? T150 : uw_array_0;
  assign T150 = T152 & T151;
  assign T151 = io_ptw_resp_bits_error ^ 1'h1;
  assign T152 = T153 & io_ptw_resp_bits_pte_w;
  assign T153 = T154 & io_ptw_resp_bits_pte_r;
  assign T154 = T155 & io_ptw_resp_bits_pte_u;
  assign T155 = io_ptw_resp_bits_pte_v & T156;
  assign T156 = T157 | io_ptw_resp_bits_pte_r;
  assign T157 = io_ptw_resp_bits_pte_x | io_ptw_resp_bits_pte_w;
  assign T158 = io_ptw_resp_valid & T159;
  assign T159 = T160[1'h0:1'h0];
  assign T160 = 1'h1 << T161;
  assign T161 = r_refill_waddr;
  assign T684 = reset ? 1'h0 : T162;
  assign T162 = T163 ? T150 : uw_array_1;
  assign T163 = io_ptw_resp_valid & T164;
  assign T164 = T160[1'h1:1'h1];
  assign T165 = {uw_array_3, uw_array_2};
  assign T685 = reset ? 1'h0 : T166;
  assign T166 = T167 ? T150 : uw_array_2;
  assign T167 = io_ptw_resp_valid & T168;
  assign T168 = T160[2'h2:2'h2];
  assign T686 = reset ? 1'h0 : T169;
  assign T169 = T170 ? T150 : uw_array_3;
  assign T170 = io_ptw_resp_valid & T171;
  assign T171 = T160[2'h3:2'h3];
  assign T172 = {T180, T173};
  assign T173 = {uw_array_5, uw_array_4};
  assign T687 = reset ? 1'h0 : T174;
  assign T174 = T175 ? T150 : uw_array_4;
  assign T175 = io_ptw_resp_valid & T176;
  assign T176 = T160[3'h4:3'h4];
  assign T688 = reset ? 1'h0 : T177;
  assign T177 = T178 ? T150 : uw_array_5;
  assign T178 = io_ptw_resp_valid & T179;
  assign T179 = T160[3'h5:3'h5];
  assign T180 = {uw_array_7, uw_array_6};
  assign T689 = reset ? 1'h0 : T181;
  assign T181 = T182 ? T150 : uw_array_6;
  assign T182 = io_ptw_resp_valid & T183;
  assign T183 = T160[3'h6:3'h6];
  assign T690 = reset ? 1'h0 : T184;
  assign T184 = T185 ? T150 : uw_array_7;
  assign T185 = io_ptw_resp_valid & T186;
  assign T186 = T160[3'h7:3'h7];
  assign T187 = T234 ? T233 : T188;
  assign T188 = T190 | T189;
  assign T189 = T146;
  assign T190 = T191;
  assign T191 = {T218, T192};
  assign T192 = {T211, T193};
  assign T193 = {sw_array_1, sw_array_0};
  assign T691 = reset ? 1'h0 : T194;
  assign T194 = T204 ? T195 : sw_array_0;
  assign T195 = T197 & T196;
  assign T196 = io_ptw_resp_bits_error ^ 1'h1;
  assign T197 = T198 & io_ptw_resp_bits_pte_w;
  assign T198 = T200 & T199;
  assign T199 = io_ptw_resp_bits_pte_u ^ 1'h1;
  assign T200 = T201 & io_ptw_resp_bits_pte_r;
  assign T201 = io_ptw_resp_bits_pte_v & T202;
  assign T202 = T203 | io_ptw_resp_bits_pte_r;
  assign T203 = io_ptw_resp_bits_pte_x | io_ptw_resp_bits_pte_w;
  assign T204 = io_ptw_resp_valid & T205;
  assign T205 = T206[1'h0:1'h0];
  assign T206 = 1'h1 << T207;
  assign T207 = r_refill_waddr;
  assign T692 = reset ? 1'h0 : T208;
  assign T208 = T209 ? T195 : sw_array_1;
  assign T209 = io_ptw_resp_valid & T210;
  assign T210 = T206[1'h1:1'h1];
  assign T211 = {sw_array_3, sw_array_2};
  assign T693 = reset ? 1'h0 : T212;
  assign T212 = T213 ? T195 : sw_array_2;
  assign T213 = io_ptw_resp_valid & T214;
  assign T214 = T206[2'h2:2'h2];
  assign T694 = reset ? 1'h0 : T215;
  assign T215 = T216 ? T195 : sw_array_3;
  assign T216 = io_ptw_resp_valid & T217;
  assign T217 = T206[2'h3:2'h3];
  assign T218 = {T226, T219};
  assign T219 = {sw_array_5, sw_array_4};
  assign T695 = reset ? 1'h0 : T220;
  assign T220 = T221 ? T195 : sw_array_4;
  assign T221 = io_ptw_resp_valid & T222;
  assign T222 = T206[3'h4:3'h4];
  assign T696 = reset ? 1'h0 : T223;
  assign T223 = T224 ? T195 : sw_array_5;
  assign T224 = io_ptw_resp_valid & T225;
  assign T225 = T206[3'h5:3'h5];
  assign T226 = {sw_array_7, sw_array_6};
  assign T697 = reset ? 1'h0 : T227;
  assign T227 = T228 ? T195 : sw_array_6;
  assign T228 = io_ptw_resp_valid & T229;
  assign T229 = T206[3'h6:3'h6];
  assign T698 = reset ? 1'h0 : T230;
  assign T230 = T231 ? T195 : sw_array_7;
  assign T231 = io_ptw_resp_valid & T232;
  assign T232 = T206[3'h7:3'h7];
  assign T233 = T191;
  assign T234 = io_ptw_status_sum ^ 1'h1;
  assign priv_s = io_priv_lvl == 2'h1;
  assign T235 = T236;
  assign T236 = {T254, T237};
  assign T237 = {T247, T238};
  assign T238 = {dirty_array_1, dirty_array_0};
  assign T699 = reset ? 1'h0 : T239;
  assign T239 = T240 ? io_ptw_resp_bits_pte_d : dirty_array_0;
  assign T240 = io_ptw_resp_valid & T241;
  assign T241 = T242[1'h0:1'h0];
  assign T242 = 1'h1 << T243;
  assign T243 = r_refill_waddr;
  assign T700 = reset ? 1'h0 : T244;
  assign T244 = T245 ? io_ptw_resp_bits_pte_d : dirty_array_1;
  assign T245 = io_ptw_resp_valid & T246;
  assign T246 = T242[1'h1:1'h1];
  assign T247 = {dirty_array_3, dirty_array_2};
  assign T701 = reset ? 1'h0 : T248;
  assign T248 = T249 ? io_ptw_resp_bits_pte_d : dirty_array_2;
  assign T249 = io_ptw_resp_valid & T250;
  assign T250 = T242[2'h2:2'h2];
  assign T702 = reset ? 1'h0 : T251;
  assign T251 = T252 ? io_ptw_resp_bits_pte_d : dirty_array_3;
  assign T252 = io_ptw_resp_valid & T253;
  assign T253 = T242[2'h3:2'h3];
  assign T254 = {T262, T255};
  assign T255 = {dirty_array_5, dirty_array_4};
  assign T703 = reset ? 1'h0 : T256;
  assign T256 = T257 ? io_ptw_resp_bits_pte_d : dirty_array_4;
  assign T257 = io_ptw_resp_valid & T258;
  assign T258 = T242[3'h4:3'h4];
  assign T704 = reset ? 1'h0 : T259;
  assign T259 = T260 ? io_ptw_resp_bits_pte_d : dirty_array_5;
  assign T260 = io_ptw_resp_valid & T261;
  assign T261 = T242[3'h5:3'h5];
  assign T262 = {dirty_array_7, dirty_array_6};
  assign T705 = reset ? 1'h0 : T263;
  assign T263 = T264 ? io_ptw_resp_bits_pte_d : dirty_array_6;
  assign T264 = io_ptw_resp_valid & T265;
  assign T265 = T242[3'h6:3'h6];
  assign T706 = reset ? 1'h0 : T266;
  assign T266 = T267 ? io_ptw_resp_bits_pte_d : dirty_array_7;
  assign T267 = io_ptw_resp_valid & T268;
  assign T268 = T242[3'h7:3'h7];
  assign T269 = {T276, T270};
  assign T270 = T275 & T271;
  assign T271 = T272 - 1'h1;
  assign T272 = 1'h1 << T273;
  assign T273 = T274 + 2'h1;
  assign T274 = T276 - T276;
  assign T275 = R9 >> T276;
  assign T276 = {1'h1, T277};
  assign T277 = R9[1'h1:1'h1];
  assign T707 = T720 ? 1'h0 : T708;
  assign T708 = T719 ? 1'h1 : T709;
  assign T709 = T718 ? 2'h2 : T710;
  assign T710 = T717 ? 2'h3 : T711;
  assign T711 = T716 ? 3'h4 : T712;
  assign T712 = T715 ? 3'h5 : T713;
  assign T713 = T714 ? 3'h6 : 3'h7;
  assign T714 = T278[3'h6:3'h6];
  assign T278 = ~ tag_cam_io_valid_bits;
  assign T715 = T278[3'h5:3'h5];
  assign T716 = T278[3'h4:3'h4];
  assign T717 = T278[2'h3:2'h3];
  assign T718 = T278[2'h2:2'h2];
  assign T719 = T278[1'h1:1'h1];
  assign T720 = T278[1'h0:1'h0];
  assign has_invalid_entry = T279 ^ 1'h1;
  assign T279 = tag_cam_io_valid_bits == 8'hff;
  assign T280 = T286 & tlb_miss;
  assign tlb_miss = T284 & T281;
  assign T281 = bad_va ^ 1'h1;
  assign bad_va = T283 != T282;
  assign T282 = io_req_bits_vpn[5'h1a:5'h1a];
  assign T283 = io_req_bits_vpn[5'h1b:5'h1b];
  assign T284 = io_en_translation & T285;
  assign T285 = tag_hit ^ 1'h1;
  assign T286 = io_req_ready & io_req_valid;
  assign T721 = r_refill_tag[6'h21:1'h0];
  assign T722 = reset ? 35'h0 : T287;
  assign T287 = T280 ? lookup_tag : r_refill_tag;
  assign lookup_tag = T288;
  assign T288 = {io_req_bits_asid, io_req_bits_vpn};
  assign T289 = T290 & io_ptw_resp_valid;
  assign T290 = state == 2'h2;
  assign T723 = reset ? 2'h0 : T291;
  assign T291 = io_ptw_resp_valid ? 2'h0 : T292;
  assign T292 = T301 ? 2'h3 : T293;
  assign T293 = T300 ? 2'h3 : T294;
  assign T294 = T299 ? 2'h2 : T295;
  assign T295 = T297 ? 2'h0 : T296;
  assign T296 = T280 ? 2'h1 : state;
  assign T297 = T298 & io_ptw_invalidate;
  assign T298 = state == 2'h1;
  assign T299 = T298 & io_ptw_req_ready;
  assign T300 = T299 & io_ptw_invalidate;
  assign T301 = T302 & io_ptw_invalidate;
  assign T302 = state == 2'h2;
  assign T724 = lookup_tag[6'h21:1'h0];
  assign T303 = io_ptw_invalidate ? 8'hff : T304;
  assign T304 = T307 | T305;
  assign T305 = tag_hit_lvl & T306;
  assign T306 = ~ tag_hits;
  assign T307 = ~ T308;
  assign T308 = T309;
  assign T309 = {T328, T310};
  assign T310 = {T321, T311};
  assign T311 = {valid_array_1, valid_array_0};
  assign T725 = reset ? 1'h0 : T312;
  assign T312 = T314 ? T313 : valid_array_0;
  assign T313 = io_ptw_resp_bits_error ^ 1'h1;
  assign T314 = io_ptw_resp_valid & T315;
  assign T315 = T316[1'h0:1'h0];
  assign T316 = 1'h1 << T317;
  assign T317 = r_refill_waddr;
  assign T726 = reset ? 1'h0 : T318;
  assign T318 = T319 ? T313 : valid_array_1;
  assign T319 = io_ptw_resp_valid & T320;
  assign T320 = T316[1'h1:1'h1];
  assign T321 = {valid_array_3, valid_array_2};
  assign T727 = reset ? 1'h0 : T322;
  assign T322 = T323 ? T313 : valid_array_2;
  assign T323 = io_ptw_resp_valid & T324;
  assign T324 = T316[2'h2:2'h2];
  assign T728 = reset ? 1'h0 : T325;
  assign T325 = T326 ? T313 : valid_array_3;
  assign T326 = io_ptw_resp_valid & T327;
  assign T327 = T316[2'h3:2'h3];
  assign T328 = {T336, T329};
  assign T329 = {valid_array_5, valid_array_4};
  assign T729 = reset ? 1'h0 : T330;
  assign T330 = T331 ? T313 : valid_array_4;
  assign T331 = io_ptw_resp_valid & T332;
  assign T332 = T316[3'h4:3'h4];
  assign T730 = reset ? 1'h0 : T333;
  assign T333 = T334 ? T313 : valid_array_5;
  assign T334 = io_ptw_resp_valid & T335;
  assign T335 = T316[3'h5:3'h5];
  assign T336 = {valid_array_7, valid_array_6};
  assign T731 = reset ? 1'h0 : T337;
  assign T337 = T338 ? T313 : valid_array_6;
  assign T338 = io_ptw_resp_valid & T339;
  assign T339 = T316[3'h6:3'h6];
  assign T732 = reset ? 1'h0 : T340;
  assign T340 = T341 ? T313 : valid_array_7;
  assign T341 = io_ptw_resp_valid & T342;
  assign T342 = T316[3'h7:3'h7];
  assign T343 = io_ptw_invalidate | T344;
  assign T344 = io_req_ready & io_req_valid;
  assign io_ptw_req_bits_fetch = r_req_instruction;
  assign reset_r_req_cmd_instruction = 1'h0;
  assign T733 = reset ? reset_r_req_cmd_instruction : T345;
  assign T345 = T280 ? io_req_bits_instruction : r_req_instruction;
  assign io_ptw_req_bits_store = r_req_store;
  assign reset_r_req_cmd_store = 1'h0;
  assign T734 = reset ? reset_r_req_cmd_store : T346;
  assign T346 = T280 ? io_req_bits_store : r_req_store;
  assign io_ptw_req_bits_prv = io_priv_lvl;
  assign io_ptw_req_bits_addr = T735;
  assign T735 = r_refill_tag[5'h1a:1'h0];
  assign io_ptw_req_valid = T347;
  assign T347 = state == 2'h1;
  assign io_resp_hit_idx = tag_hit_lvl;
  assign io_resp_xcpt_if = T348;
  assign T348 = bad_va | T349;
  assign T349 = tlb_hit & T350;
  assign T350 = T351 ^ 1'h1;
  assign T351 = T352 != 8'h0;
  assign T352 = x_array & tag_hit_lvl;
  assign x_array = priv_s ? T394 : T353;
  assign T353 = T354;
  assign T354 = {T379, T355};
  assign T355 = {T372, T356};
  assign T356 = {ux_array_1, ux_array_0};
  assign T736 = reset ? 1'h0 : T357;
  assign T357 = T365 ? T358 : ux_array_0;
  assign T358 = T360 & T359;
  assign T359 = io_ptw_resp_bits_error ^ 1'h1;
  assign T360 = T361 & io_ptw_resp_bits_pte_x;
  assign T361 = T362 & io_ptw_resp_bits_pte_u;
  assign T362 = io_ptw_resp_bits_pte_v & T363;
  assign T363 = T364 | io_ptw_resp_bits_pte_r;
  assign T364 = io_ptw_resp_bits_pte_x | io_ptw_resp_bits_pte_w;
  assign T365 = io_ptw_resp_valid & T366;
  assign T366 = T367[1'h0:1'h0];
  assign T367 = 1'h1 << T368;
  assign T368 = r_refill_waddr;
  assign T737 = reset ? 1'h0 : T369;
  assign T369 = T370 ? T358 : ux_array_1;
  assign T370 = io_ptw_resp_valid & T371;
  assign T371 = T367[1'h1:1'h1];
  assign T372 = {ux_array_3, ux_array_2};
  assign T738 = reset ? 1'h0 : T373;
  assign T373 = T374 ? T358 : ux_array_2;
  assign T374 = io_ptw_resp_valid & T375;
  assign T375 = T367[2'h2:2'h2];
  assign T739 = reset ? 1'h0 : T376;
  assign T376 = T377 ? T358 : ux_array_3;
  assign T377 = io_ptw_resp_valid & T378;
  assign T378 = T367[2'h3:2'h3];
  assign T379 = {T387, T380};
  assign T380 = {ux_array_5, ux_array_4};
  assign T740 = reset ? 1'h0 : T381;
  assign T381 = T382 ? T358 : ux_array_4;
  assign T382 = io_ptw_resp_valid & T383;
  assign T383 = T367[3'h4:3'h4];
  assign T741 = reset ? 1'h0 : T384;
  assign T384 = T385 ? T358 : ux_array_5;
  assign T385 = io_ptw_resp_valid & T386;
  assign T386 = T367[3'h5:3'h5];
  assign T387 = {ux_array_7, ux_array_6};
  assign T742 = reset ? 1'h0 : T388;
  assign T388 = T389 ? T358 : ux_array_6;
  assign T389 = io_ptw_resp_valid & T390;
  assign T390 = T367[3'h6:3'h6];
  assign T743 = reset ? 1'h0 : T391;
  assign T391 = T392 ? T358 : ux_array_7;
  assign T392 = io_ptw_resp_valid & T393;
  assign T393 = T367[3'h7:3'h7];
  assign T394 = T395;
  assign T395 = {T418, T396};
  assign T396 = {T411, T397};
  assign T397 = {sx_array_1, sx_array_0};
  assign T744 = reset ? 1'h0 : T398;
  assign T398 = T404 ? T399 : sx_array_0;
  assign T399 = T401 & T400;
  assign T400 = io_ptw_resp_bits_error ^ 1'h1;
  assign T401 = T403 & T402;
  assign T402 = io_ptw_resp_bits_pte_u ^ 1'h1;
  assign T403 = io_ptw_resp_bits_pte_v & io_ptw_resp_bits_pte_x;
  assign T404 = io_ptw_resp_valid & T405;
  assign T405 = T406[1'h0:1'h0];
  assign T406 = 1'h1 << T407;
  assign T407 = r_refill_waddr;
  assign T745 = reset ? 1'h0 : T408;
  assign T408 = T409 ? T399 : sx_array_1;
  assign T409 = io_ptw_resp_valid & T410;
  assign T410 = T406[1'h1:1'h1];
  assign T411 = {sx_array_3, sx_array_2};
  assign T746 = reset ? 1'h0 : T412;
  assign T412 = T413 ? T399 : sx_array_2;
  assign T413 = io_ptw_resp_valid & T414;
  assign T414 = T406[2'h2:2'h2];
  assign T747 = reset ? 1'h0 : T415;
  assign T415 = T416 ? T399 : sx_array_3;
  assign T416 = io_ptw_resp_valid & T417;
  assign T417 = T406[2'h3:2'h3];
  assign T418 = {T426, T419};
  assign T419 = {sx_array_5, sx_array_4};
  assign T748 = reset ? 1'h0 : T420;
  assign T420 = T421 ? T399 : sx_array_4;
  assign T421 = io_ptw_resp_valid & T422;
  assign T422 = T406[3'h4:3'h4];
  assign T749 = reset ? 1'h0 : T423;
  assign T423 = T424 ? T399 : sx_array_5;
  assign T424 = io_ptw_resp_valid & T425;
  assign T425 = T406[3'h5:3'h5];
  assign T426 = {sx_array_7, sx_array_6};
  assign T750 = reset ? 1'h0 : T427;
  assign T427 = T428 ? T399 : sx_array_6;
  assign T428 = io_ptw_resp_valid & T429;
  assign T429 = T406[3'h6:3'h6];
  assign T751 = reset ? 1'h0 : T430;
  assign T430 = T431 ? T399 : sx_array_7;
  assign T431 = io_ptw_resp_valid & T432;
  assign T432 = T406[3'h7:3'h7];
  assign io_resp_xcpt_st = T433;
  assign T433 = bad_va | T434;
  assign T434 = tlb_hit & T435;
  assign T435 = T436 ^ 1'h1;
  assign T436 = T437 != 8'h0;
  assign T437 = w_array & tag_hit_lvl;
  assign io_resp_xcpt_ld = T438;
  assign T438 = bad_va | T439;
  assign T439 = tlb_hit & T440;
  assign T440 = T441 ^ 1'h1;
  assign T441 = T442 != 8'h0;
  assign T442 = r_array & tag_hit_lvl;
  assign r_array = io_ptw_status_mxr ? T531 : r_array_pre;
  assign r_array_pre = priv_s ? T484 : T443;
  assign T443 = T444;
  assign T444 = {T469, T445};
  assign T445 = {T462, T446};
  assign T446 = {ur_array_1, ur_array_0};
  assign T752 = reset ? 1'h0 : T447;
  assign T447 = T455 ? T448 : ur_array_0;
  assign T448 = T450 & T449;
  assign T449 = io_ptw_resp_bits_error ^ 1'h1;
  assign T450 = T451 & io_ptw_resp_bits_pte_r;
  assign T451 = T452 & io_ptw_resp_bits_pte_u;
  assign T452 = io_ptw_resp_bits_pte_v & T453;
  assign T453 = T454 | io_ptw_resp_bits_pte_r;
  assign T454 = io_ptw_resp_bits_pte_x | io_ptw_resp_bits_pte_w;
  assign T455 = io_ptw_resp_valid & T456;
  assign T456 = T457[1'h0:1'h0];
  assign T457 = 1'h1 << T458;
  assign T458 = r_refill_waddr;
  assign T753 = reset ? 1'h0 : T459;
  assign T459 = T460 ? T448 : ur_array_1;
  assign T460 = io_ptw_resp_valid & T461;
  assign T461 = T457[1'h1:1'h1];
  assign T462 = {ur_array_3, ur_array_2};
  assign T754 = reset ? 1'h0 : T463;
  assign T463 = T464 ? T448 : ur_array_2;
  assign T464 = io_ptw_resp_valid & T465;
  assign T465 = T457[2'h2:2'h2];
  assign T755 = reset ? 1'h0 : T466;
  assign T466 = T467 ? T448 : ur_array_3;
  assign T467 = io_ptw_resp_valid & T468;
  assign T468 = T457[2'h3:2'h3];
  assign T469 = {T477, T470};
  assign T470 = {ur_array_5, ur_array_4};
  assign T756 = reset ? 1'h0 : T471;
  assign T471 = T472 ? T448 : ur_array_4;
  assign T472 = io_ptw_resp_valid & T473;
  assign T473 = T457[3'h4:3'h4];
  assign T757 = reset ? 1'h0 : T474;
  assign T474 = T475 ? T448 : ur_array_5;
  assign T475 = io_ptw_resp_valid & T476;
  assign T476 = T457[3'h5:3'h5];
  assign T477 = {ur_array_7, ur_array_6};
  assign T758 = reset ? 1'h0 : T478;
  assign T478 = T479 ? T448 : ur_array_6;
  assign T479 = io_ptw_resp_valid & T480;
  assign T480 = T457[3'h6:3'h6];
  assign T759 = reset ? 1'h0 : T481;
  assign T481 = T482 ? T448 : ur_array_7;
  assign T482 = io_ptw_resp_valid & T483;
  assign T483 = T457[3'h7:3'h7];
  assign T484 = T530 ? T529 : T485;
  assign T485 = T487 | T486;
  assign T486 = T444;
  assign T487 = T488;
  assign T488 = {T514, T489};
  assign T489 = {T507, T490};
  assign T490 = {sr_array_1, sr_array_0};
  assign T760 = reset ? 1'h0 : T491;
  assign T491 = T500 ? T492 : sr_array_0;
  assign T492 = T494 & T493;
  assign T493 = io_ptw_resp_bits_error ^ 1'h1;
  assign T494 = T496 & T495;
  assign T495 = io_ptw_resp_bits_pte_u ^ 1'h1;
  assign T496 = T497 & io_ptw_resp_bits_pte_r;
  assign T497 = io_ptw_resp_bits_pte_v & T498;
  assign T498 = T499 | io_ptw_resp_bits_pte_r;
  assign T499 = io_ptw_resp_bits_pte_x | io_ptw_resp_bits_pte_w;
  assign T500 = io_ptw_resp_valid & T501;
  assign T501 = T502[1'h0:1'h0];
  assign T502 = 1'h1 << T503;
  assign T503 = r_refill_waddr;
  assign T761 = reset ? 1'h0 : T504;
  assign T504 = T505 ? T492 : sr_array_1;
  assign T505 = io_ptw_resp_valid & T506;
  assign T506 = T502[1'h1:1'h1];
  assign T507 = {sr_array_3, sr_array_2};
  assign T762 = reset ? 1'h0 : T508;
  assign T508 = T509 ? T492 : sr_array_2;
  assign T509 = io_ptw_resp_valid & T510;
  assign T510 = T502[2'h2:2'h2];
  assign T763 = reset ? 1'h0 : T511;
  assign T511 = T512 ? T492 : sr_array_3;
  assign T512 = io_ptw_resp_valid & T513;
  assign T513 = T502[2'h3:2'h3];
  assign T514 = {T522, T515};
  assign T515 = {sr_array_5, sr_array_4};
  assign T764 = reset ? 1'h0 : T516;
  assign T516 = T517 ? T492 : sr_array_4;
  assign T517 = io_ptw_resp_valid & T518;
  assign T518 = T502[3'h4:3'h4];
  assign T765 = reset ? 1'h0 : T519;
  assign T519 = T520 ? T492 : sr_array_5;
  assign T520 = io_ptw_resp_valid & T521;
  assign T521 = T502[3'h5:3'h5];
  assign T522 = {sr_array_7, sr_array_6};
  assign T766 = reset ? 1'h0 : T523;
  assign T523 = T524 ? T492 : sr_array_6;
  assign T524 = io_ptw_resp_valid & T525;
  assign T525 = T502[3'h6:3'h6];
  assign T767 = reset ? 1'h0 : T526;
  assign T526 = T527 ? T492 : sr_array_7;
  assign T527 = io_ptw_resp_valid & T528;
  assign T528 = T502[3'h7:3'h7];
  assign T529 = T488;
  assign T530 = io_ptw_status_sum ^ 1'h1;
  assign T531 = r_array_pre | x_array;
  assign io_resp_ppn = T532;
  assign T532 = T643 ? T534 : T533;
  assign T533 = io_req_bits_vpn[5'h13:1'h0];
  assign T534 = tag_hits_g ? ppn_g : T535;
  assign T535 = tag_hits_m ? ppn_m : ppn_k;
  assign ppn_k = T542 | T536;
  assign T536 = T539 ? T537 : 20'h0;
  assign T537 = tag_ram[3'h7];
  assign T539 = T540[3'h7:3'h7];
  assign T540 = T541 & tag_cam_io_hits_k;
  assign T541 = T20;
  assign T542 = T546 | T543;
  assign T543 = T545 ? T544 : 20'h0;
  assign T544 = tag_ram[3'h6];
  assign T545 = T540[3'h6:3'h6];
  assign T546 = T550 | T547;
  assign T547 = T549 ? T548 : 20'h0;
  assign T548 = tag_ram[3'h5];
  assign T549 = T540[3'h5:3'h5];
  assign T550 = T554 | T551;
  assign T551 = T553 ? T552 : 20'h0;
  assign T552 = tag_ram[3'h4];
  assign T553 = T540[3'h4:3'h4];
  assign T554 = T558 | T555;
  assign T555 = T557 ? T556 : 20'h0;
  assign T556 = tag_ram[3'h3];
  assign T557 = T540[2'h3:2'h3];
  assign T558 = T562 | T559;
  assign T559 = T561 ? T560 : 20'h0;
  assign T560 = tag_ram[3'h2];
  assign T561 = T540[2'h2:2'h2];
  assign T562 = T566 | T563;
  assign T563 = T565 ? T564 : 20'h0;
  assign T564 = tag_ram[3'h1];
  assign T565 = T540[1'h1:1'h1];
  assign T566 = T568 ? T567 : 20'h0;
  assign T567 = tag_ram[3'h0];
  assign T568 = T540[1'h0:1'h0];
  assign ppn_m = {T570, T569};
  assign T569 = io_req_bits_vpn[4'h8:1'h0];
  assign T570 = T571[5'h13:4'h9];
  assign T571 = T577 | T572;
  assign T572 = T574 ? T573 : 20'h0;
  assign T573 = tag_ram[3'h7];
  assign T574 = T575[3'h7:3'h7];
  assign T575 = T576 & tag_cam_io_hits_m;
  assign T576 = T57;
  assign T577 = T581 | T578;
  assign T578 = T580 ? T579 : 20'h0;
  assign T579 = tag_ram[3'h6];
  assign T580 = T575[3'h6:3'h6];
  assign T581 = T585 | T582;
  assign T582 = T584 ? T583 : 20'h0;
  assign T583 = tag_ram[3'h5];
  assign T584 = T575[3'h5:3'h5];
  assign T585 = T589 | T586;
  assign T586 = T588 ? T587 : 20'h0;
  assign T587 = tag_ram[3'h4];
  assign T588 = T575[3'h4:3'h4];
  assign T589 = T593 | T590;
  assign T590 = T592 ? T591 : 20'h0;
  assign T591 = tag_ram[3'h3];
  assign T592 = T575[2'h3:2'h3];
  assign T593 = T597 | T594;
  assign T594 = T596 ? T595 : 20'h0;
  assign T595 = tag_ram[3'h2];
  assign T596 = T575[2'h2:2'h2];
  assign T597 = T601 | T598;
  assign T598 = T600 ? T599 : 20'h0;
  assign T599 = tag_ram[3'h1];
  assign T600 = T575[1'h1:1'h1];
  assign T601 = T603 ? T602 : 20'h0;
  assign T602 = tag_ram[3'h0];
  assign T603 = T575[1'h0:1'h0];
  assign tag_hits_m = T604 != 8'h0;
  assign T604 = T605 & tag_cam_io_hits_m;
  assign T605 = T57;
  assign ppn_g = {T607, T606};
  assign T606 = io_req_bits_vpn[5'h11:1'h0];
  assign T607 = T608[5'h13:5'h12];
  assign T608 = T614 | T609;
  assign T609 = T611 ? T610 : 20'h0;
  assign T610 = tag_ram[3'h7];
  assign T611 = T612[3'h7:3'h7];
  assign T612 = T613 & tag_cam_io_hits_g;
  assign T613 = T93;
  assign T614 = T618 | T615;
  assign T615 = T617 ? T616 : 20'h0;
  assign T616 = tag_ram[3'h6];
  assign T617 = T612[3'h6:3'h6];
  assign T618 = T622 | T619;
  assign T619 = T621 ? T620 : 20'h0;
  assign T620 = tag_ram[3'h5];
  assign T621 = T612[3'h5:3'h5];
  assign T622 = T626 | T623;
  assign T623 = T625 ? T624 : 20'h0;
  assign T624 = tag_ram[3'h4];
  assign T625 = T612[3'h4:3'h4];
  assign T626 = T630 | T627;
  assign T627 = T629 ? T628 : 20'h0;
  assign T628 = tag_ram[3'h3];
  assign T629 = T612[2'h3:2'h3];
  assign T630 = T634 | T631;
  assign T631 = T633 ? T632 : 20'h0;
  assign T632 = tag_ram[3'h2];
  assign T633 = T612[2'h2:2'h2];
  assign T634 = T638 | T635;
  assign T635 = T637 ? T636 : 20'h0;
  assign T636 = tag_ram[3'h1];
  assign T637 = T612[1'h1:1'h1];
  assign T638 = T640 ? T639 : 20'h0;
  assign T639 = tag_ram[3'h0];
  assign T640 = T612[1'h0:1'h0];
  assign tag_hits_g = T641 != 8'h0;
  assign T641 = T642 & tag_cam_io_hits_g;
  assign T642 = T93;
  assign T643 = io_en_translation & T644;
  assign T644 = io_req_bits_passthrough ^ 1'h1;
  assign io_resp_miss = tlb_miss;
  assign io_req_ready = T645;
  assign T645 = state == 2'h0;
 verilog_RocketCAM tag_cam(.clk(clk), .reset(reset),
       .io_clear( T343 ),
       .io_clear_mask( T303 ),
       .io_tag( T724 ),
       //.io_hit_g(  )
       .io_hits_g( tag_cam_io_hits_g ),
       //.io_hit_m(  )
       .io_hits_m( tag_cam_io_hits_m ),
       //.io_hit_k(  )
       .io_hits_k( tag_cam_io_hits_k ),
       .io_valid_bits( tag_cam_io_valid_bits ),
       .io_write( T289 ),
       .io_write_tag( T721 ),
       .io_write_addr( r_refill_waddr )
  );

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_refill_waddr <= 3'h0;
    end else if(T280) begin
      r_refill_waddr <= repl_waddr;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      R9 <= 8'h0;
    end else if(T141) begin
      R9 <= T11;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_0 <= 1'h0;
    end else if(T25) begin
      lvl_k_array_0 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_1 <= 1'h0;
    end else if(T30) begin
      lvl_k_array_1 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_2 <= 1'h0;
    end else if(T34) begin
      lvl_k_array_2 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_3 <= 1'h0;
    end else if(T37) begin
      lvl_k_array_3 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_4 <= 1'h0;
    end else if(T42) begin
      lvl_k_array_4 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_5 <= 1'h0;
    end else if(T45) begin
      lvl_k_array_5 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_6 <= 1'h0;
    end else if(T49) begin
      lvl_k_array_6 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_k_array_7 <= 1'h0;
    end else if(T52) begin
      lvl_k_array_7 <= T24;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_0 <= 1'h0;
    end else if(T62) begin
      lvl_m_array_0 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_1 <= 1'h0;
    end else if(T67) begin
      lvl_m_array_1 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_2 <= 1'h0;
    end else if(T71) begin
      lvl_m_array_2 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_3 <= 1'h0;
    end else if(T74) begin
      lvl_m_array_3 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_4 <= 1'h0;
    end else if(T79) begin
      lvl_m_array_4 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_5 <= 1'h0;
    end else if(T82) begin
      lvl_m_array_5 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_6 <= 1'h0;
    end else if(T86) begin
      lvl_m_array_6 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_m_array_7 <= 1'h0;
    end else if(T89) begin
      lvl_m_array_7 <= T61;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_0 <= 1'h0;
    end else if(T98) begin
      lvl_g_array_0 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_1 <= 1'h0;
    end else if(T103) begin
      lvl_g_array_1 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_2 <= 1'h0;
    end else if(T107) begin
      lvl_g_array_2 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_3 <= 1'h0;
    end else if(T110) begin
      lvl_g_array_3 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_4 <= 1'h0;
    end else if(T115) begin
      lvl_g_array_4 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_5 <= 1'h0;
    end else if(T118) begin
      lvl_g_array_5 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_6 <= 1'h0;
    end else if(T122) begin
      lvl_g_array_6 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lvl_g_array_7 <= 1'h0;
    end else if(T125) begin
      lvl_g_array_7 <= T97;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_0 <= 1'h0;
    end else if(T158) begin
      uw_array_0 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_1 <= 1'h0;
    end else if(T163) begin
      uw_array_1 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_2 <= 1'h0;
    end else if(T167) begin
      uw_array_2 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_3 <= 1'h0;
    end else if(T170) begin
      uw_array_3 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_4 <= 1'h0;
    end else if(T175) begin
      uw_array_4 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_5 <= 1'h0;
    end else if(T178) begin
      uw_array_5 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_6 <= 1'h0;
    end else if(T182) begin
      uw_array_6 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      uw_array_7 <= 1'h0;
    end else if(T185) begin
      uw_array_7 <= T150;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_0 <= 1'h0;
    end else if(T204) begin
      sw_array_0 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_1 <= 1'h0;
    end else if(T209) begin
      sw_array_1 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_2 <= 1'h0;
    end else if(T213) begin
      sw_array_2 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_3 <= 1'h0;
    end else if(T216) begin
      sw_array_3 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_4 <= 1'h0;
    end else if(T221) begin
      sw_array_4 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_5 <= 1'h0;
    end else if(T224) begin
      sw_array_5 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_6 <= 1'h0;
    end else if(T228) begin
      sw_array_6 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sw_array_7 <= 1'h0;
    end else if(T231) begin
      sw_array_7 <= T195;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_0 <= 1'h0;
    end else if(T240) begin
      dirty_array_0 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_1 <= 1'h0;
    end else if(T245) begin
      dirty_array_1 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_2 <= 1'h0;
    end else if(T249) begin
      dirty_array_2 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_3 <= 1'h0;
    end else if(T252) begin
      dirty_array_3 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_4 <= 1'h0;
    end else if(T257) begin
      dirty_array_4 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_5 <= 1'h0;
    end else if(T260) begin
      dirty_array_5 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_6 <= 1'h0;
    end else if(T264) begin
      dirty_array_6 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      dirty_array_7 <= 1'h0;
    end else if(T267) begin
      dirty_array_7 <= io_ptw_resp_bits_pte_d;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_refill_tag <= 35'h0;
    end else if(T280) begin
      r_refill_tag <= lookup_tag;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= 2'h0;
    end else if(io_ptw_resp_valid) begin
      state <= 2'h0;
    end else if(T301) begin
      state <= 2'h3;
    end else if(T300) begin
      state <= 2'h3;
    end else if(T299) begin
      state <= 2'h2;
    end else if(T297) begin
      state <= 2'h0;
    end else if(T280) begin
      state <= 2'h1;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_0 <= 1'h0;
    end else if(T314) begin
      valid_array_0 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_1 <= 1'h0;
    end else if(T319) begin
      valid_array_1 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_2 <= 1'h0;
    end else if(T323) begin
      valid_array_2 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_3 <= 1'h0;
    end else if(T326) begin
      valid_array_3 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_4 <= 1'h0;
    end else if(T331) begin
      valid_array_4 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_5 <= 1'h0;
    end else if(T334) begin
      valid_array_5 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_6 <= 1'h0;
    end else if(T338) begin
      valid_array_6 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      valid_array_7 <= 1'h0;
    end else if(T341) begin
      valid_array_7 <= T313;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_instruction <= reset_r_req_cmd_instruction;
    end else if(T280) begin
      r_req_instruction <= io_req_bits_instruction;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      r_req_store <= reset_r_req_cmd_store;
    end else if(T280) begin
      r_req_store <= io_req_bits_store;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_0 <= 1'h0;
    end else if(T365) begin
      ux_array_0 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_1 <= 1'h0;
    end else if(T370) begin
      ux_array_1 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_2 <= 1'h0;
    end else if(T374) begin
      ux_array_2 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_3 <= 1'h0;
    end else if(T377) begin
      ux_array_3 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_4 <= 1'h0;
    end else if(T382) begin
      ux_array_4 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_5 <= 1'h0;
    end else if(T385) begin
      ux_array_5 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_6 <= 1'h0;
    end else if(T389) begin
      ux_array_6 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ux_array_7 <= 1'h0;
    end else if(T392) begin
      ux_array_7 <= T358;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_0 <= 1'h0;
    end else if(T404) begin
      sx_array_0 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_1 <= 1'h0;
    end else if(T409) begin
      sx_array_1 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_2 <= 1'h0;
    end else if(T413) begin
      sx_array_2 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_3 <= 1'h0;
    end else if(T416) begin
      sx_array_3 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_4 <= 1'h0;
    end else if(T421) begin
      sx_array_4 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_5 <= 1'h0;
    end else if(T424) begin
      sx_array_5 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_6 <= 1'h0;
    end else if(T428) begin
      sx_array_6 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sx_array_7 <= 1'h0;
    end else if(T431) begin
      sx_array_7 <= T399;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_0 <= 1'h0;
    end else if(T455) begin
      ur_array_0 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_1 <= 1'h0;
    end else if(T460) begin
      ur_array_1 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_2 <= 1'h0;
    end else if(T464) begin
      ur_array_2 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_3 <= 1'h0;
    end else if(T467) begin
      ur_array_3 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_4 <= 1'h0;
    end else if(T472) begin
      ur_array_4 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_5 <= 1'h0;
    end else if(T475) begin
      ur_array_5 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_6 <= 1'h0;
    end else if(T479) begin
      ur_array_6 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ur_array_7 <= 1'h0;
    end else if(T482) begin
      ur_array_7 <= T448;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_0 <= 1'h0;
    end else if(T500) begin
      sr_array_0 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_1 <= 1'h0;
    end else if(T505) begin
      sr_array_1 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_2 <= 1'h0;
    end else if(T509) begin
      sr_array_2 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_3 <= 1'h0;
    end else if(T512) begin
      sr_array_3 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_4 <= 1'h0;
    end else if(T517) begin
      sr_array_4 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_5 <= 1'h0;
    end else if(T520) begin
      sr_array_5 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_6 <= 1'h0;
    end else if(T524) begin
      sr_array_6 <= T492;
    end
  end
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      sr_array_7 <= 1'h0;
    end else if(T527) begin
      sr_array_7 <= T492;
    end
  end
  integer tag_ram_i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (tag_ram_i=0; tag_ram_i < 8; tag_ram_i = tag_ram_i + 1) tag_ram[tag_ram_i] <= 20'h0;
    end else if (io_ptw_resp_valid)begin
      tag_ram[r_refill_waddr] <= io_ptw_resp_bits_pte_ppn;
    end
  end
endmodule


module verilog_RocketCAM(input clk, input reset,
    input  io_clear,
    input [7:0] io_clear_mask,
    input [33:0] io_tag,
    output io_hit_g,
    output[7:0] io_hits_g,
    output io_hit_m,
    output[7:0] io_hits_m,
    output io_hit_k,
    output[7:0] io_hits_k,
    output[7:0] io_valid_bits,
    input  io_write,
    input [33:0] io_write_tag,
    input [2:0] io_write_addr
);

  reg [7:0] vb_array;
  wire[7:0] T142;
  wire[7:0] T0;
  wire[7:0] T1;
  wire[7:0] T2;
  wire[7:0] T3;
  wire[7:0] T4;
  wire[7:0] T143;
  wire T5;
  wire[7:0] T6;
  wire[7:0] T7;
  wire[7:0] T8;
  wire[7:0] T9;
  wire[7:0] T10;
  wire[7:0] T11;
  wire[3:0] T12;
  wire[1:0] T13;
  wire hits_k_0;
  wire T14;
  wire[33:0] T15;
  reg [33:0] cam_tags [7:0];
  wire[33:0] T16;
  wire T17;
  wire hits_k_1;
  wire T18;
  wire[33:0] T19;
  wire T20;
  wire[1:0] T21;
  wire hits_k_2;
  wire T22;
  wire[33:0] T23;
  wire T24;
  wire hits_k_3;
  wire T25;
  wire[33:0] T26;
  wire T27;
  wire[3:0] T28;
  wire[1:0] T29;
  wire hits_k_4;
  wire T30;
  wire[33:0] T31;
  wire T32;
  wire hits_k_5;
  wire T33;
  wire[33:0] T34;
  wire T35;
  wire[1:0] T36;
  wire hits_k_6;
  wire T37;
  wire[33:0] T38;
  wire T39;
  wire hits_k_7;
  wire T40;
  wire[33:0] T41;
  wire T42;
  wire T43;
  wire[7:0] T44;
  wire[7:0] T45;
  wire[3:0] T46;
  wire[1:0] T47;
  wire hits_m_0;
  wire T48;
  wire[24:0] T49;
  wire[24:0] T50;
  wire[33:0] T51;
  wire T52;
  wire hits_m_1;
  wire T53;
  wire[24:0] T54;
  wire[24:0] T55;
  wire[33:0] T56;
  wire T57;
  wire[1:0] T58;
  wire hits_m_2;
  wire T59;
  wire[24:0] T60;
  wire[24:0] T61;
  wire[33:0] T62;
  wire T63;
  wire hits_m_3;
  wire T64;
  wire[24:0] T65;
  wire[24:0] T66;
  wire[33:0] T67;
  wire T68;
  wire[3:0] T69;
  wire[1:0] T70;
  wire hits_m_4;
  wire T71;
  wire[24:0] T72;
  wire[24:0] T73;
  wire[33:0] T74;
  wire T75;
  wire hits_m_5;
  wire T76;
  wire[24:0] T77;
  wire[24:0] T78;
  wire[33:0] T79;
  wire T80;
  wire[1:0] T81;
  wire hits_m_6;
  wire T82;
  wire[24:0] T83;
  wire[24:0] T84;
  wire[33:0] T85;
  wire T86;
  wire hits_m_7;
  wire T87;
  wire[24:0] T88;
  wire[24:0] T89;
  wire[33:0] T90;
  wire T91;
  wire T92;
  wire[7:0] T93;
  wire[7:0] T94;
  wire[3:0] T95;
  wire[1:0] T96;
  wire hits_g_0;
  wire T97;
  wire[15:0] T98;
  wire[15:0] T99;
  wire[33:0] T100;
  wire T101;
  wire hits_g_1;
  wire T102;
  wire[15:0] T103;
  wire[15:0] T104;
  wire[33:0] T105;
  wire T106;
  wire[1:0] T107;
  wire hits_g_2;
  wire T108;
  wire[15:0] T109;
  wire[15:0] T110;
  wire[33:0] T111;
  wire T112;
  wire hits_g_3;
  wire T113;
  wire[15:0] T114;
  wire[15:0] T115;
  wire[33:0] T116;
  wire T117;
  wire[3:0] T118;
  wire[1:0] T119;
  wire hits_g_4;
  wire T120;
  wire[15:0] T121;
  wire[15:0] T122;
  wire[33:0] T123;
  wire T124;
  wire hits_g_5;
  wire T125;
  wire[15:0] T126;
  wire[15:0] T127;
  wire[33:0] T128;
  wire T129;
  wire[1:0] T130;
  wire hits_g_6;
  wire T131;
  wire[15:0] T132;
  wire[15:0] T133;
  wire[33:0] T134;
  wire T135;
  wire hits_g_7;
  wire T136;
  wire[15:0] T137;
  wire[15:0] T138;
  wire[33:0] T139;
  wire T140;
  wire T141;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    vb_array = {1{$random}};
    for (initvar = 0; initvar < 8; initvar = initvar+1)
      cam_tags[initvar] = {2{$random}};
  end
// synthesis translate_on
`endif

  assign io_valid_bits = vb_array;
  assign T142 = reset ? 8'h0 : T0;
  assign T0 = io_clear ? T8 : T1;
  assign T1 = io_write ? T2 : vb_array;
  assign T2 = T6 | T3;
  assign T3 = T143 & T4;
  assign T4 = 1'h1 << io_write_addr;
  assign T143 = T5 ? 8'hff : 8'h0;
  assign T5 = 1'h1;
  assign T6 = vb_array & T7;
  assign T7 = ~ T4;
  assign T8 = vb_array & T9;
  assign T9 = ~ io_clear_mask;
  assign io_hits_k = T10;
  assign T10 = T11;
  assign T11 = {T28, T12};
  assign T12 = {T21, T13};
  assign T13 = {hits_k_1, hits_k_0};
  assign hits_k_0 = T17 & T14;
  assign T14 = T15 == io_tag;
  assign T15 = cam_tags[3'h0];
  assign T17 = vb_array[1'h0:1'h0];
  assign hits_k_1 = T20 & T18;
  assign T18 = T19 == io_tag;
  assign T19 = cam_tags[3'h1];
  assign T20 = vb_array[1'h1:1'h1];
  assign T21 = {hits_k_3, hits_k_2};
  assign hits_k_2 = T24 & T22;
  assign T22 = T23 == io_tag;
  assign T23 = cam_tags[3'h2];
  assign T24 = vb_array[2'h2:2'h2];
  assign hits_k_3 = T27 & T25;
  assign T25 = T26 == io_tag;
  assign T26 = cam_tags[3'h3];
  assign T27 = vb_array[2'h3:2'h3];
  assign T28 = {T36, T29};
  assign T29 = {hits_k_5, hits_k_4};
  assign hits_k_4 = T32 & T30;
  assign T30 = T31 == io_tag;
  assign T31 = cam_tags[3'h4];
  assign T32 = vb_array[3'h4:3'h4];
  assign hits_k_5 = T35 & T33;
  assign T33 = T34 == io_tag;
  assign T34 = cam_tags[3'h5];
  assign T35 = vb_array[3'h5:3'h5];
  assign T36 = {hits_k_7, hits_k_6};
  assign hits_k_6 = T39 & T37;
  assign T37 = T38 == io_tag;
  assign T38 = cam_tags[3'h6];
  assign T39 = vb_array[3'h6:3'h6];
  assign hits_k_7 = T42 & T40;
  assign T40 = T41 == io_tag;
  assign T41 = cam_tags[3'h7];
  assign T42 = vb_array[3'h7:3'h7];
  assign io_hit_k = T43;
  assign T43 = io_hits_k != 8'h0;
  assign io_hits_m = T44;
  assign T44 = T45;
  assign T45 = {T69, T46};
  assign T46 = {T58, T47};
  assign T47 = {hits_m_1, hits_m_0};
  assign hits_m_0 = T52 & T48;
  assign T48 = T50 == T49;
  assign T49 = io_tag >> 4'h9;
  assign T50 = T51 >> 4'h9;
  assign T51 = cam_tags[3'h0];
  assign T52 = vb_array[1'h0:1'h0];
  assign hits_m_1 = T57 & T53;
  assign T53 = T55 == T54;
  assign T54 = io_tag >> 4'h9;
  assign T55 = T56 >> 4'h9;
  assign T56 = cam_tags[3'h1];
  assign T57 = vb_array[1'h1:1'h1];
  assign T58 = {hits_m_3, hits_m_2};
  assign hits_m_2 = T63 & T59;
  assign T59 = T61 == T60;
  assign T60 = io_tag >> 4'h9;
  assign T61 = T62 >> 4'h9;
  assign T62 = cam_tags[3'h2];
  assign T63 = vb_array[2'h2:2'h2];
  assign hits_m_3 = T68 & T64;
  assign T64 = T66 == T65;
  assign T65 = io_tag >> 4'h9;
  assign T66 = T67 >> 4'h9;
  assign T67 = cam_tags[3'h3];
  assign T68 = vb_array[2'h3:2'h3];
  assign T69 = {T81, T70};
  assign T70 = {hits_m_5, hits_m_4};
  assign hits_m_4 = T75 & T71;
  assign T71 = T73 == T72;
  assign T72 = io_tag >> 4'h9;
  assign T73 = T74 >> 4'h9;
  assign T74 = cam_tags[3'h4];
  assign T75 = vb_array[3'h4:3'h4];
  assign hits_m_5 = T80 & T76;
  assign T76 = T78 == T77;
  assign T77 = io_tag >> 4'h9;
  assign T78 = T79 >> 4'h9;
  assign T79 = cam_tags[3'h5];
  assign T80 = vb_array[3'h5:3'h5];
  assign T81 = {hits_m_7, hits_m_6};
  assign hits_m_6 = T86 & T82;
  assign T82 = T84 == T83;
  assign T83 = io_tag >> 4'h9;
  assign T84 = T85 >> 4'h9;
  assign T85 = cam_tags[3'h6];
  assign T86 = vb_array[3'h6:3'h6];
  assign hits_m_7 = T91 & T87;
  assign T87 = T89 == T88;
  assign T88 = io_tag >> 4'h9;
  assign T89 = T90 >> 4'h9;
  assign T90 = cam_tags[3'h7];
  assign T91 = vb_array[3'h7:3'h7];
  assign io_hit_m = T92;
  assign T92 = io_hits_m != 8'h0;
  assign io_hits_g = T93;
  assign T93 = T94;
  assign T94 = {T118, T95};
  assign T95 = {T107, T96};
  assign T96 = {hits_g_1, hits_g_0};
  assign hits_g_0 = T101 & T97;
  assign T97 = T99 == T98;
  assign T98 = io_tag >> 5'h12;
  assign T99 = T100 >> 5'h12;
  assign T100 = cam_tags[3'h0];
  assign T101 = vb_array[1'h0:1'h0];
  assign hits_g_1 = T106 & T102;
  assign T102 = T104 == T103;
  assign T103 = io_tag >> 5'h12;
  assign T104 = T105 >> 5'h12;
  assign T105 = cam_tags[3'h1];
  assign T106 = vb_array[1'h1:1'h1];
  assign T107 = {hits_g_3, hits_g_2};
  assign hits_g_2 = T112 & T108;
  assign T108 = T110 == T109;
  assign T109 = io_tag >> 5'h12;
  assign T110 = T111 >> 5'h12;
  assign T111 = cam_tags[3'h2];
  assign T112 = vb_array[2'h2:2'h2];
  assign hits_g_3 = T117 & T113;
  assign T113 = T115 == T114;
  assign T114 = io_tag >> 5'h12;
  assign T115 = T116 >> 5'h12;
  assign T116 = cam_tags[3'h3];
  assign T117 = vb_array[2'h3:2'h3];
  assign T118 = {T130, T119};
  assign T119 = {hits_g_5, hits_g_4};
  assign hits_g_4 = T124 & T120;
  assign T120 = T122 == T121;
  assign T121 = io_tag >> 5'h12;
  assign T122 = T123 >> 5'h12;
  assign T123 = cam_tags[3'h4];
  assign T124 = vb_array[3'h4:3'h4];
  assign hits_g_5 = T129 & T125;
  assign T125 = T127 == T126;
  assign T126 = io_tag >> 5'h12;
  assign T127 = T128 >> 5'h12;
  assign T128 = cam_tags[3'h5];
  assign T129 = vb_array[3'h5:3'h5];
  assign T130 = {hits_g_7, hits_g_6};
  assign hits_g_6 = T135 & T131;
  assign T131 = T133 == T132;
  assign T132 = io_tag >> 5'h12;
  assign T133 = T134 >> 5'h12;
  assign T134 = cam_tags[3'h6];
  assign T135 = vb_array[3'h6:3'h6];
  assign hits_g_7 = T140 & T136;
  assign T136 = T138 == T137;
  assign T137 = io_tag >> 5'h12;
  assign T138 = T139 >> 5'h12;
  assign T139 = cam_tags[3'h7];
  assign T140 = vb_array[3'h7:3'h7];
  assign io_hit_g = T141;
  assign T141 = io_hits_g != 8'h0;

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      vb_array <= 8'h0;
    end else if(io_clear) begin
      vb_array <= T8;
    end else if(io_write) begin
      vb_array <= T2;
    end
  end
  integer cam_tags_i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (cam_tags_i=0; cam_tags_i < 8; cam_tags_i = cam_tags_i + 1) cam_tags[cam_tags_i] <= 34'h0;
    end else if (io_write)begin
      cam_tags[io_write_addr] <= io_write_tag;
    end
  end
endmodule

