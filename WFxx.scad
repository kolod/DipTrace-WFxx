
//	ПРОГРАММА ОТРИСОВКИ РАЗЪЕМОВ ТИПА WF-xx

//	Сначала нужно экспортировать ПО-ОТДЕЛЬНОСТИ корпус разъема и контакты в формат .STL (не забываем рендерить изображение перед каждым экспортом). Что именно в данный момент будет нарисовано - определяется параметрами Housing_Enable и Pins_Enable. Есть также возможность выбрать тип и количество контактов (см. параметры Pins_Type и Pins_Number).

//	После экспорта открываем STL-файлы в FreeCAD и экспортируем их снова в STL. Это надо для того, чтобы STL-файлы стали хорошими, а то OpenSCAD их делает какими-то кривыми.

//	Далее в Wings3D (обязательно должен быть открыт в окне, а не в полнооконном режиме) формируем разные типы разъемов при помощи комбинирования файлов STL для корпуса и разных типов контактов (File => Import => StereoLithography). Например, для получения SMD-разъема WF-xxS надо импортировать файл корпуса и файл SMD-контактов. Теперь полученный разъем надо раскрасить. В Wings3D сначала открываем список элементов (Window => Outliner) и окно палитры (Window => Palette), затем вверху выбираем полностью красный кубик (самый правый, "Body Selection Mode"). Щелкаем левой кнопкой на корпус разъема (должен полностью выделиться) и назначаем ему цвет из палитры, после чего снова щелкаем на корпусе (выделение должно полностью сняться). Проделываем то же самое с контактами (для обычных незолоченых белых контактов RGB обычно делается равным 0.8/0.8/0.8). Далее выделяем и корпус, и контакты (т.е. все элементы разъема) и, щелкнув на разъеме правой кнопкой мыши, выбираем "Vertex Attribute" => "Color to Materials". Должно активироваться окно со списком элементов (Outliner). В данном окне нам надо отредактировать свойства цвета у корпуса и контактов. Щелкаем правой кнопкой мыши на соответствующий цвет и выбираем "Edit Material". В открывшемся окне сдвигаем на минимум движки у параметров "Ambient", "Specular" и "Emission" (т.е. у всех, кроме верхнего). Параметры "Vertex Color" (Ignore), "Shininess" (1.0) и "Opacity" (1.0) не трогаем. Далее щелкаем "ОК" и переходим к следующему цвету. Цвет материала "default" трогать не надо.

//	В завершении сохраняем полученную модель в формате .WRL (File => Export => VRML 2.0), после чего ее можно использовать в DipTrace. Единственное, на что нужно обратить внимание - при назначении созданной модели какому-либо корпусу в редакторе корпусов диптрэйса в качестве единиц измерения файла надо выбирать "Метры", иначе с масштабом получится беда.



Pins_Number	    = 5;		// количество контактов разъема

Pins_Type		= 3;		// тип контактов:	1 - прямые
							//					2 - угловые
							//					3 - SMD
						
Housing_Enable	= 1;		// необходимость отрисовки корпуса разъема (1 - рисовать, 0 - нет)
Pins_Enable		= 1;		// необходимость отрисовки выводов разъема (1 - рисовать, 0 - нет)


pitch = 2.54;           // расстояние между контактами
hh1   = 1.2;            // высота выемки тела
hh2   = 3.3;            // высота площадки
hh3   = 11.5-hh2;       // высота защелки
pth   = 0.64;           // толщина контактов
phr1  = 1.75;           // длинна вывода до изгиба

RotateVector = [
    [0,0,270],
    [0,270,90],
    [0,0,270]
];

TranslateVector = [
    [0, 0, 0],
    [2.5, 0, 1.75],
    [0, 0, 0]
];
	
 
rotate (RotateVector[Pins_Type-1])
translate(TranslateVector[Pins_Type-1]) 
translate([0, (Pins_Number - 1) * 1.27, 0])
{    
	
    // ФОРМИРОВАНИЕ КОРПУСА РАЗЪЕМА
	if (Housing_Enable	== 1) {
        
        color("White", 1.0) {
            
            // Формирование основания (куда втыкаются штыри)
            
            for (i = [0.00 : -1.00 : -(Pins_Number-1)])	{
            
                translate ([-2.5, -1.27, 0.00])
                rotate ([90, 0, 90]) {
                
                    #linear_extrude (height = 5.80) {
                        polygon ([	
                            [i*pitch + 0.00, 0.0],
                            [i*pitch + 0.50, 0.0],
                            [i*pitch + 0.50, hh1],
                            [i*pitch + 2.04, hh1],
                            [i*pitch + 2.04, 0.0],
                            [i*pitch + 2.54, 0.0],
                            [i*pitch + 2.54, hh2],
                            [i*pitch + 0.00, hh2]]
                        );
                    }
                }
            }	
        
            // Формирование защелки
        
            translate ([-2.5, 0.00, hh2])
            rotate ([90, 0, 0])
        
                linear_extrude (height = (Pins_Number-1)*2.54) {

                    polygon ([	[0.0, 0.0],
                                [0.0, hh3],
                                [0.8, hh3],
                                [0.8, 5.0],
                                [1.4, 4.4],
                                [1.4, 3.7],
                                [0.8, 3.1],
                                [0.8, 0.0]]);
                }
            }
        }
	


						

