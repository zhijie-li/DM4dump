#!/usr/bin/perl

=header

May 2018

zhijie.li@utoronto.ca

DM4 format information from: #http://www.er-c.org/cbb/info/dmformat/
https://www.ntu.edu.sg/home/cbb/info/dmformat/index.html

I tried to minimize its dependencies, but still, this program requires Compress::Zlib and YAML. 
The zlib is only for PNG generation. 
If dumping the header information is the only goal, delete the two functions related to save PNG at the end.

Run it as: 

    perl dumpDM4.pl 0000.dm4 >log.txt

To dump the thumbnail (not quite useful, except to see a scale bar or to see the original orientation): 

    perl dumpDM4.pl 0000.dm4 --dumpthumbnail >log.txt

To dump the image or image slices:

    perl dumpDM4.pl 0000.dm4 --dumpPNG >log.txt


Dumping PNG from DDD movies could take quite a while. 

For each slice, a PNG image is produced. Another PNG image that indicates pixels with over 6-rms readings is also produced.
----next versions may add options to indicate how many slices to dump.

The log.txt is worth reading. It has the data represented side-by-side as HEX, ASCII and "translated". 

It also generates a YAML file, which contains the data hash (=dict in python).     

Some important information can be found in the beginning of the YAML file. 
Keys starting with '0_'.  -importantly the offsets and lengths of the two datablocks.



To dump to MRC, there is already e2proc2d, which copies the image block and flips the order of rows in each slice. 
--Origin of images are upper left(L-handed), while CCP4/MRC maps are right-handed. 


This program provides two functions processDDD_data() and processCCD_data() for converting CCD and DDD data into 8-bit PNG.
 -- DDD: direct electron detection device, such as GATAN K2.  

CCD data are simply scaled to 0-255. 
I use a 6-rms cut-off to remove the few X-ray pixels/instrument noise. These pixels then take the mean value of adjecent "good" pixels.
The majority (over 99.99%) of the image densities are within the +/- 6-rms range. 

For DDD data, I think they are electron counts with some sort of correction. 
Since most of the numbers are not too much off the integer values (average deviation = ~0.05 - indicated in output as dev-int, meandev-int, etc. .), 
I decided to use the nearest int values to replace the original float point numbers. 
The 6-rms cutoff is still used for removing the X-ray pixels. 
For the "bad" pixels, their values are replaced by the average of the adjecent 8 pixels & only those with values within the 6-rms range. 
I could go further to use 4-bit PNG (0..15). But for longer exposure or larger dose images, one may expect legit counts of more than 15. 
    --Hopefully the zlib compression will take care of the leading zeros.



##############################################################################################
Curiously, DM4 from GATAN K2 camera saves 32-bit float (datatype 2) numbers in the image array with values CLOSE to integers.
    --but not integers 
In each slice the mean < 5 and rms < 2, exactly what one would expect for electron counts for cryo-EM.
Their values are quite bit off the exact integer values, usually by 5%-10% and can be as large as 50% (ie. 0.5). 
I suspect that this may have something to do with the super-resolution mode.

John Rubinstein has discussed this in a ccpem post. 

Motioncor2 provides an option to save the maps in 4-bit int.

"the exact algorithm used by the K2 Summit camera is proprietary information. " 
    --https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4633381/ 

K2 has a internal frame rate of 400 fps. 
###############################################################################################


