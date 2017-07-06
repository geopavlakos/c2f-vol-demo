# Download H36M-Sample images
mkdir -p data/h36m-sample/images
cd data/h36m-sample/images
wget http://visiondata.cis.upenn.edu/volumetric/h36m/Sample.tar
tar -xf Sample.tar
rm Sample.tar
cd ../../..

# Download model
wget http://visiondata.cis.upenn.edu/volumetric/models/c2f-volumetric-h36m.t7
