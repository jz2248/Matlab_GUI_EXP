function varargout = chuli(varargin)
% CHULI MATLAB code for chuli.fig
%      CHULI, by itself, creates a new CHULI or raises the existing
%      singleton*.
%
%      H = CHULI returns the handle to a new CHULI or the handle to
%      the existing singleton*.
%
%      CHULI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHULI.M with the given input arguments.
%
%      CHULI('Property','Value',...) creates a new CHULI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chuli_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chuli_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chuli

% Last Modified by GUIDE v2.5 26-Jan-2021 11:33:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chuli_OpeningFcn, ...
                   'gui_OutputFcn',  @chuli_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before chuli is made visible.
function chuli_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chuli (see VARARGIN)
axes(handles.axes1);
imshow([255]);
axes(handles.axes2);
imshow([255]);
axes(handles.axes3);
imshow([255]);
% Choose default command line output for chuli
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chuli wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chuli_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

global directoryname
global tu
global index
global sorted
axes(handles.axes1)
total = length(sorted)
index = fix(total * get(handles.slider1,'value')) + 1;

info = dicominfo(strcat(directoryname,'/',sorted(index).imagename));
%open and show the image
Y = dicomread(info);
Y2 = uint8(Y);
imshow(Y2);
tu = Y2;
title(num2str(index));
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global directoryname
global tu
global index
global sorted


axes(handles.axes1)
directoryname = uigetdir;
%
if isequal([directoryname],[0])
    return
