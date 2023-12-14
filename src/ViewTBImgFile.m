%ViewTBImgFile - Views the image from the testbench in matlab
%
% USAGE: In the command window (do not run ViewTBImgFile.m file in MATLAB!) you can run it as
% ViewTBImgFile(FileName). For example we can run the following in the command window
%   ViewTBImgFile("../work_lab08_mandelbrot/work_lab08_mandelbrot.sim/sim_1/behav/xsim/ImgDataFile");
%
% INPUT PARAMETERS:
%   FileName - Name of input file, e.g. "../work_lab08_mandelbrot/work_lab08_mandelbrot.sim/sim_1/behav/xsim/ImgDataFile"

function [img, img_color] = ViewTBImgFile(FileName, IterLim)

  if nargin < 2
    IterLim = 100;
  end

  ImgWidth  = 1024;
  ImgHeight = 768;

  TBImgFile = fopen(FileName);

  [img, count] = fread(TBImgFile, 'int');
  %img(count+1) = 0;

  img = reshape(img, ImgWidth, ImgHeight);
  img = transpose(img);
 
  % TODO: Apply your color mapping algorithm
  % For our color mapping, we first make all places where we have an
  % iteration count of ITER_LIM (100 in the provided dsd package) equal to
  % 0. 
  %
  % Then, we create 3 color channels in MATLAB. We map bits from the
  % iteration number to different color channels. With 100 iterations we
  % need only 7 bits, so we can assign as follows based on the iteration
  % count (ITERxDO in VHDL) to distribute a bit evenly between the colors
  % - red: ITERxDO(6 downto 4) --> 3 bits
  % - green: ITERxDO(3 downto 2) --> 2 bits
  % - blue: ITERxDO(1 downto 0) --> 2 bits
  % For a total of 7 bits.
  %
  % Note that for the VGA controller we only have 4 bits for each colour 
  % channel.
  %
  % Finally, when we want to show these colors in MATLAB, we have to
  % consider that each channel is 8 bits, so we have to shift up so the
  % bits for the colors are at the MSBs (shift blue by 6 bits, green by 6
  % bits and red by 5 bits to put all at MSBs)
  img(img == IterLim) = 0;  
  img = uint8(img);
  img_color = uint8(zeros(ImgHeight, ImgWidth,3));

  % R, G, B
  img_color(:,:,1) = bitshift(bitand(img, uint8(0b1110000)), -4+5);
  img_color(:,:,2) = bitshift(bitand(img, uint8(0b1100)), -2+6);
  img_color(:,:,3) = bitshift(bitand(img, uint8(0b11)), 0+6);

  image(img_color);
  imwrite(img_color, 'mandelbrot_tb.png');  
end
