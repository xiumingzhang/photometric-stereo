function info = tga_read_header(fname)
% function for reading header of Truevision TARGA file, TGA, VDA, ICB VST
%
% info = tga_read_header(filename);
%
% examples:
% 1,  info=tga_read_header()
% 2,  info=tga_read_header('example.tga');

%
% typedef struct
%
%    byte  identsize;          // size of ID field that follows 18 byte header (0 usually)
%    byte  Colormaptype;      // type of Color map 0=none, 1=has palette
%    byte  imagetype;          // type of image 0=none,1=indexed,2=rgb,3=grey,+8=rle packed
%
%    short Colormapstart;     // first Color map entry in palette
%    short Colormaplength;    // number of Colors in palette
%    byte  Colormapbits;      // number of bits per palette entry 15,16,24,32%
%
%    short xstart;             // image x origin
%    short ystart;             // image y origin
%    short width;              // image width in pixels
%    short height;             // image height in pixels
%    byte  bits;               // image bits per pixel 8,16,24,32
%    byte  descriptor;         // image descriptor bits (vh flip bits)
%    
%    // pixel data follows header
%    24 bits
% TGA_HEADER

if(exist('fname','var')==0)
    [filename, pathname] = uigetfile('*.tga;*.vda;*.icb,*.vst', 'Read tga-file');
    fname = [pathname filename];
end

f=fopen(fname,'rb','l');
if(f<0)
    fprintf('could not open file %s\n',fname);
    return
end
info.Filename=fname;

% Footer Header
fseek(f,-26,'eof');
info.ExtensionArea=fread(f, 1, 'long');
info.DeveloperDirectory=fread(f, 1, 'long');
info.Signature=fread(f, 17, 'char=>char')';
if(strcmp(info.Signature,'TRUEVISION-XFILE.'))
    info.Version='new';
else
    info.Version='old';
end

% File Start Header
fseek(f,0,'bof');
info.IDlength = fread(f, 1, 'uint8');
info.ColorMapType = fread(f, 1, 'uint8');
info.ImageType =fread(f, 1, 'uint8');
switch(info.ImageType )
    case 0
        info.ImageTypeString='No Image Data';
        info.Rle=false;
    case 1
        info.ImageTypeString='Uncompressed, Color-mapped image'; 
        info.Rle=false;
    case 2
        info.ImageTypeString='Uncompressed, True-color image';
        info.Rle=false;
    case 3
        info.ImageTypeString='Uncompressed, True-color image';
        info.Rle=false;
    case 9
        info.ImageTypeString='Run-length encoded Color-mapped Image'; 
        info.Rle=true;
    case 10
        info.ImageTypeString='Run-length encoded True-color Image Image'; 
        info.Rle=true;
    case 11
        info.ImageTypeString='Run-length encoded Black-and-white Image';
        info.Rle=true;
    otherwise
        info.ImageTypeString='unknown';
        info.Rle=false;
end

% Color Map Specification (offset 3)
info.ColorMapStart = fread(f, 1, 'short');
info.ColorMapLength = fread(f, 1, 'short');
info.ColorMapBits = fread(f, 1, 'uint8');
info.ColorMapStoreBits = 8*ceil(info.ColorMapBits/8);

% Image specification offset 8
info.XOrigin = fread(f, 1, 'short');
info.YOrigin  = fread(f, 1, 'short');
info.Width = fread(f, 1, 'short');
info.Height = fread(f, 1, 'short');
info.Depth = fread(f, 1, 'uint8');
b= bitget(fread(f, 1, 'uint8=>uint8'),1:8);
info.ImageDescriptor =b;
info.AlphaChannelBits=b(1)+b(2)*2+b(3)*4+b(4)*8;
if((b(6)==0)&&(b(5)==0)), info.ImageOrigin='bottom left'; end
if((b(6)==0)&&(b(5)==1)), info.ImageOrigin='bottom right'; end
if((b(6)==1)&&(b(5)==0)), info.ImageOrigin='top left'; end
if((b(6)==1)&&(b(5)==1)), info.ImageOrigin='top right'; end
info.ImageID= fread(f, info.IDlength, 'uint8');
if(info.ColorMapType==0)
    info.ColorMap=[];
else
    ColorMap = fread(f,info.ColorMapLength*(info.ColorMapStoreBits/8),'uint8=>uint8');
    switch(info.ColorMapStoreBits)
        case 16
            % BitsPerColor = min( info.bits/3, 8);
            
            %info.ColorMap=reshape(ColorMap,[info.ColorMapLength 2]);
        case 24
            info.ColorMap=reshape(ColorMap,[3 info.ColorMapLength])';
            info.ColorMap=info.ColorMap(:,3:-1:1);
        case 32
            info.ColorMap=reshape(ColorMap,[4 info.ColorMapLength])';
            info.ColorMap=info.ColorMap(:,[3 2 1 4]);
                
    end
    info.ColorMap=double(info.ColorMap)/255;
end


% Get the header size
info.HeaderSize=ftell(f);

% Get the file length
fseek(f,0,'eof'); 
info.FileSize = ftell(f); 

fclose(f);


% Closing Header Contains :

% Developer Fields
% Developer Directory
% Extension Size (offset =0) , short
% Author Name (offset = 2) , asci 41
% Author Comments ( offset = 43), asci 324
% Date Time,   (offset=367), shorts 6 
% Job Name/ID(offset=379) , 41 ascii
% Job Time (offset = 420) , 41 asci
% Software version (offset=467), 3 bytes
% Key color (offset=470), long
% Pixel Aspect Ratio (offset = 474) , 2shorts
% Gamma Value (offset = 478 ), 2 shorts
% Color Correction Offset (offset=482), long
% Postage Stamp Offset(offset=486), long
% Scan Line Offset ( offset=490), long
% Attributes Type (offset=494)
% Scan Line Table
% Postage Stamp Image
% Color Correction Table (1K shorts)
% Extentsion Area (offset=0), long
% Developer Directory (offset=4),long
% Signature (offset=8) , ASCI

