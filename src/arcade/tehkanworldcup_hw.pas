unit tehkanworldcup_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,msm5205,rom_engine,
     pal_engine,sound_engine;

procedure Cargar_tehkanwc;
procedure tehkanwc_principal;
function iniciar_tehkanwc:boolean;
procedure reset_tehkanwc;
procedure cerrar_tehkanwc;
//Main CPU
function tehkanwc_getbyte(direccion:word):byte;
procedure tehkanwc_putbyte(direccion:word;valor:byte);
//Sub CPU
function tehkanwc_misc_getbyte(direccion:word):byte;
procedure tehkanwc_misc_putbyte(direccion:word;valor:byte);
//Sound CPU
function snd_getbyte(direccion:word):byte;
procedure snd_putbyte(direccion:word;valor:byte);
function snd_inbyte(puerto:word):byte;
procedure snd_outbyte(valor:byte;puerto:word);
procedure tehkanwc_sound_update;
procedure tehkan_porta_write(valor:byte);
procedure tehkan_portb_write(valor:byte);
function tehkan_porta_read:byte;
function tehkan_portb_read:byte;
procedure msm5205_sound;

const
        tehkanwc_rom:array[0..3] of tipo_roms=(
        (n:'twc-1.bin';l:$4000;p:0;crc:$34d6d5ff),(n:'twc-2.bin';l:$4000;p:$4000;crc:$7017a221),
        (n:'twc-3.bin';l:$4000;p:$8000;crc:$8b662902),());
        tehkanwc_cpu2:tipo_roms=(n:'twc-4.bin';l:$8000;p:0;crc:$70a9f883);
        tehkanwc_sound:tipo_roms=(n:'twc-6.bin';l:$4000;p:0;crc:$e3112be2);
        tehkanwc_chars:tipo_roms=(n:'twc-12.bin';l:$4000;p:0;crc:$a9e274f8);
        tehkanwc_sprites:array[0..2] of tipo_roms=(
        (n:'twc-8.bin';l:$8000;p:0;crc:$055a5264),(n:'twc-7.bin';l:$8000;p:$8000;crc:$59faebe7),());
        tehkanwc_tiles:array[0..2] of tipo_roms=(
        (n:'twc-11.bin';l:$8000;p:0;crc:$669389fc),(n:'twc-9.bin';l:$8000;p:$8000;crc:$347ef108),());
        tehkanwc_adpcm:tipo_roms=(n:'twc-5.bin';l:$4000;p:0;crc:$444b5544);
        //DIP
        tehkanwc_dipa:array [0..3] of def_dip=(
        (mask:$7;name:'Coin A';number:7;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$7;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$6;dip_name:'1C 2C'),(dip_val:$5;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 4C'),(dip_val:$3;dip_name:'1C 5C'),(dip_val:$2;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Coin B';number:7;dip:((dip_val:$8;dip_name:'2C 1C'),(dip_val:$38;dip_name:'1C 1C'),(dip_val:$0;dip_name:'2C 3C'),(dip_val:$30;dip_name:'1C 2C'),(dip_val:$28;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$10;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Start Credits P1/P2';number:4;dip:((dip_val:$80;dip_name:'1C/1C'),(dip_val:$c0;dip_name:'1C/2C'),(dip_val:$40;dip_name:'2C/2C'),(dip_val:$0;dip_name:'2C/3C'),(),(),(),(),(),(),(),(),(),(),(),())),());
        tehkanwc_dipb:array [0..3] of def_dip=(
        (mask:$3;name:'1P Game Time';number:4;dip:((dip_val:$0;dip_name:'2:30'),(dip_val:$1;dip_name:'2:00'),(dip_val:$3;dip_name:'1:30'),(dip_val:$2;dip_name:'1:00'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$7c;name:'2P Game Time';number:16;dip:((dip_val:$0;dip_name:'5:00/3:00 Extra'),(dip_val:$60;dip_name:'5:00/2:45 Extra'),(dip_val:$20;dip_name:'5:00/2:35 Extra'),(dip_val:$40;dip_name:'5:00/2:30 Extra'),(dip_val:$4;dip_name:'4:00/2:30 Extra'),(dip_val:$64;dip_name:'4:00/2:15 Extra'),(dip_val:$24;dip_name:'4:00/2:05 Extra'),(dip_val:$44;dip_name:'4:00/2:00 Extra'),(dip_val:$1c;dip_name:'3:30/2:15 Extra'),(dip_val:$7c;dip_name:'3:30/2:00 Extra'),(dip_val:$3c;dip_name:'3:30/1:50 Extra'),(dip_val:$5c;dip_name:'3:30/1:45 Extra'),(dip_val:$8;dip_name:'3:00/2:00 Extra'),(dip_val:$68;dip_name:'3:00/1:45 Extra'),(dip_val:$28;dip_name:'3:00/1:35 Extra'),(dip_val:$48;dip_name:'3:00/1:30 Extra'))),
        (mask:$80;name:'Game Type';number:2;dip:((dip_val:$80;dip_name:'Timer In'),(dip_val:$0;dip_name:'Credit In'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        tehkanwc_dipc:array [0..3] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Timer Speed';number:2;dip:((dip_val:$4;dip_name:'60/60'),(dip_val:$0;dip_name:'55/60'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 scroll_x,adpcm_pos,adpcm_data:word;
 sound_latch,sound_latch2,scroll_y:byte;
 track0,track1:array[0..1] of byte;
 mem_adpcm:array[0..$7fff] of byte;

implementation

procedure Cargar_tehkanwc;
begin
llamadas_maquina.iniciar:=iniciar_tehkanwc;
llamadas_maquina.bucle_general:=tehkanwc_principal;
llamadas_maquina.cerrar:=cerrar_tehkanwc;
llamadas_maquina.reset:=reset_tehkanwc;
end;

function iniciar_tehkanwc:boolean;
const
  ps_x:array[0..15] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4,
			8*32+1*4, 8*32+0*4, 8*32+3*4, 8*32+2*4, 8*32+5*4, 8*32+4*4, 8*32+7*4, 8*32+6*4);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
  pc_x:array[0..7] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
var
  memoria_temp:array[0..$ffff] of byte;
begin
iniciar_tehkanwc:=false;
iniciar_audio(false);
screen_init(1,512,256);
screen_mod_scroll(1,512,256,511,256,256,255);
screen_init(2,512,256,false,true);
screen_init(3,256,256,true);
screen_init(4,256,256,true);
iniciar_video(256,224);
//Main CPU
main_z80:=cpu_z80.create(4608000,$200);
main_z80.change_ram_calls(tehkanwc_getbyte,tehkanwc_putbyte);
//Misc CPU
sub_z80:=cpu_z80.create(4608000,$200);
sub_z80.change_ram_calls(tehkanwc_misc_getbyte,tehkanwc_misc_putbyte);
//analog
init_analog(main_z80.numero_cpu,main_z80.clock,100,10,0,63,-63);
//Sound CPU
snd_z80:=cpu_z80.create(4608000,$200);
snd_z80.change_ram_calls(snd_getbyte,snd_putbyte);
snd_z80.change_io_calls(snd_inbyte,snd_outbyte);
snd_z80.init_sound(tehkanwc_sound_update);
//Sound Chip
ay8910_0:=ay8910_chip.create(1536000,1);
ay8910_0.change_io_calls(nil,nil,tehkan_porta_write,tehkan_portb_write);
ay8910_1:=ay8910_chip.create(1536000,1);
ay8910_1.change_io_calls(tehkan_porta_read,tehkan_portb_read,nil,nil);
msm_5205_0:=MSM5205_chip.create(0,384000,MSM5205_S96_4B,0.45,msm5205_sound);
//cargar roms
if not(cargar_roms(@memoria[0],@tehkanwc_rom[0],'tehkanwc.zip',0)) then exit;
//cargar cpu 2
if not(cargar_roms(@mem_misc[0],@tehkanwc_cpu2,'tehkanwc.zip')) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@tehkanwc_sound,'tehkanwc.zip')) then exit;
//Cargar ADPCM
if not(cargar_roms(@mem_adpcm[0],@tehkanwc_adpcm,'tehkanwc.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@tehkanwc_chars,'tehkanwc.zip')) then exit;
init_gfx(0,8,8,512);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@tehkanwc_sprites[0],'tehkanwc.zip',0)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//tiles
if not(cargar_roms(@memoria_temp[0],@tehkanwc_tiles[0],'tehkanwc.zip',0)) then exit;
init_gfx(2,16,8,1024);
gfx_set_desc_data(4,0,64*8,0,1,2,3);
convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@tehkanwc_dipa;
marcade.dswb:=$ff;
marcade.dswb_val:=@tehkanwc_dipb;
marcade.dswc:=$f;
marcade.dswc_val:=@tehkanwc_dipc;
reset_tehkanwc;
iniciar_tehkanwc:=true;
end;

procedure cerrar_tehkanwc;
begin
main_z80.free;
sub_z80.free;
snd_z80.free;
ay8910_0.Free;
ay8910_1.Free;
msm_5205_0.Free;
close_audio;
close_video;
end;

procedure reset_tehkanwc;
begin
 main_z80.reset;
 sub_z80.reset;
 snd_z80.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 msm_5205_0.reset;
 reset_audio;
 marcade.in0:=$20;
 marcade.in1:=$20;
 marcade.in2:=$f;
 adpcm_pos:=0;
 adpcm_data:=$100;
 scroll_x:=0;
 scroll_y:=0;
 sound_latch:=0;
 sound_latch2:=0;
end;

procedure update_video_tehkanwc;inline;
var
  f,color,nchar,atrib,x,y:word;
begin
//background
for f:=0 to $3ff do begin
  atrib:=memoria[$e001+(f*2)];
  color:=atrib and $f;
  if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$e000+(f*2)]+((atrib and $30) shl 4);
      put_gfx_flip(x*16,y*8,nchar,(color shl 4)+512,1,2,(atrib and $40)<>0,(atrib and $80)<>0);
      gfx[2].buffer[f]:=false;
  end;
end;
scroll_x_y(1,2,scroll_x,scroll_y);
//chars
for f:=0 to $3ff do begin
  atrib:=memoria[$d400+f];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$d000+f]+((atrib and $10) shl 4);
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,3,0,(atrib and $40)<>0,(atrib and $80)<>0);
      if (atrib and $20)=0 then put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,4,0,(atrib and $40)<>0,(atrib and $80)<>0)
        else put_gfx_block_trans(x*8,y*8,4,8,8);
      gfx[0].buffer[f]:=false;
  end;
end;
//chars de arriba
actualiza_trozo(0,0,256,256,3,0,0,256,256,2);
//Sprites
for f:=0 to $ff do begin
  atrib:=memoria[$e801+(f*4)];
  x:=memoria[$e802+(f*4)]+((atrib and $20) shl 3)-128;
  y:=memoria[$e803+(f*4)];
  color:=(atrib and $7) shl 4;
  nchar:=memoria[$e800+(f*4)]+((atrib and $08) shl 5);
  put_gfx_sprite(nchar,color+256,(atrib and $40)<>0,(atrib and $80)<>0,1);
  actualiza_gfx_sprite(x,y,2,1);
end;
//Prioridad de los chars
actualiza_trozo(0,0,256,256,4,0,0,256,256,2);
actualiza_trozo_final(0,16,256,224,2);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_tehkanwc;
begin
if event.arcade then begin
  //Player 1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //Player 2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //Rest
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
end;
end;

procedure tehkanwc_principal;
var
  frame_m,frame_s,frame_m2:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_m2:=sub_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $1ff do begin
  //CPU 1
  main_z80.run(frame_m);
  frame_m:=frame_m+main_z80.tframes-main_z80.contador;
  //CPU 2
  sub_z80.run(frame_m2);
  frame_m2:=frame_m2+sub_z80.tframes-sub_z80.contador;
  //CPU Sound
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  if f=479 then begin
     main_z80.pedir_irq:=HOLD_LINE;
     sub_z80.pedir_irq:=HOLD_LINE;
     snd_z80.pedir_irq:=HOLD_LINE;
     update_video_tehkanwc;
  end;
 end;
 eventos_tehkanwc;
 video_sync;
end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.b:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+1];
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,@paleta[dir]);
  case dir of
    0..255:buffer_color[dir shr 4]:=true;
    512..767:buffer_color[((dir shr 4) and $f)+$10]:=true;
  end;
end;

procedure mem_shared_w(direccion:word;valor:byte);inline;
begin
memoria[direccion+$c800]:=valor;
case direccion of
    $800..$fff:gfx[0].buffer[direccion and $3ff]:=true;
    $1000..$17ff:if buffer_paleta[direccion and $7ff]<>valor then begin
                    buffer_paleta[direccion and $7ff]:=valor;
                    cambiar_color(direccion and $7fe);
                  end;
    $1800..$2000:gfx[2].buffer[(direccion and $7ff) shr 1]:=true;
    $2400:scroll_x:=(scroll_x and $100) or valor;
    $2401:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
    $2402:scroll_y:=valor;
end;
end;

function tehkanwc_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$ec02:tehkanwc_getbyte:=memoria[direccion];
  $f800:tehkanwc_getbyte:=track0[0]-analog.x[0];
  $f801:tehkanwc_getbyte:=track0[1]-analog.y[0];
  $f802,$f806:tehkanwc_getbyte:=marcade.in2;
  $f803:tehkanwc_getbyte:=marcade.in0;
  $f810:tehkanwc_getbyte:=track1[0]-analog.x[1];
  $f811:tehkanwc_getbyte:=track1[1]-analog.y[1];
  $f813:tehkanwc_getbyte:=marcade.in1;
  $f820:tehkanwc_getbyte:=sound_latch2;
  $f840:tehkanwc_getbyte:=marcade.dswa;
  $f850:tehkanwc_getbyte:=marcade.dswb;
  $f860:;
  $f870:tehkanwc_getbyte:=marcade.dswc;
end;
end;

procedure tehkanwc_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
    $c000..$c7ff:memoria[direccion]:=valor;
    $c800..$ec02:mem_shared_w(direccion-$c800,valor);
    $f800:track0[0]:=valor;
    $f801:track0[1]:=valor;
    $f810:track1[0]:=valor;
    $f811:track1[1]:=valor;
    $f820:begin
            sound_latch:=valor;
            snd_z80.pedir_nmi:=ASSERT_LINE;
          end;
    $f840:if valor=0 then sub_z80.pedir_reset:=ASSERT_LINE
            else sub_z80.pedir_reset:=CLEAR_LINE;
end;
end;

function tehkanwc_misc_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$c7ff:tehkanwc_misc_getbyte:=mem_misc[direccion];
  $c800..$ec02:tehkanwc_misc_getbyte:=memoria[direccion];
  $f860:;  //WatchDog
end;
end;

procedure tehkanwc_misc_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
    $8000..$c7ff:mem_misc[direccion]:=valor;
    $c800..$ec02:mem_shared_w(direccion-$c800,valor);
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$47ff:snd_getbyte:=mem_snd[direccion];
  $c000:snd_getbyte:=sound_latch;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
case direccion of
  $4000..$47ff:mem_snd[direccion]:=valor;
  $8001:msm_5205_0.reset_w((valor xor $1) and 1);
  $8003:snd_z80.clear_nmi;
  $c000:sound_latch2:=valor;
end;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
 0:snd_inbyte:=ay8910_0.Read;
 1:snd_inbyte:=ay8910_1.Read;
end;
end;

procedure snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0:ay8910_0.Write(valor);
  $1:ay8910_0.Control(valor);
  $2:ay8910_1.Write(valor);
  $3:ay8910_1.Control(valor);
end;
end;

procedure tehkan_porta_write(valor:byte);
begin
adpcm_pos:=(adpcm_pos and $ff00) or valor;
end;

procedure tehkan_portb_write(valor:byte);
begin
adpcm_pos:=(adpcm_pos and $ff) or (valor shl 8);
end;

function tehkan_porta_read:byte;
begin
tehkan_porta_read:=adpcm_pos and $ff;
end;

function tehkan_portb_read:byte;
begin
tehkan_portb_read:=adpcm_pos shr 8;
end;

procedure msm5205_sound;
begin
if (adpcm_data and $100)=0 then begin
   msm_5205_0.data_w((adpcm_data and $f0) shr 4);
   adpcm_pos:=adpcm_pos+1;
   adpcm_data:=$100;
end else begin
    adpcm_data:=mem_adpcm[adpcm_pos and $7fff];
    msm_5205_0.data_w(adpcm_data and $0f);
end;
end;

procedure tehkanwc_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

end.
