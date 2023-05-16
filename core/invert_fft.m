function filted_y=invert_fft(raw_y, fc, fs, cut_width)
% plotIt = true;
% convert into frequency domain
raw_y = raw_y';
L = length(raw_y); 
n = 2^nextpow2(L);
Y = fft(raw_y,n);
amp = abs(Y/n);
phases = angle(Y);

f = fs*(0:n-1)/n;
ff = fc:fc:fs/2;

cut_window = [];
for k = 1:length(ff)
    ffc = ff(k);
    [~, cur_cut_win] = min(abs(f-ffc));
    cut_window = [cut_window, (cur_cut_win-cut_width):(cur_cut_win+cut_width), (n-cur_cut_win -cut_width):(n-cur_cut_win+cut_width)];
end

% Convert back to time domain
temp_f = f; 
temp_f(cut_window) = [];
temp_amp = amp;
temp_amp(cut_window) = [];

ampi = interp1(temp_f, temp_amp, f, 'linear');
Xi = n*ampi.*exp(1i*phases);
emgi = ifft(Xi,n,'symmetric');
filted_y=real(emgi(1:L))';

% 
% if plotIt
%     s=1:n/2;
% %     t=(0:L)/3000;
%     figure;
%     subplot(211); plot(f(s),amp(s).^2, f(s),abs(ampi(s)).^2)
% %     pspectrum(raw_y,t); hold on;     pspectrum(filted_y,t)
%     subplot(212); plot(raw_y); hold on; plot(filted_y); hold off
% end