#####log.txt example, image data  ############################################
#('V'  An unsigned long (32-bit) in "VAX" (little-endian) order. --perl pack()):

    |6.2.1.2 <Data> root::ImageList::::ImageData::Data 1708677600 Bytes   6f
    4x427169400 [first 1K:] <0.972452223300934 1.95095467567444 6.29092597961426
    1.01709580421448 0 3.91314601898193 5.03398370742798 1.03966331481934 0
    3.04672622680664 1.97171449661255 3.00998258590698 3.88147568702698
    1.02066099643707 1.93154215812683 2.95900297164917 4.11769676208496 0
    1.00160193443298 0.987050771713257 0 2.99670648574829 6.86943626403809
    2.00665497779846 1.95751249790192 3.05586194992065 1.99976444244385
    2.93063974380493 3.89911031723022 1.02708995342255 4.02122783660889
    7.04235935211182 2.1187732219696 2.09428191184998 1.99389576911926
    2.01061391830444 1.99682581424713 1.00654804706573 5.11483001708984
    2.97628593444824 0.972916424274445 3.01517724990845 0 1.93750941753387
    1.98467373847961 0.97946172952652 4.96168422698975 1.00804150104523
    2.00764346122742 3.00924181938171 2.03571534156799 0 1.97697377204895
    5.92517423629761 4.04617357254028 1.98419070243835 0.974544525146484
    2.94617176055908 0.928169369697571 2.04030013084412 2.96833968162537
    2.00369620323181 7.13391017913818 2.97701072692871 2.09482002258301
    2.96689939498901 2.00172829627991 2.9539999961853 0.962578475475311
    0.986573040485382 3.03162097930908 1.97123777866364 3.85395407676697
    0.993788361549377 2.97628593444824 0.987289845943451 2.01508641242981
    2.98646140098572 4.94003868103027 0 1.93245780467987 3.06735897064209
    4.95444822311401 2.01957869529724 4.06534004211426 2.89457035064697
    2.07826662063599 2.08464312553406 3.00776195526123 2.026606798172
    2.02358889579773 1.94908905029297 1.99194717407227 2.88978242874146
    1.99194717407227 5.77547073364258 4.00739240646362 4.87505340576172
    1.0028338432312 3.0627498626709 8.13473606109619 3.04066610336304
    3.07121014595032 4.15653324127197 2.01708054542542 1.99146056175232
    5.00309228897095 2.95971918106079 1.99292099475861 5.0302562713623
    0.965313732624054 4.00247383117676 4.08366632461548 4.00837755203247
    1.92288672924042 3.82054328918457 1.00928938388824 1.9924339056015
    4.15124225616455 1.97793292999268 2.99377226829529 0 1.97123777866364
    1.01481699943542 1.98177921772003 0 1.96364152431488 0 0 4.02718687057495
    2.00764346122742 3.08360052108765 3.9103307723999 2.01160621643066
    0.985618889331818 1.99438345432281 1.04285490512848 3.04900503158569
    3.05128741264343 0 2.97628593444824 1.95282387733459 1.03255319595337
    5.17456150054932 1.9793735742569 5.89802694320679 5.82915115356445
    4.07346487045288 0.978051781654358 1.98806130886078 1.01734960079193
    2.03419160842896 0.986573040485382 2.00962281227112 3.98876690864563
    2.00665497779846 1.96553516387939 2.97050261497498 3.00406765937805 0
    3.01592087745667 3.07894229888916 2.0220832824707 1.99584817886353
    2.01757979393005 2.93274807929993 1.02322280406952 5.04394960403442
    5.08801746368408 4.03615808486938 3.00185537338257 3.84758830070496
    5.03149795532227 0 2.04030013084412 2.03978967666626 2.96546077728271
    2.02862405776978 4.01528692245483 2.05314517021179 8.09033966064453
    1.00779223442078 2.94262742996216 0.993788361549377 3.06351685523987
    1.95095467567444 2.00025510787964 3.98681640625 0.994273126125336
    0.965085208415985 1.04875731468201 1.01582849025726 3.04672622680664
    3.88147568702698 6.13317918777466 1.99097430706024 2.97991228103638
    2.95971918106079 2.01957869529724 0 2.03165698051453 3.04596734046936
    1.00729429721832 0 2.97628593444824 4.95565271377563 4.86458206176758
    0.998902201652527 2.99964666366577 0.992820203304291 1.97362375259399
    1.00654804706573 3.95107316970825 3.04520916938782 1.99487149715424
    2.0526282787323 0.973381042480469 1.93383288383484 3.0566258430481
    0.961443364620209 4.07651996612549 2.98865079879761 0 2.92573189735413
    3.11343169212341 2.99964666366577 4.95926952362061 3.00628328323364
    2.95828723907471 0.971293747425079 3.10394906997681 2.94191932678223
    2.01458859443665 0.974078834056854 5.9467830657959 1.00953936576843
    1.94908905029297 1.99389576911926 2.01259922981262 1.95986533164978
    2.04644560813904 2.95471358299255 2.07035040855408 4.94243431091309
    1.00110995769501 1.96506142616272 5.7254490852356 2.98938155174255
    2.9974410533905 3.93107032775879 0.983241617679596 1.06492161750793
    2.9518609046936 1.98129761219025 6.99574375152588 1.05336427688599> [ a1 f2
    78 3f e2 b8 f9 3f 44 4f c9 40 32 30 82 3f 00 00 00 00 fc 70 7a 40 65 16 a1
    40 b0 13 85 3f 00 00 00 00 90 fd 42 40 24 61 fc 3f 8e a3 40 40 19 6a 78 40
    05 a5 82 3f c6 3c f7 3f 4e 60 3d 40 2c c4 83 40 00 00 00 00 7e 34 80 3f 5c
    af 7c 3f 00 00 00 00 0a ca 3f 40 6c d2 db 40 09 6d 00 40 c5 8f fa 3f 3e 93
    43 40 48 f8 ff 3f 9a 8f 3b 40 06 8b 79 40 af 77 83 3f e6 ad 80 40 02 5b e1
    40 fb 99 07 40 b7 08 06 40 fa 37 ff 3f e6 ad 00 40 fd 97 ff 3f 91 d6 80 3f
    b0 ac a3 40 78 7b 3e 40 0d 11 79 3f aa f8 40 40 00 00 00 00 4f 00 f8 3f ca
    09 fe 3f 01 be 7a 3f 1e c6 9e 40 81 07 81 3f 3b 7d 00 40 6b 97 40 40 29 49
    02 40 00 00 00 00 7a 0d fd 3f 07 9b bd 40 41 7a 81 40 f6 f9 fd 3f c0 7b 79
    3f 14 8e 3c 40 82 9c 6d 3f 47 94 02 40 47 f9 3d 40 8f 3c 00 40 fe 48 e4 40
    58 87 3e 40 88 11 06 40 ae e1 3d 40 51 1c 00 40 56 0e 3d 40 8b 6b 76 3f 0d
    90 7c 3f 14 06 42 40 85 51 fc 3f 2f a7 76 40 ea 68 7e 3f 78 7b 3e 40 07 bf
    7c 3f 2d f7 00 40 2f 22 3f 40 cc 14 9e 40 00 00 00 00 c7 5a f7 3f 9c 4f 44
    40 d7 8a 9e 40 c7 40 01 40 44 17 82 40 a4 40 39 40 52 02 05 40 cb 6a 05 40
    2c 7f 40 40 ed b3 01 40 7b 82 01 40 c0 7b f9 3f 20 f8 fe 3f 32 f2 38 40 20
    f8 fe 3f a8 d0 b8 40 8f 3c 80 40 70 00 9c 40 dc 5c 80 3f 18 04 44 40 e1 27
    02 41 46 9a 42 40 b5 8e 44 40 52 02 85 40 d9 17 01 40 2e e8 fe 3f 55 19 a0
    40 0a 6c 3d 40 09 18 ff 3f dc f7 a0 40 cd 1e 77 3f 44 14 80 40 65 ad 82 40
    a1 44 80 40 27 21 f6 3f c8 83 74 40 65 30 81 3f 13 08 ff 3f fa d6 84 40 e8
    2c fd 3f f7 99 3f 40 00 00 00 00 85 51 fc 3f 86 e5 81 3f f1 aa fd 3f 00 00
    00 00 9b 58 fb 3f 00 00 00 00 00 00 00 00 b7 de 80 40 3b 7d 00 40 b6 59 45
    40 dc 42 7a 40 28 be 00 40 85 51 7c 3f f5 47 ff 3f 45 7c 85 3f e6 22 43 40
    4b 48 43 40 00 00 00 00 78 7b 3e 40 22 f6 f9 3f b4 2a 84 3f 02 96 a5 40 1d
    5c fd 3f a3 bc bc 40 68 88 ba 40 d3 59 82 40 9a 61 7a 3f cb 78 fe 3f 83 38
    82 3f 32 30 02 40 0d 90 7c 3f a9 9d 00 40 f5 47 7f 40 09 6d 00 40 a8 96 fb
    3f b7 1c 3e 40 a5 42 40 40 00 00 00 00 d9 04 41 40 64 0d 45 40 d0 69 01 40
    f4 77 ff 3f 07 20 01 40 25 b2 3b 40 f7 f8 82 3f 09 68 a1 40 0a d1 a2 40 35
    28 81 40 66 1e 40 40 e3 3e 76 40 08 02 a1 40 00 00 00 00 47 94 02 40 ea 8b
    02 40 1c ca 3d 40 fa d4 01 40 3b 7d 80 40 bb 66 03 40 08 72 01 41 56 ff 80
    3f 02 54 3c 40 ea 68 7e 3f a9 10 44 40 e2 b8 f9 3f 2e 04 00 40 00 28 7f 40
    af 88 7e 3f d3 0f 77 3f ae 3d 86 3f ab 06 82 3f 90 fd 42 40 19 6a 78 40 01
    43 c4 40 3f d8 fe 3f e2 b6 3e 40 0a 6c 3d 40 c7 40 01 40 00 00 00 00 ab 06
    02 40 21 f1 42 40 05 ef 80 3f 00 00 00 00 78 7b 3e 40 b5 94 9e 40 a8 aa 9b
    40 0e b8 7f 3f 36 fa 3f 40 77 29 7e 3f b4 9f fc 3f 91 d6 80 3f 62 de 7c 40
    b5 e4 42 40 f3 57 ff 3f 43 5e 03 40 80 2f 79 3f d6 87 f7 3f c2 9f 43 40 27
    21 76 3f da 72 82 40 0e 46 3f 40 00 00 00 00 31 3f 3b 40 77 42 47 40 36 fa
    3f 40 56 b2 9e 40 f2 66 40 40 94 54 3d 40 b5 a6 78 3f 1a a7 46 40 68 48 3c
    40 05 ef 00 40 3b 5d 79 3f 0c 4c be 40 96 38 81 3f c0 7b f9 3f fa 37 ff 3f
    6d ce 00 40 de dc fa 3f f7 f8 02 40 07 1a 3d 40 9f 80 04 40 6c 28 9e 40 5f
    24 80 3f 22 87 fb 3f e1 36 b7 40 07 52 3f 40 13 d6 3f 40 a8 96 7b 40 b9 b5
    7b 3f 5a 4f 88 3f 4a eb 3c 40 29 9b fd 3f 22 dd df 40 a4 d4 86
    3f][LARGE_DATA_BLOCK  f4 x 427169400 ] |6.2.1.3 <DataType>
    root::ImageList::::ImageData::DataType 4 Bytes   5V 4x1 <2> [ 02 00 00 00]
    +6.2.1.4 [Dimensions] 115 (3) root::ImageList::::ImageData::Dimensions
    |6.2.1.4.1 <> root::ImageList::::ImageData::Dimensions:: 4 Bytes   5V 4x1
    <3838> [ fe 0e 00 00] |6.2.1.4.2 <>
    root::ImageList::::ImageData::Dimensions:: 4 Bytes   5V 4x1 <3710> [ 7e 0e
    00 00] |6.2.1.4.3 <> root::ImageList::::ImageData::Dimensions:: 4 Bytes   5V
    4x1 <30> [ 1e 00 00 00]
