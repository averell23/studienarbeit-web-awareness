#!/usr/local/bin/perl
open(INFILE, "$ARGV[0]") or die ("file: $ARGV[0] can't be opened.\n");

$author = "Unknow author of $ARGV[0]\n";
$title = "Unknow document $ARGV[0]\n";

$subcount = 0;
$count = 0;
@subdata = ();

while (<INFILE>) {
  if (/\\title/) {
    /{(.*)}/;
    $title = $1;
  }
  if (/\\author/) {
    /{(.+)}/;
    $author = $1;
  }
  if (/\\section\*?{/) {
    # Set the vars
    $count++;
    /{(.+)}/;
    if ($subcount != 0) {
      @data = (@data, $subcount, @subdata, $1);
    } else {
      @data = (@data, $subcount, $1);
    }
    $subcount = 0;
    @subdata = ();
    # Now output the bookmark
    print("$_");
    print("\\pdfdest num $count fitbh\n");
    $_ = "";
  }
  if (/\\subsection\*?{/) {
    # Set the vars
    $subcount++;
    $count++;
    /{(.+)}/;
    @subdata = (@subdata, $1);
    
    # Now output the bookmark
    print("$_");
    print("\\pdfdest num $count fitbh\n");
    $_ = "";
  }
  if (/\\end{document}/) {
    # At the end of the document
    # build the reference list
    
    # Add the last subsections
    if ($subcount != 0) {
      @data = (@data, $subcount, @subdata);
    } else {
      @data = (@data, $subcount);
    }
    
    # print("Dump:\n\n@data\nSubs:\n@subdata\n\n");
    # The first subsections
    $snum = shift(@data);
    $ocount = 0;
    for ($i = 0 ; $i < $snum ; $i++) {
      $ocount++;
      $x = shift(@data);
      print("\\pdfoutline got num $ocount {$x}\n");
    }
    
    # The other subsections
    $cont = 1;
    while ($cont == 1) {
      $sname = shift(@data);
      if (($sname != undef) or ($ocount >= $count)) {
        $cont = 0;
        # print("Bailout");
      } else {
        $ocount++;
	$snum = shift(@data);
	print("\\pdfoutline goto num $ocount count -$snum {$sname}\n");
	
	for ($i = 0 ; $i < $snum ; $i++) {
	  $ocount++;
	  $x = shift(@data);
	  print("\\pdfoutline goto num $ocount {$x}\n");
	}
      }
    }
    
    print("\n\\pdfinfo{\n");
    print("  /Author ($author)\n");
    print("  /Title ($title)\n");
    print("  /Creator(TeX automated)\n");
    print("  /Producer(pdfTeX)\n");
    print("}\n\n");
  } 
  print("$_");
}
