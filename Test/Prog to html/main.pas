const
  tabs = 4;

function l_to_html(l: string): string;
begin
  var i := l.ToCharArray.FindIndex(ch -> ch <> ' ') * 5;
  if i < 0 then i := 0;
  Result := i.ToString;
  Result := '0' * (2 - Result.Length) + Result;
  Result := $'<t style="margin-left: {Result}px">{l.TrimStart('' '').Replace(''<'',''&lt'')}{#9*2}</t>';
end;

begin
  var prog := ReadAllLines('prog.pas');
  var sw := new System.IO.StreamWriter(System.IO.File.Create('html.txt'));
  sw.WriteLine;
  sw.WriteLine($'{#9*(tabs+1)}{l_to_html(prog.FirstOrDefault)}');
  foreach var l in prog.Skip(1) do
    sw.WriteLine($'{#9*tabs}<br>{l_to_html(l)}');
  sw.Close;
  Exec('html.txt');
end.