=cut

use strict;
use warnings;
use YAML;
use Compress::Zlib;
use POSIX;

my $filename      = '';
my $dumpPNG       = 0;
my $dumpthumbnail = 0;
my $dumpMRC       = 0;
if ( @ARGV == 0 )
{
  die "#
Need exactly one dm4 file as input:
perl dumpDM4.pl 0000.dm4 >log.txt

To also dump the saved thumbnail:
perl dumpDM4.pl 0000.dm4 --dumpthumbnail >log.txt

To dump the image or image slices:
perl dumpDM4.pl 0000.dm4 --dumpPNG >log.txt
";
}
#####interpret args########
if ( @ARGV > 0 )
{
  foreach my $arg (@ARGV)
  {
    if ( $arg =~ /\.dm4$/i and -e $arg ) { $filename = $arg; }
    if ( $arg eq '--dumpPNG' )       { $dumpPNG       = 1; }
    if ( $arg eq '--dumpthumbnail' ) { $dumpthumbnail = 1; }
    if ( $arg eq '--dumpMRC' )       { $dumpMRC       = 1; }
  }
}
####real work starts now####
open my $fh, "<", $filename or die "$filename not found!\n\n";
my $ver = -1;
if ( ( $ver = read_i4be($fh) ) ne 4 )
{
  die "$filename does not contain a DM4 format tag \n\n";
}
else { print "Version: DM $ver\n"; }

my $rootlen = read_i8be($fh);
print "Size of root tag directory in bytes = $rootlen\n";

my $byteord = read_i4be($fh);
print "Byte order: $byteord ";
if ( $byteord == 0 )
{
  print "(Big Endian)\n!!!this program does not try to read Big Endian image data!!!\n!!!The dump image functions are now deactivated!!!\n";
  $dumpPNG       = 0;
  $dumpthumbnail = 0;
  $dumpMRC       = 0;
}
else { print "(Little Endian)\n"; }

my $sortf  = read_i1($fh);
my $closef = read_i1($fh);
my $ntags  = read_i8be($fh);

my %tag;    # the data hash
my %important_inf;

$tag{ '0_root' }{ '$sortf' }  = $sortf;
$tag{ '0_root' }{ '$closef' } = $closef;
$tag{ '0_root' }{ 'ntags' }   = $ntags;

foreach my $i ( 1 .. $ntags )
{
  readroottag( $fh, \%tag, $i );
}

detect_image( \%tag );

savethumbnail( $filename, $fh, \%tag ) if $dumpthumbnail == 1;
save_image( $filename, $fh, \%tag ) if $dumpPNG == 1;
to_MRC( $filename, $fh, \%tag ) if $dumpMRC == 1;

close $fh;

open my $fh_YAML, ">", "$filename.YAML";

print $fh_YAML Dump( \%tag );
close $fh_YAML;

##############################end of main program##############################

##############################

sub readroottag
{
  my ( $fh, $tag_href, $s ) = (@_);

  #  my $pointer=tell $fh;
  #  print "current offset in file: $pointer";

  my $tag   = read_i1($fh);
  my $s_tag = "root";
  if ( $tag == 0 )  { return 0; }                                      #EOF
  if ( $tag == 20 ) { read_dir( $fh, $tag_href, $s_tag, 1, "$s" ); }
  if ( $tag == 21 ) { read_tag( $fh, $tag_href, $s_tag, 1, "$s" ); }

}

##################3

=head1

Tag directories contain zero or more tags and/or other tag directories

Tag directory structure
  tag       i1      tag = 14h (20), identifies tag directory
  ltname    i2be    tag name length in bytes, may be 0
  tname     a       tag name (length ltname), may be absent
  tlen      i8be    total bytes in tag directory including all sub-directories (new for DM4)
  sortf     i1      Sorted, 1 = sorted (mostly = 1)
  closef    i1      Closed, 1 = open (normally = 0)
  ntags     i8be    Number of tags in tag directory. Can be 0 (in which case tlen = 10)

#
Overall tag structure
  tag         i1           tag = 15h (21), identifies tag
  ltname      i2be         tag name length in bytes, may be 0
  tname       a            tag name (length ltname), may be absent
  tlen        i8be         total bytes in tag including %%%% (new for DM4)
  %%%%        a4           string "%%%%"
  ninfo       i8be         size of info array following
  info(ninfo) ninfo*i8be   array of ninfo integers,
                           contains tag data type(s) for tag values
                           info(1) = tag data type (see tag data types below)
  <values>    xx*          tag values (byte order set by byte order flag)
                           byte lengths specified in info(ninfo)



=cut

sub read_dir
{
  my ( $fh, $tag_href, $parent, $level, $s ) = (@_);
  my $tag    = 20;
  my $ltname = read_i2be($fh);
  my $tname  = read_str( $fh, $ltname );
  my $tlen   = read_i8be($fh);
  my $sortf  = read_i1($fh);
  my $closef = read_i1($fh);
  my $ntags  = read_i8be($fh);

  my $s_tag = "$parent::$tname";

  $tag_href->{ $s }{ 'tag' }    = $tag;
  $tag_href->{ $s }{ 'ltname' } = $ltname;
  $tag_href->{ $s }{ 'tname' }  = $tname;
  $tag_href->{ $s }{ 'tlen' }   = $tlen;
  $tag_href->{ $s }{ 'sortf' }  = $sortf;
  $tag_href->{ $s }{ 'closef' } = $closef;
  $tag_href->{ $s }{ 'ntags' }  = $ntags;
  $tag_href->{ $s }{ 'parent' } = $parent;
  $tag_href->{ $s }{ 'serial' } = $s;
  $tag_href->{ $s }{ 'path' }   = $s_tag;

  print ' ' x $level, "+$s [$tname] $tlen bytes $ntags tags $s_tag\n";
  if ( $ntags > 0 )
  {
    for my $i ( 1 .. $ntags )
    {
      my $next_tag = read_i1($fh);
      if ( $next_tag == 0 ) { return; }    #EOF
      elsif ( $next_tag == 20 )
      {
        read_dir( $fh, $tag_href, $s_tag, $level + 1, "$s.$i" );
      }                                    #EOF
      elsif ( $next_tag == 21 )
      {
        read_tag( $fh, $tag_href, $s_tag, $level + 1, "$s.$i" );
      }                                    #EOF
      else { print printhex($next_tag); }  #some error must have occured
    }
  }

}

