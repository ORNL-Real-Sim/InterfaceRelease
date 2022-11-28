'''

script to grab .exe and .dll files to RealSimRelease folder
run script within the RealSimRelease folder

'''

import os
import shutil

RealSimSourcePath = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), r'..\..\RealSimInterface'))

shutil.copy(os.path.join(RealSimSourcePath, r'TrafficLayer\x64\Release\TrafficLayer.exe'), 'TrafficLayer.exe')
shutil.copy(os.path.join(RealSimSourcePath, r'ControlLayer\x64\Release\CoordMerge.exe'), 'CoordMerge.exe')
# shutil.copy(os.path.join(RealSimSourcePath, r'ControlLayer\x64\Release\SpeedHarm.exe'), 'SpeedHarm.exe')
shutil.copy(os.path.join(RealSimSourcePath, r'VISSIMserver\x64\Release\DriverModel_RealSim.dll'), 'DriverModel_RealSim.dll')
shutil.copy(os.path.join(RealSimSourcePath, r'VISSIMserver\x64\Release\DriverModel_RealSim_v2021.dll'), 'DriverModel_RealSim_v2021.dll')

shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimPack.m'), 'RealSimPack.m')
shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimDepack.m'), 'RealSimDepack.m')
shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimMsgClass.m'), 'RealSimMsgClass.m')
shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimInterpSpeed.m'), 'RealSimInterpSpeed.m')
shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimSocket.mexw64'), 'RealSimSocket.mexw64')
shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\RealSimInitSimulink.m'), 'RealSimInitSimulink.m')

# shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\main_autoRealSim.m'), 'main_autoRealSim.m')
# shutil.copy(os.path.join(RealSimSourcePath, r'CommonLib\startVissim.m'), 'startVissim.m')

if not os.path.isdir('YAMLMatlab_0.4.3'):
    shutil.copytree(os.path.join(RealSimSourcePath, r'CommonLib\YAMLMatlab_0.4.3'), 'YAMLMatlab_0.4.3')

shutil.copy(os.path.join(RealSimSourcePath, r'VISSIMserver\setVissimStaticRouteExemption.py'), 'setVissimStaticRouteExemption.py')
shutil.copy(os.path.join(RealSimSourcePath, r'VISSIMserver\getVissimNetworkInfo.py'), 'getVissimNetworkInfo.py')


