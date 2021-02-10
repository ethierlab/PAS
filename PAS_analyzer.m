function varargout = PAS_analyzer(varargin)
% PAS_ANALYZER MATLAB code for PAS_analyzer.fig
%      PAS_ANALYZER, by itself, creates a new PAS_ANALYZER or raises the existing
%      singleton*.
%
%      H = PAS_ANALYZER returns the handle to a new PAS_ANALYZER or the handle to
%      the existing singleton*.
%
%      PAS_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAS_ANALYZER.M with the given input arguments.
%
%      PAS_ANALYZER('Property','Value',...) creates a new PAS_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PAS_analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PAS_analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PAS_analyzer

% Last Modified by GUIDE v2.5 05-Mar-2020 13:15:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PAS_analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @PAS_analyzer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT

% --- Executes just before PAS_analyzer is made visible.
function PAS_analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PAS_analyzer (see VARARGIN)

% Choose default command line output for PAS_analyzer
handles.output = hObject;

handles.data_array  = {};
handles.data_select = [];
handles.pathname    = '';
handles.filename    = '';
handles.MEPs        = [];
handles.params = struct(...
    'emg_vec'       , [1],...
    'time_before'   , 100,...
    'time_after'    , 500,...
    'amp_gain'      , 1,...
    'rectify'       , true,...
    'bar_plot_select', 'int_ave',...
    'time_window'   , [10 20]);

% Update handles structure
guidata(hObject, handles);
end
% UIWAIT makes PAS_analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = PAS_analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
%-------------------------------------------------------------------------------------------------------
%% BUTTONS

%IMPORT
function import_button_Callback(hObject, eventdata, handles)
[handles.data_array, num_data_files, handles.pathname] = TDT_import();
if ~isempty(handles.pathname)
    handles.data_table.Data = handles.data_array(:,2:end);
else
    disp('Import cancelled');
end
%update handles in guidata
guidata(hObject, handles);
end

% --- Executes on button press in import_lc_button.
function import_lc_button_Callback(hObject, eventdata, handles)
% hObject    handle to import_lc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.data_array, num_data_files, handles.pathname] = LC_import('time_before',handles.params.time_before/1000,'time_after',handles.params.time_after/1000);
if ~isempty(handles.pathname)
    handles.data_table.Data = handles.data_array(:,2:end);
else
    disp('Import cancelled');
end
%update handles in guidata
guidata(hObject, handles);
end

%LOAD
function load_button_Callback(hObject, eventdata, handles)
% load matlab file from folder:
disp('Select .mat to analyze');
[filename, pathname] = uigetfile(fullfile(handles.pathname,'*.mat'),'Select .mat file to analyze');
if pathname
    %user did not press cancel
    handles.filename = filename;
    handles.pathname = pathname;
    data_tmp           = load(fullfile(handles.pathname,handles.filename));
    if ~isfield(data_tmp,'matdata')
        warning('Incompatible data file. Data load failed');
        return;
    end
    %load data_array
    handles.data_array = data_tmp.matdata;
    handles.data_table.Data = handles.data_array(:,2:end);
    handles.data_table.ColumnName = handles.data_table.ColumnName(1);
    %load MEPs if any
    if isfield(data_tmp,'MEPs')
        handles.MEPs = data_tmp.MEPs;
        assignin('base','MEPs',handles.MEPs);
        
        %update data table with MEP values
        handles = update_meps(handles);
    end
    clear data_tmp;
    %update handles in guidata
    guidata(hObject, handles);
end
end

%SAVE
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile(fullfile(handles.pathname,handles.filename),'Save data array');
if pathname
    % user did not press cancel, update file info in handles
    handles.filename = filename;
    handles.pathname = pathname;
    matdata    = handles.data_array;
    MEPs       = handles.MEPs;
    rat_name = get(handles.edit6, 'String');
    session_date = handles.session_date;
    STDP_condition = handles.STDP_condition;
    window = handles.params.time_window;
    save(fullfile(handles.pathname,handles.filename),'matdata','MEPs','rat_name','session_date','STDP_condition','window');
    fprintf('File %s\n saved successfully. Open quickload.mat to see measurement time window.\n',fullfile(handles.pathname,handles.filename));
    clear data_array;
    % update handles in guidata
    guidata(hObject, handles);
