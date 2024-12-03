macro "Batch export Dragonfly .ims files to .tif MIPs"{
	print("STARTING");

	print("Running the Bio-Formats Macro Extension");
	run("Bio-Formats Macro Extensions");

	// Get input arguments
	args = getArgument();
	args = split(args, ",");
	input = args[0];
	make_MIP = args[1];
	make_slice = args[2];
	slice_number = args[3];
	make_JPG = args[4];
	include_scalebar = args[5];

	print("Input Arguments:");
	print("input = "+input+"");
	print("make_MIP = "+make_MIP+"");
	print("make_slice = "+make_slice+"");
	print("slice_number = "+slice_number+"");
	print("make_JPG = "+make_JPG+"");
	print("include_scalebar = "+include_scalebar+"");

	slice_number = parseInt(slice_number);

	// Get the list of files in the input folder
	list = getFileList(input);
	setBatchMode(true);

	processed = 0;
	print("Detected "+list.length+" files in folder...");
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i],".ims")){
			print("Opening "+input+list[i]+"");
			Ext.openImagePlus(""+input+list[i]+"");

			print("Setting title");
			title=replace(list[i], ".ims", "");
			print(title);

			print("Getting dimensions");
			Stack.getDimensions(width, height, channels, slices, frames);
			print("Number of slices: "+slices+"");
			getVoxelSize(scaled_width, scaled_height, scaled_depth, unit);
			if(include_scalebar == "true"){
				scalebar_target_size = width*scaled_width*0.1; //10% of FOV in calibrated units
				print("scalebar_target_size = "+scalebar_target_size+"");
				if (unit == "pixels") print("Warning, image not spatially calibrated! Scalebar in 'pixels'");
			
				scalebar_length = 1; // initial scale bar length in measurement units
				// recursively calculate a 1-2-5 series until the length reaches scalebarsize, default to 1/10th of image width
				// 1-2-5 series is calculated by repeated multiplication with 2.3, rounded to one significant digit
				while (scalebar_length < scalebar_target_size) {
					scalebar_length = round((scalebar_length*2.3)/(Math.pow(10,(floor(Math.log10(abs(scalebar_length*2.3)))))))*(Math.pow(10,(floor(Math.log10(abs(scalebar_length*2.3))))));
				}
				print("scalebar_length = "+scalebar_length+"");
			}
			if(slices>1){
				if (make_slice == "true") {
					print("Making slice");
					run("Duplicate...", "duplicate slices="+1+floor(slice_number*(slices-1)/100)+"");
					rename("Dupe");
					print("Enhancing contrast");
					for(j=1;j<=channels;j++){
						Stack.setChannel(j);
						run("Enhance Contrast", "saturated=0.25");
					}
					print("Saving slice TIFF");
					saveAs("Tiff", "SingleSlice_"+slice_number+"PctThroughStack_"+ title + ".tif");

					if(make_JPG == "true"){
						print("Making slice RGB");
						run("RGB Color");
						if(include_scalebar == "true") {
							print("Adding scalebar to slice RGB");
							run("Scale Bar...", "width="+scalebar_length+" thickness="+width/60+" font="+width/15+" bold overlay");
						}
						print("Saving slice JPEG");
						saveAs("Jpeg", "SingleSlice_"+slice_number+"PctThroughStack_" +  title + ".jpg");
						close();
					}
					close();
				}
				if (make_MIP == "true") {
					print("Calculating MIP");
					run("Z Project...", "projection=[Max Intensity]");
					for(j=1;j<=channels;j++){
						Stack.setChannel(j);
						run("Enhance Contrast", "saturated=0.25");
					}
					print("Saving MIP TIFF");
					saveAs("Tiff", "MIP_"+ title + ".tif");
					if(make_JPG == "true"){
						print("Making MIP RGB");
						run("RGB Color");
						if(include_scalebar == "true") {
							print("Adding scalebar to MIP RGB");
							run("Scale Bar...", "width="+scalebar_length+" thickness="+width/60+" font="+width/15+" bold overlay");
						}
						print("Saving MIP JPEG");
						saveAs("Jpeg", "MIP_"+ title + ".jpg");
						close();
					}
					close();
				}
			}
			close();
			processed++;
			print("Processed "+processed+" files...");
		}

	}
	setBatchMode(false);
	run("Collect Garbage");
	print("DONE!");
}