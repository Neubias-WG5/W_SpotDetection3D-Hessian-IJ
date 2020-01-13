var _NUCLEI_CHANNEL = 1;
var _SCALE = 1.7;
var _RADIUS_XY = 3;
var _RADIUS_Z = 6;
var _NOISE = 6300;

function clearSlices(n1, n2) {
	run("Select All");
	for (i = n1; i <= n2; i++) {
		setSlice(i);
		run("Clear", "slice");
	}
	run("Select None");
}

inputDir = "/home/baecker/data/in";
outputDir = "/home/baecker/data/out";

arg = getArgument();
parts = split(arg, ",");

setBatchMode(true);

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "scale")>-1) _SCALE=parseFloat(nameAndValue[1]);
	if (indexOf(nameAndValue[0], "radius_xy")>-1) _RADIUS_XY=parseFloat(nameAndValue[1]);
	if (indexOf(nameAndValue[0], "radius_z")>-1) _RADIUS_Z= parseFloat(nameAndValue[1]);
	if (indexOf(nameAndValue[0], "noise")>-1) _NOISE= parseFloat(nameAndValue[1]);
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		run("Duplicate...", "duplicate channels="+_NUCLEI_CHANNEL+"-"+_NUCLEI_CHANNEL);
		run("Set Measurements...", "  center stack redirect=None decimal=2");
		imageID = getImageID();
		// run("FeatureJ Laplacian", "compute smoothing="+_SCALE);
		run("FeatureJ Hessian", "largest smoothing="+_SCALE);
		run("Invert", "stack");
		filteredID = getImageID();
		run("3D Maxima Finder", "radiusxy="+_RADIUS_XY+" radiusz="+_RADIUS_Z+" noise="+_NOISE);
		run("Macro...", "code=[v=(v>0) * 65535] stack");
		endOfTop = _RADIUS_Z / 2;
		startOfBottom = nSlices-((_RADIUS_Z / 2)-1);
		clearSlices(1, endOfTop);
		clearSlices(startOfBottom, nSlices);
		setSlice(1);
		run("8-bit");

		// Export results
		save(outputDir + "/" + image);
		
		// Cleanup
		run("Close All");
		if(isOpen("Results"))
		{
			selectWindow("Results");
			run("Close");
		}
	}
}
run("Quit");

