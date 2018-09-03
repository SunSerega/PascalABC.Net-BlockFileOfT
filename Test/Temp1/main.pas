procedure FindNext(s, find:string; var pos:integer);
begin
  var p2 := 1;
  while true do
  begin
    if s[pos] = find[p2] then
    begin
      p2 += 1;
      if p2 > find.Length then
      begin
        pos += 1;
        exit;
      end;
    end else
      p2 := 1;
    
    pos += 1;
  end;
end;

function GetLineNumText(i:integer):string;
begin
  Result := i.ToString;
  Result := '0'*(3-Result.Length)+Result;
end;

begin
  var html := (Seq&<string>()+
			'<li><font size="5"><a href="TSize.html">TSize</a></font></li>'+
			'<li><font size="5"><a href="Offset.html"										>Offset</a></font></li>'+
			'<li><font size="5"><a href="Size.html"											>Size</a></font></li>'+
			'<li><font size="5"><a href="ByteSize.html"										>ByteSize</a></font></li>'+
			'<li><font size="5"><a href="Name.html"											>Name</a></font></li>'+
			'<li><font size="5"><a href="FullName.html"										>FullName</a></font></li>'+
			'<li><font size="5"><a href="Exists.html"										>Exists</a></font></li>'+
			'<li><font size="5"><a href="Pos.html"											>Pos</a></font></li>'+
			'<li><font size="5"><a href="PosByte.html"										>PosByte</a></font></li>'+
			'<li><font size="5"><a href="Assigned.html"										>Assigned</a></font></li>'+
			'<li><font size="5"><a href="Opened.html"										>Opened</a></font></li>'+
			'<li><font size="5"><a href="EOF.html"											>EOF</a></font></li>'+
			'<li><font size="5"><a href="BaseStream.html"									>BaseStream</a></font></li>'+
			'<li><font size="5"><a href="BinWriter.html"										>BinWriter</a></font></li>'+
			'<li><font size="5"><a href="BinReader.html"										>BinReader</a></font></li>'+
			'<li><font size="5"><a href="FileInfo.html"										>FileInfo</a></font></li>'
  ).ToArray;
  var module := ReadAllLines('BlockFileOfT.pas');
  
  foreach var html_l in html do
  begin
    var p := 1;
    FindNext(html_l,'href="',p);
    var p2 := p;
    FindNext(html_l,'"',p2);
    
    var fname := html_l.Substring(p-1,p2-p-1);
    var prop_name := fname.Split('.')[0];
    
    if prop_name = '' then continue;
    
    var prop_li := module.FindIndex(s->s.Contains($'property {prop_name}'));
    var prop_ls := 0;
    for var i := prop_li-1 downto 0 do
    begin
      if module[i].Contains('///') then continue;
      prop_ls := i + 1;
      break;
    end;
    //p := 1;
    //FindNext(module[prop_li],':',p);
    //p2 := p+1;
    //FindNext(module[prop_li],' ',p2);
    //var prop_type := module[prop_li].Substring(p-1,p2-p-1);
    
    var sw := new System.IO.StreamWriter(System.IO.File.Create(fname));
    
    sw.Write(ReadAllText('templ_p1.txt'));
    
    sw.WriteLine($'{#9*5}{GetLineNumText(prop_ls)}:<t style="margin-left: 05px">{module[prop_ls]}</t>');
    for var i := prop_ls+1 to prop_li do
      sw.WriteLine($'{#9*4}<br>{GetLineNumText(i)}:<t style="margin-left: 05px">{module[i]}{#9*2}</t>');
    
    sw.Write(ReadAllText('templ_p2.txt'));
    
    sw.Close;
    
  end;
end.