sub read_tag
{
  my ( $fh, $tag_href, $parent, $level, $s ) = (@_);
  my $tag    = 21;
  my $ltname = read_i2be($fh);
  my $tname  = read_str( $fh, $ltname );
  my $s_tag  = "$parent::$tname";

  my $tlen       = read_i8be($fh);
  my $mark       = read_str( $fh, 4 );               #the %%%%
  my $ninfo      = read_i8be($fh);
  my $info       = read_str( $fh, 8 * $ninfo );
  my @info_array = unpack( 'Q>' x $ninfo, $info );
  my $datalen    = $tlen - 4 - 8 - 8 * $ninfo;       # 1+$ltname+$tlen =record size. tlen-%%%%-8(ninfo)-8*ninfo=datasize

  my @datatype;
  my @datatype_count;
  my $ngroup;
  my $narray = 0;
  my $data_class;                                    #not actually used
  if ( $ninfo == 1 ) { $datatype[ 0 ] = $info_array[ 0 ]; $narray = 1; $data_class = 'single'; }    #simple single value
  elsif ( $ninfo > 1 )
  {

    if ( $ninfo == 3 and $info_array[ 0 ] == 20 and $info_array[ 1 ] != 15 )                        #array
    {

      $data_class    = 'array';
      $datatype[ 0 ] = $info_array[ 1 ];
      $narray        = $info_array[ 2 ];
    }
    elsif ( $info_array[ 0 ] == 15 )                                                                # group of data(struct)
    {
      $data_class = 'struct_single';
      $ngroup     = $info_array[ 2 ];
      $narray     = 1;
      foreach my $j ( 1 .. $ngroup )
      {
        $datatype[ $j - 1 ] = $info_array[ $j * 2 + 2 ];
      }
    }
    elsif ( $info_array[ 0 ] == 20 and $info_array[ 1 ] == 15 )                                     #array of groups
    {
      $data_class = 'struct_array';
      $ngroup     = $info_array[ 3 ];
      $narray     = $info_array[ $ninfo - 1 ];
      foreach my $j ( 1 .. $ngroup )
      {
        $datatype[ $j - 1 ] = $info_array[ $j * 2 + 3 ];
      }
    }
  }

  my ( $form, $unit_size ) = form_gen(@datatype);

  my $units = 0;
  $units = $datalen / $unit_size if $unit_size > 0;
  if ( $units != $narray and $units != 0 )
  {
    print "!!Warning!! The calculated data units ($units) != number of units recorded in file ($narray)!\n";
  }    #extra check, shouldn't be necessary

  my $data        = '';
  my $data_offset = tell($fh);
  my $data_flag   = 0;
  if ( $datalen <= 1024 * 1024 )
  {
    $data = read_str( $fh, $datalen );
  }
  else
  {
    $data = read_str( $fh, 1024 );
    seek( $fh, ( $datalen - 1024 ), 1 );
  }

  my $types      = '';
  my $data_trans = '';
  my $data_ascii = '';
  my $hexdata    = '';
  print ' ' x $level, "|$s '$s_tag' $datalen bytes $data_class |",, @datatype, "|$form ${unit_size}x$units $narray";

  #only print if data is less than 10K
  if ( $datalen <= 1024 )
  {
    $data_trans = join ' ', unpack( '(' . $form . ')*', $data );

    if ( $datatype[ 0 ] == 10 or $datatype[ 0 ] == 4 ) { $data_ascii = printascii($data); }
    $hexdata = printhex($data);
    print "<$data_trans> ($data_ascii) [ $hexdata]";
  }
  else
  {
    my $data_head = substr( $data, 0, 256 );
    $data_trans = join ' ', unpack( '(' . $form . ')*', $data_head );
    $data_ascii = printascii($data_head);
    $hexdata    = printhex($data_head);

    print "[first 256 bytes:] <$data_trans> ($data_ascii) [ $hexdata]";
    print "\n                 [LARGE_DATA_BLOCK  $form$unit_size x $units ]";
  }
  print "\n";

  $tag_href->{ $s }{ 'data_translated' } = $data_trans;
  $tag_href->{ $s }{ 'data_format' }     = join " ", @datatype, "$form ${unit_size}x$units ";
  $tag_href->{ $s }{ 'data' }            = $hexdata;
  $tag_href->{ $s }{ 'tag' }             = $tag;
  $tag_href->{ $s }{ 'ltname' }          = $ltname;
  $tag_href->{ $s }{ 'tname' }           = $tname;
  $tag_href->{ $s }{ 'tlen' }            = $tlen;
  $tag_href->{ $s }{ 'serial' }          = $s;
  $tag_href->{ $s }{ 'ninfo' }           = $ninfo;
  $tag_href->{ $s }{ 'info' }            = printhex($info);
  $tag_href->{ $s }{ 'parent' }          = $parent;
  $tag_href->{ $s }{ 'path' }            = $s_tag;
  $tag_href->{ $s }{ 'data_ascii' }      = $data_ascii;

  $tag_href->{ $s }{ 'data_offset' } = $data_offset;
  $tag_href->{ $s }{ 'data_len' }    = $datalen;

  if ( $s_tag =~ /^root::ImageList/ )
  {

    if ( $s_tag eq 'root::ImageList::' )
    {
      $tag_href->{ '0_datablocks' }{ $s_tag }{ 'tag' } = $s;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageData::Data' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'data_entry' }  = $s;
      $tag_href->{ '0_datablocks' }{ $ID }{ 'data_format' } = $tag_href->{ $s }{ 'data_format' };
      $tag_href->{ '0_datablocks' }{ $ID }{ 'info' }        = $tag_href->{ $s }{ 'info' };
      $tag_href->{ '0_datablocks' }{ $ID }{ 'data_offset' } = $data_offset;
      $tag_href->{ '0_datablocks' }{ $ID }{ 'data_len' }    = $datalen;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Device::Name' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Device::Name' } = $data_ascii;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Frame::Intensity::Range::Saturation Level (counts)' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Frame::Intensity::Range::Saturation Level (counts)' } = $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Frame::Sequence::Exposure Time (ns)' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Frame::Sequence::Exposure Time (ns)' } = $data_trans;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Parameters::High Level::Continuous Readout' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Parameters::High Level::Continuous Readout' } = $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Parameters::High Level::Binning' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Parameters::High Level::Binning' } = $data_trans;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Device::Active Size (pixels)' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Device::Active Size (pixels)' } = $data_trans;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Frame::CCD::Pixel Size (um)' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Acquisition::Frame::CCD::Pixel Size (um)' } = $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageData::PixelDepth' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'PixelDepth' } = $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageData::Dimensions::' )
    {
      my $ID = substr( $s, 0, 3 );
      push @{ $tag_href->{ '0_datablocks' }{ $ID }{ 'Dimesions' } }, $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageData::Calibrations::Dimension::::Scale' )
    {
      my $ID = substr( $s, 0, 3 );
      push @{ $tag_href->{ '0_datablocks' }{ $ID }{ 'Scale' } }, $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Parameters::Detector::width' )
    {
      my $ID = substr( $s, 0, 3 );
      push @{ $tag_href->{ '0_datablocks' }{ $ID }{ 'Detector_width' } }, $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Acquisition::Parameters::Detector::height' )
    {
      my $ID = substr( $s, 0, 3 );
      push @{ $tag_href->{ '0_datablocks' }{ $ID }{ 'Detector_height' } }, $data_trans;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Microscope Info::Voltage' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Microscope Info::Voltage' } = $data_trans;
    }

    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Microscope Info::Actual Magnification' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Microscope Info::Actual Magnification' } = $data_trans;
    }
    elsif ( $s_tag eq 'root::ImageList::::ImageTags::Microscope Info::Indicated Magnification' )
    {
      my $ID = substr( $s, 0, 3 );
      $tag_href->{ '0_datablocks' }{ $ID }{ 'Microscope Info::Indicated Magnification' } = $data_trans;
    }

  }
}

