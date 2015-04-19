function [I,Map] = tga_read_image(info)
% function for reading image of Truevision TARGA file, TGA, VDA, ICB VST
%
% [I,Map] = tga_read_image(file-header)
%
% or,
%
% [I,Map] = tga_read_image(filename)
%
% examples:
% 1: info = tga_read_header()
%    I = tga_read_image(info);
%    imshow(I(:,:,1:3),[]);
%
% 2: [I,map] = tga_read_image('testimages/test9.tga');
%    figure, imshow(I,map);

if(~isstruct(info)), info=tga_read_header(info); end
fid=fopen(info.Filename,'rb','l');

if(fid<0)
    fprintf('could not open file %s\n',info.Filename);
    return
end

fseek(fid,info.HeaderSize,'bof');

bytesp=ceil(info.Depth)/8;
npixels=info.Width*info.Height*bytesp;
if(~info.Rle)
    V = fread(fid,npixels,'uint8=>uint8');
else
    V = zeros([npixels 1],'uint8'); nV=0;
    while(nV<npixels)
        RCfield=fread(fid,1,'uint8=>uint8');
        RunLengthPacket=bitget(RCfield,8);
        Npix=double(mod(RCfield,128))+1;
        if(RunLengthPacket)
            PixelData=fread(fid,bytesp,'uint8=>uint8');
            PixelData=repmat(PixelData(:),[Npix 1]);
        else % Raw Packets
            PixelData=fread(fid,Npix*bytesp,'uint8=>uint8');
        end
        nVnew=nV+length(PixelData);
        V(nV+1:nVnew)=PixelData;
        nV=nVnew;
    end
    V=V(1:npixels);
end

switch(info.Depth)
    case 8;
        I = permute(reshape(V,[info.Width info.Height]),[2 1]);
    case 16
        V =uint16(V); V=V(1:2:end)+256*V(2:2:end);
        Vbits=getbits(V,16);
        B = Vbits(:,1)+Vbits(:,2)*2+Vbits(:,3)*4+Vbits(:,4)*8+Vbits(:,5)*16;
        G = Vbits(:,6)+Vbits(:,7)*2+Vbits(:,8)*4+Vbits(:,9)*8+Vbits(:,10)*16;
        R = Vbits(:,11)+Vbits(:,12)*2+Vbits(:,13)*4+Vbits(:,14)*8+Vbits(:,15)*16;
        R = permute(reshape(R,[info.Width info.Height]),[2 1]);
        G = permute(reshape(G,[info.Width info.Height]),[2 1]);
        B = permute(reshape(B,[info.Width info.Height]),[2 1]);
        I(:,:,1)=R*8;
        I(:,:,2)=G*8;
        I(:,:,3)=B*8;
        I=uint8(I);
    case 24
        I = permute(reshape(V,[3 info.Width info.Height]),[3 2 1]);
        I=I(:,:,3:-1:1);
    case 32
        I = permute(reshape(V,[4 info.Width info.Height]),[3 2 1]);
        I=I(:,:,[3 2 1 4]);
end
fclose(fid);

Map = info.ColorMap;

switch(info.ImageOrigin);
    case 'bottom left'
        I=I(end:-1:1,:,:);
    case 'bottom right'
        I=I(end:-1:1,end:-1:1,:);
    case 'top left'
        I=I(:,:,:);
    case 'top right'
        I=I(:,end:-1:1,:);
end


function bits=getbits(a,nbits)
a=double(a(:));
bits=zeros([length(a) nbits]);
for i=1:nbits, 
    a=a/2; af=floor(a); bits(:,i)=af~=a; a=af; 
end
