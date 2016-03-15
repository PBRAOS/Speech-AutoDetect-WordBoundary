clear all; close all; clc
set(0, 'DefaultAxesFontSize', 20);

% G1 contains the speech waveform and fs the sampling rate
[G1,fs] = audioread('BT_06_F_B_f_v01_s01_r.wav');
data=G1;

t=(1:length(data))/fs;

%%%%%%%%%%%%%%%%% parsing the Text Grid %%%%%%%%%%%%%%%%%%%%%%%
fid=fopen('BT_06_F_B_f_v01_s01_r.TextGrid');

A=fscanf(fid,'%s'); %%%% load the entire TextGrid into one string A
fclose(fid);

%%%%% search for the labeled words (including labeled pauses) %%%%%%%
pat = 'text="(\w*|\w*.)"';
m=regexp(A,pat,'tokens');
y=m{1}; b=''; for i=2:size(m,2),y=[y,'',m{i}]; end
words=y;

%%%%% search for the labeled word boundaries %%%%%%%
pat = 'xmax=(\d*.\d*)\w';
m=regexp(A,pat,'tokens');
y=m{1}; b=''; for i=2:size(m,2),y=[y,'',m{i}]; end
a=str2double(y);
xmax=a(3:end);
xmax=[0 xmax];

%%%%%%%% Read speech data frame-by-frame. A rectangular window is assumed. %%%%%%%%
% window length
window_len=320;
% window shift
window_shift=10;
% number of windows
num_windows=fix(length(data)/window_shift-window_len/window_shift);

%%%%%% computation of energy in every window %%%%%%%
for i=1:num_windows,
    window=data(((i-1)*window_shift+1):(i*window_shift+window_len));
    energy(i)=sum(window.*window);
end

%%%%%%% visualize the speech and its short time energy content %%%%%%%%%
% Energy(i) now contains the frame-by-frame energy
% plot the speech data
subplot(3,1,1), plot(t,data)
axis([1/fs length(data)/fs -0.5 0.5])
title('Speech Data','FontSize',25,'FontWeight','bold')
hold on
y=-0.5:0.05:0.5; for i=1:length(xmax), x=xmax(i)*ones(1,length(y)); plot(x,y,'r'), end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot the short time energy of the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,2), plot(energy), axis([1 num_windows 0 12])
title('Short-Time Energy in the Speech Data','FontSize',25,'FontWeight','bold')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smoothed version of short time energy waveform obtained using butterworth filter %%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,3), [b,a]=butter(1,100/fs); smooth_energy=filter(b,a,energy);
plot(smooth_energy), axis([1 num_windows 0 12])
title('Smoothed Short-Time Energy Waveform','FontSize',25,'FontWeight','bold')
hold on
% thresholding the short time energy waveform
temp=smooth_energy; a=temp>0.025*max(temp);
window_len=50; num_windows=fix(length(a)/window_len);
for i=1:num_windows,
    % handling smooth energy instances lingering in the neighborhood of the energy threshold
    if sum(a(50*(i-1)+1:50*i))>1; a(50*(i-1)+1:50*i)=ones(1,50); end
end
plot(a,'r')
hold off

%%%%%%%%%% automated word boundary detection %%%%%%%%%%%
% plot the speech data
figure, subplot(2,1,1), plot(t,data)
axis([1/fs length(data)/fs -0.5 0.5])
title('Speech Data with Manually Labeled Word Boundaries','FontSize',25,'FontWeight','bold')
hold on
y=-0.5:0.05:0.5; for i=1:length(xmax), x=xmax(i)*ones(1,length(y)); plot(x,y,'r'), end
hold off
% plot the speech data
subplot(2,1,2), plot(t,data)
axis([1/fs length(data)/fs -0.5 0.5])
title('Speech Data with Automatically Detected Word Boundaries','FontSize',25,'FontWeight','bold')
hold on
% to perform a(n)-a(n-1) to get the energy transitions
bound_energy=abs([a(2:end)-a(1:end-1),0]);
% windows coresponding to energy transitions
b=find(bound_energy>0);
% transition windows mapped to time
y=-0.5:0.05:0.5; for i=1:length(b), x=((b(i)-1)*window_shift)/fs*ones(1,length(y)); plot(x,y,'r'), end
hold off

% %%%%%% play the recorded utterance %%%%%%%%
% uiwait(msgbox('Hit OK to play the utterance','Title','modal'));
% sound(G1,fs)