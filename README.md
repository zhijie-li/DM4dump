# DM4dump
Dump GATAN DM4 file information into human-readable format.

The DM4 file format is described in http://www.er-c.org/cbb/info/dmformat/#dm4 

This program will unpack the binary data saved in DM4 files and try to interpret a few most interesting entries such as image dimention, Angstromes per pixle (Apix), etc..
For now, data blocks that are larger than 10 MB will be simply skipped. This in most cases only affects two data blocks: the image thumbnail data block and the image/movies data block.


Syntax
DM4dump.pl xxxx.dm4 >dump.txt

The dump.txt lists the directory structure of the DM4 file. A numbering system is also printed so that each node in the DM4 file gets a unique identifier so future use.

This program will also dump the read information into a YAML file "xxxx.dm4.YAML" which contains the data hash constructed during the reading of the dm4 file. This hash does not use the same hiarachical structure as that in the original dm4 file. Each tag/directory in the orginal dm4 file is saved with its path to the root (the "parent" and "path" items, see example below). The aforementioned numbering system is used as the keys to uniquely identify each tag/directory.

For example:

6.2.1.1.2.3.1:
  data: 00 00 00 00
  data_format: '6 f 4x1 '
  data_translated: 0
  info: 00 00 00 00 00 00 00 06
  ltname: 6
  ninfo: 1
  parent: 'root::ImageList::::ImageData::Calibrations::Dimension::'
  path: root::ImageList::::ImageData::Calibrations::Dimension::::Origin
  serial: 6.2.1.1.2.3.1
  tag: 21
  tlen: 24
  tname: Origin



The most interesting information are copied and given keys starting with "0_", so that they will be printed in the YAML file at the top:

0_height:
  - 3710
0_scales:
  - 1
  - 1
  - 0.148674234747887
  - 0.148674234747887
  - 1
0_width:
  - 3838

In this example above, the Apix is 0.14867 nm/pix.