sub form_gen
{    #generates unpacking format strings
  my (@dataform) = (@_);
  my %type_table   = ( 2, 's', 3, 'i', 4, 'v', 5, 'V', 6, 'f', 7, 'd', 8, 'C', 9, 'A', 10, 'C', 11, 'Q', 18, 'A' );
  my %sizeof_table = ( 2, 2,   3, 4,   4, 2,   5, 4,   6, 4,   7, 8,   8, 1,   9, 1,   10, 1,   11, 8,   18, 1 );
  my $form         = '';
  my $size         = 0;
  foreach my $i (@dataform)
  {
    if ( $type_table{ $i } )
    {
      $form .= $type_table{ $i };
      $size += $sizeof_table{ $i };
    }
  }

  return ( $form, $size );

}

sub read_str    #read int4 big endian and convert to number
{
  my ( $fh, $len ) = (@_);
  my $buffer;
  read( $fh, $buffer, $len );

  return $buffer;
}

sub read_i1     #read int4 big endian and convert to number
{
  my ($fh) = (@_);
  my $buffer;
  read( $fh, $buffer, 1 );
  my $int_value = unpack( 'C', $buffer );
  return $int_value;
}

sub read_i2be    #read int4 big endian and convert to number
{
  my ($fh) = (@_);
  my $buffer;
  read( $fh, $buffer, 2 );
  my $int_value = unpack( 'S>', $buffer );
  return $int_value;
}

sub read_i4be    #read int4 big endian and convert to number
{
  my ($fh) = (@_);
  my $buffer;
  read( $fh, $buffer, 4 );
  my $int_value = unpack( 'N', $buffer );

  return $int_value;
}

sub read_i8be    #read int8 big endian and convert to number
{
  my ($fh) = (@_);
  my $buffer;
  read( $fh, $buffer, 8 );
  my $int_value = unpack( 'Q>', $buffer );

  return $int_value;
}

sub printhex
{

  my ($str) = @_;
  $str =~ s/(.)/sprintf("%02x ",ord($1))/seg;
  $str =~ s/ $//;
  return "$str";

}

sub printascii
{

  my ($str) = @_;
  my @s = ( split '', $str );
  my $r = '';
  foreach my $c (@s)
  {
    if   ( $c gt ' ' and $c le '~' ) { $r .= $c; }
    else                             { $r .= ' '; }
  }
  return $r;

}