// ФОРМИРОВАНИЕ КОНТАКТОВ
	
	if (Pins_Enable	== 1)	{
        
        color ("Gold", 1.0) {

            
            for (i = [0.00 : -1.00 : -(Pins_Number-1)])	{
        
                // Формирование контактов, торчащих вверх из основания (т.е. на которые одевается "мама")
                union() {            
                    // Рисование "основной" части штырей	
                    translate ([0.00, i*pitch, hh2])
                        linear_extrude (height = 14.2-3.4-hh2-.5)
                            polygon ([
                                [+pth/2, +pth/2],
                                [+pth/2, -pth/2],
                                [-pth/2, -pth/2],
                                [-pth/2, +pth/2]]);
                    
                    // Рисование пирамидальных макушек штырей
                    translate ([0.00, i*pitch, 14.2-3.4-.5])
                        linear_extrude (height = 0.50, scale = 0.50)
                            polygon ([
                                [+pth/2, +pth/2],
                                [+pth/2, -pth/2],
                                [-pth/2, -pth/2],
                                [-pth/2, +pth/2]]);
                }
            }	
        
            
            // Формирование нижних частей контактов (т.е. которые монтируются на плату)
            
                // Контакты прямого типа
            
                if (Pins_Type == 1)	{
                
                    for (i = [0.00 : -1.00 : -(Pins_Number-1)])	{
                    
                        translate ([0.00, i*2.54, -3.40])
                        rotate ([0, 0, 0])

                        linear_extrude (height = 3.4+hh1)
            
                            polygon ([		[+pth/2, +pth/2],
                                            [+pth/2, -pth/2],
                                            [-pth/2, -pth/2],
                                            [-pth/2, +pth/2]]);
                    }			
                }
            
                
                // Контакты углового типа
                
                if (Pins_Type == 2)	{
                
                    for (i = [0.00 : -1.00: -(Pins_Number-1)])	{
                    
                        translate ([0.00, i*pitch - pth / 2, hh1])
                        rotate ([-90, -90, 0])

                        linear_extrude (height = 0.64)
            
                            polygon ([		[+0.0           , +pth/2],
                                            [+0.0           , -pth/2],
                                            [-phr1-hh1+pth  , -pth/2],
                                            [-phr1-hh1+pth/2, -pth  ],
                                            [-phr1-hh1+pth/2, -5.9  ],
                                            [-phr1-hh1-pth/2, -5.9  ],
                                            [-phr1-hh1-pth/2, -pth/2],
                                            [-phr1-hh1+pth/2, +pth/2]]);
                    }			
                }
                
                // Контакты SMD-типа
                
                if (Pins_Type == 3)	{
                
                    // Формируем контакты с нечетными номерами (1, 3, 5...)				
                    for (i = [0.00 : -2.00 : -(Pins_Number-1)])	{
                    
                        translate ([0.00, i*2.54 - 0.32, hh1])
                        rotate ([-90, -90, 0])
                        linear_extrude (height = pth)
                            polygon ([
                                [+0.00, +pth/2],
                                [+0.00, -pth/2],
                                [-2.04+1.8, -pth/2],
                                [-2.36+1.8, -pth],
                                [-2.36+1.8, -4.25],
                                [-3.00+1.8,	-4.25],
                                [-3.00+1.8, -pth/2],
                                [-2.36+1.8,	+pth/2]]);
                    }
                    
                    // Формируем контакты с четными номерами (2, 4, 6...)	
                    for (i = [-1.00 : -2.00 : -(Pins_Number-1)])	{
                    
                        translate ([0.00, i*2.54 + 0.32, hh1])
                        rotate ([-90, -90, 180])
                        linear_extrude (height = pth)
                            polygon ([
                                [+0.00, +pth/2],
                                [+0.00, -pth/2],
                                [-2.04+1.8, -pth/2],
                                [-2.36+1.8, -pth],
                                [-2.36+1.8, -4.25],
                                [-3.00+1.8,	-4.25],
                                [-3.00+1.8, -pth/2],
                                [-2.36+1.8,	+pth/2]]);
                    }			
                }
        }
    }
}