else
    %read image
    %list all files in the the directory
    lsName=strcat(directoryname,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    %get the total number of all files in this directory
    m = length(d);
    %create m rows 2 columns empty structure and name them as imagename and instance.
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        %read files one by one
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        %copy the name of all filenames and position into the imagename and instance in sdata
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading¡­¡­');
    end
    close(h);
    %make the instances in sdata in an increasing order
    [unused, order] = sort([sdata.instance],'ascend');
    %make order transpose to sorted
    sorted = sdata(order).';

    
    total = m;
    index = fix(total * get(handles.slider1,'value')) + 1;
    info = dicominfo(strcat(directoryname,'/',sorted(index).imagename));
    %info.InstanceNumber
    Y = dicomread(info);
    Y2 = uint8(Y);
    imshow(Y2);
    tu = Y2;
    title(num2str(index));
    %handle.axes1=b;
end

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global tu;
global m;
global mask;
axes(handles.axes1);
img_gray = tu;
fig_r = 2;
fig_c = 1;

[seed_col, seed_row] = ginput(1); % using mouse in GUI of matlab

seed_col = round(seed_col);
seed_row = round(seed_row);

blood_region = edge_based_region_growth(img_gray, 20, seed_row, seed_col, 0);
blood_edge = edge_based_region_growth(img_gray, 20, seed_row, seed_col, 1);

mean_blood = mean(img_gray(blood_region));
std_blood = std(double(img_gray(blood_region)));

% Threshold-based region-growth to estimate myocardial mean
[i_list, vol_list, mask] = threshold_based_region_growth(img_gray, blood_region, seed_row, seed_col, 0);


% Determine the optimal i which achieving best discontinuity
i_num = size(i_list, 2);
diff_i = diff(vol_list);             % (i_num - 1) elements
delta_i = zeros(1, i_num-2);         % (i_num - 2) elements
for x=1:(i_num-2)
    delta_i(x) = diff_i(x+1) / diff_i(x);
end

delta_i = [0, delta_i, 0]; % add 0 for dummy numbers
delta_i(not(isfinite(delta_i))) = 0; % inf changed to 0
[delta_max, i_opt_index] = max(delta_i);
i_spike_val = i_list(i_opt_index); % myocardial appears
i_opt_val = i_spike_val - 0.1;


% Estimate myocardial region, i.e. edge of LV
myocardial_region = explore_LV_region(img_gray, blood_region, i_spike_val, 0, seed_row, seed_col, 1);
myocardial_region = logical(myocardial_region);
lv_full_region = explore_LV_region(img_gray, blood_region, i_spike_val, 0, seed_row, seed_col, 0);


lv_full_val = img_gray(lv_full_region);
lv_full_vol = sum(lv_full_region(:));
std_myocardial = std(double(img_gray(myocardial_region)));
mean_myocardial = mean_blood / i_spike_val;
dummy_full_myocardial = uint8(normrnd(mean_myocardial, std_myocardial, [lv_full_vol, 1]));
dummy_full_blood = uint8(normrnd(mean_blood, std_blood, [lv_full_vol, 1]));


lv_window_lower = mean_myocardial + 4 * std_myocardial;
lv_window_upper = mean_blood - 4 * std_blood;
lv_region = fetch_LV_region(img_gray, blood_region, lv_window_lower, lv_window_upper, seed_row, seed_col, 0);

% figure;
img_mask = zeros(size(img_gray));
img_mask(lv_region) = img_gray(lv_region);
img_mask = uint8(img_mask);


tu2 = img_mask;
mask = lv_region;
axes(handles.axes2);
%get the length and width of the image

%show the image after segmented
imshow(tu2);
title('Image after Segmented');
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
global mask
global directorynamemask
global index
mulu2 = strcat(directorynamemask,'\',num2str(index),'.bmp');
imwrite(mask,mulu2);
msgbox('save successful');
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
global tu
axes(handles.axes1);
imshow(tu);
title('Reset');
axes(handles.axes2);
imshow([255]);

% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
global mask
global directoryname
global directoryname1
global directoryname2
global directoryname3
global directoryname4
global directoryname5
global directorynamemask
global sorted
global sorted1
global sorted2
global sorted3
global sorted4
global sorted5


zhistr = get(handles.listbox1,'string');
for index = 1:length(zhistr)
    index = str2num(zhistr{index});
    info = dicominfo(strcat(directoryname,'/',sorted(index).imagename));
    tu = dicomread(info);
    tu = uint8(tu);
    meanValue0 = getMeans(tu,mask);
    meanValue(1) = meanValue0;
    
    info = dicominfo(strcat(directoryname1,'/',sorted1(index).imagename));
    t1 = dicomread(info);
    t1 = uint8(t1);
    meanValue1 = getMeans(t1,mask);
    meanValue(2) = meanValue1;
    
    info = dicominfo(strcat(directoryname2,'/',sorted2(index).imagename));
    t1 = dicomread(info);
    t1 = uint8(t1);
    meanValue2 = getMeans(t1,mask);
    meanValue(3) = meanValue2;
    
    info = dicominfo(strcat(directoryname3,'/',sorted3(index).imagename));
    t1 = dicomread(info);
    t1 = uint8(t1);
    meanValue3 = getMeans(t1,mask);
    meanValue(4) = meanValue3;
    
    info = dicominfo(strcat(directoryname4,'/',sorted4(index).imagename));
    t1 = dicomread(info);
    t1 = uint8(t1);
    meanValue4 = getMeans(t1,mask);
    meanValue(5) = meanValue4;
    
    info = dicominfo(strcat(directoryname5,'/',sorted5(index).imagename));
    t1 = dicomread(info);
    t1 = uint8(t1);
    meanValue5 = getMeans(t1,mask);
    meanValue(6) = meanValue5;
    
    meanValue = meanValue - meanValue0;
    meanValueTotal(index,:) = meanValue;
end
if length(zhistr) >1
    meanValueTotal = sum(meanValueTotal);
end

meanValueTotal = meanValueTotal/length(zhistr);
axes(handles.axes3);
plot([0:5],meanValueTotal,'*-r');
grid on;
% axis([0 5 0 255]);
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global index
zhistr = get(handles.listbox1,'string');
zhistr{length(zhistr) + 1} = num2str(index);
set(handles.listbox1,'String',zhistr);
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)

index = get(handles.listbox1,'value')
zhistr = get(handles.listbox1,'string')
count = 0;
for i = 1:length(zhistr)
    if i~=index
        count = count + 1;
        str2{count} = zhistr{i};
    end
end
if index == length(zhistr)
    index = index - 1;
    set(handles.listbox1,'value',index);
end

if count ~= 0
    set(handles.listbox1,'String',str2);
end

% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
global directoryname1
global sorted1


directoryname1 = uigetdir;
%
if isequal([directoryname1],[0])
    return
else
    %read image and list all file in the directory
    lsName=strcat(directoryname1,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    m = length(d);
    
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading...');
    end
    close(h);
    [unused, order] = sort([sdata.instance],'ascend');
    sorted1 = sdata(order).';
    msgbox('read t1 success!');
end
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
global directoryname2
global sorted2


directoryname2 = uigetdir;
%
if isequal([directoryname2],[0])
    return
else
    lsName=strcat(directoryname2,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    m = length(d);
    
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading...');
    end
    close(h);
    [unused, order] = sort([sdata.instance],'ascend');
    sorted2 = sdata(order).';
    msgbox('read t2 success!');
end
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
global directoryname3
global sorted3


directoryname3 = uigetdir;
%
if isequal([directoryname3],[0])
    return
else
    lsName=strcat(directoryname3,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    m = length(d);
    
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading...');
    end
    close(h);
    [unused, order] = sort([sdata.instance],'ascend');
    sorted3 = sdata(order).';
    msgbox('read t3 success!');
end
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
global directoryname4
global sorted4


directoryname4 = uigetdir;
%
if isequal([directoryname4],[0])
    return
else
    lsName=strcat(directoryname4,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    m = length(d);
    
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading...');
    end
    close(h);
    [unused, order] = sort([sdata.instance],'ascend');
    sorted4 = sdata(order).';
    msgbox('read t4 success!');
end
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
global directoryname5
global sorted5


directoryname5 = uigetdir;
%
if isequal([directoryname5],[0])
    return
else
    lsName=strcat(directoryname5,'\');
    d = ls(lsName);
    d(1,:)=[];
    d(1,:)=[];
    m = length(d);
    
    sdata(m) = struct('imagename','','instance',0);
    h = waitbar(0,'DICOM file loading...');
    for i = 1:m
        image_name = d(i,:);
        metadata = dicominfo(strcat(lsName,image_name));
        position = metadata.InstanceNumber;
        sdata(i) = struct('imagename',d(i,:),'instance',position);
        waitbar(i/m,h,'DICOM file loading...');
    end
    close(h);
    [unused, order] = sort([sdata.instance],'ascend');
    sorted5 = sdata(order).';
    msgbox('read t5 success!');
end
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
global directorynamemask


directorynamemask = uigetdir;
%
if isequal([directorynamemask],[0])
    return
else
    msgbox('open mask path success!');
end
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
