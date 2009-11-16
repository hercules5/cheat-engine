unit pointerscannerfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, syncobjs,syncobjs2, Menus, math,
  frmRescanPointerUnit, pointervaluelist, 

  {$ifdef injectedpscan}
  virtualmemorystub, symbolhandlerlite, globals;
  {$else}
  virtualmemory, symbolhandler,mainunit,disassembler,cefuncproc,newkernelhandler;
  {$endif}


const staticscanner_done=wm_user+1;
const rescan_done=wm_user+2;
const open_scanner=wm_user+3;

{$ifdef injectedpscan}
const wm_drawtreeviewdone=wm_user+4;
const wm_drawtreeviewAddToList=wm_user+5;
{$endif}

type TDrawTreeview=class(tthread)
  private
    st: string;
    offset: dword;
    offsetlist: array of dword;
    offsetsize: integer;
  public
    treeview: ttreeview;
    pointerlist: tmemorystream;
    progressbar: tprogressbar;
    procedure execute; override;
    //procedure done;
    procedure AddToList;
end;

type TMatches = array of ttreenode;
type tpath = array of dword;


type trescanpointers=class(tthread)
  private
    function ismatchtovalue(p: pointer): boolean;
  public
    progressbar: tprogressbar;
    oldpointerlist: tmemorystream;
    newpointerlist: tmemorystream;
    address: dword;
    forvalue: boolean;
    valuetype: TVariableType;
    valuescandword: dword;
    valuescansingle: single;
    valuescandouble: double;
    valuescansinglemax: single;
    valuescandoublemax: double;

    procedure execute; override;
end;



type
  toffsetlist = array of dword;
  TStaticscanner = class;

  TReverseScanWorker = class (tthread)
  private
    offsetlist: array of dword;
    results: tmemorystream;
    resultsfile: tfilestream;


    procedure flushresults;
    procedure rscan(valuetofind:dword; level: integer);
    procedure StorePath(level: integer; staticdata: PStaticData=nil);

  public
    valuetofind: dword;
    maxlevel: integer;
    structsize: integer;
//    startaddress: dword;
    startlevel: integer;
    alligned: boolean;
    staticonly: boolean;

    isdone: boolean;
    startworking: tevent;
    stop: boolean;

    staticscanner: TStaticscanner;
    tempresults: array of dword;


    //info:
    currentaddress: pointer;
    currentlevel: integer;
    LookingForMin: dword;
    LookingForMax: dword;
    lastaddress: dword;
    
    filename: string;
    procedure execute; override;
    constructor create(suspended: boolean);
    destructor destroy; override;
  end;

  TStaticscanner = class(TThread)
  private
    updateline: integer; //not used for addentry

    memoryregion: array of tmemoryregion;
    lasttreenodeadded: ttreenode;
    addnode: ttreenode;
    addnodeextension: tmatches;

    reversescanners: array of treversescanworker;

//    procedure UpdateList;
    //procedure done;
//    procedure automaticfinish;
//    procedure addentry;


    function ismatchtovalue(p: pointer): boolean;  //checks if the pointer points to a value matching the user's input
    procedure reversescan;

  public
    //reverse
    firstaddress: pointer;
    currentaddress: pointer;
    lastaddress: pointer;

    lookingformin: dword;
    lookingformax: dword;
    //reverse^

    reverse: boolean;
    automatic: boolean;
    automaticaddress: dword;
//    filterstart:dword;
//    filterstop:dword;
    start: dword;
    stop: dword;
    progressbar: TProgressbar;
    sz,sz0: integer;
    maxlevel: integer;
    unalligned: boolean;
    codescan: boolean;
//    method2: boolean;
//    method3: boolean;

    fast: boolean;
    psychotic: boolean;
    writableonly: boolean;
    unallignedbase: boolean;

{$ifndef injectedpscan}
    useheapdata: boolean;
    useOnlyHeapData: boolean;
{$endif}

    findValueInsteadOfAddress: boolean;
    valuetype: TVariableType;
    valuescandword: dword;
    valuescansingle: single;
    valuescandouble: double;
    valuescansinglemax: single;
    valuescandoublemax: double;


    mustEndWithSpecificOffset: boolean;
    mustendwithoffsetlist: array of dword;
    onlyOneStaticInPath: boolean;


    threadcount: integer;
    scannerpriority: TThreadPriority;

    filenames: array of string;
    phase: integer;
    currentpos: ^Dword;

    starttime: dword;

    isdone: boolean;

    staticonly: boolean; //for reverse

    procedure execute; override;
   // destructor destroy; override;
  end;

type TPointerEntry=record
  modulenumber: integer;
  offset: dword;
  level: integer;  
  offsetlist: array of dword;
end;


