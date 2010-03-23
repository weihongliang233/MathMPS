(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



MPSProductState::usage="MPSProductState[numTensors] creates a Matrix Product State of length numTensors. 
Options:
   Spin->s (default = 2)
   Bond->\[Chi] (default = 10)
   Type-> \"Random\" (default), \"Identity\", \"Decaying\". 
As of now the Random option produces an warning but the state is correct." 


MPSExpandBond::usage="MPSExpandBond[mps,new\[Chi]] expands the bond dimension \[Chi] of mps to new\[Chi]. Returns the expanded mps as a new variable"


MPSOverlap::usage="MPSOverlap[mps1,mps2] returns the overlap <psi_1|psi_2>, where psi_i is the state represented by mpsi"


MPSNormalize::usage="MPSNormalize[mps] normalizes mps so that MPSOverlap[mps,mps]=1. It changes the state."


MPSCanonize::usage="MPSCanonize[mps] transforms mps into its canonical form. 
Options:
      Direction->\"Left\" (default) or \"Right\""


MPSSave::usage="MPSSave[MPS,filename] saves MPS into ASCII files for later retrieval. Right now it produces a lot of files, to be changed in the future. filename needs to be a string"



MPSRead::usage="MPSRead[filename] reads the files produced by MPSSave and returns a new MPS object"


DefaultSpinDimension=2;
MPSDefaultBond=10;
DefaultSweeps=10;
DefaultEnergyTolerance=10^(-4);
DefaultApproximationTolerance=10^(-10);
DefaultInteractionRange=1;
MPSMaxBond=100;


ClearAll[LProduct,RProduct];
LProduct[A_,B_]:=Plus@@MapThread[ConjugateTranspose[#2].#1&,{A,B}];
LProduct[A_,B_,Lm_]:=Plus@@MapThread[ConjugateTranspose[#2].Lm.#1&,{A,B}];
RProduct[A_,B_]:=Plus@@MapThread[#1.ConjugateTranspose[#2]&,{A,B}];
RProduct[A_,B_,Rm_]:=Plus@@MapThread[#1.Rm.ConjugateTranspose[#2]&,{A,B}];


sigma[0]=SparseArray[{{1.0,0.0},{0.0,1.0}}];
sigma[1]=SparseArray[{{0.0,0.5},{0.5,0.0}}];
sigma[2]=SparseArray[{{0.0,-I 0.5},{I 0.5,0.0}}];
sigma[3]=SparseArray[{{0.5,0.0},{0.0,-0.5}}];


Clear[MPSProductState];
Options[MPSProductState]={Spin->DefaultSpinDimension,Bond->MPSDefaultBond,Type->"Random"};
MPSProductState[numTensors_,OptionsPattern[]]:=Module[{\[CapitalGamma]=Array[0&,{numTensors}],type=OptionValue[Type],coeffList,spin=OptionValue[Spin],\[Chi]=OptionValue[Bond]},
Switch[type,
"Identity",
coeffList=Table[Table[If[i==j==1,{1.0}~Join~Table[0.0,{m,1,spin-1}],Table[0.0,{m,spin}]],{k,1,numTensors}],{i,1,\[Chi]},{j,1,\[Chi]}];
"Decaying",
coeffList=Table[Table[If[i==j==1,Normalize[Table[Exp[-0.5 Log[20](m-1)/spin],{m,1,spin}]],0],{k,1,numTensors}],{i,1,\[Chi]},{j,1,\[Chi]}];
"Random",
coeffList=Table[Table[Normalize[RandomComplex[{-1-I,1+I},spin]],{k,1,numTensors}],{i,1,\[Chi]},{j,1,\[Chi]}];
];
{Table[SparseArray[Table[coeffList[[i,j,1,n]],{i,1,1},{j,1,\[Chi]}]],{n,1,spin}]}~Join~Table[
Table[SparseArray[Table[coeffList[[i,j,k,n]],{i,1,\[Chi]},{j,1,\[Chi]}]],{n,1,spin}],
{k,2,numTensors-1}]~Join~{Table[SparseArray[Table[coeffList[[i,j,numTensors,n]],{i,1,\[Chi]},{j,1,1}]],{n,1,spin}]}
];


Clear[MPSExpandBond];
SetAttributes[MPSExpandBond,HoldFirst];
MPSExpandBond[MPS_,new\[Chi]_]:=Module[
{old\[Chi]},
old\[Chi]=Max[Dimensions[#]&/@MPS];
If[old\[Chi]>new\[Chi],Print["WARNING: Trying to expand an MPS to a smaller bond dimension"];MPS,
Print["Grow \[Chi] to "<>ToString[new\[Chi]]];
{SparseArray[PadRight[#,{1,new\[Chi]}]&/@MPS[[1]]]}~Join~Table[SparseArray[PadRight[#,{new\[Chi],new\[Chi]}]&/@MPS[[M]]],{M,2,Length[MPS]-1}]~Join~{SparseArray[PadRight[#,{new\[Chi],1}]&/@MPS[[Length[MPS]]]]}
]
];


ClearAll[MPSOverlap];
SetAttributes[MPSOverlap,HoldAll];
MPSOverlap[mps1_,mps2_]:=Module[{ctemp=0,L},
(* This function also works with Fold, which is appealing because can also give FoldList:
Fold[LProduct[mps1[[#2]],mps2[[#2]],#1]&,LProduct[mps1[[1]],mps2[[1]]],Range[2,Length[mps1]]][[1,1]]
*)
L[1]=LProduct[mps1[[1]],mps2[[1]]];
L[n_]:=LProduct[mps1[[n]],mps2[[n]],L[n-1]];
Chop[L[Length[mps1]][[1,1]]]
];


ClearAll[MPSNormalize];
SetAttributes[MPSNormalize,HoldAll];
MPSNormalize[mps_]:=Module[{norm},
norm=Chop[MPSOverlap[mps,mps]];
mps=Chop[mps/Abs[norm]^(1/(2 Length[mps]))];
norm
];


ClearAll[MPSCanonizeSite];
Options[MPSCanonizeSite]={Direction->"Right",UseMatrix->True};
SetAttributes[MPSCanonizeSite,HoldAll];
MPSCanonizeSite[tensor_,matrix_,OptionsPattern[]]:=Module[{sense=OptionValue[Direction],usematrix=OptionValue[UseMatrix],numTensors,\[Chi]L,\[Chi]R,\[Chi],u,v,t,newTensor},(* Start by multiplying the tensor with the matrix from the previous site *)
If[sense=="Right",
If[usematrix,newTensor=tensor.matrix,newTensor=tensor];
{\[Chi]L,\[Chi]R}=Dimensions[newTensor[[1]]];
\[Chi]=Max[\[Chi]L,\[Chi]R];
(* SVD of the new tensor, putting [chiL, spin*chiR] *)
{u,v,t}=SingularValueDecomposition[Flatten[newTensor,{{2},{1,3}}]];
(* Prepare new right matrix *)
matrix=PadRight[u.v,{Min[\[Chi],\[Chi]L],Min[\[Chi],Length[t],\[Chi]L]}];
(* Form the new tensor with the first row of t^dagger *)
(Partition[ConjugateTranspose[t],{Min[\[Chi],Length[t],\[Chi]L],\[Chi]R}][[1,All]])
,
If[usematrix,newTensor=matrix.#&/@tensor,newTensor=tensor];
{\[Chi]L,\[Chi]R}=Dimensions[newTensor[[1]]];
\[Chi]=Max[\[Chi]L,\[Chi]R];
(* SVD of the new tensor, putting [chiL*spin, chiR] *)
{u,v,t}=SingularValueDecomposition[Flatten[newTensor,{{1,2},{3}}]];
(* Prepare new right matrix *)
matrix=PadRight[v.ConjugateTranspose[t],{Min[\[Chi],Length[u],\[Chi]R],Min[\[Chi],\[Chi]R]}];
(* Form the new tensor with the first column of u *)
(Partition[u,{\[Chi]L,Min[\[Chi],Length[u],\[Chi]R]}][[All,1]])
]
];


ClearAll[MPSCanonize];
Options[MPSCanonize]={Site->0};
SetAttributes[MPSCanonize,HoldAll];
MPSCanonize[mps_,OptionsPattern[]]:=Module[{site=OptionValue[Site],numTensors,xM},
numTensors=Length[mps];
(* First: Right normalization up to site *)
xM={{1.}};
Do[
mps[[s]]=SparseArray[MPSCanonizeSite[mps[[s]],xM]];
,{s,numTensors,site+1,-1}];
(* Now do LEFT normalization *)
xM={{1.}};
Do[
mps[[s]]=SparseArray[MPSCanonizeSite[mps[[s]],xM,Direction->"Left"]];
,{s,1,site-1}];
site
];


ClearAll[MPSCanonizationCheck];
Options[MPSCanonizationCheck]={Site->1};
SetAttributes[MPSCanonizationCheck,HoldAll];
MPSCanonizationCheck[mps_,OptionsPattern[]]:=Module[{checksite=OptionValue[Site],numTensors,spin,norm},
numTensors=Length[mps];
spin=Length[mps[[1]]];
norm=Sum[
Total[
Abs[
Sum[mps[[site,s]].ConjugateTranspose[mps[[site,s]]],{s,1,spin}]-IdentityMatrix[Length[mps[[site,1]]
]
]
],Infinity]
,{site,numTensors,checksite+1,-1}];
norm+=Sum[
Total[
Abs[
Sum[ConjugateTranspose[mps[[site,s]]].mps[[site,s]],{s,1,spin}]-IdentityMatrix[Length[mps[[site,1,1]]
]
]
],Infinity]
,{site,1,checksite-1}];
Chop[norm]==0
];


MPSSiteOperator[tensor_,operator_]:=Module[{},
Flatten[Transpose[tensor,{3,1,2}].operator.Conjugate[tensor],{{3,1},{2,4}}]
];


MPSExpectation[mps_,operator_,site_Integer]:=Module[{L,R,numTensors},
numTensors=Length[mps];
R[numTensors+1]={{1}};
R[n_]:=R[n]=RProduct[mps[[n]],mps[[n]],R[n+1]];
L[0]={{1}};
L[n_]:=L[n]=LProduct[mps[[n]],mps[[n]],L[n-1]];
Chop[
Flatten[L[site-1]].MPSSiteOperator[mps[[site]],operator].Flatten[ R[site+1]]
]
];


MPSExpectation[mps_,operator_,site1_Integer,site2_Integer]:=Module[{L,R,numTensors},
MPSExpectation[mps,operator,site1,operator,site2]
];



MPSExpectation[mps_,operator1_,site1_Integer,operator2_,site2_Integer]:=Module[{L,R,numTensors},
Last[MPSCorrelation[mps,operator1,site1,operator2,site2]]
];


MPSCorrelation[mps_,operator1_,site1_Integer,operator2_,site2_Integer]:=Module[{L,R,Lo,numTensors,siteL,siteR,opL,opR,NormalOrder,corr},
numTensors=Length[mps];
Which[
0<site1<site2<numTensors+1,
{siteL,siteR}={site1,site2};
{opL,opR}={operator1,operator2};
NormalOrder=True;
,0<site2<site1<numTensors+1,
{siteL,siteR}={site2,site1};
{opL,opR}={operator2,operator1};
NormalOrder=False;
,True,
Print["MPSCorrelation called with wrong sites"];Abort[];
];
R[numTensors+1]={{1}};
R[n_]:=R[n]=RProduct[mps[[n]],mps[[n]],R[n+1]];
L[0]={{1}};
L[n_]:=L[n]=LProduct[mps[[n]],mps[[n]],L[n-1]];
Lo[siteL]=LProduct[opL.mps[[siteL]],mps[[siteL]],L[siteL-1]];
Lo[n_]:=Lo[n]=LProduct[mps[[n]],mps[[n]],Lo[n-1]];
corr=Table[
Chop[Flatten[Lo[site-1]].MPSSiteOperator[mps[[site]],opR].Flatten[ R[site+1]]]
,{site,siteL+1,siteR}];
If[NormalOrder,corr,Reverse[corr]]
];


SetAttributes[MPSApproximate,HoldAll];
Options[MPSApproximate]={UseRandomState->True,Ansatz->{},Tolerance->DefaultApproximationTolerance,Sweeps->DefaultSweeps,Verbose->False};
MPSApproximate[mps_,new\[Chi]_,OptionsPattern[]]:=Module[{sweeps=OptionValue[Sweeps],sweep=0,tol=OptionValue[Tolerance],L,R,numTensors,defineRight,defineLeft,\[Chi]R,\[Chi]L,new,canon,stillconverging=True,verbose=OptionValue[Verbose],message,info,success,newmps,overlapBIG,overlap,prevoverlap},
If[verbose,message=PrintTemporary["Preparing matrices"]];
(*Preparation assignments*)
(*MPSNormalize[mps];*)
numTensors=Length[mps];
overlapBIG=MPSOverlap[mps,mps];
newmps=MPSProductState[numTensors,Bond->new\[Chi]];
MPSCanonize[newmps];
prevoverlap=1+overlapBIG-2 Re[MPSOverlap[newmps,mps]];
(* These will be used to define left and right matrices *)
defineRight[temp_]:=Module[{fer},
ClearAll[R];
R[numTensors+1]={{1}};
R[n_]:=R[n]=RProduct[mps[[n]],newmps[[n]],R[n+1]];
];
defineLeft[temp_]:=Module[{fer},
ClearAll[L];
L[0]={{1}};
L[n_]:=L[n]=LProduct[mps[[n]],newmps[[n]],L[n-1]];
];
(* Start from the left, so prepare all right matrices *)
defineRight[1];
While[sweep<sweeps&&stillconverging,
(* Sweep to the right clears all left matrices and defines them one by one *)
defineLeft[1];
canon={{1.}};
Do[
If[verbose,NotebookDelete[message];message=PrintTemporary["Right sweep:"<>ToString[sweep]<>", site:"<>ToString[site]<>", overlap:"<>ToString[1+overlapBIG-2 Re[MPSOverlap[newmps,mps]]]];Pause[1]];
success=False;
newmps[[site]]=canon.#&/@newmps[[site]];
new=L[site-1].#.R[site+1]&/@mps[[site]];
newmps[[site]]=MPSCanonizeSite[new,canon,Direction->"Left",UseMatrix->False]; (* This routine changes canon *)
,{site,1,numTensors}];
sweep+=0.5;
(* Sweep to the left clears all right matrices and defines them one by one *)
defineRight[1];
canon={{1.}};
Do[
If[verbose,NotebookDelete[message];message=PrintTemporary["Left sweep:"<>ToString[sweep]<>", site:"<>ToString[site]<>", overlap:"<>ToString[1+overlapBIG-2 Re[MPSOverlap[newmps,mps]]]];Pause[1]];
success=False;
newmps[[site]]=newmps[[site]].canon;
new=L[site-1].#.R[site+1]&/@mps[[site]];
newmps[[site]]=MPSCanonizeSite[new,canon,UseMatrix->False];
,{site,numTensors,1,-1}];
sweep+=0.5;
overlap=1+overlapBIG-2 Re[MPSOverlap[newmps,mps]];
If[Abs[(overlap-prevoverlap)/overlap]<tol,stillconverging=False,prevoverlap=overlap];
];
If[verbose,NotebookDelete[message]];
newmps
];


ClearAll[MPSSave];
SetAttributes[MPSSave,HoldFirst];
MPSSave[MPS_,filename_]:=Module[{numSites,spin},
numSites=Length[MPS];
spin=Length[MPS[[1]]];
Export[filename<>".info",{numSites,spin},"Table"];
Do[
Do[
Export[filename<>"."<>ToString[n]<>"."<>ToString[s]<>".dat",MPS[[n,s]],"Table"]
,{s,1,spin}];
,{n,1,numSites}];
Run["tar -czf "<>filename<>".MPSz "<>filename<>".*.dat "<>filename<>".info"];
Run["rm "<>filename<>"*.dat "<>filename<>".info"]
];


ClearAll[MPSRead];
MPSRead[filename_]:=Module[{MPS,numSites,spin,\[Chi],info},
If[Length[FileNames[filename<>".MPSz"]]=!=1,Return[]];
Run["tar -zxf "<>filename<>".MPSz"];
If[Length[FileNames[filename<>".info"]]=!=1,Return[]];
info=Flatten[Import[filename<>".info","Table"]];
{numSites,spin}=info;
MPS={};
Do[
MPS=Append[MPS,SparseArray[Table[
If[Length[FileNames[filename<>"."<>ToString[n]<>"."<>ToString[s]<>".dat"]]=!=1,Print["Missing File "<>filename<>"."<>ToString[n]<>"."<>ToString[s]<>".dat"];Break[]];
ToExpression[
Import[filename<>"."<>ToString[n]<>"."<>ToString[s]<>".dat","Table"]
]
,{s,1,spin}]]];
,{n,1,numSites}];
Run["rm "<>filename<>"*.dat "<>filename<>".info"];
MPS
];


ClearAll[MPSMinimizeEnergy];
Options[MPSMinimizeEnergy]={Sweeps->DefaultSweeps,InteractionRange->DefaultInteractionRange,Tolerance->DefaultEnergyTolerance,MonitorEnergy->True,Verbose->False};
SetAttributes[MPSMinimizeEnergy,HoldFirst];
MPSMinimizeEnergy[mps_,HMatrix_,OptionsPattern[]]:=
Module[{energy,prevEnergy=0,energyList={},sweeps=OptionValue[Sweeps],sweep=0,IntRange=OptionValue[InteractionRange],monitorenergy=OptionValue[MonitorEnergy],tol=OptionValue[Tolerance],L,R,fieldL,fieldR,operatorsR,operatorsL,interactionsL,interactionsR,Heff,numTensors,defineRight,defineLeft,\[Chi]R,\[Chi]L,new,canon,stillconverging=True,verbose=OptionValue[Verbose],message,info,success},
If[verbose,message=PrintTemporary["Preparing matrices"]];
(*Preparation assignments*)
(*MPSNormalize[mps];*)
MPSCanonize[mps];
numTensors=Length[mps];
(* These will be used to define left and right matrices *)
defineRight[temp_]:=Module[{fer},
ClearAll[R,fieldR,operatorsR,interactionsR];
R[numTensors+1]={{1}};
R[n_]:=R[n]=RProduct[mps[[n]],mps[[n]],R[n+1]];
fieldR[numTensors+1]=Table[{{0}},{\[Alpha],1,3}];
fieldR[n_]:=fieldR[n]=Table[
RProduct[mps[[n]],mps[[n]],fieldR[n+1][[\[Alpha]]]]+HMatrix[[\[Alpha],n,n]]RProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],R[n+1]],{\[Alpha],1,3}];
operatorsR[numTensors+2]=Table[{},{\[Alpha],1,3}];
operatorsR[numTensors+1]=Table[{},{\[Alpha],1,3}];
operatorsR[n_]:=operatorsR[n]=Table[
Prepend[RProduct[mps[[n]],mps[[n]],#]&/@(Take[operatorsR[n+1][[\[Alpha]]],Min[IntRange-1,Length[operatorsR[n+1][[\[Alpha]]]]]]),RProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],R[n+1]]],{\[Alpha],1,3}];
interactionsR[numTensors+1]=Table[{{0}},{\[Alpha],1,3}];
interactionsR[n_]:=interactionsR[n]=Table[
RProduct[mps[[n]],mps[[n]],interactionsR[n+1][[\[Alpha]]]]+(HMatrix[[\[Alpha],n,n+1;;Min[n+IntRange,numTensors]]].(RProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],#]&/@operatorsR[n+1][[\[Alpha]]])),{\[Alpha],1,3}];
];
defineLeft[temp_]:=Module[{fer},
ClearAll[L,fieldL,operatorsL,interactionsL];
L[0]={{1}};
L[n_]:=L[n]=LProduct[mps[[n]],mps[[n]],L[n-1]];
fieldL[0]=Table[{{0}},{\[Alpha],1,3}];
fieldL[n_]:=fieldL[n]=Table[LProduct[mps[[n]],mps[[n]],fieldL[n-1][[\[Alpha]]]]+HMatrix[[\[Alpha],n,n]]LProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],L[n-1]],{\[Alpha],1,3}];
operatorsL[-1]=Table[{},{\[Alpha],1,3}];
operatorsL[0]=Table[{},{\[Alpha],1,3}];
operatorsL[n_]:=operatorsL[n]=Table[
Prepend[LProduct[mps[[n]],mps[[n]],#]&/@Take[operatorsL[n-1][[\[Alpha]]],Min[IntRange-1,Length[operatorsL[n-1][[\[Alpha]]]]]],LProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],L[n-1]]],{\[Alpha],1,3}];
interactionsL[0]=Table[{{0}},{\[Alpha],1,3}];
interactionsL[n_]:=interactionsL[n]=Table[LProduct[mps[[n]],mps[[n]],interactionsL[n-1][[\[Alpha]]]]+(Reverse[HMatrix[[\[Alpha],Max[n-IntRange,1];;n-1,n]]].(LProduct[sigma[\[Alpha]].mps[[n]],mps[[n]],#]&/@operatorsL[n-1][[\[Alpha]]])),{\[Alpha],1,3}];
];
(* Start from the left, so prepare all right matrices *)
defineRight[1];
While[sweep<sweeps&&stillconverging,
(* Sweep to the right clears all left matrices and defines them one by one *)
defineLeft[1];
canon={{1.}};
Do[
If[verbose,NotebookDelete[message];message=PrintTemporary["Right sweep:"<>ToString[sweep]<>", site:"<>ToString[site]<>", Energy:"<>ToString[energy]]];
success=False;
While[!success,
{energy,new,info}=FindGroundMPSSite[canon.#&/@mps[[site]],interactionsL[site-1],interactionsR[site+1],fieldL[site-1],fieldR[site+1],operatorsL[site-1],operatorsR[site+1],HMatrix[[All,Max[1,site-IntRange];;site,Max[1,site-IntRange];;Min[numTensors,site+IntRange]]]];
success=(IsLinkActive[]===1);
If[!success,Print["Fallen link..."];ClearLink[link];EstablishLink[link];Print["And we're back."]];
];
mps[[site]]=MPSCanonizeSite[new,canon,Direction->"Left",UseMatrix->False]; (* This routine changes canon *)
If[monitorenergy,energyList=energyList~Join~{{energy/(Conjugate[Flatten[new]].Flatten[new]),info}}];
,{site,1,numTensors}];
sweep+=0.5;
(* Sweep to the left clears all right matrices and defines them one by one *)
defineRight[1];
canon={{1.}};
Do[
If[verbose,NotebookDelete[message];message=PrintTemporary["Left sweep:"<>ToString[sweep]<>", site:"<>ToString[site]<>", Energy:"<>ToString[energy]]];
success=False;
While[!success,
{energy,new,info}=FindGroundMPSSite[mps[[site]].canon,interactionsL[site-1],interactionsR[site+1],fieldL[site-1],fieldR[site+1],operatorsL[site-1],operatorsR[site+1],HMatrix[[All,Max[1,site-IntRange];;site,Max[1,site-IntRange];;Min[numTensors,site+IntRange]]]];
success=(IsLinkActive[]===1);
If[!success,Print["Fallen link..."];ClearLink[link];EstablishLink[link];Print["And we're back."]];
];
mps[[site]]=MPSCanonizeSite[new,canon,UseMatrix->False];
If[monitorenergy,energyList=energyList~Join~{{energy/(Conjugate[Flatten[new]].Flatten[new]),info}}];
,{site,numTensors,1,-1}];
sweep+=0.5;
If[Abs[(energy-prevEnergy)/energy]<tol,stillconverging=False,prevEnergy=energy];
];
If[verbose,NotebookDelete[message]];
If[Total[Abs[#[[2]]]&/@energyList]>0,
Print["Arpack error reported:"];
Print[Cases[#[[2]]&/@energyList,Except[0]]]
];
ClearAll[energy,prevEnergy,sweeps,sweep,IntRange,monitorenergy,tol,L,R,fieldL,fieldR,operatorsR,operatorsL,interactionsL,interactionsR,Heff,numTensors,defineRight,defineLeft,\[Chi]R,\[Chi]L,new,canon,stillconverging,verbose,message,info,success];
#[[1]]&/@energyList
];


(* Define internal versions *)
ClearAll[MPSEffectiveSingleHam];
SetAttributes[MPSEffectiveSingleHam,HoldAll];
MPSEffectiveSingleHam[L_,R_,op_]:=(*KroneckerProduct[op,SparseArray[Flatten[Transpose[{L},{3,1,2}].{R},{{4,1},{3,2}}]] *)
KroneckerProduct[op,L,Transpose[R]];


ClearAll[MPSEffectiveHam];
SetAttributes[MPSEffectiveHam,HoldAll];
MPSEffectiveHam[interactionsL_,interactionsR_,fieldL_,fieldR_,operatorsL_,operatorsR_,Hmatrix_]:=Module[{Htemp=0,\[Chi]L,\[Chi]R,intrangeL,intrangeR,L,R},
(* Preparation of internal matrices and constants *)
intrangeL=Length[operatorsL[[1]]];
intrangeR=Length[operatorsR[[1]]];
\[Chi]L=Length[fieldL[[1]]];
\[Chi]R=Length[fieldR[[1]]];
L=SparseArray[IdentityMatrix[\[Chi]L]];
R=SparseArray[IdentityMatrix[\[Chi]R]];
(* First compute the contribution from the fields h *)
Htemp= Sum[MPSEffectiveSingleHam[L,fieldR[[\[Alpha]]],sigma[0]],{\[Alpha],1,3}];
Htemp+=Sum[MPSEffectiveSingleHam[fieldL[[\[Alpha]]],R,sigma[0]],{\[Alpha],1,3}];
(* Now compute the contribution from the interactions contained in the right and left blocks *)
Htemp+=Sum[MPSEffectiveSingleHam[interactionsL[[\[Alpha]]],R,sigma[0]],{\[Alpha],1,3}];
Htemp+= Sum[MPSEffectiveSingleHam[L,interactionsR[[\[Alpha]]],sigma[0]],{\[Alpha],1,3}];
(* Now compute the interactions between the left and right blocks that do not involve the spin at the site *)
Htemp+=Sum[Sum[Sum[MPSEffectiveSingleHam[operatorsL[[\[Alpha],x]],operatorsR[[\[Alpha],y]],If[(x+y-1)<Max[intrangeL,intrangeR],Hmatrix[[\[Alpha],intrangeL+1-x,intrangeL+1+y]],0]sigma[0]],{\[Alpha],1,3}],{y,1,intrangeR}],{x,1,intrangeL}]; 
(* Now add the term with the field at the site *)
Htemp+= Sum[MPSEffectiveSingleHam[L,R,Hmatrix[[\[Alpha],intrangeL+1,intrangeL+1]]sigma[\[Alpha]] ],{\[Alpha],1,3}];
(* Finally, the interactions between the site and the left and right blocks *) Htemp+=Sum[Sum[MPSEffectiveSingleHam[operatorsL[[\[Alpha],x]]Hmatrix[[\[Alpha],intrangeL+1-x,intrangeL+1]],R,sigma[\[Alpha]]],{\[Alpha],1,3}],{x,1,intrangeL}]; 
Htemp+=Sum[Sum[MPSEffectiveSingleHam[L,operatorsR[[\[Alpha],x]],Hmatrix[[\[Alpha],intrangeL+1,intrangeL+1+x]]sigma[\[Alpha]]],{\[Alpha],1,3}],{x,1,intrangeR}]; 
Return[Htemp]
];


ClearAll[FindGroundMPSSiteManual];
SetAttributes[FindGroundMPSSiteManual,HoldAll];
FindGroundMPSSiteManual[A_,DLeft_,DRight_,hLeft_,hRight_,vLeft_,vRight_,Ham_]:=Module[{H,sol,\[Chi]L,\[Chi]R,spin},
(* Print["Link could not be established, reverting to internal routines..."];*)
H=MPSEffectiveHam[DLeft,DRight,hLeft,hRight,vLeft,vRight,Ham];
sol=Eigensystem[-H,1,Method->{"Arnoldi",MaxIterations->10^5,Criteria->RealPart}];
{spin,\[Chi]L,\[Chi]R}=Dimensions[A];
{Chop[-sol[[1,1]]],Chop[-Partition[Partition[sol[[2,1]],\[Chi]R],\[Chi]L]],0}
];


(*This clears a link and associated variables*)
ClearLink[LINK_]:=Module[{},
Uninstall[LINK];
ClearAll[FindGroundMPSSite,IsLinkActive];
ForceUseInternalRoutine=True;
];


(* Now try to establish the link *)
EstablishLink[LINK_]:=(
ClearLink[LINK];
ClearAll[FindGroundMPSSite,IsLinkActive];
If[Length[Links["*arpackformps"]]==0,LINK=Install["arpackformps_"<>$SystemID]];
If[LINK===$Failed||ForceUseInternalRoutine,
SetAttributes[FindGroundMPSSite,HoldAll];
FindGroundMPSSite[A_,DLeft_,DRight_,hLeft_,hRight_,vLeft_,vRight_,Ham_]:=FindGroundMPSSiteManual[A,DLeft,DRight,hLeft,hRight,vLeft,vRight,Ham]
]
);


EstablishLink[link];