sub write_thumbnail_to_PNG
{    #specially for DM4 thumnails...the alpha channels are all 00 which need to be inverted
  my ( $fn, $data, $w, $h ) = (@_);

  my @bytes = split( '', $data );
  my $size = scalar @bytes;
  if ( $size != 4 * $w * $h )
  {
    print "This file does not store thumnail in RGBA, please check: Bytes:$size, W: $w, H: $h \n";
    print( printhex( substr( $data, 0, 32 ) ) );
    print "\n";
    return;
  }
  my $check_alpha = 0;
  my $check_RGB   = 0;
  foreach my $i ( 0 .. $#bytes )
  {
    if ( $i % 4 == 3 )
    {
      if ( ord( $bytes[ $i ] ) != 0 ) { $check_alpha = -1; }
    }
    if ( $i % 4 == 1 )
    {
      if ( $bytes[ $i - 1 ] ne $bytes[ $i ] or $bytes[ $i ] ne $bytes[ $i + 1 ] ) { $check_RGB = -1; }
    }
  }
  if ( $check_alpha == 0 and $check_RGB == 0 )
  {    #typical RGBA grayscale thumnail, can invert the alpha,change to grayscale and send.
    my $pngstr = '';
    foreach my $i ( 0 .. $#bytes )
    {
      if ( $i % 4 == 0 ) { $pngstr .= $bytes[ $i ]; }
    }
    my $dl = length $pngstr;
    print "=====writing thumbnail $dl bytes, $w x $h 8-bit grayscale to PNG=====\n";
    write_PNG( $fn, $pngstr, $w, $h, 8, 0 );
  }
  elsif ( $check_alpha == 0 and $check_RGB != 0 )
  {    #color RGBA PNG, just invert the alpha
    my $pngstr = '';
    foreach my $i ( 0 .. $#bytes )
    {
      if ( $i % 4 == 3 ) { $bytes[ $i ] = chr(255); }
      $pngstr .= $bytes[ $i ];
    }
    my $dl = length $pngstr;

    print "=====writing thumbnail $dl bytes, $w x $h x4 to RGBA PNG=====\n";
    write_PNG( $fn, $pngstr, $w, $h, 8, 6 );
  }
  else { print "The thumbnail in this DM4 is not RGBA, please check: ["; printhex( substr( $data, 0, 32 ) ); print "]\n"; return; }
}

sub stat_image
{

  my ($aref) = (@_);

  my ( $min, $max, $dev, $maxdev, $mindev, $meandev, $mean ) = ( $aref->[ 0 ], $aref->[ 0 ], 0, 0, 0, 0, 0 );
  my $rms   = 0;
  my $total = scalar @{ $aref };

  my @count = (0) x 65536;
  foreach my $a ( @{ $aref } )
  {
    $min = $min < $a ? $min : $a;
    $max = $max > $a ? $max : $a;
    $mean += $a / $total;

    my $floor = floor($a);
    $dev = ( $a - $floor ) > 0.5 ? $floor - $a + 1 : $a - $floor;
    my $nearint = ( $a - $floor ) > 0.5 ? $floor + 1 : $floor;

    $maxdev = $maxdev > $dev ? $maxdev : $dev;
    $mindev = $mindev < $dev ? $mindev : $dev;
    $meandev += $dev / $total;
    $count[ $nearint ]++;
  }

  foreach my $i ( int($min) .. int($max) + 1 ) { print "$i\t$count[$i]\n"; }
  my $rmssum = 0;
  foreach my $a ( @{ $aref } )
  {
    $rmssum += ( $a - $mean ) * ( $a - $mean );
  }
  $rms = sqrt( $rmssum / $total );

  return ( $min, $max, $dev, $maxdev, $mindev, $meandev, $mean, \@count, $rms );
}

sub detect_image
{
  my ($tag_href) = (@_);
  my @datablocks = keys( %{ $tag_href->{ '0_datablocks' } } );
  foreach my $data_b (@datablocks)
  {
    my @tags      = keys( %{ $tag_href->{ '0_datablocks' }{ $data_b } } );
    my $arraytype = 'thumbnail';
    foreach my $t (@tags)
    {
      if ( $t =~ /^Acquisition/ )
      {
        $arraytype = 'image';
        last;
      }
    }
    $tag_href->{ '0_datablocks' }{ $data_b }{ 'type' } = $arraytype;
  }
}

sub savethumbnail
{
  my ( $fn, $fh, $tag_href ) = (@_);
  my @datablocks = keys( %{ $tag_href->{ '0_datablocks' } } );
  foreach my $data_b (@datablocks)
  {
    my $arraytype = $tag_href->{ '0_datablocks' }{ $data_b }{ 'type' };
    if ( $arraytype eq 'thumbnail' )
    {

      my $offset  = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_offset' };
      my $datalen = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_len' };

      my $datastr;
      my ( $w, $h ) = ( $tag_href->{ '0_datablocks' }{ $data_b }{ 'Dimesions' }[ 0 ], $tag_href->{ '0_datablocks' }{ $data_b }{ 'Dimesions' }[ 1 ] );

      seek( $fh, $offset, 0 );
      read( $fh, $datastr, $datalen );
      my $sl = length $datastr;
      if ( $w * $h * 4 != $sl )
      {
        print " \n\nstring length $sl != $w x $h x 4)\n";
        return;
      }
      write_thumbnail_to_PNG( "$fn.thumbnail.png", $datastr, $w, $h );
    }
  }
}

sub save_image
{
  my ( $fn, $fh, $tag_href ) = (@_);

  my %type_table   = ( 2, 's', 3, 'i', 4, 'v', 5, 'V', 6, 'f', 7, 'd', 8, 'C', 9, 'A', 10, 'C', 11, 'Q', 18, 'A' );
  my %sizeof_table = ( 2, 2,   3, 4,   4, 2,   5, 4,   6, 4,   7, 8,   8, 1,   9, 1,   10, 1,   11, 8,   18, 1 );

  my @datablocks = keys( %{ $tag_href->{ '0_datablocks' } } );

  foreach my $data_b (@datablocks)
  {
    my $arraytype = $tag_href->{ '0_datablocks' }{ $data_b }{ 'type' };
    if ( $arraytype eq 'image' )
    {
      my @dimensions = @{ $tag_href->{ '0_datablocks' }{ $data_b }{ 'Dimesions' } };
      my $offset     = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_offset' };
      my $datalen    = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_len' };
      my ( $w, $h ) = ( $dimensions[ 0 ], $dimensions[ 1 ] );
      my $slices = 1;
      if ( scalar(@dimensions) == 3 ) { $slices = $dimensions[ 2 ]; }
      my $datatype = substr( $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_format' }, 0, 1 );
      my $datasize = $sizeof_table{ $datatype };

      my $fmtchar = $type_table{ $datatype };
      if ( $datasize * $w * $h * $slices != $datalen )
      {
        print "Error! The image array size $datalen != $w x $h x $slices $datasize \n";
        return;
      }
      else { print "The image array size $datalen == $w x $h x $slices x $datasize ($fmtchar)\n"; }

      seek( $fh, $offset, 0 );
      my $datastr  = '';
      my $slicelen = $datalen / $slices;
      my ( $min, $max, $dev, $maxdev, $mindev, $meandev, $mean, $count_ref, $rms );

      #  my @frame_bin;
      foreach my $s ( 1 .. $slices )
      {

        read( $fh, $datastr, $slicelen );
        my @data_array = unpack( "($fmtchar)*", $datastr );
        if ( $s == 1 )
        {
          print "\nGenerating stats from slice #$s\n";
          ( $min, $max, $dev, $maxdev, $mindev, $meandev, $mean, $count_ref, $rms ) = stat_image( \@data_array );
          print "min $min, max $max, mean $mean, rms $rms\ndeviation to integers: dev-int $dev, maxdev-int $maxdev, mindev-int $mindev, meandev-int $meandev\n";
        }

        if ( $slices == 1 )
        {    #CCD
          my ( $imagestr, $badpixels ) = processCCD_data( \@data_array, $mean, $rms, $w, $h );
          write_PNG( "$fn.png",           $imagestr,  $w, $h, 8, 0 );
          write_PNG( "$fn.badpixels.png", $badpixels, $w, $h, 8, 0 );

        }
        else
        {    #DDD

          my ( $imagestr, $badpixels ) = processDDD_data( \@data_array, $mean, $rms, $w, $h );

          my $fns = $fn . '.' . sprintf( "%02d", $s );
          write_PNG( "$fns.png",           $imagestr,  $w, $h, 8, 0 );
          write_PNG( "$fns.badpixels.png", $badpixels, $w, $h, 8, 0 );

          my $bin = 4;
          my ( $imagestr_2bin, $bin_aref ) = binning( $imagestr, $w, $h, $bin );

          write_PNG( "$fns" . 'bin' . $bin . 'x' . $bin . ".png", $imagestr_2bin, int( $w / $bin ), int( $h / $bin ), 8, 0 );

        }

      }    #slice loop ends

      #            my @all_frame_binsum=(0)x(int($w/4)*int($h/4));
      #            my $sumstr='';
      #            foreach my $i (0..int($w/4)*int($h/4)-1){
      #                foreach my $s (1..$slices){                    $all_frame_binsum[$i]+=${$frame_bin[$s]}->[$i]; }
      #                    $all_frame_binsum[$i]=int($all_frame_binsum[$i]/15);
      #                    $all_frame_binsum[$i]=$all_frame_binsum[$i]>255?255:$all_frame_binsum[$i];
      #                    $sumstr.=chr($all_frame_binsum[$i]);
      #            }
      #            write_PNG("sumbin4.png",$sumstr,int($w/4),int($h/4),8,0);

    }    #if.. 'image'
  }
}

sub processCCD_data
{
  my ( $aref, $mean, $rms, $w, $h ) = (@_);
  my $rtnstr    = '';
  my $badpixels = '';
  my $cutoff    = $rms * 6;
  my $lowend    = $mean - $cutoff;
  my $highend   = $mean + $cutoff;
  my $scale     = 127 / $cutoff;
  my $datasize  = scalar( @{ $aref } );
  my $badcount  = 0;
  foreach my $i ( 0 .. $datasize - 1 )
  {
    my $bad   = chr(127);
    my $value = 0;
    if ( $aref->[ $i ] < $mean + $cutoff and $aref->[ $i ] > $mean - $cutoff ) { $value = $aref->[ $i ] - $lowend; }
    else
    {
      $badcount++;
      $bad = $aref->[ $i ] < $mean - $cutoff ? chr(0) : chr(255);
      my $c = 0;
      $value = 0;
      my @n = ( $i - 1, $i + 1, $i - $w, $i + $w, $i - $w - 1, $i + $w - 1, $i - $w + 1, $i + $w + 1 );
      foreach my $j (@n)
      {
        if ( $j >= 0 and $j < $datasize and abs( $aref->[ $j ] - $mean ) < $cutoff )
        {
          $c++;
          $value += $aref->[ $j ];

        }
      }
      if   ( $c != 0 ) { $value = $value / $c - $lowend; }
      else             { $value = $cutoff; print "!!large flare!!!\n"; }
    }
    my $scaled   = $value * $scale;
    my $intvalue = int($scaled);

    if ( $intvalue > 255 ) { print "!!!$aref->[$i] $value $scaled $intvalue\n"; }
    $rtnstr .= chr($intvalue);

    $badpixels .= $bad;
  }
  if ( length $rtnstr != $datasize ) { print "!!!!!!!!!!!!!!!111"; }
  print("\n[$badcount] pixels are over 6-rms off the mean\n");
  return ( $rtnstr, $badpixels );
}

sub processDDD_data
{
  ##ddd images are unlikely to have very high readings. many pixels would have 0 readings. So there is no need to do a low cut off.
  #only high-cutoff is needed to remove flare pixels
  #6 rms is already quite generous
  #Round the numbers to nearest int
  #using floor() then test how far the value is from floor
  #although considering all numbers should be positive, int() should also work

  my ( $aref, $mean, $rms, $w, $h ) = (@_);
  my $rtnstr    = '';
  my $badpixels = '';
  my $cutoff    = $rms * 6;
  my $lowend    = $mean - $cutoff;
  my $highend   = $mean + $cutoff;
  my $scale     = 1;
  my $datasize  = scalar( @{ $aref } );
  my $badcount  = 0;
  foreach my $i ( 0 .. $datasize - 1 )
  {
    my $bad   = chr(0);
    my $value = 0;
    if ( $aref->[ $i ] < $mean + $cutoff ) { $value = $aref->[ $i ]; }
    else
    {
      $badcount++;
      $bad = chr(255);
      my $c = 0;
      $value = 0;
      my @n = ( $i - 1, $i + 1, $i - $w, $i + $w, $i - $w - 1, $i + $w - 1, $i - $w + 1, $i + $w + 1 );
      foreach my $j (@n)
      {
        if ( $j >= 0 and $j < $datasize and $aref->[ $j ] < $mean + $cutoff )
        {
          $c++;
          $value += $aref->[ $j ];
        }
      }
      if   ( $c != 0 ) { $value = $value / $c; }
      else             { $value = $mean; print "!!large flare!!!\n"; }
    }

    my $nearint = floor($value);
    if ( $value - $nearint > 0.5 ) { $nearint += 1; }

    #        my $intvalue=int($nearint);

    if ( $nearint > 255 ) { print "!!!$aref->[$i] $value $nearint\n"; }
    $rtnstr .= chr($nearint);

    $badpixels .= $bad;
  }
  if ( length $rtnstr != $datasize ) { print "!!!!!!!!!!!!!!!111"; }
  print("\n[$badcount] pixels are over 6-rms off the mean\n");
  return ( $rtnstr, $badpixels );
}

sub binning2x2
{
  my ( $imagestr, $w, $h ) = (@_);
  my $w2  = $w / 2;
  my $h2  = $h / 2;
  my $rtn = '';
  my $b   = 0;
  my @arr = split( '', $imagestr );
  foreach my $y ( 0 .. $h2 - 1 )
  {

    foreach my $x ( 0 .. $w2 - 1 )
    {
      $b =
        ord( $arr[ $y * 2 * $w + $x * 2 ] ) +
        ord( $arr[ $y * 2 * $w + $x * 2 + 1 ] ) +
        ord( $arr[ ( $y * 2 + 1 ) * $w + $x * 2 ] ) +
        ord( $arr[ ( $y * 2 + 1 ) * $w + $x * 2 + 1 ] );
      $rtn .= chr($b);

    }
  }
  return $rtn;
}

sub binning
{
  my ( $imagestr, $w, $h, $bin ) = (@_);
  my $w4  = int( $w / $bin );
  my $h4  = int( $h / $bin );
  my $rtn = '';
  my $b   = 0;
  my @arr = split( '', $imagestr );
  my @rtnval;
  foreach my $y ( 0 .. $h4 - 1 )
  {

    foreach my $x ( 0 .. $w4 - 1 )
    {
      $b = 0;
      foreach my $i ( 0 .. $bin - 1 )
      {
        foreach my $j ( 0 .. $bin - 1 )
        {
          $b += ord( $arr[ ( $y * $bin + $i ) * $w + $x * $bin + $j ] );
        }
      }
      push @rtnval, $b;
      if ( $b > 255 ) { $b = 255; }
      $rtn .= chr($b);

    }
  }
  return $rtn, \@rtnval;
}

##########functions for writing PNG######delete below if do not want to install Compress::zlib

sub write_PNG    #takes a pre-formatted string of data, pack into PNG,
{

  my ( $fn, $data, $x, $y, $bit, $mode ) = (@_);

  if ( !defined $mode ) { $mode = 0; }
  if ( !defined $bit )  { $bit  = 8; }    #should try always using 8... for simplicity
  if ( $bit == 0 ) { print "PNG file bit depth cannot be zero. PNG generation abortted for '$fn'. \n"; return; }    #something is wrong
  if ( $mode != 0 and $mode != 2 and $mode != 6 )
  {
    print "Can only handel PNG modes 0(grayscale) 2(RGB) 6(RGBA). PNG generation abortted for '$fn'. \n";
    return;
  }                                                                                                                 #something is wrong

  my $bpp = 0;                                                                                                      #byte per pixel
  if ( $mode == 0 ) { $bpp = 1 * $bit / 8; }                                                                        #GrayScale
  if ( $mode == 6 ) { $bpp = 4 * $bit / 8; }                                                                        #RGBA
  if ( $mode == 2 ) { $bpp = 3 * $bit / 8; }                                                                        #RGB
  my $dl = length $data;
  if ( $dl != $x * $y * $bpp ) { print "Error!! PNG array ($dl bytes) is not $x x $y x $bit\n No PNG will be written. \n"; return; }

  my $raw_data;

  foreach my $r ( 0 .. $y - 1 )
  {    #y-1..0 row, so no vertical inverting is attemped

    my $start = $r * $x * $bpp;
    my $rowstr = substr( $data, $start, $x * $bpp );

    $raw_data .= "\0" . join( '', $rowstr );
  }

  my $compressed_str = Compress::Zlib::compress( $raw_data, 9 );

  my $returnstr =
    chr(137) . "PNG\r\n\x1A\n" . png_pack( 'IHDR', pack( "NNCCCCC", $x, $y, $bit, $mode, 0, 0, 0 ) ) .    # bit 0 palette  bit 1 color bit 2 alpha: 00000111
    png_pack( 'IDAT', $compressed_str ) . png_pack( 'IEND', '' );

  open my $fh1, ">", $fn;
  print $fh1 $returnstr;
  close $fh1;

}

sub png_pack
{
  my ( $tag, $data ) = (@_);
  my $chunk = $tag . $data;
  my $crc   = Compress::Zlib::crc32($chunk);
  return ( pack( "N", length($data) ) . $chunk . pack( "N", $crc ) );
}

sub to_MRC    #this produces exactly what e2prod produces, but 30% faster---by not running stats on the data
{
  my ( $fn, $ifh, $tag_href ) = (@_);
  my %type_table   = ( 2, 's', 3, 'i', 4, 'v', 5, 'V', 6, 'f', 7, 'd', 8, 'C', 9, 'A', 10, 'C', 11, 'Q', 18, 'A' );
  my %sizeof_table = ( 2, 2,   3, 4,   4, 2,   5, 4,   6, 4,   7, 8,   8, 1,   9, 1,   10, 1,   11, 8,   18, 1 );

  my @datablocks = keys( %{ $tag_href->{ '0_datablocks' } } );
  foreach my $data_b (@datablocks)
  {
    my $arraytype = $tag_href->{ '0_datablocks' }{ $data_b }{ 'type' };
    if ( $arraytype eq 'image' )
    {
      my @dimensions = @{ $tag_href->{ '0_datablocks' }{ $data_b }{ 'Dimesions' } };
      my $offset     = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_offset' };
      my $datalen    = $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_len' };
      my ( $w, $h ) = ( $dimensions[ 0 ], $dimensions[ 1 ] );
      my $slices = 1;
      if ( scalar(@dimensions) == 3 ) { $slices = $dimensions[ 2 ]; }
      my $datatype = substr( $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_format' }, 0, 1 );
      my $datasize = $sizeof_table{ $datatype };
      my $apix     = $tag_href->{ '0_datablocks' }{ $data_b }{ 'Scale' }[ 0 ];                    #EM cameras have to be sqare or there will be a big problem

      my $fmtchar = $type_table{ $datatype };
      if ( $datasize * $w * $h * $slices != $datalen )
      {
        print "Error! The image array size $datalen != $w x $h x $slices $datasize \n";
        return;
      }
      else { print "The image array size $datalen == $w x $h x $slices x $datasize ($fmtchar)\n"; }

      seek( $fh, $offset, 0 );
      my @datastr = '' x $h;

      my $ofn = $fn;
      if   ( scalar(@dimensions) >= 3 ) { $ofn =~ s/\.dm4$/\.mrcs/i; }
      else                              { $ofn =~ s/\.dm4$/\.mrc/i; }

      open my $ofh, '>', $ofn;
      my $info = '';
      $info .= sprintf( "APIX: %.4f \0 Width: %d \0 Height: %d \0", $apix * 10, $w, $h );

      $info .= "Voltage: $tag_href->{ '0_datablocks' }{ $data_b }{ 'Microscope Info::Voltage' }";
      $info .= " \0";
      $info .=" Device: $tag_href->{ '0_datablocks' }{ $data_b }{ 'Acquisition::Device::Name' }";
      $info .= " \0";
      $info .= "Pixel Size (um): $tag_href->{ '0_datablocks' }{ $data_b }{ 'Acquisition::Frame::CCD::Pixel Size (um)' }";
      $info .= " \0";
      $info .=
        sprintf( "Exposure Time (s): %6.4f", $tag_href->{ '0_datablocks' }{ $data_b }{ 'Acquisition::Frame::Sequence::Exposure Time (ns)' } / 1000000000 );
      $info .= " \0";
      $info .= " Continuous Readout: $tag_href->{ '0_datablocks' }{ $data_b }{ 'Acquisition::Parameters::High Level::Continuous Readout' }";
      $info .= " \0";
      $info .= "Data bytes: $tag_href->{ '0_datablocks' }{ $data_b }{ 'data_len' } Data type: $tag_href->{ '0_datablocks' }{ $data_b }{ 'type' }";
      $info .= " \0";

      my $header_str = MRC_header_gen( $w, $h, $slices, $apix, $info );
      print $ofh $header_str;

      foreach my $s ( 1 .. $slices )
      {
        foreach my $line ( 0 .. $h - 1 )
        {
          read( $fh, $datastr[ $line ], $w * $datasize );

        }
        foreach my $line ( reverse( 0 .. $h - 1 ) )
        {

          print $ofh $datastr[ $line ];

        }

      }
      close $ofn;
    }
  }

}

sub MRC_header_gen
{
  my ( $x, $y, $z, $apix, $info ) = (@_);

  ####### prepare header  ################################
  my $header_block;
  my $mapmode = 2;
  my ( $nxstart, $nystart, $nzstart ) = ( -$x / 2, -$y / 2, -$z / 2 );
  my ( $mx, $my, $mz ) = ( $x, $y, $z );
  my ( $cellx, $celly, $cellz ) = ( $x * $apix * 10, $y * $apix * 10, $z * $apix * 10 );
  my ( $alpha, $beta, $gamma ) = ( 90, 90, 90 );
  my ( $min, $max, $mean, $rms ) = ( 0, 0, 0, 0 );
  my ( $ispg, $nsymbt ) = ( 0, 0 );

  my @header1_list = (
                       $x,     $y,     $z,    $mapmode, $nxstart, $nystart, $nzstart, $mx,  $my,  $mz,   $cellx, $celly,
                       $cellz, $alpha, $beta, $gamma,   1,        2,        3,        $min, $max, $mean, $ispg,  $nsymbt
  );

  my $head1 = "l l l l l l l l l l f f f f f f l l l f f f l l";

  $header_block = pack $head1, @header1_list;
  my $extra1 = "\0\0\0\0" x 25;

  #  my $extra1="\0\0\0\0\0\0\0\0MRCO";
  #my $nversion=20140;
  #my $extra2="\0\0\0\0"x22;
  my ( $orix, $oriy, $oriz ) = ( 0, 0, 0 );
  my $mapstr   = "MAP\0";
  my $machst   = "DA\0\0";
  my $nlabel   = 0;
  my $labelstr = $info . "\0" x ( 800 - length($info) );

  $header_block .= $extra1

    #             .pack('f',$nversion)
    #            .$extra2
    . pack( 'f f f', ( $orix, $oriy, $oriz ) ) . $mapstr . $machst . pack( 'f l', $rms, $nlabel ) . $labelstr;

  return $header_block;

}
