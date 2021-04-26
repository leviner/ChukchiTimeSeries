%
%  script EV_surfacereferenced_DY1502_macebase2.m
%
%  MACE ECHOVIEW EXPORT SCRIPT MODIFIED FOR MACEBASE2 EXPORTS
%
%
%  Our standard template exports the following:
%
%  Analysis common:
%    Date_S
%    Lat_S
%    Lon_S
%    Num_intervals
%    Num_layers
%    Time_S
%    VL_end
%    VM_start
%
%  Analysis domain:
%    Exclude_above_line_depth_mean
%    Exclude_below_line_depth_mean
%    First_layer_depth_start
%    Last_layer_depth_start
%    Layer_depth_min
%    Layer_depth_max
%
%  Analysis Export:
%    EV_filename
%    Processing_date
%    Processing_time
%    Program_version
%
%  Integration results:
%    NASC
%    PRC_NASC
%
%  Integration settings:
%    Alpha
%    Exclude_above_line_applied
%    Exclude_below_line_applied
%    Gain_constant
%    Maximum_integration_threshold
%    Maximum_Sv_threshold_applied
%    Minimum_integration_threshold
%    Minimum_Sv_threshold_applied
%    Noise_Sv_1m
%
%
%  FOR MACEBASE2 EXPORTS WE ADD THE FOLLOWING:
%
%  Analysis common:
%    Date_E
%    Lat_E
%    Lon_E
%    Time_E
%    Region_notes
%
%  Analysis domain:
%    Grid_reference_line
%    Layer_bottom_to_reference_line_depth
%    Layer_top_to_reference_line_depth
%    Samples_In_Domain
%    Good_samples
%    No_data_samples
%
%  Integration results:
%    Sv_max



% --------------------------------------------------------------------------
% ------------------------ edit these variables ----------------------------
% --------------------------------------------------------------------------

%  define the input file path - directory paths must end with a slash
EVFilePath = 'E:\ChukchiTimeSeries\data\acousticData\2017_2019\EV\2017\echoview\';  

%  define the output file path
ExportFileBase = 'E:\ChukchiTimeSeries\data\acousticData\2017_2019\EV\2017\echoview\exports\5m_long\';   

%set .ecs file (calibration file) to use.
%ECSfilename = 'G:\DY1502\calibration\DY1502postcal.ecs';
ECSfilename = 'E:\ChukchiTimeSeries\data\acousticData\2017_2019\EV\2017\calibration\Ocean_Starr_2017_MB2_long.ecs';
 %typically it's Fileset 1 in our survey templates
Filesetname = 'Primary fileset'; 

%sets the variable to export from each file, typically '38 kHz for survey'
Variable_for_export  = '38 kHz unfiltered data';  

%  define the thresholds
minimum_integration_threshold = -70;  %typically -70 dB Sv 
maximum_integration_threshold = 0;  %an Sv of 0 dB seems reasonable

%  define the grid parameters
layer_thickness = 5;  %surface-reference layer thickness, typically 10 m,
EDSU_length = 0.5;  %typically 0.5 nmi

% Update raw file path
newRawFiles = 0;
rawDir = 'D:\AIESII\OceanStarr_201701_AIERP\EK60_Data';


%  define the zones
%
%  zone contains the zone number that corresponds to the zone defined in
%  the exclude_above_line_name/exclude_below_line_name. The first element
%  in this array will correspond to the zone defined by the first elements
%  in the exclude_above_line_name/exclude_below_line_name arrays and so on.
%  The script will export a set of files for each zone defined here.
zone = [0];
%  exclude_above_line_name/exclude_below_line_name contain the EV lines that
%  define each of the zones. They are paired element wise so the first zone
%  is between the first element in exclude_above_line_name and the first
%  element in exclude_below_line_name, the second is between the 2nd
%  elements and so on.
exclude_above_line_name= {'surface_exclusion'};
exclude_below_line_name= {'bottom_exclusion'};


%----------------------------------------------------------------------------
%----------------------- end user editable variables ------------------------
%----------------------------------------------------------------------------


%  start the show...
disp('Echoview export script is running')

%make a list of the EV files in the above directory
files = dir([EVFilePath '*0-LONGPULSE.ev']);
files.name

