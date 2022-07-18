How to analyze toonotopy data and draw ROIs with Kendrick Kay's CVN lab drawing tools:

Step 0. Edit setSessions.m to include the freesurfer recon folder name and mrVista session name (which includes the niftis and stimuli) for the subject(s) you would like to analyze.

Step 1. Run step1_mrv_with_fsmesh_pipeline.m, ideally section by section as this is probably easiest and the code includes manually steps (namely, alignment). This script will preprocess, align and analyze your toonotopy data. It will also convert your maps to the freesurfer surface format so that you can use them with Kendrick's tools to draw your retinotopic ROIs. 

Step 2. Run step2_draw_EVC_ROIs.m. This loads and processes the retinotopic maps (eccentricity, polar angle, size and variance explained) and then sets up the variables you need to define ROIs with cvndefinerois.m. Change details in the section "specific setup for cvndefinerois.m" depending on which ROIs you'd like to draw and whether you've already started drawing them. 

=========================================================================================================

Notes on how to use cvndefinerois.m
- Video where Kendrick discusses the tool (starts around 8 minute mark): https://www.youtube.com/watch?v=205CMEKS7n0
- You can use the number keys to toggle between the different maps you have input under mgznames. 1 will always be the ROIs you are currently drawing, and 2 is the cortical sulci. The row of keys below can be used to draw outlines of the corresponding maps. For example, pressing ‘q’ will outline the ROIs you’ve drawn so far. The Enter key brings up the menu of actions (Draw, Erase, Switch Views etc). Note that after you have drawn an ROI, you will need to X out of that figure window in order to continue (a new figure window will pop up once you do so). No ROIs are saved until you officially save them as mgz files (using Enter -> Save), though if you exit out, the ROIs you have drawn so far will be dumped in your workspace under roivals. 
