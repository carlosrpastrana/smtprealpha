import 'package:tucu_free_tacc/models/articulo.dart';

final List<Articulo> listaArticulos = [
  const Articulo(
    id: 1,
    titulo: '¿Qué es la contaminación cruzada y cómo evitarla?',
    resumen:
        'Descubre los peligros ocultos en la cocina diaria y aprende cómo evitar que el gluten contamine tus alimentos...',
    contenido:
        'Para una persona con celiaquía, ingerir incluso la cantidad más microscópica de gluten activa una respuesta autoinmune que atrofia las vellosidades del intestino delgado.\n\n'
        'La contaminación cruzada ocurre cuando un producto apto entra en contacto con partículas de gluten. Esto puede suceder durante la manipulación, en la vajilla compartida o por el simple contacto con migas en superficies no desinfectadas.\n\n'
        'La clave para una cocina segura es el orden, la delimitación estricta de utensilios exclusivos y la concientización del entorno familiar.',
    categoria: 'Salud',
    tipo: 'educacion',
    autor: 'Dra. Elena Martínez',
    fecha: '15 de Mayo, 2026',
    tiempoLectura: '6 min',
    imagenUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=50',
    subtituloSeccion: 'Puntos críticos en el hogar',
    puntosClave: [
      'Tostadoras y hornos compartidos sin bolsas térmicas protectoras.',
      'Tablas de madera y esponjas de cocina compartidas.',
      'Frascos de mermelada o manteca donde se introducen cubiertos con migas.',
      'Aceites de fritura utilizados previamente con harinas.',
    ],
  ),
  const Articulo(
    id: 2,
    titulo: 'Tarjeta Social para Celíacos: cronograma de acreditación',
    resumen:
        'Fechas estimadas de depósito para los beneficiarios del subsidio alimentario y requisitos para mantener el padrón activo.',
    contenido:
        'El Ministerio de Desarrollo Social confirmó que entre los primeros 5 días hábiles del mes se completa la acreditación de fondos destinados al programa de asistencia celíaca.\n\n'
        'El monto está destinado exclusivamente a la compra de alimentos secos, premezclas y harinas certificadas con el logo oficial Sin T.A.C.C. en comercios y supermercados adheridos.\n\n'
        'Recordá conservar los comprobantes de compra y mantener actualizado tu certificado médico y biopsia en el padrón provincial para evitar suspensiones temporales.',
    categoria: 'Trámite Social',
    tipo: 'noticia',
    autor: 'Equipo SMT Libre de Gluten',
    fecha: '1 de Septiembre, 2026',
    tiempoLectura: '3 min',
    imagenUrl:
        'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=50',
    subtituloSeccion: 'Requisitos para solicitar el beneficio',
    puntosClave: [
      'Constancia médica con diagnóstico por biopsia intestinal o serología oficial.',
      'Certificación negativa de ANSES para verificar cobertura asistencial.',
      'DNI con domicilio actualizado en la provincia.',
      'Presentación del trámite en la Dirección de Políticas Alimentarias.',
    ],
  ),
  const Articulo(
    id: 3,
    titulo: '5 de Mayo: Expo Gastronómica por el Día del Celíaco',
    resumen:
        'Se llevará a cabo una feria comunitaria con stands de productores regionales, charlas de nutrición y cocina en vivo.',
    contenido:
        'En conmemoración del Día Internacional de la Celiaquía, se realizará un encuentro multitudinario con más de 30 emprendimientos, distribuidores y restaurantes con certificación libre de gluten.\n\n'
        'Habrá degustaciones gratuitas, talleres de elaboración de masa madre sin TACC y un panel con gastroenterólogos para responder dudas sobre diagnóstico temprano y celiaquía refractaria.\n\n'
        'La entrada es libre y gratuita para toda la familia.',
    categoria: 'Evento',
    tipo: 'noticia',
    autor: 'Comunidad Celíaca Tucumán',
    fecha: '28 de Abril, 2026',
    tiempoLectura: '4 min',
    imagenUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=50',
    subtituloSeccion: 'Actividades confirmadas',
    puntosClave: [
      'Feria de panificados y pastas frescas 100% libres de gluten.',
      'Cocina magistral en vivo con chefs especialistas en pastelería apta.',
      'Espacio de consulta diagnóstica con médicos especialistas.',
      'Punto de asesoramiento para trámites de cobertura en obras sociales.',
    ],
  ),
  const Articulo(
    id: 4,
    titulo: 'Cómo leer etiquetas de alimentos y reconocer el logo oficial',
    resumen:
        'Guía práctica para identificar ingredientes ocultos, rotulados engañosos y verificar el listado oficial de ANMAT.',
    contenido:
        'No todos los productos que dicen "natural" o "a base de arroz" son seguros. La única garantía real en Argentina es la presencia del logo oficial "Sin T.A.C.C." acompañado por el número de registro nacional (RNPA y RNE).\n\n'
        'Muchos aditivos, espesantes y aromatizantes industriales pueden provenir del trigo o la cebada sin mencionarlo explícitamente en el frente del envase.\n\n'
        'Antes de comprar una marca desconocida, se aconseja consultar el listado integrado de alimentos libres de gluten en la web oficial.',
    categoria: 'Guía Básica',
    tipo: 'educacion',
    autor: 'Lic. Sofía Carrizo',
    fecha: '12 de Agosto, 2026',
    tiempoLectura: '5 min',
    imagenUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=50',
    subtituloSeccion: 'Ingredientes bajo alerta',
    puntosClave: [
      'Almidón modificado sin especificar su origen vegetal.',
      'Malta, extracto de malta o jarabe de malta (derivados de cebada).',
      'Proteína vegetal hidrolizada (suele contener derivados de trigo).',
      'Especias molidas sueltas que pueden contener harina como antiaglomerante.',
    ],
  ),
];
