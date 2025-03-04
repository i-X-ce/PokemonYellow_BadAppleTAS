RST0 equ $0000
RST1 equ $0008
RST2 equ $0010
RST3 equ $0018
RST4 equ $0020
RST5 equ $0028
RST6 equ $0030
RST7 equ $0038
VBLANK equ $0040
LASTER equ $0048
TIMER equ $0050
SERIAL equ $0058
PORT equ $0060
entry equ $0100
reset equ $0150
cont equ $0153
lcdc_stop equ $0167
lcdc_on equ $0181
oam_clr equ $0188
oam_off equ $0193
bank_chg_block_m equ $01a3
block_move equ $01bb
bui_nukemichi equ $01c4
bui_machi equ $01ca
bui_room equ $01de
bui_miseyado equ $01e8
bui_school equ $01ee
bui_dungeon equ $01fa
bui_minka equ $020a
bui_gatehaku equ $0214
bui_ship equ $021f
bui_port equ $022a
bui_tower equ $022f
bui_daimania equ $0237
bui_doukutu equ $0241
bui_depart equ $024d
bui_manshon equ $0255
bui_kenkyujo equ $025f
bui_cycle equ $0266
bui_building equ $0272
bui_centering equ $0285
chrset equ $028c
chrset2 equ $02a2
fontset equ $02c0
chrmove equ $02dd
fontmove equ $031b
wait_cont equ $0359
block_cls equ $0374
put_block equ $03ac
dvram_cls equ $03bf
put_window equ $03d2
put_msg equ $0405
scroll2 equ $05c9
msg_wait equ $05eb
put_msg_s equ $05f1
vcalc equ $0774
cls equ $0787
clx equ $078b
com equ $078c
haji_put equ $0798
all_put equ $07ee
all_move equ $083b
block_prt equ $087e
fnt_move equ $089f
chr_move equ $08fb
wave equ $095b
flower equ $0993
hana1 equ $09af
hana2 equ $09bf
soft_reset equ $09cf
reset2 equ $09da
chrarea_clr equ $0a8c
music_all_bank_init equ $0a96
vblank equ $0aac
wait_vb equ $0b31
color_reset equ $0b3c
b_to_n equ $0b53
n_to_w equ $0b5a
color_inc equ $0b5f
n_to_b equ $0b71
w_to_n equ $0b78
color_dec equ $0b7d
color3 equ $0b8f
color4 equ $0b9b
sio equ $0ba7
title_sio equ $0bc4
ret_sio equ $0be4
send_byts equ $0bf1
send_byt equ $0c1c
send_cnt_chk equ $0cb9
send_time_over equ $0cc1
send_send_buf equ $0cc9
send_byts_wait equ $0cd1
send_send_buf2_0 equ $0cf0
send_send_buf2 equ $0d01
send_byt2 equ $0d45
music_skip equ $0de1
check_music_bank equ $0e07
direct_play equ $0e23
play equ $0e33
actor_blanch equ $0eab
item_town_2A equ $0ec4
item_town_3B equ $0ecb
item_town_4C equ $0ed5
item_town_4D equ $0edf
item_town_6E equ $0ee3
item_town_5F equ $0eec
item_town_7G equ $0ef8
item_town_7P equ $0f04
item_town_7H equ $0f10
item_town_7I equ $0f18
item_town_7O equ $0f22
item_town_8J equ $0f29
item_town_8K equ $0f32
item_town_9L equ $0f3a
item_town_TM equ $0f44
item_town_10N equ $0f4d
msg_eom equ $0f57
msg_return equ $0f58
dummy_obj equ $0f5c
earth_up equ $0f5f
rock_on equ $0f71
pf_kanban equ $0f84
hotel_kanban equ $0f9d
capsule_item equ $0fb3
uncompress equ $0fbc
uncompress1 equ $0fd9
CompMainLoop equ $1015
Comp1 equ $103f
Comp0 equ $1054
CalcNextPos equ $1097
SetImgArea equ $1108
Read1Bit equ $112f
ReadData equ $114a
add_val equ $115e
XorFunctions equ $117e
InitType0 equ $1193
Type0MainLoop equ $11c3
GetXorVal equ $122c
xor0_tbl equ $1266
xor1_tbl equ $126e
rev_xor0_tbl equ $1276
rev_xor1_tbl equ $127e
XorType1 equ $1286
RevData equ $12f6
InitType1 equ $1300
rev_tbl equ $1326
XorType2 equ $1336
set_img_and_area equ $1356
hero_setup equ $1365
fadeplay equ $138a
talk_map equ $13df
talk_99 equ $1496
talk_100 equ $149f
talk_200 equ $14a8
obj_rewrite equ $14cb
itemshop equ $14ee
wazashop equ $1527
set_data equ $1527
hotel1 equ $153f
SafariEnd equ $155d
doku_dead equ $1568
zenmetu equ $157e
splay_kireta equ $15b4
personal equ $15cc
watashi1 equ $15db
serifu_talk_100 equ $166f
how_many_bit equ $167e
chk_pey equ $1695
buy_item equ $169d
sub_item equ $16ba
add_item equ $16ce
shop_window equ $16e5
shop_win_loop equ $1753
plural equ $1858
sel_end equ $193a
owari_select equ $193a
put_item_g equ $1956
get_mons_name equ $1a99
get_item_name equ $1acb
get_hiden_name equ $1aef
chk_hidenmachine equ $1b43
chk_hidenwaza equ $1b4c
hidenwaza_tbl equ $1b55
get_waza_name equ $1b5b
map_rewrite equ $1b74
map_rewrite2 equ $1b93
wing_ticket equ $1bac
JumpEffect equ $1da9
mapper equ $1db1
no_press_key equ $1ed2
derc_chk equ $1ef0
kurukuru equ $1fba
ROMBANK equ $2000
fight_ready equ $2088
ctrl_scroller equ $20a5
not_fight equ $20b9
exit_se equ $22ce
maptype_check equ $22e6
maptype_check2 equ $22ee
map_pal_set equ $2324
game_over equ $2336
over_music_fade equ $2356
warp equ $236a
warp_effect equ $2394
set_jiki equ $239c
ride_check equ $23ca
ride_on_tbl equ $23e7
set_mapimg equ $23ed
set_ram_map equ $2401
search_hit equ $2528
search_hit1_0 equ $2570 ;スプライトの番号をFF8Cに書き込む
search_hit1 equ $2572
chk_aruki equ $25d6
map_hit_chk equ $2615
chk_ramp equ $262f
ramp_tbl equ $2680
raplus_tbl equ $269f
put_map equ $26a9
put_map2 equ $26b4
scroller equ $2726
uehaji_put equ $2890
puthaji_yoko equ $28a5
sitahaji_put equ $28b1
migihaji_put equ $28d2
puthaji_tate equ $28f1
hidarihaji_put equ $2907
put_1cell equ $291c
cont_map equ $294c
contmap_main equ $2971
raplus_step equ $29b6
event_call equ $2a1a
get_map_info equ $2a7b
init_map equ $2c40
set_map_bank equ $2cbb
key_cancel_set equ $2cd9
special_reset equ $2ce6
lifting equ $2cec
set_sxy_rammap equ $2cf7
put_graph equ $2d1a
set_monsdata_dmy equ $2d56
put_waza_no equ $2d5e
prt_mons_chr equ $2d68
prt_mons_chr2 equ $2d6d
gyaarth_play equ $2db5
gyaarth equ $2dbe
cap_list equ $2de1
cap_list2 equ $2df6
cap_list_ready equ $2e05
cap_list1 equ $2e3f
cap_list_sub equ $2eb9
cap_list_sub2 equ $2ebe
cap_sub_call equ $2ec1
put_condition equ $2ec6
put_condition2 equ $2edb
put_level_s equ $2ef0
put_level equ $2f00
put_level1 equ $2f08
get_waza_no equ $2f13
get_monsadr equ $2f1c
get_pet_name_0 equ $2f99
get_pet_name equ $2f9f
put_bcd equ $2fb2
get_monsimg equ $2feb
put_monschr equ $3022
put_monschr2 equ $302f
set_monsimg equ $30a7
FUN_30ec equ $30ec
FUN_30f2 equ $30f2
check_item2 equ $310f
step_prn_win equ $311e
check_demo equ $3133
act_demo equ $3144
demo_kind equ $3176
system_demo equ $317c
after_care_finish equ $3184
set_talk_data equ $318d
battle_sequence equ $3196
gym_setting equ $31b5
GetBattleData equ $31c9
BitControl equ $31fd
DealerTalking equ $3202
battle_main equ $324f
battle_missing equ $3282
battle_ready equ $3293
battle_after equ $32ab
missing equ $3305
set_battle_data equ $330d
save_position equ $3325
save_position_s equ $332a
load_position equ $332f
load_position_s equ $3334
lrp_same equ $3337
obs_battler equ $333c
set_battle_msg equ $338a
set_battle equ $33a0
check_battle equ $33b7
check_cross_way equ $3415
CheckSlip equ $347a
item_stock0 equ $3498
mons_stock0 equ $34a2
coin_goods equ $34ac
BankPushCall equ $34b1
vunix equ $34b7
init_hero_anime equ $34be
check_pack equ $34cb
look_guide equ $34d3
SetActorSite equ $34de
SetActorSite2 equ $34e6
acttbl2set equ $34f1
CheckAssignPos equ $34f7
CheckPosition equ $34ff
CheckActorPos equ $351c
acttbl_l_adrs equ $3534
acttbl_h_adrs equ $3538
acttbl_adrs equ $353a
mk_trace_cmd equ $3544
obj_stepping equ $356b
obj_stopping equ $3579
GetAnimeStatus equ $3586
GetMoveStatus equ $3590
get_dealer_data equ $359e
get_dealer_name equ $35d6
check_money equ $35de
check_coin equ $35e9
push_bank equ $35f4
pop_bank equ $3605
bank_push_call equ $360e
yes_no equ $3624
ex_yes_no equ $362c
yes_no_same equ $3637
leave equ $3642
i_see equ $3652
same_r equ $3660
abs_ab equ $366b
actor_anime_set equ $3672
ex_div equ $36a3
set_kana equ $36b8
set_serifu equ $36d8
set_gauge equ $36f8
memset equ $3718
get_img_direct equ $3723
push_vram_m equ $372c
pop_vram_m equ $3738
pop_vram_s equ $3740
push_vram equ $374f
pop_vram equ $375b
wait_vb_s equ $376f ;待機　C,待機時間(フレーム)
se_play equ $3776
se_wait equ $377e ; 音が鳴り終わるまで待つ
table_list equ $3793
get_table equ $37a1 ;ポケモンの名前、技名などをCF45に書き出す　(D092),内部番号　(D093),カテゴリ　(D094),バンク　04,02でわざ
get_gold equ $3815
str_cpy equ $385c
strcpy equ $385f
cont_repeat equ $3867
cont_abwait equ $389c
cont_abwait_pi equ $38cf
mul_direct equ $38e3
div_direct equ $38f0
okuri_chk equ $390b
block_move_inc equ $394b
sub_capsule equ $3957
add_capsule_new equ $395f
set_status_all equ $396e
get_status equ $3982
add_capsule equ $3a8b
add_capsule2 equ $3aa0
mul_6 equ $3ab5
mul_any equ $3abf
cmp_byt equ $3ac6
set_oam_buf16 equ $3acf
allow equ $3af6
allow2 equ $3afa
allow_1 equ $3bb4
white_allow equ $3c0a
cls_allow equ $3c17
tenmetsu equ $3c22
init_for_talkmap equ $3c5a
init_for_talk2 equ $3c5d
init_for_talk3 equ $3c5f
put_win_msg equ $3c67
put_nowin_msg equ $3c77
put_dec equ $3c7d
table_jump equ $3db5
table_search equ $3dc9
table_search1 equ $3dcb
set_objdata equ $3ddc
pal_off_put_wait equ $3df2
put_wait equ $3df5
palset equ $3dfa
pal_off equ $3e03
color_rewrite equ $3e0b
color_set equ $3e0d
hp_color_chk equ $3e17
set_objdata_main equ $3e26
take_item equ $3e4c
take_monster equ $3e66
rnd equ $3e7a
bank2bank equ $3e8b
ready2ready equ $3eb2
gym9_door_hook equ $3ecb
pickup_search equ $3ed3
easy_talk equ $3f13
ev_msg_adrs_load equ $3f23
ev_msg_adrs_save equ $3f2d
ev_msg_tbl equ $3f40

;SECTION "Test",ROM0
;load "ACE", wramx[$da00]

;main::
    

;Hblankを待つ
;hblank_wait::
;    push hl 
;    push af 
;    ld hl, $ff41
;.lp1 
;    ld a, [hl]
;    and $03  
;    jr z, .lp1
;.lp2 
;    ld a, [hl]
;    and $03 
;    jr nz, .lp2
;    pop af 
;    pop hl 
;    ret  
;
;;aの値をhlに足す
;add_hl:
;    push bc 
;    ld c, a 
;    ld b, 0 
;    add hl, bc
;    pop bc 
;    ret

;16進数を描画
; draw_hex::
;     call .core
; .core
;     swap a 
;     push af 
;     and a, $0f
;     add a, $f6
;     jr nc, .cskp
;     add a, $60
; .cskp
;     ld [hli], a
;     pop af 
;     ret  