end
end

%CLEAR
function clear_button_Callback(hObject, eventdata, handles)
clear_data = questdlg('Are you sure you want to clear all data?', ...
    'Confirm clear', ...
    'Yes', 'Cancel', 'Yes');
if strcmp(clear_data,'Yes')
    handles.data_array  = {};
    handles.data_select = [];
    handles.pathname    = '';
    handles.filename    = '';
    handles.MEPs        = [];
    set ([handles.edit6, handles.edit7, handles.edit8], 'String','');
    handles.data_table.Data = [];
    handles.data_table.ColumnName = handles.data_table.ColumnName(1);
else
    disp('Clear data cancelled');
end
    % update handles in guidata
    guidata(hObject, handles);
end

%LOAD WS
function load_ws_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_ws_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i = 1:length(handles.data_select)
    assignin('base',handles.data_array{handles.data_select(i),2},handles.data_array{handles.data_select(i),1});
end
assignin('base','rat_name',get(handles.edit6, 'String'));
assignin('base','session_date',get(handles.edit7, 'String'));
assignin('base','exp_condition',get(handles.edit8, 'String'));
end

%CONV2ELF
function conv2ELF_button_Callback(hObject, eventdata, handles)
% hObject    handle to conv2ELF_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.data_array{1,1},'format')
    handles.data_array = convertTDT2ELformat(handles.data_array);
    disp('Data converted to ELF format');
elseif ~strcmpi(handles.data_array{1,1}.format,'ELF')
    handles.data_array = convertTDT2ELformat(handles.data_array);
    disp('Data converted to ELF format');
else
    disp('Data already in ELF format');
end
% update handles in guidata
guidata(hObject, handles);      
end

%VALIDATE
function validate_snips_button_Callback(hObject, eventdata, handles)
% hObject    handle to validate_snips_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if length(handles.data_select)>1
    msgbox('Please select only one data block at a time','Wô les moteurs!','warn')
else
    if isfield(handles.data_array{1,1},'format')
        if strcmpi(handles.data_array{1,1}.format,'ELF')
            data = validate_EMG_snips_ELF(handles.data_array{handles.data_select,1},handles.params);
            handles.data_array{handles.data_select,1} = data;
            set(handles.data_table,'Data',handles.data_array(:,2));
            clear data;
        end
    else
        warning('Please convert to ELF format first');
    end
end

% update handles in guidata
guidata(hObject, handles);
end

%GET MEP
function get_mep_button_Callback(hObject, eventdata, handles)
% hObject    handle to get_mep_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.data_array{1,1},'format')
    if strcmpi(handles.data_array{1,1}.format,'ELF')
        MEPs = calc_mean_MEPs(handles.data_array,...
            'window',handles.params.time_window,...
            'emg_vec',handles.params.emg_vec,...
            'amp_gain',handles.params.amp_gain);
        assignin('base','MEPs',MEPs);
    end
    handles.MEPs = MEPs;
    
    %update data table with MEP values
    handles = update_meps(handles);
else
    warning('Please convert to ELF format first');
    return;
end

% update handles in guidata
guidata(hObject, handles);
end

function handles = update_meps(handles)
%update data table with MEP values
handles.data_table.Data = handles.data_table.Data(:,1);
handles.data_table.ColumnName = handles.data_table.ColumnName(1);

if ~isempty(handles.MEPs)
    num_ch = length(handles.MEPs.chan_list);
    for c = 1:num_ch
        %column label:
        handles.data_table.ColumnName{c+1}        = sprintf('MEP p2p ch%d (mVpp)',handles.MEPs.chan_list(c));
        handles.data_table.ColumnName{c+1+num_ch} = sprintf('MEP int ch%d (mV*ms)',handles.MEPs.chan_list(c));
        %display mean meps for each block
        for b=1:size(handles.data_array,1)
            handles.data_table.Data{b,c+1} = handles.MEPs.p2p.mean(b,c);
            handles.data_table.Data{b,c+1+num_ch} = handles.MEPs.integral.mean(b,c);
        end
    end
end
end

%PLOT EMG
function plot_emg_button_Callback(hObject, eventdata, handles)
if isempty(handles.data_select)
    warning('Please select a data set first');
    return;
