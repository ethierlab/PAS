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

% Last Modified by GUIDE v2.5 04-Jun-2018 17:51:05

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
handles.meanMEPs    = [];
handles.params = struct(...
    'emg_vec'       , [1 2],...
    'time_before'   , 100,...
    'time_after'    , 500,...
    'rectify'       , true,...
    'median'        , true,...
    'time_window'   , [0 200]);

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
    if isfield(data_tmp,'meanMEPs')
        handles.meanMEPs = data_tmp.meanMEPs;
        assignin('base','meanMEPs',handles.meanMEPs);
        %update data table with MEP values
        for i = 1:length(handles.meanMEPs.chan_list)
            handles.data_table.ColumnName{i+1} = sprintf('MEP ch%d (uV)',handles.meanMEPs.chan_list(i));
        end
        for b = 1:size(handles.data_array,1)
            for c = 1:length(handles.meanMEPs.chan_list)
                handles.data_table.Data{b,c+1} = handles.meanMEPs.MEPs(b,c)*10^6;
            end
        end
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
    meanMEPs   = handles.meanMEPs;
    save(fullfile(handles.pathname,handles.filename),'matdata','meanMEPs');
    fprintf('File %s\n saved successfully\n',fullfile(handles.pathname,handles.filename));
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
    handles.meanMEPs    = [];
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
        meanMEPs = calc_mean_MEPs(handles.data_array,'rectify',handles.params.rectify,...
            'median',handles.params.median,...
            'window',handles.params.time_window,...
            'emg_vec',handles.params.emg_vec);
        assignin('base','meanMEPs',meanMEPs);
    end
else
    warning('Please convert to ELF format first');
    return;
end

%update data table with MEP values
handles.data_table.Data = handles.data_table.Data(:,1);
handles.data_table.ColumnName = handles.data_table.ColumnName(1);
for i = 1:length(meanMEPs.chan_list)
    if meanMEPs.integral
        handles.data_table.ColumnName{i+1} = sprintf('MEP ch%d (mV*ms)',meanMEPs.chan_list(i));
    else
        handles.data_table.ColumnName{i+1} = sprintf('MEP ch%d (mVpp)',meanMEPs.chan_list(i));
    end
end

for b = 1:size(handles.data_array,1)
    for c = 1:length(meanMEPs.chan_list)
        handles.data_table.Data{b,c+1} = meanMEPs.MEPs(b,c);
    end
end

handles.meanMEPs = meanMEPs;

% update handles in guidata
guidata(hObject, handles);
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
                                    'time_range',[-handles.params.time_before handles.params.time_after]/1000);
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

if isempty(handles.meanMEPs)
    warning('Please calculate MEPs first');
    return;
end
PAS_plot_bar(handles.meanMEPs,handles.data_select,handles.params.emg_vec)
end

%-------------------------------------------------------------------------------------------------------
%% TABLE
function data_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.data_select = eventdata.Indices(:,1);
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
% hObject    handle to time_after_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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

function mean_radio_Callback(hObject, eventdata, handles)
handles.params.median = ~hObject.Value;
% update handles in guidata
guidata(hObject, handles);
end

function median_radio_Callback(hObject, eventdata, handles)
handles.params.median = hObject.Value;
% update handles in guidata
guidata(hObject, handles);
end
