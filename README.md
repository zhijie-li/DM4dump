# DM4dump

Dumps GATAN DM4 file information into human-readable format.

The DM4 file format is described in http://www.er-c.org/cbb/info/dmformat/#dm4 

This program will unpack the binary data saved in DM4 files and try to interpret a few most interesting entries such as image dimensions, Angstroms per pixel (Apix), etc..


## Reqirements

I tried to minimize its dependencies, but still, this program requires Compress::Zlib and YAML. 


The Zlib is needed only for PNG generation. If dumping the header information is the only goal, delete the two functions related to save PNG near the end to drop the dependency on Zlib.

## Syntax

To simply dump the "header information" (DM4 does not really have a "header"):
<pre>
   perl dumpDM4.pl 0000.dm4 >log.txt
</pre>
To dump the thumbnail (not quite useful, except to see a scale bar or to see the original orientation):
<pre>
   perl dumpDM4.pl 0000.dm4 --dumpthumbnail >log.txt
</pre>
To dump the image or image slices:
<pre>
   perl dumpDM4.pl 0000.dm4 --dumpPNG >log.txt
</pre>
To dump data to MRC/MRCS file:
<pre>
   perl dumpDM4.pl 0000.dm4 --dumpMRC >log.txt
</pre>
If the dm4 contains more than 1 slices, a .mrcs file is generated. Otherwise a .mrc file is generated.
This program dumps MRC slightly faster than e2proc2d. But there won't be min max mean rms in the header - perl is slow in math. 


The file "log.txt" lists the directory structure of the DM4 file. A numbering system is also printed so that each node in the DM4 file gets a unique identifier.

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

In this example, the Apix is 0.14867 nm/pix (imaging CCDs should always have square pixels?).
