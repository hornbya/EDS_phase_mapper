

<a href="https://zenodo.org/badge/latestdoi/540486820"><img src="https://zenodo.org/badge/540486820.svg" alt="DOI"></a>


# EDS phase mapper
Readme for EDS phase mapping macro for ImageJ/FIJI
REQUIREMENTS: ImageJ or Fiji v1.53+
Read + write access to input and output folders
File inputs: Folder containing labeled single-element phase maps (color or greyscale) as TIFF files

About the macro/disclaimer

This macro helps to spatially define (or ‘segment’) regions of interest differentiated by their chemistry in geologic materials measured by SEM-EDS mapping. It produces false-color ‘phase maps’ and ‘phase’ fractions. The macros operation is explicitly governed by user-led decisions on element selection, thresholding and noise reduction; therefore the macro is not designed to offer an objective and perfectly repeatable formula, but requires the judgement of a ‘Skilled user’ to generate useful and comparable results. Changing the user is likely to change the results.

Specific mineral species and precise phase definitions are not achievable using the macro alone. The macro can only output regions of interest defined by the apparent concentration of a set of elements defined by SEM-EDS element maps*. The segmentation of phases with similar element concentrations may not be effective unless an element with sufficiently different concentration is included in thresholding. 
In keeping with this, using the predefined phases option implies an interpretation of relative element concentrations that is not appropriate for most materials. While the macro was being compiled, the primary objective was to distinguish between phases in andesitic volcanic ash and predefined phases are only set up for some common minerals in volcanic ash and should only be used for similar samples*. 
Separate measurements (e.g., XRD) are required to determine mineral species and phase names.

Given the results-focused mechanics, no consistent estimation of error or uncertainty of the macro outputs for a single SEM-EDS can be given. In addition, the degree to which an SEM-EDS map is representative of a material cannot be known. It is likely that the results of multiple SEM-EDS map processing by the same user for a single sample (or material) are required to improve the representativeness and consistency of the results.
*SEM-EDS element mapping is sensitive to the instrument settings and sample properties, which should also be considered when interpreting and comparing outputs. 

Tips for use:
Before you start:
-	Knowledge of the phases present in the samples is a great help. 
This macro is not effective at identifying specific phases – it will only report relative enrichments of different elements. 

Phase identification should happen beforehand, if possible. XRD, Raman or other microanalytical measurements help to determine which phases (and therefore which elements) are useful to define the phase assemblage.

-	Element map output files from SEM-EDS mapping
By default, element maps show qualitative concentration of an element via the intensity of pixels using a preselected color. The intensity range is scaled to the minimum and maximum values measured for the specific element. 
Although false-color maps are useful for producing multi-element maps that help to distinguish phases, the best differentiation between concentration levels is achieved by using greyscale output maps.

-	Choose input files
Create a new folder and add single-element phase maps directly to it (without annotations but with a scale bar). Multi-element phase maps can be added to guide element selection but should not be selected in the ‘choose element’ dialog. SE/BSE images can also be useful in interpreting the EDS output (e.g., effects of topography/poor signal).

The fewer the element maps, the faster the processing of the images, however all relevant element maps are needed to define a full set of phases. If you do not need all phases, only add element maps for the target phases.

Element maps concentrated and ubiquitous in either the material (e.g. Si, O) or background (e.g. C) are useful for defining the ROI for all particles/sample (see below).

-	Running the macro
An easy way to open and run the macro is via the editor – Plugins > Macros > Edit… and point the macro file. On Windows, this will open in an editor, allowing you to select the language – this should be IJ1 macro. On Mac, this will open in simpler window. In both cases, you can run the macro using the ‘Run’ button or selecting Macro > Run.


In-macro tips
-	Thresholding
Phases are defined by thresholding the median pixel value(s) of the selected (or predefined) element(s). Different phases are usually defined by elements that are more enriched (on average) than other phases in the sample. However, the opposite approach (element(s) more depleted in a specific phase than all others) or an intermediate thresholding (restricting minimum and maximum threshold values) can be equally effective.

There is no perfect threshold level to define a phase, although there might be a level that is objectively ‘best’. If you are intending on including all phases (or as many as possible), it is better to err on the side of ‘over-selecting’ the major phases. Before any measurements, phases are rearranged so that phases with smaller area are ‘on top’ and mask underlying phases selections, covering up overly generous thresholding of major phases.

-	Noise reduction
Pixels in element maps tend to be big and thresholding will include noise. Remove outliers options are provided before and after thresholding to help with this. An outlier is defined by examining the surrounding pixels. The size of the region examined is controlled by the Radius option - higher values will remove more pixels and smooth/round boundaries.

Tip 1. Use the ‘Preview’ button. Either light (e.g., selected by thresholding) or dark pixels can be removed using the dropdown menu. 

Tip 2. Threshold value determines which pixels are defined as light or dark. This can be important before thresholding but makes no difference after thresholding (binary light/dark).

Tip 3. In some cases, it is beneficial to remove both light and dark outlier pixels in the threshold images. An option for this is offered in a dialog window before reaching the Run Options menu. This will add an extra ‘Remove outliers’ option at every occasion and can get tedious if it isn’t required.

-	Define ROI for all particles
Typically the best elements to use here are Si (if all phases are silicates, this is the cleanest) or O. Alternatively, the inverse threshold of C can be used in no carbonates are expected. Free element choice is available.

-	Building the phase map
Once a phase is spatially defined, it is added to a new image with the total sample or particle area highlighted. As phases are added, remaining areas without assigned phases become easier to define or select with an ROI.
The overlay image of phases will not look clean before the final step, but different colored selections are apparent.


-	RUN OPTIONS menu
Let me look around
Activity is locked to the Run Options menu, but it is useful to look at your element maps before selecting a threshold option. Use ‘Let me look around’ and scroll through slices in the stack using the horizontal scroll bar.

Choose predefined phases
Currently, predefined phases are limited to minerals common in volcanic ash only. If you select this option but do not want to choose any of the predefined phases, select cancel to return to the Run option menu.

‘Customize a phase’ allows you to give a name (as well as the standard elements chosen) and color to the phase before thresholding.

Choose elements
If you know which elements are enriched in the phase of interest, select ‘Choose elements’. 

Tip 1: You could have a hard time justifying the threshold method if you include BSE/SE or multi-element maps at this stage, but it can be done.

Tip 2: it is usually not useful to choose elements that are enriched in most phases, e.g. Si – better to select the set of relatively enriched elements that are unique to the target phase.

Select ROI
If you see apparent enrichment of an element, but do not know which other elements are associated, the ‘Select ROI’ option will allow you to define an area (region of interest) in one of the element maps. The macro will measure all slices in the ROI and provide a table showing data for each slice in the stack. The ‘mean/max’ and ‘min/max’ values are useful to determine which elements are concentrated in the ROI.

Tip 1: By default, area selection is made using the magic wand tool, but you can use any tool in the ImageJ toolbar to select the ROI (use Ctrl-Enter to bring the toolbar to the front).

Tip 2. As more phases are defined, areas without phases become easy to identify. Selecting an ROI in these areas helps to complete the phase map. Note that not all phases/area need to be defined.

All done
Only click this once you are happy with phase selection. Calculations, phase reordering and saving of final multi-phase map + single phase maps + key + results + ROIs.


