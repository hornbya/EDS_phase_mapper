	run("Fresh Start");
	directory=getDirectory("Choose directory containing EDS element map image files *only*");
	filelist = getFileList(directory) 
	call("ij.gui.ImageWindow.setNextLocation", 20, 100);
	open(directory)
	stackT=getTitle();
	
	Dialog.create("Default element maps");
	Dialog.addCheckbox("Are element maps already defined?", 1);
	Dialog.show();
	dmaps=Dialog.getCheckbox();
	if (dmaps==1) {
		
		selectWindow("elements");
		qm="\"";
		elemstr=getInfo("window.contents");
		elist=split(elemstr, ",");
		n=elist.length;
		elist=Array.trim(elist, n-1);
	
		n=nSlices;
		for (i = 1; i <= n; i++) {
			j=i-1;
			label=elist[j];
			Property.setSliceLabel(label, i);
		}
	}
	else {
		for (i = 1; i <= nSlices; i++) {
			setSlice(i);
			n=getSliceNumber();
			Dialog.create("set elements");
		    Dialog.addMessage("Enter element for the slice shown");
		    Dialog.addString(n, "Al");
		    Dialog.show();
		    slicename=Dialog.getString();
		    qm="\"";
		    qmslicename=qm+slicename+qm;
		    Property.setSliceLabel(qmslicename);
			}
		n=nSlices;
		elist=newArray(n);
		for (i = 1; i <= nSlices; i++) {
	  		setSlice(i);
	  		j=i-1;
	  		elist[j]=getInfo("slice.label");
		}
//		**shortcut for testing**
//		flist= newArray("Al", "C", "Ca", "Ch1", "Cl", "Fe", "K", "Mg", "Mn", "Na", "O", "S", "Si", "Ti");
//		n=flist.length;
//		elist=newArray(n);
//		for (i = 0; i < n; i++) {
//			elist[i]="\""+flist[i]+"\"";
		
		strlist=String.join(elist,",");
		strlist=strlist+",";
		print(strlist);
		
		name = "[elements]";
	  	run("New... ", "name="+name+" type=Table");
	  	f = name;
	  	print(f, "\\Clear");
	  	print(f, strlist);
	  	x=screenWidth;
	  	x=x-(x/4);
		y=screenHeight;
		y=y-(y/3);
	  	selectWindow("elements");
	  	setLocation(x, y);
	}
	setTool("line");
	Dialog.create("Scale and image adjustment")
	Dialog.addMessage("Enter length of scale bar (numbers only)");
	Dialog.addNumber("scale bar length", 10);
	Dialog.show();
	scale=Dialog.getNumber();

	waitForUser("Measure scale... then press OK");
	getLine(x1, y1, x2, y2, lineWidth);
	scaleL=x2-x1;
	run("Set Scale...", "known="+scale+" pixel=1 unit=um");
	
	
	setTool(0);
	waitForUser("Select area to measure (or crop out scale text)... then press OK");	
	run("Crop");
	Particles();
	runoptions();
	
	function runoptions(){
		Dialog.create("Run options");
		predef="predefined phases";
		choose="choose elements";
		roi="select ROI";
		look="Let me look around";
		done="All done!";
		items=newArray(look, predef, choose, roi, done);
		Dialog.addRadioButtonGroup("****Method****", items, 5, 1, 1);
		Dialog.show();
		runchoice=Dialog.getRadioButton();
		 
		if (runchoice==predef) {
			Dialog.create("predefined phases");
			CaS="Ca sulfate";
			plagio="Plagioclase (Ca-Na) feldspar";
			silica="SiO2";
			FeTi="Fe-Ti oxide";
			Cpx="Ca(Fe-Mg) Clinopyroxene";
			Gls="Glass (defined by Al content alone)";
			Ctm1="Customize a phase!";
			defaults=newArray(7);
			Array.fill(defaults, 0);
			labels=newArray(CaS,plagio,silica,FeTi,Cpx,Gls, Ctm1);
			Dialog.addMessage("Choose phase. Multiple phases can be selected and will be run in sequence\nnote: it's useful to run the largest or most abundant phases first");
			Dialog.addCheckboxGroup(7, 1, labels, defaults);
			Dialog.show();
			if	(isOpen("predefined phases"))
				g="[predefined phases]";
			else {
				name = "[predefined phases]";
				run("New... ", "name="+name+" type=Table");
				x=screenWidth;
				x=0+(x/10);
				y=screenHeight;
				y=0+(y/3);
				selectWindow("predefined phases");
				setLocation(x, y);
				g = name;
				print(g, "\\Clear");
			}
			if (Dialog.getCheckbox()==1) {
				print(g, CaS);
				CaSulphate();
			}
			if (Dialog.getCheckbox()==1) {
				print(g, plagio);
				Plag();
			}
			if (Dialog.getCheckbox()==1) {
				print(g, silica);
				SiO2();
			}
			if (Dialog.getCheckbox()==1) {
				print(g, FeTi);
				IronTiOxide();
			}
			if (Dialog.getCheckbox()==1) {
				print(g, Cpx);
				Clinopyroxene();
			}
			if (Dialog.getCheckbox()==1) {
				print(g, Gls);
				Glass();
			}
			if (Dialog.getCheckbox()==1) {	
				custompsetup();
			}
		}
		
		else if (runchoice==choose) {
			elements();
		}
		
		else if (runchoice==roi) {
			wait(100);
			selectWindow(stackT);
			setTool(8);
			waitForUser("Choose slice and select area using wand or freehand tools");
			run("Set Measurements...", "area mean min display redirect=None decimal=3");
			run("Measure Stack...");
			n=nResults;
//			elist= newArray("Al", "C", "Ca", "Ch1", "Cl", "Fe", "K", "Mg", "Mn", "Na", "O", "S", "Si", "Ti");
			Table.setColumn("Elem", elist);
			for (i = 0; i < nResults(); i++) {
				u=getResult("Min", i);
				v = getResult("Mean", i);
				w=getResult("Max", i);
				x=v/w;
				y=u/w;
				setResult("Mean/Max", i, x);
				setResult("Min/Max", i, y);
			}
			Table.sort("Min/Max");
			n = Table.size;
			Table.setColumn("idx", Array.reverse(Array.getSequence(n)));
			Table.sort("idx");
			Table.deleteColumn("idx");
			Table.deleteColumn("Area");
			Table.deleteColumn("Slice");
			updateResults();
			waitForUser("choose elements of interest");
			close("Results");
			run("Select None");
			elements();
		}
	
		else if (runchoice==look) {
			waitForUser("Just looking...", "Click OK when you're done");
			runoptions();
		}
		
		else if (runchoice==done) {
			roiManager("deselect");
			run("Set Measurements...", "area mean min display redirect=None decimal=3");
			roiManager("show none");
			roiManager("show all");
			roiManager("Measure");
			n=nResults;
			roirank=newArray(n);
			for (i = 0; i < nResults(); i++) {
		    	roirank[i]=getResult("Area", i);
			}
			print("\\Clear");
			roirank=Array.invert(roirank);
			rankPosArr = Array.rankPositions(roirank);
			ranks = Array.rankPositions(rankPosArr);
   			ranks=Array.invert(ranks);
   			desc=newArray(n);
   			for (i = 0; i < nResults(); i++) {
				desc[i]=n-ranks[i];
			}
   			
   			for (i=0; i<roiManager("count"); i++) {
				roiManager("select", i);
				roiname=getInfo("roi.name");
				roiManager("Rename", IJ.pad(desc[i], 2)+roiname); 
			}
			roiManager("Deselect");
			roiManager("Sort");
			roiManager("Show None");
			roiManager("Show All");
			selectWindow("Results");
			run("Close");
			roiManager("Measure");
			w = getResult("Area", 0);
			for (i=0; i<nResults; i++) {
			    oldLabel = getResultLabel(i);
			    delimiter = indexOf(oldLabel, ":");
			    newLabel = substring(oldLabel, delimiter+3);
			    setResult("Label", i, newLabel);
  			}
  			updateResults();
  			
  			IJ.deleteRows(0, 0);
  			roiManager("select", 0);
  			roiManager("delete");
			
			roilist=newArray(roiManager("count"));
			for (i=0; i<nResults; i++) {
			  	newLabel = getResultLabel(i);
			    roiManager("select", i);
				roiManager("Rename", newLabel);
				roilist[i]=Roi.getName;    
			}

			selectWindow("RGB");
			rgbph=getInfo("window.contents");
			rgbarr=split(rgbph, "\n");
			len=rgbarr.length;
			rgbs=newArray(len);
			phases=newArray(len);
			phases[0]=0;
			rgbs[0]=0;
			for (i = 0; i < len ; i++) {
				rgblist=rgbarr[i];
				eq=indexOf(rgblist, "=");
				eqplus=eq+1;
				rgbval=substring(rgblist, eqplus);
				rgbs[i]=rgbval;
				rgbphase=substring(rgblist, 0, eq);
				phases[i]=rgbphase;
			}
		
			for (i = 0; i < len; i++) {
			roiManager("show none");
			roiManager("select", i);
			phname=roilist[i];
				for (j=0; j<len; j++) {
					if (phases[j]==phname) {
						rgbval=rgbs[j];
						strl=rgbval.length;
						rgbqmf=substring(rgbval, 0, strl);
						rgbspl=split(rgbqmf, ",");
						r=rgbspl[0];
						g=rgbspl[1];
						b=rgbspl[2];
						setForegroundColor(r,g,b);
						fill();
					}
				}
			}
			
			print("\\Clear");

			for (i = 0; i < len; i++) {
			phname=roilist[i];
				for (j=0; j<len; j++) {
					if (phases[j]==phname) {
						rgbval=rgbs[j];
						strl=rgbval.length;
						rgbqmf=substring(rgbval, 0, strl);
						rgbspl=split(rgbqmf, ",");
						r=rgbspl[0];
						g=rgbspl[1];
						b=rgbspl[2];
						a=getTitle();
						run("Select None");
						run("Duplicate...", " ");
						min=newArray(3);
						max=newArray(3);
						filter=newArray(3);
						run("RGB Stack");
						run("Convert Stack to Images");
						selectWindow("Red");
						rename("0");
						selectWindow("Green");
						rename("1");
						selectWindow("Blue");
						rename("2");
						min[0]=r;
						max[0]=r;
						filter[0]="pass";
						min[1]=g;
						max[1]=g;
						filter[1]="pass";
						min[2]=b;
						max[2]=b;
						filter[2]="pass";
						for (k=0;k<3;k++){
						  selectWindow(""+k);
						  setThreshold(min[k], max[k]);
						  run("Convert to Mask");
						  if (filter[k]=="stop")  run("Invert");
						}
						imageCalculator("AND create", "0","1");
						imageCalculator("AND create", "Result of 0","2");
						for (k=0;k<3;k++){
						  selectWindow(""+k);
						  close();
						}
						selectWindow("Result of 0");
						close();
						selectWindow("Result of Result of 0");
						rename(phname);
						selectWindow(a);
					}
				}
			}
			roiManager("reset");
			run("Clear Results");
			for (i = 0; i<len; i++) {
	   			npname=phases[i];
	   			run("Select None");
	   			if (isOpen(npname)) {
		   			selectWindow(npname);
		   			run("Create Selection");
					roiManager("add");
					run("Select None");
		   			roinum=roiManager("count")-1;
		   			roiManager("select", roinum);
		   			roiManager("rename", npname);
		   			roiManager("measure");
					rgbval=rgbs[i];
					strl=rgbval.length;
					rgbqmf=substring(rgbval, 0, strl);
					rgbspl=split(rgbqmf, ",");
					r=rgbspl[0];
					g=rgbspl[1];
					b=rgbspl[2];
					setForegroundColor(r,g,b);
					setResult("r", i, r);
					setResult("g", i, g);
					setResult("b", i, b);
					run("RGB Color");
					fill();
//					name=npname+".tif";
//					qm="\"";
//					namenqm=replace(name, qm, "");
////					print(namenqm);
//					directory=File.directory;
//					File.makeDirectory(directory+File.separator+"output");
//					path=directory+File.separator+"output"+File.separator+namenqm;
//					save(path);
				}
				updateResults();
			}
			
			for (i=0; i<nResults; i++) {
			    oldLabel = getResultLabel(i);
			    delimiter = indexOf(oldLabel, ":");
			    newLabel = substring(oldLabel, delimiter+1);
			    setResult("Label", i, newLabel);
			    v = getResult("Area", i);
		    	x = v/w*100;
		   		setResult("Area %", i, x);
  			}
  			updateResults();
  			cols=newArray("Mean", "Min", "Max");
  			for (i = 0; i < cols.length; i++) {
	  			colname=cols[i];
	  			selectWindow("Results");
	  			Table.deleteColumn(colname);
	  			Table.sort("Area");
	  			n = Table.size;
				Table.setColumn("idx", Array.reverse(Array.getSequence(n)));
				Table.sort("idx");
				Table.deleteColumn("idx");
  			}
  			
			for (i = 0; i<len; i++) {
	   			npname=phases[i];
	   			if (isOpen(npname)) {
		   			selectWindow(npname);
		   			name=getInfo("window.title")+".tif";
					qm="\"";
					namenqm=replace(name, qm, "");
					print(namenqm);
					directory=File.directory;
					File.makeDirectory(directory+File.separator+"output");
					File.makeDirectory(directory+File.separator+"output"+File.separator+"phase_maps");
					path=directory+File.separator+"output"+File.separator+"phase_maps"+File.separator+namenqm;
					save(path);
	   			}
			}	

			call("ij.gui.ImageWindow.setNextLocation", 10, 10);
			newImage("key", "RGB", 200, 300, 1);
			for (i = 0; i < nResults; i++) {
				area=getResultString("Area %", i);
				areadp=substring(area, 0, 4);
				labres=getResultString("Label", i);
				setColor("black");
				j=20*i;
				j=j+10;
				drawOval(10, j, 10, 10);
				r=getResult("r",i);
				g=getResult("g", i);
				b=getResult("b", i);
				setColor(r, g, b);
				wait(50);
				fillOval(10, j, 10, 10);
				setColor("black");
				drawString(areadp+"%", 30, j+15);
				drawString(labres, 75, j+15);
			}
		
			directory=File.directory;
			File.makeDirectory(directory+File.separator+"output");
			output=File.separator+"output"+File.separator;
			savewindow=newArray("RGB", "chosen elements", "predefined phases");
			for (i = 0; i < savewindow.length; i++) {
				wn=savewindow[i];
				if (isOpen(wn)) {
					selectWindow(wn);
					name=getInfo("window.title")+".txt";
					path=directory+output+name;
					save(path);
				}
			}
			name="Results.csv";
			path=directory+output+name;
			selectWindow("Results");
			saveAs("Results", path);
			
			savewindow=newArray("MAX_Stack","key");
			for (i = 0; i < savewindow.length; i++) {
				wn=savewindow[i];
				if (isOpen(wn)) {
					selectWindow(wn);
					name=getInfo("window.title")+".tif";
					path=directory+output+name;
					save(path);
				}
			}
			
			name="ROIs";
			path=directory+output+name;
			roiManager("save", path+".zip");
			close("RGB");
			close("Log");
			close("chosen colors");
			close("chosen elements");
			close("stack");
			for (i = 0; i<len; i++) {
	   			npname=phases[i];
	   			if (isOpen(npname)) {
		   			selectWindow(npname);
		   			close();
	   			}
			}
			selectWindow("Results");
			selectWindow("MAX_Stack");
			getLocationAndSize(x, y, width, height);
			selectWindow("key");
			w2=getWidth();
			setLocation(x+width-w2, y);
		}
	
		if (isOpen("key")==0) {
			if (nImages>2)
				flatten();
			runoptions();
		}
	}
	
	function elements() {
//		elist= newArray("Al", "C", "Ca", "Ch1", "Cl", "Fe", "K", "Mg", "Mn", "Na", "O", "S", "Si", "Ti");
		n=elist.length;
		cbox=newArray(n);
		Array.fill(cbox, 0);
		Dialog.create("Choose elements");
		Dialog.addCheckboxGroup(5, 3, elist,cbox);
		Dialog.show;
		print("\\Clear");
		j=0;
		if (isOpen("chosen elements")==0){
		
			name = "[chosen elements]";
			run("New... ", "name="+name+" type=Table");
			f = name;
			print(f, "\\Clear");
		  	x=screenWidth;
		  	x=x-(x/4);
			y=screenHeight;
			y=y-(y/3);
		  	selectWindow("elements");
		  	setLocation(x, y);	  
		}
		else
			f="[chosen elements]";
		name = "[elarr]";
		run("New... ", "name="+name+" type=Table");
		g = name;
		print(g, "\\Clear");
		selectImage(stackT);
		
		for (i = 0; i < n; i++) {
			if (Dialog.getCheckbox()) {
				print(i);
				eli=elist[i];
				qm="\"";
				print(f, "el="+qm+eli+qm);
				if (i!=0) {
					setSlice(i);
					run("Next Slice [>]");
				}
				else 
					setSlice(1);
				j=getSliceNumber();
				print(g,j);
			}
		}
		print(f, "*******");
		selectWindow("elarr");
		selel=getInfo("window.contents");
		elsel=split(selel);
		subst=String.join(elsel);
		substnsp=replace(subst, " ", "");
//		print("\\Clear");
		elems=getInfo("log");
		elemarr=split(elems);
		n=elemarr.length;
		elss=newArray(n);
		
		for (i = 0; i < n; i++) {
			k=elemarr[i];
			elss[i]=elist[k];
		}
		pname=String.join(elss, "+");
		selectWindow("elarr");
		run("Close");
		
		run("Make Substack...","  slices="+substnsp+"");
		run("8-bit");
		n=elsel.length;
		if (n>1) {
			ss=getTitle();
			run("Z Project...", "projection=Median");
//			run("Close-");
			selectWindow(ss);
			run("Close");
		}
		cleanthresh();
		addROI();
		run("Color Picker...");
		waitForUser("select color for phase");
		run("Close");
		color=getValue("rgb.foreground");
		print(color);
		r=(color>>16)&0xff;
	  	g=(color>>8)&0xff;
	  	b=color&0xff;
		fillcolor();	
		
	}
	
	function cleanthresh() {
		run("8-bit");
		run("Despeckle");
		run("Remove Outliers...");
		setOption("BlackBackground", true);
		setAutoThreshold("Default dark");
		run("Threshold...");
		waitForUser("set threshold...  click apply... then press OK");
		run("Close");
		run("Despeckle");
		run("Remove Outliers...");
		rename(pname);
	}
	
	function addROI() {
		run("Create Selection");
		run("Add to Manager");
		i=roiManager("count");
		roiManager("select", i-1);
		Roi.setName(pname);
		roiName=Roi.getName;
		roiManager("rename", roiName);
	}
	
	function flatten() {
		if (isOpen("chosen colors")) {
			selectWindow("chosen colors");
			close();
		}	
		run("Images to Stack");
		w=getWidth()+20;
		x=screenWidth-w;
		call("ij.gui.ImageWindow.setNextLocation", x, 50);
		run("Z Project...", "projection=[Max Intensity]");
		selectWindow("Stack");
		close();
		roiManager("select", 0);
		wait(1000);
	}
	
		function fillcolor() {
//		print("\\Clear");
		setForegroundColor(r,g,b);
		run("RGB Color");
		run("Fill");
		rgb=""+r+","+g+","+b;
		if (isOpen("RGB"))
			selectWindow("RGB");
		else
			Table.create("RGB");
		w="RGB";
		x="["+w+"]";
		y=(roiManager("size"))-1;
		roiManager("select", y);
		roiName=Roi.getName;
		print(x, roiName+"="+rgb);	
		
		cc="chosen colors";
		if (isOpen(cc))
			close(cc);
		call("ij.gui.ImageWindow.setNextLocation", 300, 10);
		newImage(cc, "RGB", 200, 50, 1);
		
		selectWindow("RGB");
		rgbinfo=getInfo("window.contents");
		rgbcount=split(rgbinfo, "\n");
		rgbz=rgbcount.length;
		selectWindow(cc);
		wide=getWidth();
		high=getHeight();
		lefts=newArray(rgbz);
		rights=newArray(rgbz);
		tops=newArray(rgbz);
		bottoms=newArray(rgbz);
		for (i = 0; i < rgbz; i++) {
			lefts[i]=wide/rgbz*i;
			lef=lefts[i];
			rights[i]=lef+wide/rgbz;
			tops[i]=0;
			bottoms[i]=high;
			rgbcc=newArray(rgbz);
			rgblist=rgbcount[i];
			eq=indexOf(rgblist, "=");
			eqplus=eq+1;
			rgbcc[i]=substring(rgblist, eqplus);
			rgbval=rgbcc[i];
			rgbspl=split(rgbval, ",");
			r=rgbspl[0];
			g=rgbspl[1];
			b=rgbspl[2];
			l=lefts[i];
			t=tops[i];
			rt=rights[i];
			bt=bottoms[i];
			drawRect(l, t, rt, bt);
			setForegroundColor(r,g,b);
			fillRect(l, t, rt, bt);
		}
	}
	
	function Particles() {
elist= newArray("Al", "C", "Ca", "Ch1", "Cl", "Fe", "K", "Mg", "Mn", "Na", "O", "S", "Si", "Ti");
		qm="\"";
		Dialog.create("Define particles or measurement area");
		Dialog.addMessage("Next step - define particles or region to measure \nBy default this is done thresholding the "+qm+"O"+qm+" slice\n \n - Set the threshold to include all particles or ROIs");
		label="Choose element map to define particles or ROI(s)";
		items=newArray("O", "Si", "C", "A different element");
		Dialog.addRadioButtonGroup(label, items, 2, 2, "O");
		Dialog.show();
		partschoice=Dialog.getRadioButton();
		if (partschoice=="A different element") {
			Dialog.create("Select threshold element");
			Dialog.addRadioButtonGroup("Select threshold element", elist, 3, 5, "O");
			Dialog.show();
			partschoice=Dialog.getRadioButton();
		}
		el1=qm+partschoice+qm;
		selectImage(stackT);
		pdef="notOK";
		for (i = 1; i <= nSlices; i++) {
		   	setSlice(i);
		   	el=getInfo("slice.label");
		    if (el1==el) {
				pdef="ok";
				sel1=getSliceNumber();
		    }
	    }
	    if  (pdef!="ok") {
	    	Dialog.create("Choose again...");
	    	Dialog.addMessage("slice containing "+partschoice+" does not exist! \n choose again or check slice labels");
	    	Dialog.show();
	    	Particles();
	    }
	    
		pname="All particles/ROIs";
		run("Make Substack...", "  slices="+sel1+"");
		cleanthresh();
		addROI();
		close();
	}
	
	function custompsetup() {
//		elist= newArray("Al", "C", "Ca", "Ch1", "Cl", "Fe", "K", "Mg", "Mn", "Na", "O", "S", "Si", "Ti");
		Dialog.create("Custom phase option (1/3)");
		Dialog.addString("Phase name", "Enter name here");
		Dialog.show();
		ctmpn=Dialog.getString();
		e="[predefined phases]";
		print(e, ctmpn);
		n=elist.length;
		cbox=newArray(n);
		Array.fill(cbox, 0);
		Dialog.create("Custom phase options (2/3)");
		Dialog.addMessage("Select elements in "+ctmpn);
		Dialog.addCheckboxGroup(5, 3, elist,cbox);
		Dialog.show();
			
		name = "[custom elements]";
		run("New... ", "name="+name+" type=Table");
		g = name;
		print(g, "\\Clear");
//		directory=getDirectory("Choose directory containing EDS element map image files *only*");
//		call("ij.gui.ImageWindow.setNextLocation", 20, 100);
//		open(directory)
//		stackT=getTitle();
		selectImage(stackT);
		if (isOpen("chosen elements")==0){
			name = "[chosen elements]";
			run("New... ", "name="+name+" type=Table");
			h = name;
			print(h, "\\Clear");
		  	x=screenWidth;
		  	x=x-(x/4);
			y=screenHeight;
			y=y-(y/3);
		  	selectWindow("chosen elements");
		  	setLocation(x, y);	  
		}
		else
			h="[chosen elements]";
		
		print("\\Clear");
		for (i = 0; i < n; i++) {
			if (Dialog.getCheckbox()) {
				print(i);
				eli=elist[i];
//				qm="\"";
				print(h, "el="+eli);
				if (i!=0) {
					setSlice(i);
					run("Next Slice [>]");
				}
				else 
					setSlice(1);
				j=getSliceNumber();
				print(g,j);
			}
		}
		print(h, "*******");
		customphase();
	}
	
	function customphase() {
		run("Color Picker...");
		waitForUser("Choose color for "+ctmpn);
		run("Close");
		color=getValue("rgb.foreground");
		r=(color>>16)&0xff;
	  	g=(color>>8)&0xff;
	  	b=color&0xff;
	  	
	  	selectWindow("custom elements");
		selel=getInfo("window.contents");
		elsel=split(selel);
		subst=String.join(elsel);
		substnsp=replace(subst, " ", "");
		elems=getInfo("log");
		elemarr=split(elems);
		n=elemarr.length;
		elemsname=newArray(n);
		if (elemarr.length>1) {
			for (i = 0; i < n; i++) {
				j=elemarr[i];
				j=parseInt(j);
				elemsname[i]=elist[j];
			}
			pname=String.join(elemsname, "+");
		}
		else {
			k=parseInt(elems);
			pname=elist[k];
		}
		selectWindow("custom elements");
		run("Close");
		print("\\Clear");
		selectImage(stackT);
		
		run("Make Substack...","  slices="+substnsp+"");
		run("8-bit");
		n=elsel.length;
		if (n>1) {
			ss=getTitle();
			run("Z Project...", "projection=Median");
//			run("Close-");
			selectWindow(ss);
			run("Close");
		}
		cleanthresh();
		addROI();
		fillcolor();
	}
	
	function CaSulphate() {
		qm="\"";
		el1 = qm+"Ca"+qm;
		el2= qm+"S"+qm;
		print("\\Clear");
		r=255;
		g=0;
		b=0;
		twoelphase();
	}
	
		function IronTiOxide() {
		qm="\"";
		el1 = qm+"Fe"+qm;
		el2= qm+"Ti"+qm;
		print("\\Clear");
		r=165;
		g=45;
		b=45;
		twoelphase();
	}
	
		function Clinopyroxene() {
		Ca="Ca";
		Mg="Mg";
		wait(100);
		Fe="Fe";
		qm="\"";
		el1 = qm+Ca+qm+"";
		el2= qm+Mg+qm+"";
		el3= qm+Fe+qm+"";
		r=50;
		g=200;
		b=50;
		ssol1=el2;
		ssol2=el3;
		remel=el1;
		twostagethreeelphase();
	}		
	
	function Plag() {
		Al="Al";
		Ca="Ca";
		Na="Na";
		qm="\"";
		el1 = qm+Al+qm+"";
		el2= qm+Ca+qm+"";
		el3= qm+Na+qm+"";
		ssol1=el2;
		ssol2=el3;
		remel=el1;
		r=50;
		g=200;
		b=255;
		twostagethreeelphase();
	}
		
	function Glass() {
		qm="\"";
		el1 = qm+"Al"+qm;
		print("\\Clear");
		r=180;
		g=180;
		b=180;
		oneelphase();
	}	
	
	function SiO2() {
		qm="\"";
		el1 = qm+"Si"+qm;
		print("\\Clear");
		r=255;
		g=200;
		b=200;
		oneelphase();
	}
		
	function oneelphase() {
		selectImage(stackT);
		for (i = 1; i <= nSlices; i++) {
		    setSlice(i);
			elem=Property.getSliceLabel;
			if (elem==el1)
				sel1=getSliceNumber();
			else 
				continue
		}
		pname=el1;
		run("Make Substack...", "  slices="+sel1+"");
		sst=getTitle();
		selectWindow("predefined phases");
		selectWindow(sst);
		cleanthresh();
		addROI();
		fillcolor();
	}	
	
	function twostagethreeelphase() {
		print("\\Clear");
		selectImage(stackT);
		for (i = 1; i <= nSlices; i++) {
		    setSlice(i);
			elem=Property.getSliceLabel;
			if (elem==ssol1)
				sel1=getSliceNumber();
			else if (elem==ssol2)
				sel2=getSliceNumber();
			else if (elem==remel)
				sel3=getSliceNumber();
			else	
				continue
		}
		pname=el1+"+"+el2+"+"+el3;
		run("Make Substack...", "  slices="+sel1+","+sel2+"");
		run("8-bit");
		ssol=getTitle();
		run("Z Project...", "projection=[Max Intensity]");
		ssolMI=getTitle();
		selectWindow(ssol);
		close();
		selectImage(stackT);
		Stack.setSlice(sel3);
		run("Make Substack...","  slices="+sel3+"");
		run("Select All");
		run("Copy");
		close();
		selectWindow(ssolMI);
		run("Add Slice");
		run("Paste");
		run("Z Project...", "projection=Median");
		trimed=getTitle();
		selectWindow(ssolMI);
		close();
//		run("Close-");
		selectWindow("predefined phases");
		selectWindow(trimed);
		cleanthresh();
		addROI();
		fillcolor();
	}
	

	function twoelphase() {
	selectImage(stackT);
		for (i = 1; i <= nSlices; i++) {
		    setSlice(i);
			m=elist.length-1;
			if (i<nSlices)
				elem=Property.getSliceLabel;
			else 
				elem=elist[m];
			if (elem==el1)
				sel1=getSliceNumber();
			else if (elem==el2)
				sel2=getSliceNumber();
			else 
				continue

		}
		pname=el1+"+"+el2;
		run("Make Substack...", "  slices="+sel1+","+sel2+"");
		run("8-bit");
		ss=getTitle();
		run("Z Project...", "projection=Median");
		sst=getTitle();
//		run("Close-");
		selectWindow(ss);
		close();
		selectWindow("predefined phases");
		selectWindow(sst);
		cleanthresh();
		addROI();
		fillcolor();
	}