# Download H36M annotations
cd data
wget http://visiondata.cis.upenn.edu/volumetric/h36m/h36m_annot.tar
tar -xf h36m_annot.tar
rm h36m_annot.tar

# Download H36M images
mkdir -p h36m/images
cd h36m/images
wget http://visiondata.cis.upenn.edu/volumetric/h36m/S9.tar
tar -xf S9.tar
rm S9.tar
wget http://visiondata.cis.upenn.edu/volumetric/h36m/S11.tar
tar -xf S11.tar
rm S11.tar
cd ../../..
