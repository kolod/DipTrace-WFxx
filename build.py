#!/us/bin/python3

import os
import re
import subprocess

PinsTypeName = ['Stright', 'Right_Angle', 'SMD']



def set_env():
    openscad_path      = 'C:\\Program Files\\OpenSCAD'
    meshlabserver_path = 'C:\\Program Files\\VCG\\MeshLab'
    os.environ['PATH'] = meshlabserver_path + os.pathsep + openscad_path + os.pathsep + os.environ['PATH']


def change_material(filepath, material):
    model = ''
    with open(filepath, 'r+') as wrl_file:
        model = wrl_file.read()
        model = re.sub(r'(material Material[\s]*{)[^}]*', material, model)
        wrl_file.seek(0)
        wrl_file.truncate(0)
        wrl_file.write(model)


def get_geometry(filename):
    with open(filename, 'r') as wrl_file:
        model = wrl_file.read()
        geometry = re.search(r'(geometry[^;]*?)appearance', model).group(1) + ' }'
        geometry = re.sub(r'\s(.*){', r' {', geometry)
        geometry = re.sub(r'\s(.*)\[', r' [', geometry)
        geometry = re.sub(r'[^ ] {12}([^ ])', '\n                    \\1', geometry)
        geometry = re.sub(r'[^ ] {10}([^ ])', '\n                \\1', geometry)
        geometry = re.sub(r'[^ ] {8}([^ ])' , '\n            \\1', geometry)
        geometry = re.sub(r'[^ ] {6}([^ ])' , '\n        \\1', geometry)
        geometry = re.sub(r'[^ ] {7}([^ ])' , '\n    \\1', geometry)
        return geometry


def build_model(housing, pins):
    header = "#VRML V2.0 utf8\n\nchildren ["
    footer = "\n]\n"
    pins_material = '''
    Shape {
        appearance Appearance {
            material Material {
                diffuseColor 0.72 0.72 0.72
                emissiveColor 0.0 0.0 0.0
                specularColor 1.0 1.0 1.0
                ambientIntensity 1.0
                transparency 0.0
                shininess 1.0
            }
        }
        '''
    housing_material = '''
    Shape {
        appearance Appearance {
            material Material {  
                diffuseColor 1.0 1.0 1.0
                emissiveColor 0.0 0.0 0.0
                specularColor 1.0 1.0 1.0
                ambientIntensity 1.0
                transparency 0.0
                shininess 1.0
            }
        }
        '''
    return header + housing_material + housing + pins_material + pins + footer


def build_stl():

    print('Make STL')

    if not os.path.exists('stl'):
        os.makedirs('stl')

    for PinsNumber in range(2,21):

        # Housing
        print('Build WF-{0:02}_Housing.stl'.format(PinsNumber))
        command = 'openscad -D Pins_Number={0} -D Pins_Type=1 -D Pins_Enable=0 -D Housing_Enable=1 -o stl/WF-{0:02}_Housing.stl WFxx.scad'.format(PinsNumber)
        subprocess.call(command)

        print('Build WF-{0:02}_Housing_Right_Angle.stl'.format(PinsNumber))
        command = 'openscad -D Pins_Number={0} -D Pins_Type=2 -D Pins_Enable=0 -D Housing_Enable=1 -o stl/WF-{0:02}_Housing_Right_Angle.stl WFxx.scad'.format(PinsNumber)
        subprocess.call(command)

        # Pins
        for PinsType in range(1,4):
            print('Build WF-{0:02}_Pins_{1}.stl'.format(PinsNumber, PinsTypeName[PinsType-1]))
            command = 'openscad -D Pins_Number={0} -D Pins_Type={1} -D Pins_Enable=1 -D Housing_Enable=0 -o stl/WF-{0:02}_Pins_{2}.stl WFxx.scad'.format(PinsNumber, PinsType, PinsTypeName[PinsType-1])
            subprocess.call(command)


def build_wrl():

    print('Convert to VRML')

    if not os.path.exists('wrl'):
        os.makedirs('wrl')

    for PinsNumber in range(2,21):

        # Convert housing to VRML
        print('Build WF-{0:02}_Housing.wrl'.format(PinsNumber))
        command = 'meshlabserver -i stl/WF-{0:02}_Housing.stl -o wrl/WF-{0:02}_Housing.wrl'.format(PinsNumber)
        subprocess.call(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

        print('Build WF-{0:02}_Housing_Right_Angle.wrl'.format(PinsNumber))
        command = 'meshlabserver -i stl/WF-{0:02}_Housing_Right_Angle.stl -o wrl/WF-{0:02}_Housing_Right_Angle.wrl'.format(PinsNumber)
        subprocess.call(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

        # Convert pins to VRML
        for PinsType in range(1,4):
            print('Build WF-{0:02}_Pins_{1}.wrl'.format(PinsNumber, PinsTypeName[PinsType-1]))
            command = 'meshlabserver -i stl//WF-{0:02}_Pins_{1}.stl -o wrl/WF-{0:02}_Pins_{1}.wrl'.format(PinsNumber, PinsTypeName[PinsType-1])
            subprocess.call(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)


def build():
    build_stl()
    build_wrl()

    if not os.path.exists('out'):
        os.makedirs('out')

    print('-----')

    for PinsNumber in range(2,21):
        for PinsType in range(1,4):

            print('Build WF-{0:02}_{1}.wrl'.format(PinsNumber, PinsTypeName[PinsType-1]))

            housing = ''
            if PinsType == 2:
                housing = get_geometry('wrl/WF-{0:02}_Housing_Right_Angle.wrl'.format(PinsNumber))
            else:
                housing = get_geometry('wrl/WF-{0:02}_Housing.wrl'.format(PinsNumber))

            pins = get_geometry('wrl/WF-{0:02}_Pins_{1}.wrl'.format(PinsNumber, PinsTypeName[PinsType-1]))

            with open('out/WF-{0:02}_{1}.wrl'.format(PinsNumber, PinsTypeName[PinsType-1]), 'w') as wrl_file:
                wrl_file.write(build_model(housing, pins))

    
if __name__ == '__main__':
    set_env()
    build()