% loop -- select each file, open file, find variable to export
for i = 1:size(files,1);
    disp(['Working on File ' num2str(i) ' of ' num2str(size(files,1))])
    %  create the EV COM object "EvApp"
    EvApp = actxserver('EchoviewCom.EvApplication'); 
    %  minimize it...
    EvApp.Minimize;

    % most settings already made in EV files.  Make sure of the following:
    
    %open file and select the variable for export
    EvFilename = [EVFilePath files(i).name];
    EvFile = EvApp.OpenFile(EvFilename);
    EvVar =  EvFile.Variables.FindByName(Variable_for_export);
    
    %force pre-read of data files using a method
    EvFile.PreReadDataFiles;  
    if newRawFiles == 1
        EvFile.Properties.DataPaths.Add(rawDir)
        EvFile.SaveAs(EvFilename)
        EvApp.CloseFile(EvFile)
        EvFile = EvApp.OpenFile(EvFilename);
        EvVar =  EvFile.Variables.FindByName(Variable_for_export);
    end

    %find the fileset and set the .ecs file (calibration file) to use for it
    Evfileset = EvFile.Filesets.FindByName(Filesetname);
    calfiletest = Evfileset.SetCalibrationFile(ECSfilename);
    %  check to see if .ecs file change was successful
    if calfiletest~=1
        disp(['FATAL: Failed to read the .ecs file: ' ECSfilename]);
        disp('We are out of here!');
        break;
    end

    %  Add in the additional variables for export as defined above  
    Date_E=EvFile.Properties.Export.Variables.Item('Date_E');
    Date_E.Enabled=1;
    
    Lat_E=EvFile.Properties.Export.Variables.Item('Lat_E');
    Lat_E.Enabled=1;
    
    Lon_E=EvFile.Properties.Export.Variables.Item('Lon_E');
    Lon_E.Enabled=1;
    
    Time_E=EvFile.Properties.Export.Variables.Item('Time_E');
    Time_E.Enabled=1;
    
    Region_notes=EvFile.Properties.Export.Variables.Item('Region_notes');
    Region_notes.Enabled=1;
    
    Grid_reference_line=EvFile.Properties.Export.Variables.Item('Grid_reference_line');
    Grid_reference_line.Enabled=1;
    
    Layer_btrld=EvFile.Properties.Export.Variables.Item('Layer_bottom_to_reference_line_depth');
    Layer_btrld.Enabled=1;
    
    Layer_ttrld=EvFile.Properties.Export.Variables.Item('Layer_top_to_reference_line_depth');
    Layer_ttrld.Enabled=1;
    
    Samples_In_Domain=EvFile.Properties.Export.Variables.Item('Samples_In_Domain');
    Samples_In_Domain.Enabled=1;
    
    Good_samples=EvFile.Properties.Export.Variables.Item('Good_samples');
    Good_samples.Enabled=1;
    
    No_data_samples=EvFile.Properties.Export.Variables.Item('No_data_samples');
    No_data_samples.Enabled=1;    
        
    Sv_max=EvFile.Properties.Export.Variables.Item('Sv_max');
    Sv_max.Enabled=1;  
    
    %  set thresholds
    EvVar.Properties.Data.ApplyMinimumThreshold= 1; 
    EvVar.Properties.Data.MinimumThreshold= minimum_integration_threshold;
    EvVar.Properties.Data.ApplyMaximumThreshold= 1;
    EvVar.Properties.Data.MaximumThreshold= maximum_integration_threshold;
    
    % Before setting the grid, make sure the gps is set
    EvPlatform = EvFile.Platforms.Item(0);
    EvPlatform.PositionSource = EvFile.Variables.FindByName('Primary fileset: position GPS fixes');
    
    %  set grid settings for range in m and distance in nmi as defined by VL
    EvVar.Properties.Grid.SetDepthRangeGrid(1,layer_thickness);
    EvVar.Properties.Grid.SetTimeDistanceGrid(3,EDSU_length);

    %  export the regions logfile
    ExportFileName = [ExportFileBase, files(i).name(1:26),' (regions).csv'];
    exporttest = EvVar.ExportRegionsLogAll(ExportFileName);
    %  check to see if export was successful, if not, print error message to screen
    if exporttest~=1
        disp(['The system has failed - unable to regions logbook ' ExportFileName]);
    end
    
    %  loop through the zones, exporting them
    for z=1:length(zone)
    
        %  set exclusion lines
        EvVar.Properties.Analysis.ExcludeAboveLine = exclude_above_line_name{z};
        EvVar.Properties.Analysis.ExcludeBelowLine = exclude_below_line_name{z};

        %  assemble filename and do the export
        ExportFileName = [ExportFileBase, files(i).name(1:26),'z',num2str(zone(z)),'-','.csv'];
        exporttest = EvVar.ExportIntegrationByRegionsByCellsAll(ExportFileName);
        
        %  check to see if export was successful, if not, print error message to screen
        if exporttest~=1
            disp(['The system has failed - unable to export ' ExportFileName]);
        end
   end
    
    %close application
    EvApp.Quit;

end

disp('All done!')