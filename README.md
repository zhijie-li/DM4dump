# DM4dump
Dump GATAN DM4 file information into human-readable format.

The DM4 file format is described in http://www.er-c.org/cbb/info/dmformat/#dm4 

This program will unpack the binary data saved in DM4 files and try to interpret a few most interesting entries such as image dimention, Angstroms per pixle (Apix), etc..
For now, data blocks that are larger than 10 MB will be simply skipped. This in most cases only affects two data blocks: the image thumbnail data block and the image/movies data block.

## Reqires

YAML
Compress::Zlib

The Zlib is only for PNG generation. If dumping the header information is the only goal, delete the two functions related to save PNG at the end.

## Syntax

   perl dumpDM4.pl 0000.dm4 >log.txt

to dump the thumbnail (not quite useful, except to see a scale bar or to see the original orientation):

   perl dumpDM4.pl 0000.dm4 --dumpthumbnail >log.txt

to dump the image or image slices:

   perl dumpDM4.pl 0000.dm4 --dumpPNG >log.txt


The file "dump.txt" lists the directory structure of the DM4 file. A numbering system is also printed so that each node in the DM4 file gets a unique identifier so future use.
<pre>
##example dump.txt##

 |1 <ApplicationBounds> root::ApplicationBounds 32 Bytes   11111111QQQQ 32x1 <0 0 1464 2236> [ 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 b8 05 00 00 00 00 00 00 bc 08 00 00 00 00 00 00]
 
 +2 [DocumentObjectList] 5525 (1) root::DocumentObjectList
 
  +2.1 [] 5504 (18) root::DocumentObjectList::
  
   +2.1.1 [AnnotationGroupList] 1201 (1) root::DocumentObjectList::::AnnotationGroupList
   
    +2.1.1.1 [] 1180 (18) root::DocumentObjectList::::AnnotationGroupList::
 
####################
</pre>


This program will also dump the information into a YAML file "xxxx.dm4.YAML", which contains the data hash. This hash does not use the same hierachical structure as that in the original dm4 file. Each tag/directory in the orginal dm4 file is saved with its path (the "parent" and "path" items, see example below). The aforementioned numbering system is used as the keys to uniquely identify each tag/directory.

<pre>
###example##########

2.1.1.1.15:

  data: 00 00 80 3f
  
  data_format: '6 f 4x1 '
  
  data_translated: 1
  
  info: 00 00 00 00 00 00 00 06
  
  ltname: 11
  
  ninfo: 1
  
  parent: 'root::DocumentObjectList::::AnnotationGroupList::'
  
  path: root::DocumentObjectList::::AnnotationGroupList::::TextOffsetH
  
  serial: 2.1.1.1.15
  
  tag: 21
  
  tlen: 24
  
  tname: TextOffsetH
  

####################
</pre>


The most interesting entries are copied and are given keys starting with "0_", so that they will be printed at the top of the YAML file:

<pre>
###example##########

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
  


####################

</pre>

In this example, the Apix is 0.14867 nm/pix (with square pixels).
