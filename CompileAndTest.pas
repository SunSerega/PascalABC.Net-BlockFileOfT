procedure CompileFile(fname:string);
begin
  var p := new System.Diagnostics.Process;
  p.StartInfo.FileName := 'C:\Program Files (x86)\PascalABC.NET\pabcnetc.exe';
  p.StartInfo.Arguments := '"'+System.IO.Path.GetFullPath(fname)+'"';
  p.StartInfo.UseShellExecute := false;
  p.StartInfo.RedirectStandardError := true;
  p.Start;
  write(p.StandardError.ReadToEnd+#10*1);
  p.WaitForExit;
end;

procedure CompileSource;
begin
  System.IO.Directory.EnumerateFiles('LibSource')
  .Where(fname->System.IO.Path.GetExtension(fname)='.pas')
  .ForEach(fname->CompileFile(fname));
  
  System.IO.Directory.EnumerateFiles('Lib')
  .Where(fname->System.IO.Path.GetExtension(fname)='.pcu')
  .ForEach(fname->System.IO.File.Delete(fname));
  
  System.IO.Directory.EnumerateFiles('LibSource')
  .Where(fname->System.IO.Path.GetExtension(fname)='.pcu')
  .ForEach(fname->System.IO.File.Move(fname,'Lib\'+System.IO.Path.GetFileName(fname)));
  
  write('compile ok'+#10*2)
end;

function GetReadyPcu:array of string :=
System.IO.Directory.EnumerateFiles('Lib')
.Where(fname->System.IO.Path.GetExtension(fname)='.pcu')
.Select(fname->System.IO.Path.GetFileName(fname))
.ToArray;

procedure TestAll(path:string; ReadyPcu:array of string) :=
try
  
  System.IO.Directory.EnumerateDirectories(path)
  .ForEach(procedure(dir)->(new System.Threading.Thread(()->TestAll(dir, ReadyPcu))).Start);
  
  ReadyPcu.ForEach(fname->
  begin
    System.IO.File.Delete(path+'\'+fname);
    System.IO.File.Copy('Lib\'+fname,path+'\'+fname);
  end);
  
  System.IO.Directory.EnumerateFiles(path)
  .Where(fname->System.IO.Path.GetExtension(fname)='.pas')
  .ForEach(fname->
  try
    CompileFile(fname)
  except
    on e:Exception do
      write($'Error compiling file {fname}{#10}{e}{#10}');
  end);
  
  ReadyPcu.ForEach(fname->System.IO.File.Delete(path+'\'+fname));
  
  System.IO.Directory.EnumerateFiles(path)
  .Where(fname->System.IO.Path.GetExtension(fname)='.exe')
  .ForEach(fname->
  try
    var p := new System.Diagnostics.Process;
    p.StartInfo.FileName := fname;
    p.StartInfo.WorkingDirectory := path;
    p.StartInfo.UseShellExecute := false;
    p.StartInfo.RedirectStandardError := true;
    p.Start;
    write(p.StandardError.ReadToEnd+#10*1);
    (**
    var normal_exit := false;
    var i := 0;
    while (i < 50) and not normal_exit do
      if p.HasExited then
        normal_exit := true else
        Sleep(100);
    if not normal_exit then
    begin
      writeln($'файл {fname} не завершился за 5 сек');
      readln;
    end;
    (**)
    p.WaitForExit;
    
  except
    on e:Exception do
      write($'Error executing file {fname}{#10}{e}{#10}');
  end);
  
  write($'path {path} ok{#10*2}');
  
except
  on e:Exception do
    write($'Error testing path {path}{#10}{e}{#10}');
end;

begin
  try
    CompileSource;
    var ReadyPcu := GetReadyPcu;
    TestAll('Test',ReadyPcu);
    //TestAll('BlockFileOfT',ReadyPcu);//ToDo потом придумать как красивее...
    readln;
  except
    on e:Exception do
      writeln(e);
  end;
end.