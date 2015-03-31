unit dietgogo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco16ic,deco_decr,deco_common,deco_104,deco_146,
     misc_functions;

procedure Cargar_dietgo;
function iniciar_dietgo:boolean;
procedure reset_dietgo;
procedure cerrar_dietgo;
procedure dietgo_principal;
//Main CPU
function dietgo_getword(direccion:dword;putbyte:boolean):word;
procedure dietgo_putword(direccion:dword;valor:word);
function dietgo_bank_callback(bank:word):word;
procedure sound_bank_rom(valor:byte);

const
        dietgo_rom:array[0..2] of tipo_roms=(
        (n:'jy00-2.h4';l:$40000;p:1;crc:$014dcf62),(n:'jy01-2.h5';l:$40000;p:$0;crc:$793ebd83),());
        dietgo_sound:tipo_roms=(n:'jy02.m14';l:$10000;p:$0;crc:$4e3492a5);
        dietgo_char:tipo_roms=(n:'may00';l:$100000;p:0;crc:$234d1f8d);
        dietgo_oki:tipo_roms=(n:'may03';l:$80000;p:0;crc:$b6e42bae);
        dietgo_sprites:array[0..2] of tipo_roms=(
        (n:'may01';l:$100000;p:0;crc:$2da57d04),(n:'may02';l:$100000;p:$1;crc:$3a66a713),());
        dietgo_dip_a:array [0..7] of def_dip=(
        (mask:$0007;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3 Coin - 1 Credit'),(dip_val:$1;dip_name:'2 Coin - 1 Credit'),(dip_val:$7;dip_name:'1 Coin - 1 Credit'),(dip_val:$6;dip_name:'1 Coin - 2 Credit'),(dip_val:$5;dip_name:'1 Coin - 3 Credit'),(dip_val:$4;dip_name:'1 Coin - 4 Credit'),(dip_val:$3;dip_name:'1 Coin - 5 Credit'),(dip_val:$2;dip_name:'1 Coin - 6 Credit'),(),(),(),(),(),(),(),())),
        (mask:$0038;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3 Coin - 1 Credit'),(dip_val:$8;dip_name:'2 Coin - 1 Credit'),(dip_val:$38;dip_name:'1 Coin - 1 Credit'),(dip_val:$30;dip_name:'1 Coin - 2 Credit'),(dip_val:$28;dip_name:'1 Coin - 3 Credit'),(dip_val:$20;dip_name:'1 Coin - 4 Credit'),(dip_val:$18;dip_name:'1 Coin - 5 Credit'),(dip_val:$10;dip_name:'1 Coin - 6 Credit'),(),(),(),(),(),(),(),())),
        (mask:$0040;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0080;name:'Continue Coin';number:2;dip:((dip_val:$80;dip_name:'1 Start/1 Continue'),(dip_val:$0;dip_name:'2 Start/1 Continue'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0300;name:'Lives';number:4;dip:((dip_val:$100;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$200;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0c00;name:'Difficulty';number:4;dip:((dip_val:$800;dip_name:'Easy'),(dip_val:$c00;dip_name:'Normal'),(dip_val:$400;dip_name:'Hard'),(dip_val:$000;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$1000;name:'Free Play';number:2;dip:((dip_val:$1000;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom_opcode,rom_data:array[0..$3ffff] of word;
 ram:array[0..$7fff] of word;
 oki1_mem:pbyte;

implementation

procedure Cargar_dietgo;
begin
llamadas_maquina.bucle_general:=dietgo_principal;
llamadas_maquina.iniciar:=iniciar_dietgo;
llamadas_maquina.cerrar:=cerrar_dietgo;
llamadas_maquina.reset:=reset_dietgo;
llamadas_maquina.fps_max:=58;
end;

//Inicio Normal
function iniciar_dietgo:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  pt_x:array[0..15] of dword=(256,257,258,259,260,261,262,263,
  0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
  8*16,9*16,10*16,11*16,12*16,13*16,14*16,15*16);
  ps_x:array[0..15] of dword=(512,513,514,515,516,517,518,519,
   0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
	  8*32, 9*32,10*32,11*32,12*32,13*32,14*32,15*32 );
var
  memoria_temp:pbyte;
  memoria_temp_rom:pword;
begin
iniciar_dietgo:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
init_dec16ic(0,1,2,$0,$0,$f,$f,0,1,0,16,dietgo_bank_callback,dietgo_bank_callback);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
main_m68000:=cpu_m68000.create(14000000,$100);
main_m68000.change_ram16_calls(dietgo_getword,dietgo_putword);
//Sound CPU
deco16_sprite_color_add:=$200;
deco16_sprite_mask:=$3fff;
deco16_snd_simple_init(32220000 div 12,32220000,sound_bank_rom);
getmem(memoria_temp,$200000);
getmem(memoria_temp_rom,$80000);
//cargar roms
if not(cargar_roms16w(memoria_temp_rom,@dietgo_rom[0],'dietgo.zip',0)) then exit;
deco102_decrypt_cpu(memoria_temp_rom,@rom_opcode[0],@rom_data[0],$e9ba,$01,$19,$80000);
//cargar sonido
if not(cargar_roms(@mem_snd[0],@dietgo_sound,'dietgo.zip',1)) then exit;
//OKI rom
getmem(oki1_mem,$80000);
if not(cargar_roms(oki1_mem,@dietgo_oki,'dietgo.zip',1)) then exit;
//convertir chars
if not(cargar_roms(memoria_temp,@dietgo_char,'dietgo.zip',1)) then exit;
deco56_decrypt_gfx(memoria_temp,$100000);
init_gfx(0,8,8,$8000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,$8000*16*8+8,$8000*16*8+0,8,0);
convert_gfx(@gfx[0],0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
//Tiles
init_gfx(1,16,16,$2000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$2000*32*16+8,$2000*32*16+0,8,0);
convert_gfx(@gfx[1],0,memoria_temp,@pt_x[0],@pt_y[0],false,false);
//Sprites
if not(cargar_roms16b(memoria_temp,@dietgo_sprites[0],'dietgo.zip',0)) then exit;
init_gfx(2,16,16,$4000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*32,24,8,16,0);
convert_gfx(@gfx[2],0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//Proteccion deco104
main_deco104:=cpu_deco_104.create;
main_deco104.SET_INTERFACE_SCRAMBLE_INTERLEAVE;
main_deco104.SET_USE_MAGIC_ADDRESS_XOR;
//Dip
marcade.dswa:=$ffff;
marcade.dswa_val:=@dietgo_dip_a;
//final
freemem(memoria_temp);
reset_dietgo;
iniciar_dietgo:=true;
end;

procedure cerrar_dietgo;
begin
main_m68000.free;
main_deco104.free;
close_dec16ic(0);
freemem(oki1_mem);
deco16_snd_simple_close;
close_audio;
close_video;
end;

procedure reset_dietgo;
begin
 main_m68000.reset;
 reset_dec16ic(0);
 main_deco104.reset;
 copymemory(oki_6295_0.get_rom_addr,oki1_mem,$40000);
 deco16_snd_simple_reset;
 reset_audio;
 marcade.in0:=$FFFF;
 marcade.in1:=$7;
end;

procedure update_video_dietgo;inline;
begin
update_pf_2(0,3,false);
update_pf_1(0,3,true);
deco16_sprites;
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_dietgo;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $ffFd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $ffF7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $0040);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $0080);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $Fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $F7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure dietgo_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=main_h6280.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   //Main
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   //Sound
   main_h6280.run(frame_s);
   frame_s:=frame_s+main_h6280.tframes-main_h6280.contador;
   case f of
      247:begin
            main_m68000.irq[6]:=HOLD_LINE;
            update_video_dietgo;
            marcade.in1:=marcade.in1 or $8;
          end;
      255:marcade.in1:=marcade.in1 and $7;
   end;
 end;
 eventos_dietgo;
 video_sync;
end;
end;

function dietgo_protection_region_0_104_r(real_address:word):word;inline;
var
  deco146_addr,data:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	data:=main_deco104.read_data(deco146_addr,cs);
	dietgo_protection_region_0_104_r:=data;
end;

function dietgo_getword(direccion:dword;putbyte:boolean):word;
begin
direccion:=direccion and $fffffe;
case direccion of
  $0..$7ffff:if main_m68000.opcode then dietgo_getword:=rom_opcode[direccion shr 1]
                  else dietgo_getword:=rom_data[direccion shr 1];
  $210000..$210fff:dietgo_getword:=deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $212000..$212fff:dietgo_getword:=deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff] shl 8);
  $280000..$2807ff:dietgo_getword:=deco_sprite_ram[(direccion and $7ff) shr 1];
  $300000..$300bff:dietgo_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $340000..$343fff:dietgo_getword:=dietgo_protection_region_0_104_r(direccion and $3fff);
  $380000..$38ffff:dietgo_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure cambiar_color(numero:word);inline;
var
  color:tcolor;
begin
  color.b:=buffer_paleta[(numero shl 1)] and $ff;
  color.g:=buffer_paleta[(numero shl 1)+1] shr 8;
  color.r:=buffer_paleta[(numero shl 1)+1] and $ff;
  set_pal_color(color,@paleta[numero]);
  case numero of
    $000..$0ff:deco16ic_chip[0].dec16ic_buffer_color[1,(numero shr 4) and $f]:=true;
    $100..$1ff:deco16ic_chip[0].dec16ic_buffer_color[2,(numero shr 4) and $f]:=true;
  end;
end;

procedure dietgo_protection_region_0_104_w(real_address,data:word);inline;
var
  deco146_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,  17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	main_deco104.write_data(deco146_addr, data,cs);
end;

procedure dietgo_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffffe;
if direccion<$80000 then exit;
case direccion of
  $200000..$20000f:dec16ic_pf_control_w(0,(direccion and $f) shr 1,valor);
  $210000..$210fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $212000..$212fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $220000..$2207ff:deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $222000..$2227ff:deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
  $280000..$2807ff:deco_sprite_ram[(direccion and $7ff) shr 1]:=valor;
  $211000..$211fff,$213000..$213fff,$2c0002,$2c000a,$230000..$2300ff,$240000:;
  $300000..$300bff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $fff) shr 1]:=valor;
                      cambiar_color((direccion and $fff) shr 2);
                   end;
  $340000..$343fff:dietgo_protection_region_0_104_w(direccion and $3fff,valor);
  $380000..$38ffff:ram[(direccion and $ffff) shr 1]:=valor;
end;
end;

function dietgo_bank_callback(bank:word):word;
begin
  	dietgo_bank_callback:=((bank shr 4) and $7)*$1000;
end;

procedure sound_bank_rom(valor:byte);
var
  temp:pbyte;
begin
  temp:=oki1_mem;
  inc(temp,(valor and 1)*$40000);
  copymemory(oki_6295_0.get_rom_addr,temp,$40000);
end;


end.
