function varargout = SigVerify(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SigVerify_OpeningFcn, ...
                   'gui_OutputFcn',  @SigVerify_OutputFcn, ...
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
% --- Executes just before SigVerify is made visible.
function SigVerify_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = SigVerify_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in test_btn.
function test_btn_Callback(hObject, eventdata, handles)
global IbwTest;
%% Find the class the test signature image belongs
Ftest=feature_extraction(IbwTest);
%% Compare with the feature of training image in the database
load DB.mat
Ftrain=DB(:,1:9);
Ctrain=DB(:,10);
for(i=1:size(Ftrain,1))
    dist(i,:)=sum(abs(Ftrain(i,:)-Ftest));
end
Min=min(dist);
m=find(dist==Min,1);
det_class=Ctrain(m);
%msgbox(strcat('Detected Class=',num2str(det_class)));
if det_class == 1
    set(handles.text2,'String',"Matched with Person 1");
    disp('Person 1');
elseif det_class == 2
    set(handles.text2,'String',"Matched with Person 2");
    disp(' Person 2 ');
elseif det_class == 3
    set(handles.text2,'String',"Matched with Person 3");
    disp('Person 3');
elseif det_class == 4
      set(handles.text2,'String',"Matched with Person 4");
    disp('Person 4 ');
elseif det_class == 5
      set(handles.text2,'String',"Matched with Person 5");
    disp('Person 5 ');
elseif det_class == 6
    set(handles.text2,'String',"Matched with Person 6");
    disp('Person 6 ');
elseif det_class == 7
   set(handles.text2,'String',"Matched with Person 7");
    disp('Person 7 ');
elseif det_class == 8
     set(handles.text2,'String',"Matched with Person 8");
    disp('Person 8 ');
elseif det_class == 9
    set(handles.text2,'String',"Matched with Person 9");
    disp(' Person 9 ');
elseif det_class == 10
     set(handles.text2,'String',"Matched with Person 10");
    disp('Person 10 ');
else
    helpdlg('Unable to recognize');
    disp('Unable to recognize');
end
% --- Executes on button press in clear_test_btn.
function clear_test_btn_Callback(hObject, eventdata, handles)
axes(handles.axes5); cla(handles.axes5); title('');
axes(handles.axes6); cla(handles.axes6); title('');
set(handles.text2,'String'," ");
% --- Executes on button press in select_test_btn.
function select_test_btn_Callback(hObject, eventdata, handles)
global IbwTest;
cla(handles.axes5);
[Sel_Img,SelImage_Path] = uigetfile({'*.jpg;*.png;*.bmp;*.*'},pwd,'Pick the test image file');
SelImage_Path = [SelImage_Path Sel_Img];

if Sel_Img == 0
    return;
end

im1 = imread(SelImage_Path);%Reading the input image
axes(handles.axes5);
imshow(im1), title('Image for Testing')
%% Preprocessing for testing
 [row col channel] = size(im1);
    img_resized = imresize(im1,[512 512]); % changing the size of the image
    A = im2gray(img_resized); %conveting into gray scale image
    %% Noise Removal Using Median Filter
    %PAD THE MATRIX WITH ZEROS ON ALL SIDES
    modifyA=zeros(size(A)+2);
    B=zeros(size(A));

    %COPY THE ORIGINAL IMAGE MATRIX TO THE PADDED MATRIX
        for x=1:size(A,1)
            for y=1:size(A,2)
                modifyA(x+1,y+1)=A(x,y);
            end
        end
      %LET THE WINDOW BE AN ARRAY
      %STORE THE 3-by-3 NEIGHBOUR VALUES IN THE ARRAY
      %SORT AND FIND THE MIDDLE ELEMENT
       
        for i= 1:size(modifyA,1)-2
            for j=1:size(modifyA,2)-2
             window=zeros(9,1);
             inc=1;
             for x=1:3
                for y=1:3
                window(inc)=modifyA(i+x-1,j+y-1);
                inc=inc+1;
                end
             end
       
            med=sort(window);
            %PLACE THE MEDIAN ELEMENT IN THE OUTPUT MATRIX
            B(i,j)=med(5);
       
            end
        end
     %CONVERT THE OUTPUT MATRIX TO 0-255 RANGE IMAGE TYPE
     B=uint8(B);%Noise Removed Image B
     %%
    gs = imadjust(B); %Adjusting image's contrast
    mask = fspecial("average",3);
    gsSmooth = imfilter(gs,mask,"replicate"); %Appllying mask and filter to the image
    
    SE = strel("disk",8);  
    Ibg = imclose(gsSmooth, SE); %Performing closing operation on image for extra enhancement 
    Ibgsub =  Ibg - gsSmooth;
    IbwTest = ~imbinarize(Ibgsub); %converting gray scale image into B/W image

%Displaying processed Test Image
axes(handles.axes6);
imshow(IbwTest), title('Preprocessed Image for Testing')


% --- Executes on button press in selectImage.
function selectImage_Callback(hObject, eventdata, handles)
global image;
cla(handles.axes1);
[Sel_Img,SelImage_Path] = uigetfile({'*.jpg;*.png;*.bmp;*.*'},pwd,'Pick the test image file');
SelImage_Path = [SelImage_Path Sel_Img];

if Sel_Img == 0
    return;
end

image = imread(SelImage_Path);

axes(handles.axes1);
imshow(image), title('Image for Recognition');

handles.image = image;
guidata(hObject,handles);


% --- Executes on button press in preprocess_btn.
function preprocess_btn_Callback(hObject, eventdata, handles)
global image;
global Ibw;
    [row col channel] = size(image);
    img_resized = imresize(image,[512 512]); % changing the size of the image


    A = im2gray(img_resized); %conveting into gray scale image
     %% Noise Removal Using Median Filter
    %PAD THE MATRIX WITH ZEROS ON ALL SIDES
    modifyA=zeros(size(A)+2);
    B=zeros(size(A));

    %COPY THE ORIGINAL IMAGE MATRIX TO THE PADDED MATRIX
        for x=1:size(A,1)
            for y=1:size(A,2)
                modifyA(x+1,y+1)=A(x,y);
            end
        end
      %LET THE WINDOW BE AN ARRAY
      %STORE THE 3-by-3 NEIGHBOUR VALUES IN THE ARRAY
      %SORT AND FIND THE MIDDLE ELEMENT
       
    for i= 1:size(modifyA,1)-2
        for j=1:size(modifyA,2)-2
        window=zeros(9,1);
        inc=1;
        for x=1:3
            for y=1:3
                window(inc)=modifyA(i+x-1,j+y-1);
                inc=inc+1;
            end
        end
       
        med=sort(window);
        %PLACE THE MEDIAN ELEMENT IN THE OUTPUT MATRIX
        B(i,j)=med(5);
       
        end
    end
    %CONVERT THE OUTPUT MATRIX TO 0-255 RANGE IMAGE TYPE
    B=uint8(B);
    %% 
    gs = imadjust(B); %Adjusting image's contrast
    
    mask = fspecial("average",3);
    gsSmooth = imfilter(gs,mask,"replicate"); %Appllying mask and filter to the image
    
    SE = strel("disk",8);  
    Ibg = imclose(gsSmooth, SE); %Performing closing operation on image for extra enhancement 
    Ibgsub =  Ibg - gsSmooth;
    Ibw = ~imbinarize(Ibgsub); %converting gray scale image into B/W image

% Displaying the images
axes(handles.axes2);
imshow(img_resized),title('Resized Image(512*512)');
axes(handles.axes3);
imshow(B), title('Noise Removed & Gray Scaled Image');
axes(handles.axes4);
imshow(Ibw), title('Binarized Image');


% --- Executes on button press in train_btn.
function train_btn_Callback(hObject, eventdata, handles)
global Ibw;
c=input('Enter the Class(Number from 1-10)');
%% Feature Extraction
 Feat_Val = feature_extraction(Ibw);
try 
    load DB;
    
    Feat_Val=[Feat_Val c];
    DB=[DB; Feat_Val];
    save DB.mat DB 
catch 
    DB=[Feat_Val c]; % 10 12 1
    save DB.mat DB
end

% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
axes(handles.axes1); cla(handles.axes1); title('');
axes(handles.axes2); cla(handles.axes2); title('');
axes(handles.axes3); cla(handles.axes3); title('');
axes(handles.axes4); cla(handles.axes4); title('');
