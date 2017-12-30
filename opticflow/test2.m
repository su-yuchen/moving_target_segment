clear;
clc;
close all;

%% ����ͼƬ
figure;
N_image = 9;
Cell_image=cell(1,N_image);
for i=1:N_image
    Name_image=strcat('images/traffic/mobile_',num2str(i+27),'.bmp');
    Cell_image{1,i} = imread(Name_image);
end
Gray_image = cell(1,N_image);
for i=1:N_image
    if size(Cell_image{1,i},3) > 1
        Gray_image{1,i} = rgb2gray(Cell_image{1,i});
    else
        Gray_image{1,i} = Cell_image{1,i};
    end
end

subplot(331);
imshow(Gray_image{1,8}),title('(1)�ο�ͼ��');
subplot(332);
imshow(Gray_image{1,4}),title('(2)ԭʼͼ��');

%% ���������Ϣ
Iinputg = Gray_image{1,8};
Irefg = Gray_image{1,4};
% ����������������ת������
opticalFlow = vision.OpticalFlow('ReferenceFrameDelay', 1);
converter = vision.ImageDataTypeConverter;

% �޸Ĺ������������
opticalFlow.OutputValue = 'Horizontal and vertical components in complex form'; % ���ظ�����ʽ����ͼ
opticalFlow.ReferenceFrameSource = 'Input port'; % �Ա�����ͼƬ����������Ƶ��
if 1 % ʹ�õ��㷨
    opticalFlow.Method = 'Lucas-Kanade';
    opticalFlow.NoiseReductionThreshold = 0.01; % Ĭ����0.0039
else
    opticalFlow.Method = 'Horn-Schunck';
    opticalFlow.Smoothness = 0.5; % Ĭ����1
end

% ���ù��������������ͼƬ�Ĺ���
Iinputg_c = step(converter, Iinputg);
Irefg_c = step(converter, Irefg);
opticflow = step(opticalFlow, Iinputg_c, Irefg_c);

%% ����ͼ���ֵ��
% �������Ĳ�ɫ��ʾ
flow_H = real(opticflow);
flow_V = imag(opticflow);
flow_cc = computeColor(flow_H, flow_V);
subplot(333)
imshow(flow_cc),title('(3)�������Ĳ�ɫ��ʾ');

% �������ĻҶ���ʾ
flow_gray = 255 - rgb2gray(flow_cc);
subplot(334);
imshow(flow_gray),title('(4)�������ĻҶ���ʾ');

threshold = 45;
New_image = flow_gray;
for i=1:size(flow_gray,1)
   for j=1:size(flow_gray,2)
       if flow_gray(i,j) > threshold
           New_image(i,j) = 255;
       else
           New_image(i,j) = 0;
       end
   end
end
flow_gray = New_image;

subplot(335);
imshow(flow_gray),title('(5)��ֵ����Ĺ������ĻҶ���ʾ');

%% ��ʴ������
se1 = strel('square',8);
se0 = strel('square',1);
flow_gray = imdilate(flow_gray, se1);
flow_gray = imerode(flow_gray,se0);
subplot(336);
imshow(flow_gray),title('(6)��̬ѧ�����Ĺ������ĻҶ���ʾ');

%% ���
Image = mark(Iinputg, flow_gray);
subplot(337)
imshow(Image),title('(7)�˶�Ŀ��ָ�');