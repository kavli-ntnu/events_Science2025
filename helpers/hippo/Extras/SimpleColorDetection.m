% Demo macro to very, very simple color detection in RGB color space.
% by ImageAnalyst
function SimpleColorDetection()
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
% imtool close all;	% Close all figure windows created by imtool.
workspace;	% Make sure the workspace panel is showing.

% Change the current folder to the folder of this m-file.
% (The "cd" line of code below is from Brett Shoelson of The Mathworks.)
if(~isdeployed)
	cd(fileparts(which(mfilename))); % From Brett
end

ver % Display user's toolboxes in their command window.

% Introduce the demo, and ask user if they want to continue or exit.
message = sprintf('This demo will illustrate very simple color detection in RGB color space.\nIt requires the Image Processing Toolbox.\nDo you wish to continue?');
reply = questdlg(message, 'Run Demo?', 'OK','Cancel', 'OK');
if strcmpi(reply, 'Cancel')
	% User canceled so exit.
	return;
end

try
	% Check that user has the Image Processing Toolbox installed.
	versionInfo = ver; % Capture their toolboxes in the variable.
	hasIPT = false;
	for k = 1:length(versionInfo)
		if strcmpi(versionInfo(k).Name, 'Image Processing Toolbox') > 0
			hasIPT = true;
		end
	end
	if ~hasIPT
		% User does not have the toolbox installed.
		message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
		reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
		if strcmpi(reply, 'No')
			% User said No, so exit.
			return;
		end
	end

	% Continue with the demo.  Do some initialization stuff.
	close all;
	fontSize = 16;
	figure;
	% Maximize the figure. 
	set(gcf, 'Position', get(0, 'ScreenSize')); 

	% Change the current folder to the folder of this m-file.
	% (The line of code below is from Brett Shoelson of The Mathworks.)
	if(~isdeployed)
		cd(fileparts(which(mfilename)));
	end

	% Ask user if they want to use a demo image or their own image.
	message = sprintf('Do you want use a standard demo image,\nOr pick one of your own?');
	reply2 = questdlg(message, 'Which Image?', 'Demo','My Own', 'Demo');
	% Open an image.
	if strcmpi(reply2, 'Demo')
		% Read standard MATLAB demo image.
	% 	fullImageFileName = 'peppers.png';
		message = sprintf('Which demo image do you want to use?');
		selectedImage = questdlg(message, 'Which Demo Image?', 'Onions', 'Peppers', 'Canoe', 'Onions');
		if strcmp(selectedImage, 'Onions')
			fullImageFileName = 'onion.png';
		elseif strcmp(selectedImage, 'Peppers')
			fullImageFileName = 'peppers.png';
		else
			fullImageFileName = 'canoe.tif';
		end
	else
		% They want to pick their own.
		% Change default directory to the one containing the standard demo images for the MATLAB Image Processing Toolbox. 
		originalFolder = pwd; 
		folder = 'C:\Program Files\MATLAB\R2010a\toolbox\images\imdemos'; 
		if ~exist(folder, 'dir') 
			folder = pwd; 
		end 
		cd(folder); 
		% Browse for the image file. 
		[baseFileName, folder] = uigetfile('*.*', 'Specify an image file'); 
		fullImageFileName = fullfile(folder, baseFileName); 
		% Set current folder back to the original one. 
		cd(originalFolder);
		selectedImage = 'My own image'; % Need for the if threshold selection statement later.

	end

	% Check to see that the image exists.  (Mainly to check on the demo images.)
	if ~exist(fullImageFileName, 'file')
		message = sprintf('This file does not exist:\n%s', fullImageFileName);
		uiwait(msgbox(message));
		return;
	end

	% Read in image into an array.
	[rgbImage storedColorMap] = imread(fullImageFileName); 
	[rows columns numberOfColorBands] = size(rgbImage); 
	% If it's monochrome (indexed), convert it to color. 
	% Check to see if it's an 8-bit image needed later for scaling).
	if strcmpi(class(rgbImage), 'uint8')
		% Flag for 256 gray levels.
		eightBit = true;
	else
		eightBit = false;
	end
	if numberOfColorBands == 1
		if isempty(storedColorMap)
			% Just a simple gray level image, not indexed with a stored color map.
			% Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
			rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
		else
			% It's an indexed image.
			rgbImage = ind2rgb(rgbImage, storedColorMap);
			% ind2rgb() will convert it to double and normalize it to the range 0-1.
			% Convert back to uint8 in the range 0-255, if needed.
			if eightBit
				rgbImage = uint8(255 * rgbImage);
			end
		end
	end 
	% Display the original image.
	subplot(3, 4, 1);
	imshow(rgbImage);
	drawnow; % Make it display immediately. 
	if numberOfColorBands > 1 
		title('Original Color Image', 'FontSize', fontSize); 
	else 
		caption = sprintf('Original Indexed Image\n(converted to true color with its stored colormap)');
		title(caption, 'FontSize', fontSize);
	end

	% Extract out the color bands from the original image
	% into 3 separate 2D arrays, one for each color component.
	redBand = rgbImage(:, :, 1); 
	greenBand = rgbImage(:, :, 2); 
	blueBand = rgbImage(:, :, 3); 
	% Display them.
	subplot(3, 4, 2);
	imshow(redBand);
	title('Red Band', 'FontSize', fontSize);
	subplot(3, 4, 3);
	imshow(greenBand);
	title('Green Band', 'FontSize', fontSize);
	subplot(3, 4, 4);
	imshow(blueBand);
	title('Blue Band', 'FontSize', fontSize);
	message = sprintf('These are the individual color bands.\nNow we will compute the image histograms.');
	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	fontSize = 13;

	% Compute and plot the red histogram. 
	hR = subplot(3, 4, 6); 
	[countsR, grayLevelsR] = imhist(redBand); 
	maxGLValueR = find(countsR > 0, 1, 'last'); 
	maxCountR = max(countsR); 
	bar(countsR, 'r'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Red Band', 'FontSize', fontSize);

	% Compute and plot the green histogram. 
	hG = subplot(3, 4, 7); 
	[countsG, grayLevelsG] = imhist(greenBand); 
	maxGLValueG = find(countsG > 0, 1, 'last'); 
	maxCountG = max(countsG); 
	bar(countsG, 'g', 'BarWidth', 0.95); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Green Band', 'FontSize', fontSize);

	% Compute and plot the blue histogram. 
	hB = subplot(3, 4, 8); 
	[countsB, grayLevelsB] = imhist(blueBand); 
	maxGLValueB = find(countsB > 0, 1, 'last'); 
	maxCountB = max(countsB); 
	bar(countsB, 'b'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Blue Band', 'FontSize', fontSize);

	% Set all axes to be the same width and height.
	% This makes it easier to compare them.
	maxGL = max([maxGLValueR,  maxGLValueG, maxGLValueB]); 
	if eightBit 
			maxGL = 255; 
	end 
	maxCount = max([maxCountR,  maxCountG, maxCountB]); 
	axis([hR hG hB], [0 maxGL 0 maxCount]); 

	% Plot all 3 histograms in one plot.
	subplot(3, 4, 5); 
	plot(grayLevelsR, countsR, 'r', 'LineWidth', 2); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	hold on; 
	plot(grayLevelsG, countsG, 'g', 'LineWidth', 2); 
	plot(grayLevelsB, countsB, 'b', 'LineWidth', 2); 
	title('Histogram of All Bands', 'FontSize', fontSize); 
	maxGrayLevel = max([maxGLValueR, maxGLValueG, maxGLValueB]); 
	% Trim x-axis to just the max gray level on the bright end. 
	if eightBit 
		xlim([0 255]); 
	else 
		xlim([0 maxGrayLevel]); 
	end 

	% Now select thresholds for the 3 color bands.
	message = sprintf('Now we will select some color threshold ranges\nand display them over the histograms.');
	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Assign the low and high thresholds for each color band.
	if strcmpi(reply2, 'My Own') || strcmpi(selectedImage, 'Canoe') > 0
		% Take a guess at the values that might work for the user's image.
		redThresholdLow = graythresh(redBand);
		redThresholdHigh = 255;
		greenThresholdLow = 0;
		greenThresholdHigh = graythresh(greenBand);
		blueThresholdLow = 0;
		blueThresholdHigh = graythresh(blueBand);
		if eightBit
			redThresholdLow = uint8(redThresholdLow * 255);
			greenThresholdHigh = uint8(greenThresholdHigh * 255);
			blueThresholdHigh = uint8(blueThresholdHigh * 255);
		end
	else
		% Use values that I know work for the onions and peppers demo images.
		redThresholdLow = 85;
		redThresholdHigh = 255;
		greenThresholdLow = 0;
		greenThresholdHigh = 70;
		blueThresholdLow = 0;
		blueThresholdHigh = 90;
	end

	% Show the thresholds as vertical red bars on the histograms.
	PlaceThresholdBars(6, redThresholdLow, redThresholdHigh);
	PlaceThresholdBars(7, greenThresholdLow, greenThresholdHigh);
	PlaceThresholdBars(8, blueThresholdLow, blueThresholdHigh);

	message = sprintf('Now we will apply each color band threshold range to the color band.');
	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Now apply each color band's particular thresholds to the color band
	redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
	greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
	blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);

	% Display the thresholded binary images.
	fontSize = 16;
	subplot(3, 4, 10);
	imshow(redMask, []);
	title('Is-Red Mask', 'FontSize', fontSize);
	subplot(3, 4, 11);
	imshow(greenMask, []);
	title('Is-Not-Green Mask', 'FontSize', fontSize);
	subplot(3, 4, 12);
	imshow(blueMask, []);
	title('Is-Not-Blue Mask', 'FontSize', fontSize);
	% Combine the masks to find where all 3 are "true."
	% Then we will have the mask of only the red parts of the image.
	redObjectsMask = uint8(redMask & greenMask & blueMask);
	subplot(3, 4, 9);
	imshow(redObjectsMask, []);
	caption = sprintf('Mask of Only\nThe Red Objects');
	title(caption, 'FontSize', fontSize);

	% Tell user that we're going to filter out small objects.
	smallestAcceptableArea = 100; % Keep areas only if they're bigger than this.
	message = sprintf('Note the small regions in the image in the lower left.\nNext we will eliminate regions smaller than %d pixels.', smallestAcceptableArea);
	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% Open up a new figure, since the existing one is full.
	figure;  
	% Maximize the figure. 
	set(gcf, 'Position', get(0, 'ScreenSize'));

	% Get rid of small objects.  Note: bwareaopen returns a logical.
	redObjectsMask = uint8(bwareaopen(redObjectsMask, smallestAcceptableArea));
	subplot(3, 3, 1);
	imshow(redObjectsMask, []);
	fontSize = 13;
	caption = sprintf('bwareaopen() removed objects\nsmaller than %d pixels', smallestAcceptableArea);
	title(caption, 'FontSize', fontSize);

	% Smooth the border using a morphological closing operation, imclose().
	structuringElement = strel('disk', 4);
	redObjectsMask = imclose(redObjectsMask, structuringElement);
	subplot(3, 3, 2);
	imshow(redObjectsMask, []);
	fontSize = 16;
	title('Border smoothed', 'FontSize', fontSize);

	% Fill in any holes in the regions, since they are most likely red also.
	redObjectsMask = uint8(imfill(redObjectsMask, 'holes'));
	subplot(3, 3, 3);
	imshow(redObjectsMask, []);
	title('Regions Filled', 'FontSize', fontSize);

	message = sprintf('This is the filled, size-filtered mask.\nNow we will apply this mask to the original image.');
	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
	if strcmpi(reply, 'Cancel')
		% User canceled so exit.
		return;
	end

	% You can only multiply integers if they are of the same type.
	% (redObjectsMask is a logical array.)
	% We need to convert the type of redObjectsMask to the same data type as redBand.
	redObjectsMask = cast(redObjectsMask, class(redBand)); 

	% Use the red object mask to mask out the red-only portions of the rgb image.
	maskedImageR = redObjectsMask .* redBand;
	maskedImageG = redObjectsMask .* greenBand;
	maskedImageB = redObjectsMask .* blueBand;
	% Show the masked off red image.
	subplot(3, 3, 4);
	imshow(maskedImageR);
	title('Masked Red Image', 'FontSize', fontSize);
	% Show the masked off green image.
	subplot(3, 3, 5);
	imshow(maskedImageG);
	title('Masked Green Image', 'FontSize', fontSize);
	% Show the masked off blue image.
	subplot(3, 3, 6);
	imshow(maskedImageB);
	title('Masked Blue Image', 'FontSize', fontSize);
	% Concatenate the masked color bands to form the rgb image.
	maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
	% Show the masked off, original image.
	subplot(3, 3, 8);
	imshow(maskedRGBImage);
	fontSize = 13;
	caption = sprintf('Masked Original Image\nShowing Only the Red Objects');
	title(caption, 'FontSize', fontSize);
	% Show the original image next to it.
	subplot(3, 3, 7);
	imshow(rgbImage);
	title('The Original Image (Again)', 'FontSize', fontSize);

	% Measure the mean RGB and area of all the detected blobs.
	[meanRGB, areas, numberOfBlobs] = MeasureBlobs(redObjectsMask, redBand, greenBand, blueBand);
	if numberOfBlobs > 0
		fprintf(1, '\n----------------------------------------------\n');
		fprintf(1, 'Blob #, Area in Pixels, Mean R, Mean G, Mean B\n');
		fprintf(1, '----------------------------------------------\n');
		for blobNumber = 1 : numberOfBlobs
			fprintf(1, '#%5d, %14d, %6.2f, %6.2f, %6.2f\n', blobNumber, areas(blobNumber), ...
				meanRGB(blobNumber, 1), meanRGB(blobNumber, 2), meanRGB(blobNumber, 3));
		end
	else
		% Alert user that no red blobs were found.
		message = sprintf('No red blobs were found in the image:\n%s', fullImageFileName);
		fprintf(1, '\n%s\n', message);
		uiwait(msgbox(message));
	end

	subplot(3, 3, 9);
	ShowCredits();
	message = sprintf('Done!\n\nThe demo has finished.\n\nLook the MATLAB command window for\nthe area and color measurements of the %d regions.', numberOfBlobs);
	msgbox(message);
	
catch ME
	errorMessage = sprintf('Error running this m-file:\n%s\n\nThe error message is:\n%s', ...
		mfilename('fullpath'), ME.message);
	errordlg(errorMessage);
end
return; % from SimpleColorDetection()
% ---------- End of main function ---------------------------------


%----------------------------------------------------------------------------
% Measure the mean intensity and area of each blob in each color band.
function [meanRGB, areas, numberOfBlobs] = MeasureBlobs(maskImage, redBand, greenBand, blueBand)
	[labeledImage numberOfBlobs] = bwlabel(maskImage, 8);     % Label each blob so we can make measurements of it
	if numberOfBlobs == 0
		% Didn't detect any yellow blobs in this image.
		meanRGB = [0 0 0];
		areas = 0;
		return;
	end
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	blobMeasurementsR = regionprops(labeledImage, redBand, 'area', 'MeanIntensity');   
	blobMeasurementsG = regionprops(labeledImage, greenBand, 'area', 'MeanIntensity');   
	blobMeasurementsB = regionprops(labeledImage, blueBand, 'area', 'MeanIntensity');   
	
	meanRGB = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	meanRGB(:,1) = [blobMeasurementsR.MeanIntensity]';
	meanRGB(:,2) = [blobMeasurementsG.MeanIntensity]';
	meanRGB(:,3) = [blobMeasurementsB.MeanIntensity]';
	
	% If redBand etc. are double, the intensities will be in the range of 0-1.
	% Multiply by 255 to get them back into the uint8 range of 0-255.
	if ~strcmpi(class(redBand), 'uint8')
		meanRGB = meanRGB * 255.0;
	end
	
	% Now assign the areas.
	areas = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	areas(:,1) = [blobMeasurementsR.Area]';
	areas(:,2) = [blobMeasurementsG.Area]';
	areas(:,3) = [blobMeasurementsB.Area]';

	return; % from MeasureBlobs()
	
	
%----------------------------------------------------------------------------
% Function to show the low and high threshold bars on the histogram plots.
function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
	% Show the thresholds as vertical red bars on the histograms.
	subplot(3, 4, plotNumber); 
	hold on;
	maxYValue = ylim;
	maxXValue = xlim;
	hStemLines = stem([lowThresh highThresh], [maxYValue(2) maxYValue(2)], 'r');
	children = get(hStemLines, 'children');
	set(children(2),'visible', 'off');
	% Place a text label on the bar chart showing the threshold.
	fontSizeThresh = 14;
	annotationTextL = sprintf('%d', lowThresh);
	annotationTextH = sprintf('%d', highThresh);
	% For text(), the x and y need to be of the data class "double" so let's cast both to double.
	text(double(lowThresh + 5), double(0.85 * maxYValue(2)), annotationTextL, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	text(double(highThresh + 5), double(0.85 * maxYValue(2)), annotationTextH, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	
	% Show the range as arrows.
	% Can't get it to work, with either gca or gcf.
% 	annotation(gca, 'arrow', [lowThresh/maxXValue(2) highThresh/maxXValue(2)],[0.7 0.7]);

	return; % from PlaceThresholdBars()


%----------------------------------------------------------------------------
% Display the MATLAB logo.
function ShowCredits()
% 	xpklein;
% 	surf(peaks(30));
	logoFig = subplot(3,3,9);
	caption = sprintf('A MATLAB Demo\nby ImageAnalyst');
	text(0.5,1.15, caption, 'Color','r', 'FontSize', 18, 'FontWeight','b', 'HorizontalAlignment', 'Center') ;
	positionOfLowerRightPlot = get(logoFig, 'position');
	L = 40*membrane(1,25);
	logoax = axes('CameraPosition', [-193.4013 -265.1546  220.4819],...
		'CameraTarget',[26 26 10], ...
		'CameraUpVector',[0 0 1], ...
		'CameraViewAngle',9.5, ...
		'DataAspectRatio', [1 1 .9],...
		'Position', positionOfLowerRightPlot, ...
		'Visible','off', ...
		'XLim',[1 51], ...
		'YLim',[1 51], ...
		'ZLim',[-13 40], ...
		'parent',gcf);
	s = surface(L, ...
		'EdgeColor','none', ...
		'FaceColor',[0.9 0.2 0.2], ...
		'FaceLighting','phong', ...
		'AmbientStrength',0.3, ...
		'DiffuseStrength',0.6, ... 
		'Clipping','off',...
		'BackFaceLighting','lit', ...
		'SpecularStrength',1.1, ...
		'SpecularColorReflectance',1, ...
		'SpecularExponent',7, ...
		'Tag','TheMathWorksLogo', ...
		'parent',logoax);
	l1 = light('Position',[40 100 20], ...
		'Style','local', ...
		'Color',[0 0.8 0.8], ...
		'parent',logoax);
	l2 = light('Position',[.5 -1 .4], ...
		'Color',[0.8 0.8 0], ...
		'parent',logoax);

	return; % from ShowCredits()