type
  Tfrmpointerscanner = class(TForm)
    ProgressBar1: TProgressBar;
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    N2: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Pointerscanner1: TMenuItem;
    Method3Fastspeedandaveragememoryusage1: TMenuItem;
    N1: TMenuItem;
    Rescanmemory1: TMenuItem;
    Showresults1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Timer2: TTimer;
    pgcPScandata: TPageControl;
    tsPSDefault: TTabSheet;
    tsPSReverse: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label9: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    btnStopScan: TButton;
    tvRSThreads: TTreeView;
    Panel2: TPanel;
    Label5: TLabel;
    lblRSTotalStaticPaths: TLabel;
    lblRSTotalPaths: TLabel;
    Panel3: TPanel;
    Button1: TButton;
    Label6: TLabel;
    view1: TMenuItem;
    Sortlist1: TMenuItem;
    ListView1: TListView;
    procedure Method3Fastspeedandaveragememoryusage1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Showresults1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Rescanmemory1Click(Sender: TObject);
    procedure btnStopScanClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure tvResultsDblClick(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Sortlist1Click(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
    start:tdatetime;

    rescan: trescanpointers;
    cewindowhandle: thandle;
    drawtreeviewthread: TDrawTreeview;

    {$ifdef injectedpscan}
    procedure drawtreeviewdone(var message: tmessage); message wm_drawtreeviewdone;
    procedure drawtreeviewAddToList(var message: tmessage); message wm_drawtreeviewAddToList;
    {$endif}
    procedure tvResultCompare(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
    

    procedure m_staticscanner_done(var message: tmessage); message staticscanner_done;
    procedure rescandone(var message: tmessage); message rescan_done;
    procedure openscanner(var message: tmessage); message open_scanner;
    procedure drawtreeview;
    procedure doneui;
  public
    { Public declarations }
    pointerlist: tmemorystream;
    Staticscanner:TStaticScanner;


    pointerfile: TfileStream;
    modulelist: tstringlist;
    pointerfileoffsetlength: integer;
    pointerfileStartPosition: integer;

    sizeOfEntry: integer;
    startinfexoflist: integer;
    pointerentrylist: array of TPointerEntry;
  end;

type TExecuter = class(tthread)
  public
    procedure execute; override;
end;

type tarraypath= array of tpath;


var
  frmPointerScanner: TfrmPointerScanner;
  staticlist: array of dword;
  dissectedstatics: dword=0;

//  dissectedpointersLevelpos:array of integer;
//  dissectedpointersLevel: array of array of dword;
//  dissectedpointersLevelMREWS: array of TMultiReadExclusiveWriteSynchronizer; //every level has it's own lock


  treenodeswithchildrenpos: integer;
  treenodeswithchildren: array of ttreenode;
  treenodeswithchildrencs: tcriticalsection;

  matchednodescs: tcriticalsection;
  matchednodes: array of Tmatches;
  matchednodespos: integer;

  reverseScanCS: TCriticalSection;
  reverseScanSemaphore: tsemaphore;

//  PossiblepathsLevelMREWS: array of TMultiReadExclusiveWriteSynchronizer;
//  possiblepathsLevel: array of array of dword; //all addresses that finished in a address
//  possiblepathsLevelpos: array of integer;
//  method2semaphore: tsemaphore;





  totalpointers: integer;
  lastlevel: integer;

  pointersfound: dword=0;
  foundbyappending: dword=0;
  skipped: dword;

  lastaddress: dword;
  cpucount: integer;

  scanaddresscount: dword;
  incorrectresult: dword;
  continued: dword;

//  vm: tvirtualmemory;
  pointerlisthandler: TReversePointerListHandler;


implementation

{$R *.dfm}

{$ifdef injectedpscan}
uses PointerscannerSettingsFrm, CEFuncProc;
{$else}
uses PointerscannerSettingsFrm, frmMemoryAllocHandlerUnit;
{$endif}


procedure TExecuter.execute;
begin
  try
    try
      frmpointerscanner:=tfrmpointerscanner.Create(nil);
      frmpointerscanner.ShowModal;

      messagebox(0,'Exit pointerscan','exit',mb_ok);

      //FreeLibraryAndExitThread(getmodulehandle('pscan.dll'),0);
    except
      on e: exception do
      begin
        messagebox(0,pchar('pointerscan crash.'),'error',mb_ok);
        messagebox(0,pchar('pointerscan crash. '+e.message),'error',mb_ok);
      end;

    end;
  finally
    messagebox(0,'Exit pointerscan 2','exit',mb_ok);
    FreeLibraryAndExitThread(hinstance,0);
  end;
end;

procedure TDrawtreeView.AddToList;
var y: ttreenode;
    i,j: integer;
begin
  y:=treeview.Items.Add(nil,st+inttohex(offset,8));

  for j:=0 to offsetsize-1 do
    treeview.Items.AddChild(y,inttohex(offsetlist[j],1)); 
end;

procedure TDrawTreeview.execute;
var total: integer;
    s: pchar;
    ssize: dword;
    stringlength: dword;
begin
//frmpointerscanner can nevr be closed while this routine is running. See the onclose event for why
  s:=nil;
 { 
  try
    pointerlist.Seek(0,sofrombeginning);

    treeview.items.clear;
    total:=0;
    setlength(offsetlist,10);


    getmem(s,100);
    ssize:=100;

    progressbar.Position:=0;
    progressbar.Max:=pointerlist.Size;

    try
      while (not terminated) and (frmpointerscanner.pointerlist.Position<>pointerlist.Size) do
      begin
        pointerlist.ReadBuffer(stringlength,sizeof(stringlength));
        if ssize<=stringlength then
        begin
          freemem(s);
          getmem(s,stringlength+1);
          ssize:=stringlength+1;
        end;

        pointerlist.ReadBuffer(s^,stringlength);
        s[stringlength]:=#0;
        st:=s;

        pointerlist.readbuffer(offset,sizeof(offset));

        pointerlist.ReadBuffer(offsetsize,sizeof(offsetsize));
        if length(offsetlist)<(offsetsize) then
          setlength(offsetlist,offsetsize*2);
        pointerlist.ReadBuffer(offsetlist[0],(offsetsize)*sizeof(offsetlist[0]));

        if st<>'' then st:=st+'+';
        }
//        {$ifdef injectedpscan}
//        if not terminated then sendmessage(frmpointerscanner.Handle,wm_drawtreeviewAddToList,0,0);
//        {$else}
//        if not terminated then synchronize(AddToList);
//        {$endif}
{
        inc(total);

        if (total mod 50)=0 then
          progressbar.Position:=pointerlist.Position;
      end;
    except
      //done, eof
    end;

    pointersfound:=total;
    
  finally
    if s<>nil then
      freemem(s);
  end;


  setlength(offsetlist,0);

  }
  {$ifdef injectedpscan}
 // if not terminated then sendmessage(frmpointerscanner.Handle,wm_drawtreeviewdone,0,0);
  {$else}
 // if not terminated then synchronize(done);
  {$endif}
end;

//----------------------- scanner info --------------------------
//----------------------- staticscanner -------------------------

{$ifdef injectedpscan}
procedure Tfrmpointerscanner.drawtreeviewdone(var message: tmessage);
begin
  if DrawTreeviewThread<>nil then
    DrawTreeviewThread.done;
end;


procedure Tfrmpointerscanner.drawtreeviewAddToList(var message: tmessage);
begin
  if DrawTreeviewThread<>nil then
    DrawTreeviewThread.AddToList;
end;
{$endif}

procedure Tfrmpointerscanner.drawtreeview;
begin
 { file1.Enabled:=false;
  Pointerscanner1.Enabled:=false;
  tvResults.Items.BeginUpdate;
  DrawTreeviewthread:=TDrawtreeview.Create(true);
  DrawTreeviewThread.pointerlist:=pointerlist;
  DrawTreeviewThread.treeview:=tvResults;
  DrawTreeviewThread.progressbar:=progressbar1;
  DrawTreeviewThread.Resume;   }
end;


procedure TFrmpointerscanner.doneui;
begin
  progressbar1.position:=0;

  pgcPScandata.Visible:=false;
  open1.Enabled:=true;
  new1.enabled:=true;
  save1.Enabled:=true;
  rescanmemory1.Enabled:=true;
  showmessage('The results are saved in results.ptr');
end;

procedure Tfrmpointerscanner.m_staticscanner_done(var message: tmessage);
var x: tfilestream;
    result: tfilestream;
    i: integer;
begin

  if staticscanner=nil then exit;

{$ifndef injectedpscan}
  if staticscanner.useHeapData then
    frmMemoryAllocHandler.displaythread.Resume; //continue adding new entries
{$endif}


  //now combile all thread results to 1 file
  result:=tfilestream.Create({$ifdef injectedpscan}scansettings.{$endif}cheatenginedir+'result.ptr',fmcreate);
  pointerlisthandler.saveModuleListToResults(result);

  result.Write(message.LParam,sizeof(message.LParam)); //write max level (maxlevel is provided in the message (it could change depending on the settings)



  for i:=0 to length(staticscanner.filenames)-1 do
  begin
    x:=tfilestream.Create(staticscanner.filenames[i],fmopenread);
    result.CopyFrom(x,0);
    x.free;
    deletefile(staticscanner.filenames[i]);
  end;
  result.Free;

  setlength(staticscanner.filenames,1);
  staticscanner.filenames[0]:={$ifdef injectedpscan}scansettings.{$endif}cheatenginedir+'result.ptr';

  showresults1.Enabled:=true;
  showresults1.Click;

  //update the treeview
  if message.WParam<>0 then
  begin
    messagedlg('Error during scan: '+pchar(message.LParam), mtError, [mbok] ,0);


  end;


  doneui;



end;







procedure TReverseScanWorker.flushresults;
begin
  resultsfile.WriteBuffer(results.Memory^,results.Position);
  results.Seek(0,sofrombeginning);
 // results.Clear;
end;

constructor TReverseScanWorker.create(suspended:boolean);
begin
  results:=tmemorystream.Create;
  results.SetSize(16*1024*1024);
 // results.WriteBuffer('WEEEEEEEE',9);

  startworking:=tevent.create(nil,false,false,'');
  isdone:=true;

  inherited create(suspended);
end;

destructor TReverseScanWorker.destroy;
begin
  results.free;
  if resultsfile<>nil then
    freeandnil(resultsfile);

  startworking.free;
end;

procedure TReverseScanWorker.execute;
var wr: twaitresult;
begin
  filename:={$ifdef injectedpscan}scansettings.{$endif}cheatenginedir+inttostr(getcurrentprocessid)+'-'+inttostr(getcurrentthreadid)+'.ptr';
  resultsfile:= tfilestream.Create(filename,fmcreate);

  while not terminated do
  begin
    wr:=startworking.WaitFor(infinite);
    if stop then exit;

    if wr=wrSignaled then
    begin
      try
        rscan(valuetofind,startlevel);
      finally
        isdone:=true;  //set isdone to true
        reversescansemaphore.release;
      end;
    end;
  end;

end;


var fcount:integer=0;
var scount:integer=0;

procedure TReverseScanWorker.StorePath(level: integer; staticdata: PStaticData=nil);
{Store the current path to memory and flush if needed}
var i: integer;
    x: dword;

    foundstatic: boolean;
    mi: tmoduleinfo;
begin
  inc(fcount); //increme
  if (staticdata=nil) and staticonly then exit; //don't store it

  inc(scount);


  //fill in the offset list
  inc(pointersfound);

  //for i:=0 to level do
  //  offsetlist[level-i]:=tempresults[i];


  results.WriteBuffer(staticdata.moduleindex, sizeof(staticdata.moduleindex));
  results.WriteBuffer(staticdata.offset,sizeof(staticdata.offset));
  i:=level+1; //store many offsets are actually used (since all are saved)
  results.WriteBuffer(i,sizeof(i));
  results.WriteBuffer(tempresults[0], maxlevel*sizeof(tempresults[0]) );

  if results.position>15*1024*1024 then //bigger than 15mb
    flushresults;

end;

procedure TReverseScanWorker.rscan(valuetofind:dword; level: integer);
{
scan through the memory for a address that points in the region of address, if found, recursive call till level maxlevel
}
var p: ^byte;
    pd: ^dword absolute p;
    maxaddress: dword;
    AddressMinusMaxStructSize: dword;
    found: boolean;
    i,j,k: integer;
    createdworker: boolean;

    mi: tmoduleinfo;
    mbi: _MEMORY_BASIC_INFORMATION;

    ExactOffset: boolean;
{$ifndef injectedpscan}
    mae: TMemoryAllocEvent;
{$endif}

  originalStartvalue: dword;
  startvalue: dword;
  stopvalue: dword;
  plist: PPointerlist;
begin
  currentlevel:=level;
  if (level>=maxlevel) then //in the previous version the check if it was a static was done here, that is now done earlier
  begin
    //reached max level
    if (not staticonly) then //store this results entry
      StorePath(level-1);
    exit;
  end;

  if self.staticscanner.Terminated then
    exit;


 {
  p:=vm.GetBuffer;  }

  exactOffset:=staticscanner.mustEndWithSpecificOffset and (length(staticscanner.mustendwithoffsetlist)-1>=level);

  if exactOffset then
  begin
    startvalue:=valuetofind-staticscanner.mustendwithoffsetlist[level];
    stopvalue:=startvalue;
  end
  else
  begin
    startvalue:=valuetofind-structsize;
    stopvalue:=valuetofind;

    if staticscanner.useheapdata then
    begin
      mae:=frmMemoryAllocHandler.FindAddress(@frmMemoryAllocHandler.HeapBaselevel, valuetofind);
      if mae<>nil then
      begin
        exactoffset:=true;
        startvalue:=mae.BaseAddress;
        stopvalue:=startvalue;
      end
      else //not static and not in heap
       if staticscanner.useOnlyHeapData then
         exit;
    end;
  end;
 {
  maxaddress:=dword(p)+vm.GetBufferSize;   }
  lastaddress:=maxaddress;

  LookingForMin:=startvalue;
  LookingForMax:=stopvalue;


  found:=false;
  while startvalue<=stopvalue do
  begin
    plist:=pointerlisthandler.findPointerValue(startvalue, stopvalue);
    if plist<>nil then
    begin
      found:=true;
      for j:=0 to plist.pos-1 do
      begin

        tempresults[level]:=valuetofind-startvalue; //store the offset
        if plist.list[j].staticdata=nil then
        begin
          //check if whe should go deeper into these results (not if max level has been reached)

          if (level+1) >= maxlevel then
          begin
            if (not staticonly) then //store this results entry
              StorePath(level-1);
          end
          else
          begin
            //not at max level, so scan for it
            //scan for this address
            //either spawn of a new thread that can do this, or do it myself

            createdworker:=false;
            reverseScanCS.Enter;

            //scan the worker thread array for a idle one, if found use it
            for i:=0 to length(staticscanner.reversescanners)-1 do
            begin
              if staticscanner.reversescanners[i].isdone then
              begin
                staticscanner.reversescanners[i].isdone:=false;
                staticscanner.reversescanners[i].maxlevel:=maxlevel;
                staticscanner.reversescanners[i].valuetofind:=plist.list[j].address;

                for k:=0 to maxlevel-1 do
                  staticscanner.reversescanners[i].tempresults[k]:=tempresults[k]; //copy results

                staticscanner.reversescanners[i].startlevel:=level+1;
                staticscanner.reversescanners[i].structsize:=structsize;
                staticscanner.reversescanners[i].startworking.SetEvent;
                createdworker:=true;
                break;
              end;
            end;

            reverseScanCS.Leave;


            if not createdworker then
            begin
              //I'll have to do it myself
              rscan(plist.list[j].address,level+1);
            end;
          end;

        end
        else
        begin
          //found a static one
          StorePath(level, plist.list[j].staticdata);

          if staticscanner.onlyOneStaticInPath then exit;
        end;
      end;

      if not staticscanner.unalligned then
        startvalue:=startvalue+4
      else
        startvalue:=startvalue+1;
        
    end else
    begin
      if (not found) and (not staticonly) then
      begin
        //nothing was found, let's just say this is the final level and store it...
        StorePath(level-1);
      end;
      exit;
    end;

  end;
end;

function TStaticScanner.ismatchtovalue(p: pointer): boolean;
begin
  case valuetype of
    vtDword: result:=pdword(p)^=valuescandword;
    vtSingle: result:=(psingle(p)^>=valuescansingle) and (psingle(p)^<valuescansinglemax);
    vtDouble: result:=(pdouble(p)^>=valuescandouble) and (pdouble(p)^<valuescandoublemax);
  end;
end;

procedure TStaticScanner.reversescan;
{
Do a reverse pointer scan
}
var p: ^byte;
    pd: ^dword absolute p;
    maxaddress: dword;
    automaticAddressMinusMaxStructSize: dword;

    results: array of dword;
    i,j: integer;
    alldone: boolean;
    {$ifdef injectedpscan}
    mbi: _MEMORY_BASIC_INFORMATION;
    {$endif}

    exactoffset: boolean;
{$ifndef injectedpscan}
    mae: TMemoryAllocEvent;
{$endif}

  startvalue: dword;
  stopvalue: dword;

  plist: PPointerList;
begin
  //scan the buffer
  fcount:=0; //debug counter to 0
  scount:=0;
  alldone:=false;

  if not findValueInsteadOfAddress then
    maxlevel:=maxlevel-1; //adjustment for this kind of scan

  setlength(results,maxlevel);  

  //initialize the first reverse scan worker
  //that one will spawn of all his other siblings

  reversescanners[0].isdone:=false;
  reversescanners[0].maxlevel:=maxlevel;

  reversescanners[0].valuetofind:=self.automaticaddress;
  reversescanners[0].structsize:=sz;
  reversescanners[0].startlevel:=0;
  reversescanners[0].startworking.SetEvent;


  //wait till all threads are in isdone state
  while (not alldone) do
  begin
    sleep(500);
    alldone:=true;

    //no need for a CS here since it's only a read, and even when a new thread is being made, the creator also has the isdone boolean to false
    for i:=0 to length(reversescanners)-1 do
    begin
      if not reversescanners[i].isdone then
      begin
        alldone:=false;
        break;
      end;
    end;
  end;

  isdone:=true;


  //all threads are done
  setlength(filenames,length(reversescanners));

  for i:=0 to length(reversescanners)-1 do
  begin
    reversescanners[i].stop:=true;
    reversescanners[i].startworking.SetEvent;  //run it in case it was waiting
    reversescanners[i].WaitFor; //wait till this thread has terminated because the main thread has terminated
    reversescanners[i].flushresults;  //write results to disk
    filenames[i]:=reversescanners[i].filename;
    reversescanners[i].Free;
  end;

  postmessage(frmpointerscanner.Handle,staticscanner_done,0,maxlevel);
  terminate;
  freeandnil(reversescansemaphore);
end;

procedure TStaticScanner.execute;
var
    i,j,k: integer;
    x,opcode:string;

    t:dword;
    hexcount,hexstart: integer;
    isstruct: boolean;
    isstatic: boolean;
    found: boolean;

    mbi: _MEMORY_BASIC_INFORMATION;

    tn,tempnode: ttreenode;
    lastnode: ttreenode;
    oldshowsymbols: boolean;
    oldshowmodules: boolean;


    bitcount: integer;

    scanregions: tmemoryregions;
    currentregion: integer;
    maxpos: dword;
    dw: byte;

begin
  if terminated then exit;

  if pointerlisthandler=nil then
  begin
    phase:=1;
    progressbar.Position:=0;
    try
      pointerlisthandler:=TReversePointerListHandler.Create(start,stop,not unalligned,progressbar);
    except
      postmessage(frmpointerscanner.Handle,staticscanner_done,1,dword(pchar('Failure copying target process memory'))); //I can just priovide this string as it's static in the .code section
      terminate;
      exit;
    end;
  end; 


  phase:=2;
  progressbar.Position:=0;
  
  currentpos:=pointer(start);





  i:=0;

  if reverse then  //always true since 5.6
  begin
    reverseScanCS:=tcriticalsection.Create;
    try
      reverseScanSemaphore:=tsemaphore.create(threadcount);
      setlength(reversescanners,threadcount);
      for i:=0 to threadcount-1 do
      begin
        reversescanners[i]:=TReverseScanWorker.Create(true);
        reversescanners[i].Priority:=scannerpriority;
        reversescanners[i].staticscanner:=self;
        setlength(reversescanners[i].tempresults,maxlevel);
        setlength(reversescanners[i].offsetlist,maxlevel);
        reversescanners[i].staticonly:=staticonly;
        reversescanners[i].alligned:=not self.unalligned;


        reversescanners[i].Resume;
      end;
      reversescan;
    finally
      reverseScanCS.Free;
    end;

  end;

  {
  if (vm<>nil) and (not reuse) then
    freeandnil(vm);   }
    
end;


    {
destructor TStaticscanner.destroy;
begin
  terminate;
  waitfor;
  inherited destroy;
end;   }

//---------------------------------main--------------------------

procedure Tfrmpointerscanner.Method3Fastspeedandaveragememoryusage1Click(
  Sender: TObject);
var
  i: integer;
  floataccuracy: integer;
  floatsettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetThreadLocale, FloatSettings);
  
  start:=now;
  if frmpointerscannersettings=nil then
    frmpointerscannersettings:=tfrmpointerscannersettings.create(nil);

  if frmpointerscannersettings.Visible then exit; //already open, so no need to make again

  {
  if vm<>nil then
    frmpointerscannersettings.cbreuse.Caption:='Reuse memory copy from previous scan';}

  if frmpointerscannersettings.Showmodal=mrok then
  begin
    new1.click;

    pgcPScandata.Visible:=false;
    open1.Enabled:=false;
    new1.enabled:=false;
    save1.Enabled:=false;
    rescanmemory1.Enabled:=false;


    incorrectresult:=0;
    continued:=0;
    pointersfound:=0;

    label1.Caption:='Matches found:';
    label2.Left:=label1.Left+label1.Width+5;

    timer2.Enabled:=true;

    treenodeswithchildrenpos:=0;
    matchednodespos:=0;



    //initialize array's
   
    //default scan
    staticscanner:=TStaticscanner.Create(true);

    try

      staticscanner.reverse:=true; //since 5.6 this is always true

      staticscanner.start:=frmpointerscannersettings.start;
      staticscanner.stop:=frmpointerscannersettings.Stop;

      staticscanner.unalligned:=not frmpointerscannersettings.CbAlligned.checked;
      pgcPScandata.ActivePage:=tsPSReverse;
      tvRSThreads.Items.Clear;


      staticscanner.codescan:=frmpointerscannersettings.codescan;
      staticscanner.staticonly:=frmpointerscannersettings.cbStaticOnly.checked;

      staticscanner.automatic:=true;

      staticscanner.automaticaddress:=frmpointerscannersettings.automaticaddress;
      staticscanner.sz:=frmpointerscannersettings.structsize;
      staticscanner.sz0:=frmpointerscannersettings.level0structsize;
      staticscanner.maxlevel:=frmpointerscannersettings.maxlevel;

      staticscanner.progressbar:=progressbar1;
      staticscanner.threadcount:=frmpointerscannersettings.threadcount;
      staticscanner.scannerpriority:=frmpointerscannersettings.scannerpriority;

      staticscanner.mustEndWithSpecificOffset:=frmpointerscannersettings.cbMustEndWithSpecificOffset.checked;
      if staticscanner.mustEndWithSpecificOffset then
      begin
        setlength(staticscanner.mustendwithoffsetlist, frmpointerscannersettings.offsetlist.count);
        for i:=0 to frmpointerscannersettings.offsetlist.count-1 do
          staticscanner.mustendwithoffsetlist[i]:=TOffsetEntry(frmpointerscannersettings.offsetlist[i]).offset;
      end;

      staticscanner.onlyOneStaticInPath:=frmpointerscannersettings.cbOnlyOneStatic.checked;

{$ifndef injectedpscan}
      staticscanner.useHeapData:=frmpointerscannersettings.cbUseHeapData.Checked;
      staticscanner.useOnlyHeapData:=frmpointerscannersettings.cbHeapOnly.checked;


      if staticscanner.useHeapData then
        frmMemoryAllocHandler.displaythread.Suspend; //stop adding entries to the list
{$endif}        

      //check if the user choose to scan for addresses or for values
      staticscanner.findValueInsteadOfAddress:=frmpointerscannersettings.rbFindValue.checked;
      if staticscanner.findValueInsteadOfAddress then
      begin
        //if values, check what type of value
        floataccuracy:=pos(FloatSettings.DecimalSeparator,frmpointerscannersettings.edtAddress.Text);
        if floataccuracy>0 then
          floataccuracy:=length(frmpointerscannersettings.edtAddress.Text)-floataccuracy;

        case frmpointerscannersettings.cbValueType.ItemIndex of
          0:
          begin
            staticscanner.valuetype:=vtDword;
            val(frmpointerscannersettings.edtAddress.Text, staticscanner.valuescandword, i);
            if i>0 then raise exception.Create(frmpointerscannersettings.edtAddress.Text+' is not a valid 4 byte value');
          end;

          1:
          begin
            staticscanner.valuetype:=vtSingle;
            val(frmpointerscannersettings.edtAddress.Text, staticscanner.valuescansingle, i);
            if i>0 then raise exception.Create(frmpointerscannersettings.edtAddress.Text+' is not a valid floating point value');
            staticscanner.valuescansingleMax:=staticscanner.valuescansingle+(1/(power(10,floataccuracy)));
          end;

          2:
          begin
            staticscanner.valuetype:=vtDouble;
            val(frmpointerscannersettings.edtAddress.Text, staticscanner.valuescandouble, i);
            if i>0 then raise exception.Create(frmpointerscannersettings.edtAddress.Text+' is not a valid double value');
            staticscanner.valuescandoubleMax:=staticscanner.valuescandouble+(1/(power(10,floataccuracy)));            
          end;
        end;
      end;


      progressbar1.Max:=staticscanner.stop-staticscanner.start;


      open1.Enabled:=false;
      staticscanner.starttime:=gettickcount;
      staticscanner.Resume;

      if staticscanner.reverse then
      begin
        label10.visible:=false;
        label3.Visible:=false;
        label4.Visible:=false;
        label12.Visible:=false;
        label7.Visible:=false;
        label9.Visible:=false;
        label14.Visible:=false;
        label15.Visible:=false;
      end
      else
      begin
        label10.visible:=true;
        label3.Visible:=true;
        label4.Visible:=true;
        label12.Visible:=true;
        label7.Visible:=true;
        label8.Visible:=true;
        label14.Visible:=true;
        label15.Visible:=true;
      end;

      pgcPScandata.Visible:=true;
    except
      on e: exception do
      begin
        staticscanner.Free;
        staticscanner:=nil;
        raise e;
      end;
    end;

  end;
end;

procedure Tfrmpointerscanner.Timer2Timer(Sender: TObject);
var i,j,l: integer;
    s: string;
    a: string;
    smallestaddress: dword;
    todo: dword;
    done: dword;
    donetime,todotime: integer;
    oneaddresstime: double;
    _h,_m,_s: integer;
    tn,tn2: TTreenode;
begin
 // label6.Caption:=inttostr(fcount);
 // label23.Caption:=inttostr(scount);
  label8.Caption:=inttostr(continued);
  label2.Caption:=inttostr(pointersfound);
  label13.caption:=inttostr(skipped);

  if staticscanner<>nil then
  try
    if staticscanner.isdone then
    begin
      if tvRSThreads.Items.Count>0 then
        tvRSThreads.Items.Clear;
        
      exit;
    end;

    if staticscanner.reverse then
    begin
      lblRSTotalPaths.caption:=format('Total pointer paths encountered: %d ',[fcount]);
      lblRSTotalStaticPaths.caption:=format('Of those %d have a static base',[scount]);

      if scount>fcount then  lblRSTotalStaticPaths.caption:= lblRSTotalStaticPaths.caption+' WTF?';

      if pointerlisthandler<>nil then
        label6.caption:='Pointer addresses found in the whole process:'+inttostr(pointerlisthandler.count);
        
      //{$ifdef injectedpscan
      //lblRSCurrentAddress.Caption:=format('Currently at address %p (going till %p)',[staticscanner.currentaddress, staticscanner.lastaddress]);
     // {$else
      //if vm<>nil then
  //    lblRSCurrentAddress.Caption:=format('Currently at address %0.8x (going till %0.8x)',[vm.PointerToAddress(staticscanner.currentaddress), vm.PointerToAddress(staticscanner.lastaddress)]);
      //{$endif

      {

      label2.Caption:=inttostr(scount)+' of '+inttostr(fcount);
      label6.caption:='Looking for :'+inttohex(staticscanner.lookingformin,8)+'-'+inttohex(staticscanner.lookingformax,8);;
     
      if staticscanner.phase=2 then
      begin
        //calculate time left
        todo:=dword(staticscanner.lastaddress)-dword(staticscanner.currentaddress);
        done:=dword(staticscanner.currentaddress)-dword(staticscanner.firstaddress);
      end;

      }
      if tvRSThreads.Items.Count<length(staticscanner.reversescanners) then
      begin
        //add them

        for i:=0 to length(staticscanner.reversescanners)-1 do
        begin
          tn:=tvRSThreads.Items.Add(nil,'Thread '+inttostr(i+1));
          tvRSThreads.Items.AddChild(tn,'Current Level:0');
          tvRSThreads.Items.AddChild(tn,'Looking for :0-0');
        end;
      end;

      tn:=tvRSThreads.Items.GetFirstNode;
      i:=0;
      while tn<>nil do
      begin
        if staticscanner.reversescanners[i].isdone then
        begin
          tn.Text:='Thread '+inttostr(i+1)+' (Sleeping)';
          tn2:=tn.getFirstChild;
          tn2.text:='Sleeping';
          tn2:=tn2.getNextSibling;
          tn2.text:='Sleeping';
        end
        else
        begin
          tn.text:='Thread '+inttostr(i+1)+' (Active)';
          tn2:=tn.getFirstChild;

          begin
            s:='';
            for j:=0 to staticscanner.reversescanners[i].currentlevel-1 do
              s:=s+' '+inttohex(staticscanner.reversescanners[i].tempresults[j],8);


            tn2.text:='Current Level:'+inttostr(staticscanner.reversescanners[i].currentlevel)+' ('+s+')';
            tn2:=tn2.getNextSibling;
            tn2.text:='Looking for :'+inttohex(staticscanner.reversescanners[i].lookingformin,8)+'-'+inttohex(staticscanner.reversescanners[i].lookingformax,8);;
          end;
        end;

        tn:=tn.getNextSibling;
        inc(i);
      end;
    end
    else
    begin
     
    end;


  except
    label11.caption:='0 (0)';
  end else label18.Caption:='Idle';

  label4.Caption:=inttostr(scanaddresscount);
end;

procedure Tfrmpointerscanner.Showresults1Click(Sender: TObject);
begin
  panel1.caption:='There are '+inttostr(pointersfound)+' pointers in the list';
  
  if pointersfound>15000 then
    if messagedlg('This is a huge ammount of pointers and will take a while to display them. ('+inttostr(pointersfound)+') Are you sure you want to show them? (If you click no you can still filter out wrong paths)',mtconfirmation,[mbyes,mbno],0)<>mryes then exit;

  drawtreeview;


end;

procedure Tfrmpointerscanner.Save1Click(Sender: TObject);
var y: tfilestream;
begin
  if savedialog1.execute then
  begin
    y:=tfilestream.Create(savedialog1.FileName,fmcreate);
    try
      y.CopyFrom(pointerlist,0);
    finally
      y.free;
    end;
  end;
end;

procedure Tfrmpointerscanner.Open1Click(Sender: TObject);
var
  modulelistlength: dword;
  i: integer;
  x: dword;
  temppchar: pchar;
  temppcharmaxlength: integer;

  col_baseaddress:TListColumn;
  col_offsets: Array of TListColumn; 
begin
  temppcharmaxlength:=256;
  getmem(temppchar, temppcharmaxlength);

  if opendialog1.Execute then
  begin
    pointerfile:=tfilestream.Create(opendialog1.Filename, fmopenRead);
    pointerfile.Read(modulelistlength,sizeof(modulelistlength)); //modulelistcount
    modulelist:=tstringlist.Create;

    for i:=0 to modulelistlength-1 do
    begin
      pointerfile.Read(x,sizeof(x));
      while x>temppcharmaxlength do
      begin
        temppcharmaxlength:=temppcharmaxlength*2;
        getmem(temppchar, temppcharmaxlength);
      end;

      pointerfile.Read(temppchar[0], x);
      temppchar[x]:=#0;

      modulelist.Add(temppchar);
    end;

    //modulelist has been loaded
    pointerfile.read(pointerfileoffsetlength, sizeof(pointerfileoffsetlength));
    pointerfileStartPosition:=pointerfile.Position;

    listview1.Columns.Clear;

    col_baseaddress:=listview1.Columns.Add;
    col_baseaddress.Caption:='Base Address';
    col_baseaddress.Width:=100;

    setlength(col_offsets, pointerfileoffsetlength);
    for i:=0 to pointerfileoffsetlength-1 do
    begin
      col_offsets[i]:=listview1.Columns.Add;
      col_offsets[i].Caption:='Offset '+inttostr(i);
      col_offsets[i].Width:=50;
    end;

    sizeOfEntry:=(12+pointerfileoffsetlength*4);

    listview1.Items.Count:=(pointerfile.size-pointerfileStartPosition) div sizeOfEntry;
  end;
end;


function TRescanpointers.ismatchtovalue(p: pointer): boolean;
begin
  case valuetype of
    vtDword: result:=pdword(p)^=valuescandword;
    vtSingle: result:=(psingle(p)^>=valuescansingle) and (psingle(p)^<valuescansinglemax);
    vtDouble: result:=(pdouble(p)^>=valuescandouble) and (pdouble(p)^<valuescandoublemax);
  end;
end;

procedure TRescanpointers.execute;
var offsetsize: dword;
    offsetlist: array of dword;
    tempbuf: array [0..7] of byte;
    x,br: dword;
    i: integer;
    mi: TModuleInfo;

    stringlength: dword;
    ssize: dword;
    s: pchar;
    offset: dword;
    pointermatch: boolean;
begin
  pointersfound:=0;

  newpointerlist:=tmemorystream.Create;
  oldpointerlist.Seek(0,sofrombeginning);

  progressbar.Min:=0;
  progressbar.Max:=oldpointerlist.Size;

  s:=nil;
  getmem(s,100);

  try
    ssize:=100;

    setlength(offsetlist,10);
    while oldpointerlist.Position<oldpointerlist.Size do
    begin
      oldpointerlist.ReadBuffer(stringlength,sizeof(stringlength));
      if ssize<=stringlength then
      begin
        freemem(s);
        s:=nil;
        getmem(s,stringlength+1);
        ssize:=stringlength+1;
      end;

      oldpointerlist.ReadBuffer(s^,stringlength);
      s[stringlength]:=#0;

      oldpointerlist.ReadBuffer(offset,sizeof(offset));

  
      oldpointerlist.ReadBuffer(offsetsize,sizeof(offsetsize));
      if length(offsetlist)<(offsetsize+1) then
        setlength(offsetlist,offsetsize*2);

      oldpointerlist.ReadBuffer(offsetlist[0],offsetsize*sizeof(offsetlist[0]));
      //now check if it matches, and if so, save it back to the newpointerlist


      try
        x:=symhandler.getAddressFromName(s,true)+offset;

        for i:=0 to offsetsize-1 do
        begin
          if not readprocessmemory(processhandle,pointer(x),@x,sizeof(x),br) then
          begin
            //unreadable pointer
            progressbar.Position:=oldpointerlist.Position;
            x:=address+1;
            break;
          end;

          inc(x,offsetlist[i]);
        end;

        
        if forvalue then
        begin
          //also check that x contains the proper value
          if valuetype=vtdouble then //8 bytes long
            pointermatch:=readprocessmemory(processhandle,pointer(x),@tempbuf[0],8,br)
          else
            pointermatch:=readprocessmemory(processhandle,pointer(x),@tempbuf[0],4,br);

          pointermatch:=pointermatch and ismatchtovalue(@tempbuf[0]);
          
        end
        else
        begin
          pointermatch:=x=address;
        end;

        if pointermatch then
        begin
          newpointerlist.WriteBuffer(stringlength,sizeof(stringlength));
          newpointerlist.WriteBuffer(s^,stringlength);
          newpointerlist.WriteBuffer(offset,sizeof(offset));

          newpointerlist.WriteBuffer(offsetsize,sizeof(offsetsize));
          newpointerlist.WriteBuffer(offsetlist[0],offsetsize*sizeof(offsetlist[0]));
          inc(pointersfound);
        end;
      except
        //not valid, so dont save
      end;

      progressbar.Position:=oldpointerlist.Position;
    end;

  finally
    postmessage(frmPointerScanner.Handle,rescan_done,0,0);
    if s<>nil then freemem(s);
  end;
end;

procedure Tfrmpointerscanner.Rescanmemory1Click(Sender: TObject);
var address: dword;
    saddress: string;
    FloatSettings: TFormatSettings;
    floataccuracy: integer;
    i: integer;
begin
  GetLocaleFormatSettings(GetThreadLocale, FloatSettings);
  saddress:='';

  rescan:=trescanpointers.create(true);
  rescan.progressbar:=progressbar1;
  rescan.oldpointerlist:=pointerlist;


  try

    with TFrmRescanPointer.Create(self) do
    begin
      try
        if showmodal=mrok then
        begin
          Rescanmemory1.Enabled:=false;
          Save1.Enabled:=false;
          new1.Enabled:=false;
          showresults1.Enabled:=false;

          if rbFindAddress.Checked then
          begin
            address:=strtoint('$'+edtAddress.Text);

            //rescan the pointerlist

            rescan.address:=address;
            rescan.forvalue:=false;

          end
          else
          begin

            //if values, check what type of value
            floataccuracy:=pos(FloatSettings.DecimalSeparator,frmpointerscannersettings.edtAddress.Text);
            if floataccuracy>0 then
              floataccuracy:=length(frmpointerscannersettings.edtAddress.Text)-floataccuracy;

            case cbValueType.ItemIndex of
              0:
              begin
                rescan.valuetype:=vtDword;
                val(edtAddress.Text, rescan.valuescandword, i);
                if i>0 then raise exception.Create(edtAddress.Text+' is not a valid 4 byte value');
              end;

              1:
              begin
                rescan.valuetype:=vtSingle;
                val(edtAddress.Text, rescan.valuescansingle, i);
                if i>0 then raise exception.Create(edtAddress.Text+' is not a valid floating point value');
                rescan.valuescansingleMax:=rescan.valuescansingle+(1/(power(10,floataccuracy)));
              end;

              2:
              begin
                rescan.valuetype:=vtDouble;
                val(edtAddress.Text, rescan.valuescandouble, i);
                if i>0 then raise exception.Create(edtAddress.Text+' is not a valid double value');
                rescan.valuescandoubleMax:=rescan.valuescandouble+(1/(power(10,floataccuracy)));
              end;
            end;



            rescan.forvalue:=true;

          end;
          rescan.resume;
        end;


      finally
        free;
      end;
    end;


  except
    on e: exception do
    begin
      Rescanmemory1.Enabled:=true;
      Save1.Enabled:=true;
      new1.Enabled:=true;
      showresults1.Enabled:=true;


      freeandnil(rescan);
      raise e;
    end;

  end;

end;

procedure tfrmpointerscanner.rescandone(var message: tmessage);
{
The rescan is done. rescan.oldpointerlist (the current pointerlist) can be deleted
and the new pointerlist becomes the current pointerlist
}
begin
  if pointerlist<>nil then freeandnil(pointerlist);
  if rescan<>nil then
  begin
    pointerlist:=rescan.newpointerlist;
    freeandnil(rescan);
  end;

  doneui;
    
  showresults1.Enabled:=true;
  Rescanmemory1.Enabled:=true;
  Save1.Enabled:=true;
  new1.Enabled:=true;

  showresults1.Click;  
end;

procedure Tfrmpointerscanner.btnStopScanClick(Sender: TObject);
begin
  if staticscanner<>nil then
  begin
    staticscanner.Terminate;
    staticscanner.WaitFor;
  end;
end;

procedure Tfrmpointerscanner.FormClose(Sender: TObject;
  var Action: TCloseAction);
var i,j: integer;
begin
  


  action:=cafree; //on close free itself
  frmpointerscanner:=nil; //and set it to nil so other objects that use it will have to recreate it

  {$ifdef injectedpscan}
  FreeLibraryAndExitThread(hinstance,0);
  {$endif}
end;

procedure Tfrmpointerscanner.FormShow(Sender: TObject);
begin
  label9.Left:=0;
  label9.Top:=frmPointerScanner.ClientHeight-progressbar1.Height;
end;

procedure Tfrmpointerscanner.openscanner(var message: tmessage);
begin
  if frmpointerscannersettings=nil then
    frmpointerscannersettings:=tfrmpointerscannersettings.create(nil);

  frmpointerscannersettings.edtAddress.text:=inttohex(message.WParam,8);
  Method3Fastspeedandaveragememoryusage1.Click;
end;


procedure Tfrmpointerscanner.tvResultsDblClick(Sender: TObject);
{$ifdef injectedpscan}
var ms: tmemorystream;
    x: dword;
    t: ttreenode;

    p: thandle;
    targetbuffer: pointer;
    CDS: COPYDATASTRUCT;
begin
  t:=tvResults.Selected;
  if t=nil then exit;
  if t.Level<>0 then exit;

  ms:=tmemorystream.Create;
  try
    x:=length(tvResults.Selected.Text);
    ms.WriteBuffer(x,sizeof(x));
    ms.WriteBuffer(tvResults.Selected.Text[1],x);

    t:=t.GetLastChild;

    while t<>nil do
    begin
      x:=strtoint('$'+t.Text);
      ms.WriteBuffer(x,4);
      t:=t.getPrevSibling;
    end;

    cds.dwData:=$ce;
    cds.cbData:=ms.Size;
    cds.lpData:=ms.Memory;
    sendmessage(scansettings.mainformHandle,WM_COPYDATA,handle,dword(@CDS));
  finally
    ms.free;
  end;
end;
{$else}
var base :ttreenode;
    baseaddress: dword;
    offsets: array of dword;
    i: integer;
    t: string;
begin
 { base:=tvResults.Selected;
  if base<>nil then
  begin
    if base.Level=1 then
      base:=base.Parent;

    t:=base.Text;

    baseaddress:=symhandler.getAddressFromName(t);
    setlength(offsets,base.count);

    base:=base.getFirstChild;
    i:=length(offsets)-1;
    while base<>nil do
    begin
      offsets[i]:=strtoint('$'+base.Text);
      base:=base.GetNextsibling;
      dec(i);
    end;

    mainform.addaddress('pointerscan result',baseaddress,offsets,length(offsets),true,2,0,0,false);
    mainform.memrec[length(mainform.memrec)-1].pointers[length(mainform.memrec[length(mainform.memrec)-1].pointers)-1].Interpretableaddress:=t;
  end;    }
end;
{$endif}

procedure Tfrmpointerscanner.New1Click(Sender: TObject);
var i: integer;
begin
  btnStopScan.click;
  if staticscanner<>nil then
    freeandnil(staticscanner);

 
  pgcPScandata.Visible:=false;
  panel1.Caption:='';
  open1.Enabled:=true;
  new1.enabled:=true;
  save1.Enabled:=false;
  rescanmemory1.Enabled:=false;
  showresults1.enabled:=false;

  

  if drawtreeviewthread<>nil then
  begin
    drawtreeviewthread.Terminate;
    drawtreeviewthread.WaitFor;
    freeandnil(drawtreeviewthread);
  end;


  {
  if vm<>nil then
    freeandnil(vm);  }


    
  setlength(staticlist,0);


  for i:=0 to length(treenodeswithchildren)-1 do
    freeandnil(treenodeswithchildren[i]);

  setlength(treenodeswithchildren,0);

  if matchednodescs<>nil then freeandnil(matchednodescs);

  for i:=0 to length(matchednodes)-1 do
    setlength(matchednodes[i],0);
  setlength(matchednodes,0);

  if pointerlist<>nil then freeandnil(pointerlist);  
end;



procedure Tfrmpointerscanner.FormCreate(Sender: TObject);
begin
  tsPSDefault.TabVisible:=false;
  tsPSReverse.TabVisible:=false;

  {$ifdef injectedpscan}
  caption:='CE Injected Pointerscan';
  {$endif}

end;

procedure Tfrmpointerscanner.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Staticscanner<>nil then
    canclose:=false
  else
    canclose:=true;

  btnStopScanClick(Button1);

  if Staticscanner<>nil then
  begin
    Staticscanner.Terminate;
    Staticscanner.WaitFor;
    freeandnil(Staticscanner);
  end;

  postmessage(handle,wm_close,0,0);
end;

procedure Tfrmpointerscanner.tvResultCompare(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  compare:=0;
  if (node1.Level>0) or (node2.level>0) then exit;

  if node1.Text<node2.Text then
    compare:=-1
  else
  if node1.Text>node2.Text then
    compare:=1;


end;


procedure Tfrmpointerscanner.Sortlist1Click(Sender: TObject);
var i,j: integer;
begin
 { tvResults.OnCompare:=tvResultCompare;
  tvResults.AlphaSort(false);  }
end;

procedure Tfrmpointerscanner.ListView1Data(Sender: TObject;
  Item: TListItem);
var i: integer;
    offset: dword;
    actualoffsetcount: integer;
begin
  pointerfile.Position:=pointerfileStartPosition+item.Index*sizeofentry;
  pointerfile.Read(i,sizeof(i));
  pointerfile.read(offset,sizeof(offset));
  item.Caption:=modulelist[i]+'+'+inttohex(offset,1);

  pointerfile.Read(actualoffsetcount,sizeof(actualoffsetcount));


  {
  results.WriteBuffer(staticdata.offset,sizeof(staticdata.offset));
  i:=level+1; //store many offsets are actually used (since all are saved)
  results.WriteBuffer(i,sizeof(i));
  results.WriteBuffer(tempresults[0], maxlevel*sizeof(tempresults[0]) );
  }
  for i:=0 to actualoffsetcount-1 do
  begin
    pointerfile.Read(offset,sizeof(offset));
    if i>=item.SubItems.Count then
      item.SubItems.Add(inttohex(offset,1))
    else
      item.SubItems[i]:=inttohex(offset,1);
  end;

  for i:=actualoffsetcount to item.SubItems.Count-1 do
    item.SubItems[i]:='';
end;

end.