end
    
if isfield(handles.data_array{1,1},'format')
    if strcmpi(handles.data_array{1,1}.format,'ELF')
        meanEMGs  = mean_EMG_traces(handles.data_array(handles.data_select,:),...
                                    handles.params.emg_vec,'rectify',handles.params.rectify,...
                                    'time_range',[-handles.params.time_before handles.params.time_after]/1000,...
                                    'amp_gain', handles.params.amp_gain);
        assignin('base','meanEMGs',meanEMGs);
        
    end
else
    disp('Please convert to ELF format first');
end
end

%BAR PLOT
function bar_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to bar_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.data_select)
    warning('Please select rows in data tables');
    return;
end

if isempty(handles.MEPs)
    warning('Please calculate MEPs first');
    return;
end
PAS_plot_bar(handles.MEPs,handles.data_select,handles.params.emg_vec,handles.params.bar_plot_select)
end

%-------------------------------------------------------------------------------------------------------
%% TABLE
function data_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.data_select = unique(eventdata.Indices(:,1));
guidata(hObject, handles);
end

%% PARAMS
%EMG VEC
function emg_vec_edit_Callback(hObject, eventdata, handles)
% hObject    handle to emg_vec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emg_vec_edit as text
%        str2double(get(hObject,'String')) returns contents of emg_vec_edit as a double
val = hObject.String;
if strcmpi(val,':')
    %if ':', use all available emgs, set handles.emg_vec to empty array
    handles.params.emg_vec = [];
else
    %otherwise, set handles.emg_vec to value in emg_vec_edit textbox    
    try val = eval(val);
    catch
        warning('Invalid EMG chan vector format. Use standard matlab vector format.');
        handles.params.emg_vec_edit.String = ':';
    end
    handles.params.emg_vec = val;
end
% update handles in guidata
guidata(hObject, handles);
end

function emg_vec_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emg_vec_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%TIME BEFORE / TIME AFTER
function time_before_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_before_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_before_edit as text
%        str2double(get(hObject,'String')) returns contents of time_before_edit as a double
handles.params.time_before = str2double(hObject.String);
% update handles in guidata
guidata(hObject, handles);
end

function time_before_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_before_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function time_after_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_after_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_after_edit as text
%        str2double(get(hObject,'String')) returns contents of time_after_edit as a double
handles.params.time_after = str2double(hObject.String);
% update handles in guidata
guidata(hObject, handles);
end

function time_after_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% GAIN
% --- Executes during object creation, after setting all properties.
function amp_gain_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amp_gain_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function amp_gain_edit_Callback(hObject, eventdata, handles)
handles.params.amp_gain = str2double(hObject.String);
guidata(hObject, handles);
end

%RECTIFY
function rectify_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to rectify_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rectify_cbx

handles.params.rectify = get(hObject,'Value');
% update handles in guidata
guidata(hObject, handles);
end


function time_window_edit_Callback(hObject, eventdata, handles)
val = hObject.String;
    try val = eval(val);
        if numel(val)~=2
            warning('Invalid time window vector format. Enter a 2-element vecgtor in strandard matlab format.');
            handles.time_window_edit.String = [ '[' num2str(handles.params.time_window) ']'];
        else
            handles.params.time_window = val;
        end
    catch 
        warning('Invalid time window vector format. Use standard matlab vector format.');
        handles.time_window_edit.String = [ '[' num2str(handles.params.time_window) ']'];
    end
% update handles in guidata
guidata(hObject, handles);
end

function time_window_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_window_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function int_radio_Callback(hObject, eventdata, handles)
handles.params.bar_plot_select = 'integral';
% update handles in guidata
guidata(hObject, handles);
end

function p2p_radio_Callback(hObject, eventdata, handles)
handles.params.bar_plot_select = 'p2p';
% update handles in guidata
guidata(hObject, handles);
end


% --- Executes on button press in int_ave_radio.
function int_ave_radio_Callback(hObject, eventdata, handles)
handles.params.bar_plot_select = 'int_ave';
% update handles in guidata
guidata(hObject, handles);
end


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.rat_name = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.session_date = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.STDP_condition = get(hObject, 'String');
% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

