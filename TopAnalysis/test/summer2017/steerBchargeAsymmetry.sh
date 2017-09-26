#!/bin/bash

WHAT=$1; 
if [ "$#" -ne 1 ]; then 
    echo "steerBchargeAsymmetry.sh <SEL/MERGE/PLOT/WWW>";
    echo "        TESTSEL      - tests the selection locally with a single file";
    echo "        SEL          - launches selection jobs to the batch, output will contain summary trees and control plots"; 
    echo "        MERGE        - merge output"
    echo "        PLOT         - make plots"
    echo "        WWW          - move plots to web-based are"
    exit 1; 
fi
githash=096794a
lumi=35922
lumiUnc=0.025
whoami=`whoami`
myletter=${whoami:0:1}
eosdir=/store/cmst3/group/top/ReReco2016/${githash}
outdir=${CMSSW_BASE}/src/TopLJets2015/TopAnalysis/test/summer2017/BchargeAsymmetry
wwwdir=~/www/BchargeAsymmetry
eoswwwdir=/eos/user/$myletter/$whoami/www/
if [ -d $eoswwwdir ]; then
    wwwdir=$eoswwwdir/BchargeAsymmetry
fi

RED='\e[31m'
NC='\e[0m'
case $WHAT in
    
    TESTSEL )
	python scripts/runLocalAnalysis.py -i root://eoscms//eos/cms/${eosdir}/MC13TeV_TTJets/MergedMiniEvents_0_ext0.root \
            --only test/summer2017/mttbar_samples.json --exactonly \
            -q local \
            -o ${outdir}/Chunks/MC13TeV_TTJets_0.root \
            --era era2016 -m BjetChargeTreeProducer::RunBjetChargeTreeProducer --ch 0 --runSysts;
        ;;

    SEL )
        #to run locally use "--njobs 8 -q local"
        #to run on the batck use "-q workday"
	python scripts/runLocalAnalysis.py -i ${eosdir} \
            --only test/summer2017/mttbar_samples.json --exactonly \
            -q workday \
            -o ${outdir} \
            --era era2016 -m BjetChargeTreeProducer::RunBjetChargeTreeProducer --ch 0 --runSysts;
	;;
    SELSYST )
        #to run locally use "--njobs 8 -q local"
        #to run on the batck use "-q workday"
	python scripts/runLocalAnalysis.py -i ${eosdir} \
            --only test/summer2017/ttbar_systs.json --exactonly \
            -q workday \
            -o ${outdir} \
            --era era2016 -m BjetChargeTreeProducer::RunBjetChargeTreeProducer --ch 0 --runSysts;
	;;

    MERGE )
	./scripts/mergeOutputs.py ${outdir};
	;;
    PLOT )
	commonOpts="-i ${outdir} --puNormSF puwgtctr -j test/summer2017/mttbar_samples.json -l ${lumi}  --saveLog --mcUnc ${lumiUnc} --noStack"
	python scripts/plotter.py ${commonOpts}; 
	;;
    WWW )
	mkdir -p ${wwwdir}/sel
	cp ${outdir}/plots/*.{png,pdf} ${wwwdir}/sel
	cp test/index.php ${wwwdir}/sel
	;;
esac
